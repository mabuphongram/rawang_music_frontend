import 'package:flutter/foundation.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';
import 'package:rawang_melodies/data/local/database_helper.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/player/audio_player_engine.dart';

enum AppTab { home, albums, playlists, offline, chat }

class MusicViewModel extends ChangeNotifier {
  final DatabaseHelper db = DatabaseHelper.instance;
  final AudioPlayerEngine playerEngine;

  AppTab currentTab = AppTab.home;
  String searchQuery = "";
  String selectedOwnerFilter = "ALL";
  String? selectedOwnerName; // when set, filter by exact owner name
  AlbumEntity? selectedAlbum;
  PlaylistEntity? selectedPlaylist;
  bool isAddSongDialogOpen = false;
  bool isCreatePlaylistDialogOpen = false;
  TrackEntity? trackToAddToPlaylist;
  TrackEntity? trackToShare;

  List<AlbumEntity> albums = [];
  List<TrackEntity> tracks = [];
  List<OwnerEntity> owners = [];
  List<TrackEntity> downloadedTracks = [];
  List<TrackEntity> favoriteTracks = [];
  List<PlaylistEntity> playlists = [];

  List<AlbumEntity> get filteredAlbums {
    final query = searchQuery.trim().toLowerCase();
    return albums.where((album) {
      // If a specific owner name is set, filter by exact name only
      bool matchesOwner;
      if (selectedOwnerName != null && selectedOwnerName!.isNotEmpty) {
        matchesOwner = album.ownerName == selectedOwnerName;
      } else {
        matchesOwner = selectedOwnerFilter == "ALL" ||
            (selectedOwnerFilter == "SINGER" && album.ownerType == OwnerType.singer.name) ||
            (selectedOwnerFilter == "ORGANIZATION" && album.ownerType == OwnerType.organization.name) ||
            (selectedOwnerFilter == "ANONYMOUS" && album.ownerType == OwnerType.anonymous.name) ||
            album.ownerType == selectedOwnerFilter;
      }

      final matchesSearch = query.isEmpty ||
          album.title.toLowerCase().contains(query) ||
          album.ownerName.toLowerCase().contains(query);

      return matchesOwner && matchesSearch;
    }).toList();
  }

  List<TrackEntity> get currentAlbumTracks {
    if (selectedAlbum == null) return [];
    return tracks.where((t) => t.albumId == selectedAlbum!.id).toList();
  }

  List<TrackEntity> selectedPlaylistTracks = [];

  MusicViewModel(this.playerEngine) {
    _loadData();
    playerEngine.addListener(() {
      notifyListeners();
    });
  }

  Future<void> _loadData() async {
    // ── Step 1: show cached data instantly ──────────────────────────────
    albums = await db.getAllAlbums();
    tracks = await db.getAllTracks();
    owners = await db.getAllOwners();
    downloadedTracks = await db.getDownloadedTracks();
    favoriteTracks = await db.getFavoriteTracks();
    playlists = await db.getAllPlaylists();
    if (selectedPlaylist != null) {
      selectedPlaylistTracks = await db.getTracksForPlaylist(selectedPlaylist!.id);
    }
    notifyListeners(); // ← UI renders immediately with cached data

    // ── Step 2: sync from API in background, write to cache, refresh UI ─
    await db.syncFromApi();            // fetch → store to SQLite (owners included)
    albums = await db.getAllAlbums();  // read fresh cache
    tracks = await db.getAllTracks();
    owners = await db.getAllOwners();  // read fresh owners from cache
    downloadedTracks = await db.getDownloadedTracks();
    favoriteTracks = await db.getFavoriteTracks();
    playlists = await db.getAllPlaylists();
    if (selectedPlaylist != null) {
      selectedPlaylistTracks = await db.getTracksForPlaylist(selectedPlaylist!.id);
    }
    notifyListeners(); // ← UI refreshes silently with fresh data
  }

  void selectTab(AppTab tab) {
    currentTab = tab;
    selectedAlbum = null;
    selectedPlaylist = null;
    notifyListeners();
  }

  void updateSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setOwnerFilter(String filter) {
    selectedOwnerFilter = filter;
    selectedOwnerName = null; // clear name filter when using type filter
    notifyListeners();
  }

  void setOwnerNameFilter(String ownerName) {
    selectedOwnerName = ownerName;
    selectedOwnerFilter = "ALL"; // clear type filter when filtering by name
    notifyListeners();
  }

  void selectAlbum(AlbumEntity? album) {
    selectedAlbum = album;
    notifyListeners();
  }

