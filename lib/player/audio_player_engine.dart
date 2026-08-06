import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';

class PlayerStateData {
  final TrackEntity? currentTrack;
  final bool isPlaying;
  final int currentPositionSec;
  final int durationSec;
  final bool isLooping;
  final bool isShuffle;
  final List<TrackEntity> playlistQueue;
  final int currentIndex;
  final bool isExpandedPlayerVisible;
  final bool isKaraokeMode;

  PlayerStateData({
    this.currentTrack,
    this.isPlaying = false,
    this.currentPositionSec = 0,
    this.durationSec = 0,
    this.isLooping = false,
    this.isShuffle = false,
    this.playlistQueue = const [],
    this.currentIndex = -1,
    this.isExpandedPlayerVisible = false,
    this.isKaraokeMode = false,
  });

  PlayerStateData copyWith({
    TrackEntity? currentTrack,
    bool? isPlaying,
    int? currentPositionSec,
    int? durationSec,
    bool? isLooping,
    bool? isShuffle,
    List<TrackEntity>? playlistQueue,
    int? currentIndex,
    bool? isExpandedPlayerVisible,
    bool? isKaraokeMode,
  }) {
    return PlayerStateData(
      currentTrack: currentTrack ?? this.currentTrack,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPositionSec: currentPositionSec ?? this.currentPositionSec,
      durationSec: durationSec ?? this.durationSec,
      isLooping: isLooping ?? this.isLooping,
      isShuffle: isShuffle ?? this.isShuffle,
      playlistQueue: playlistQueue ?? this.playlistQueue,
      currentIndex: currentIndex ?? this.currentIndex,
      isExpandedPlayerVisible: isExpandedPlayerVisible ?? this.isExpandedPlayerVisible,
      isKaraokeMode: isKaraokeMode ?? this.isKaraokeMode,
    );
  }
}

class AudioPlayerEngine extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  PlayerStateData _playerState = PlayerStateData();

  PlayerStateData get playerState => _playerState;

  Timer? _synthTimer;
  bool _isSynthPlaying = false;

  AudioPlayerEngine() {
    _audioPlayer.positionStream.listen((pos) {
      if (!_isSynthPlaying) {
        _updateState(_playerState.copyWith(currentPositionSec: pos.inSeconds));
      }
    });
    
    _audioPlayer.playerStateStream.listen((state) {
      if (!_isSynthPlaying) {
        if (state.processingState == ProcessingState.completed) {
          _onPlaybackFinished();
        }
      }
    });

    // Update durationSec whenever just_audio resolves the stream duration
    _audioPlayer.durationStream.listen((duration) {
      if (!_isSynthPlaying && duration != null) {
        _updateState(_playerState.copyWith(durationSec: duration.inSeconds));
      }
    });
  }

  void _updateState(PlayerStateData newState) {
    _playerState = newState;
    notifyListeners();
  }

  void playTrack(TrackEntity track, {List<TrackEntity>? queue}) {
    final activeQueue = queue ?? [track];
    final index = activeQueue.indexWhere((t) => t.id == track.id);
    final safeIndex = index >= 0 ? index : 0;

    _stopCurrentPlayback();

    _updateState(_playerState.copyWith(
      currentTrack: track,
      isPlaying: true,
      currentPositionSec: 0,
      durationSec: track.durationSeconds,
      playlistQueue: activeQueue,
      currentIndex: safeIndex,
    ));

    _startAudioPlayback(track);
  }

  void togglePlayPause() {
    if (_playerState.currentTrack == null) return;

    if (_playerState.isPlaying) {
      pausePlayback();
    } else {
      resumePlayback();
    }
  }

  void resumePlayback() {
    _updateState(_playerState.copyWith(isPlaying: true));
    if (_isSynthPlaying) {
      _startSynthTimer();
    } else {
      _audioPlayer.play();
    }
  }

  void pausePlayback() {
    _updateState(_playerState.copyWith(isPlaying: false));
    if (_isSynthPlaying) {
      _synthTimer?.cancel();
    } else {
      _audioPlayer.pause();
    }
  }

  void playNext() {
    if (_playerState.playlistQueue.isEmpty) return;

    int nextIndex = _playerState.currentIndex + 1;
    if (_playerState.isShuffle) {
      nextIndex = (DateTime.now().millisecondsSinceEpoch % _playerState.playlistQueue.length).toInt();
    } else if (nextIndex >= _playerState.playlistQueue.length) {
      nextIndex = 0;
    }

    final nextTrack = _playerState.playlistQueue[nextIndex];
    playTrack(nextTrack, queue: _playerState.playlistQueue);
  }

  void playPrevious() {
    if (_playerState.playlistQueue.isEmpty) return;

    int prevIndex = _playerState.currentIndex - 1;
    if (prevIndex < 0) {
      prevIndex = _playerState.playlistQueue.length - 1;
    }

    final prevTrack = _playerState.playlistQueue[prevIndex];
    playTrack(prevTrack, queue: _playerState.playlistQueue);
  }

  void seekTo(int seconds) {
    final maxDur = _playerState.durationSec;
    final clamped = seconds.clamp(0, maxDur);
    _updateState(_playerState.copyWith(currentPositionSec: clamped));

    if (_isSynthPlaying) {
      // Just update state
    } else {
      _audioPlayer.seek(Duration(seconds: clamped));
    }
  }

  void seekRelative(int secondsDelta) {
    final current = _playerState.currentPositionSec;
    seekTo(current + secondsDelta);
  }

  void toggleLoop() {
    _updateState(_playerState.copyWith(isLooping: !_playerState.isLooping));
  }

  void toggleShuffle() {
    _updateState(_playerState.copyWith(isShuffle: !_playerState.isShuffle));
  }

  void setExpandedPlayerVisible(bool visible) {
    _updateState(_playerState.copyWith(isExpandedPlayerVisible: visible));
  }

  void toggleKaraokeMode() {
    _updateState(_playerState.copyWith(isKaraokeMode: !_playerState.isKaraokeMode));
    if (_playerState.currentTrack != null && _playerState.isPlaying) {
      // Restart playback for karaoke vs normal track
      _startAudioPlayback(_playerState.currentTrack!);
    }
  }

  void _startAudioPlayback(TrackEntity track) async {
    final rawUrl = _playerState.isKaraokeMode && track.karaokeAudioUrl != null
        ? track.karaokeAudioUrl!
        : track.audioUrl;

    // Resolve relative Minio path → full encoded URL
    final url = ApiService.resolveMediaUrl(rawUrl);

    if (url.startsWith('http://') || url.startsWith('https://')) {
      _isSynthPlaying = false;
      try {
        final duration = await _audioPlayer.setUrl(url);
        // Capture real duration from the stream header
        if (duration != null) {
          _updateState(_playerState.copyWith(durationSec: duration.inSeconds));
        }
        if (_playerState.isPlaying) {
          _audioPlayer.play();
        }
      } catch (e) {
        print('Error playing URL: $e');
        _playAcousticBambooTone(track);
      }
    } else {
      _playAcousticBambooTone(track);
    }
  }

  void _playAcousticBambooTone(TrackEntity track) {
    _isSynthPlaying = true;
    _synthTimer?.cancel();
    if (_playerState.isPlaying) {
      _startSynthTimer();
    }
  }

  void _startSynthTimer() {
    _synthTimer?.cancel();
    _synthTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_playerState.isPlaying) {
        timer.cancel();
        return;
      }
      
      final nextPos = _playerState.currentPositionSec + 1;
      if (nextPos >= _playerState.durationSec) {
        timer.cancel();
        _onPlaybackFinished();
      } else {
        _updateState(_playerState.copyWith(currentPositionSec: nextPos));
      }
    });
  }

  void _onPlaybackFinished() {
    if (_playerState.isLooping && _playerState.currentTrack != null) {
      playTrack(_playerState.currentTrack!, queue: _playerState.playlistQueue);
    } else {
      playNext();
    }
  }

  void _stopCurrentPlayback() {
    _synthTimer?.cancel();
    _audioPlayer.stop();
  }

  @override
  void dispose() {
    _synthTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