  void selectPlaylist(PlaylistEntity? playlist) async {
    selectedPlaylist = playlist;
    if (playlist != null) {
      selectedPlaylistTracks = await db.getTracksForPlaylist(playlist.id);
    } else {
      selectedPlaylistTracks = [];
    }
    notifyListeners();
  }

  void playTrack(TrackEntity track, {List<TrackEntity>? playlistContext}) {
    playerEngine.playTrack(track, queue: playlistContext ?? [track]);
    // increment play count logic would go here
  }

  Future<void> toggleDownload(TrackEntity track) async {
    await db.updateDownloadStatus(track.id, !track.isDownloaded);
    await _loadData();
  }

  Future<void> toggleFavorite(TrackEntity track) async {
    await db.updateFavoriteStatus(track.id, !track.isFavorite);
    await _loadData();
  }

  void setAddSongDialogOpen(bool open) {
    isAddSongDialogOpen = open;
    notifyListeners();
  }

  void setCreatePlaylistDialogOpen(bool open) {
    isCreatePlaylistDialogOpen = open;
    notifyListeners();
  }

  void setTrackToAddToPlaylist(TrackEntity? track) {
    trackToAddToPlaylist = track;
    notifyListeners();
  }

  void setTrackToShare(TrackEntity? track) {
    trackToShare = track;
    notifyListeners();
  }

  Future<void> createPlaylist(String name, String description) async {
    final newPlaylist = PlaylistEntity(
      id: "pl_\${DateTime.now().millisecondsSinceEpoch}",
      name: name,
      description: description,
    );
    await ApiService.createPlaylist(newPlaylist);
    await db.insertPlaylist(newPlaylist);
    setCreatePlaylistDialogOpen(false);
    await _loadData();
  }

  Future<void> addTrackToPlaylist(String playlistId, String trackId) async {
    await ApiService.addTrackToPlaylist(playlistId, trackId);
    await db.insertPlaylistTrack(playlistId, trackId);
    setTrackToAddToPlaylist(null);
    if (selectedPlaylist?.id == playlistId) {
      selectedPlaylistTracks = await db.getTracksForPlaylist(playlistId);
    }
    notifyListeners();
  }

  Future<void> removeTrackFromPlaylist(String playlistId, String trackId) async {
    await ApiService.removeTrackFromPlaylist(playlistId, trackId);
    await db.deletePlaylistTrack(playlistId, trackId);
    if (selectedPlaylist?.id == playlistId) {
      selectedPlaylistTracks = await db.getTracksForPlaylist(playlistId);
    }
    notifyListeners();
  }

  void toggleKaraokeMode() {
    playerEngine.toggleKaraokeMode();
  }

  Future<void> contributeTrack(
    String title,
    String rawangTitle,
    String artistName,
    String albumTitle,
    OwnerType ownerType,
    String genre,
    String lyrics,
    bool hasKaraoke,
  ) async {
    final albumId = "alb_custom_\${DateTime.now().millisecondsSinceEpoch}";
    final trackId = "trk_custom_\${DateTime.now().millisecondsSinceEpoch}";

    final newAlbum = AlbumEntity(
      id: albumId,
      title: albumTitle.isEmpty ? "\$title Single" : albumTitle,
      ownerType: ownerType.name,
      ownerName: artistName.isEmpty ? "Community Contributor" : artistName,
      coverImage: '',
      releaseYear: 2026,
      description: "Preserved community contribution",
      trackCount: 1,
    );

    final newTrack = TrackEntity(
      id: trackId,
      albumId: albumId,
      title: title,
      rawangTitle: rawangTitle,
      artistName: artistName.isEmpty ? "Community Contributor" : artistName,
      albumName: albumTitle.isEmpty ? "\$title Single" : albumTitle,
      ownerType: ownerType.name,
      durationSeconds: 210,
      audioUrl: "synth:440:600",
      lyrics: lyrics.isEmpty ? "[Community Preserved Rawang Lyrics]" : lyrics,
      genre: genre.isEmpty ? "Cultural Preservation" : genre,
      isDownloaded: true,
      hasKaraoke: hasKaraoke,
      karaokeAudioUrl: hasKaraoke ? "synth:karaoke:440:600" : null,
    );

    await ApiService.createAlbum(newAlbum);
    await ApiService.createTrack(newTrack);
    await db.insertAlbum(newAlbum);
    await db.insertTrack(newTrack);
    setAddSongDialogOpen(false);
    await _loadData();
  }
}
