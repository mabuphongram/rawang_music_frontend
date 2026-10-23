import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/player/audio_player_engine.dart';
import 'package:rawang_melodies/ui/components/dialogs.dart';
import 'package:rawang_melodies/ui/components/full_screen_player_modal.dart';
import 'package:rawang_melodies/ui/components/mini_player_bar.dart';
import 'package:rawang_melodies/ui/screens/album_detail_screen.dart';
import 'package:rawang_melodies/ui/screens/albums_screen.dart';
import 'package:rawang_melodies/ui/screens/community_chat_screen.dart';
import 'package:rawang_melodies/ui/screens/contribute_screen.dart';
import 'package:rawang_melodies/ui/screens/home_screen.dart';
import 'package:rawang_melodies/ui/screens/offline_screen.dart';
import 'package:rawang_melodies/ui/screens/owners_screen.dart';
import 'package:rawang_melodies/ui/screens/video_player_screen.dart';
import 'package:rawang_melodies/ui/screens/settings/settings_screen.dart';
import 'package:rawang_melodies/ui/screens/auth/auth_gate.dart';
import 'package:rawang_melodies/ui/screens/auth/login_screen.dart';
import 'package:rawang_melodies/ui/screens/splash_screen.dart';
import 'package:rawang_melodies/ui/theme.dart';
import 'package:rawang_melodies/viewmodels/auth_view_model.dart';
import 'package:rawang_melodies/viewmodels/chat_view_model.dart';
import 'package:rawang_melodies/viewmodels/music_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AudioPlayerEngine()),
        ChangeNotifierProxyProvider<AudioPlayerEngine, MusicViewModel>(
          create: (context) => MusicViewModel(Provider.of<AudioPlayerEngine>(context, listen: false)),
          update: (context, engine, previous) => previous ?? MusicViewModel(engine),
        ),
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: const RawangMusicApp(),
    ),
  );
}

class RawangMusicApp extends StatelessWidget {
  const RawangMusicApp({super.key}); 

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rawang Melodies',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const SplashScreen(nextScreen: AuthGate()),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  void _showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login required'),
        content: const Text(
          'Streaming needs a free account (3 years free). Log in or register to keep listening.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LoginScreen(
                    onLoginSuccess: () => Navigator.of(context).pop(),
                    onGuest: () => Navigator.of(context).pop(),
                  ),
                ),
              );
            },
            child: const Text('Login / Register'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicViewModel = context.watch<MusicViewModel>();
    final chatViewModel = context.watch<ChatViewModel>();
    final authViewModel = context.watch<AuthViewModel>();
    final playerState = musicViewModel.playerEngine.playerState;

    // Paywall: guests can browse but streaming needs a (free) account.
    final engine = musicViewModel.playerEngine;
    engine.requireLogin = !authViewModel.isLoggedIn;
    engine.onBlockedPlay = () => _showLoginPrompt(context);

    final user = authViewModel.currentUser;
    final inGrace = user != null && !user.isSubscriptionActive && user.inGracePeriod;

    String? miniPlayerCoverImage;
    if (playerState.currentTrack != null) {
      for (var album in musicViewModel.albums) {
        if (album.id == playerState.currentTrack!.albumId) {
          miniPlayerCoverImage = album.coverImage;
          break;
        }
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            if (inGrace)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Your access has expired — contact support within ${UserEntity.graceDays - user!.daysOverdue} day(s) to keep listening.',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              // IndexedStack keeps all screens alive in the widget tree.
              // Switching tabs only changes which child is visible — no rebuilds,
              // no Image.network reloads, no lost scroll positions.
              child: IndexedStack(
                index: musicViewModel.currentTab.index,
                children: _buildAllScreens(context, musicViewModel, chatViewModel),
              ),
            ),
            if (playerState.currentTrack != null)
              MiniPlayerBar(
                playerState: playerState,
                albumCoverImage: miniPlayerCoverImage,
                onTogglePlayPause: musicViewModel.playerEngine.togglePlayPause,
                onNext: musicViewModel.playerEngine.playNext,
                onExpandPlayer: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return Consumer<MusicViewModel>(
                        builder: (context, mvm, child) {
                          final state = mvm.playerEngine.playerState;
                          String? coverImage;
                          if (state.currentTrack != null) {
                            for (var album in mvm.albums) {
                              if (album.id == state.currentTrack!.albumId) {
                                coverImage = album.coverImage;
                                break;
                              }
                            }
                          }
                          
                          return FullScreenPlayerModal(
                            playerState: state,
                            albumCoverImage: coverImage,
                            onDismiss: () => Navigator.pop(context),
                            onTogglePlayPause: mvm.playerEngine.togglePlayPause,
                            onNext: mvm.playerEngine.playNext,
                            onPrevious: mvm.playerEngine.playPrevious,
                            onSeekTo: mvm.playerEngine.seekTo,
                            onSeekRelative: mvm.playerEngine.seekRelative,
                            onToggleLoop: mvm.playerEngine.toggleLoop,
                            onToggleShuffle: mvm.playerEngine.toggleShuffle,
                            onToggleDownload: () => mvm.toggleDownload(state.currentTrack!),
                            onToggleFavorite: () => mvm.toggleFavorite(state.currentTrack!),
                            onToggleKaraokeMode: mvm.toggleKaraokeMode,
                          );
                        },
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: musicViewModel.currentTab.index,
        onDestinationSelected: (index) {
          musicViewModel.selectTab(AppTab.values[index]);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.album), label: 'Albums'),
          NavigationDestination(icon: Icon(Icons.offline_pin), label: 'Offline'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  List<Widget> _buildAllScreens(BuildContext context, MusicViewModel viewModel, ChatViewModel chatViewModel) {
    return [
      // AppTab.home (index 0)
      viewModel.homeSelectedAlbum != null
          ? AlbumDetailScreen(
              album: viewModel.homeSelectedAlbum!,
              tracks: viewModel.tracks.where((t) => t.albumIds.contains(viewModel.homeSelectedAlbum!.id)).toList(),
              currentPlayingTrackId: viewModel.playerEngine.playerState.currentTrack?.id,
              onBack: () => viewModel.selectHomeAlbum(null),
              onPlayTrack: (track, ctx) => viewModel.playTrack(track, playlistContext: ctx),
              onPlayAll: () {
                final albumTracks = viewModel.tracks.where((t) => t.albumIds.contains(viewModel.homeSelectedAlbum!.id)).toList();
                if (albumTracks.isNotEmpty) {
                  viewModel.playTrack(albumTracks.first, playlistContext: albumTracks);
                }
              },
              onDownloadAlbum: () {},
              onToggleDownload: viewModel.toggleDownload,
              onToggleFavorite: viewModel.toggleFavorite,
              onAddToPlaylist: (track) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playlists removed - use Favorites (heart)')));
              },
              onShare: (track) => showShareDialog(context, track),
            )
          : HomeScreen(
        albums: viewModel.albums,
        tracks: viewModel.tracks,
        popularTracks: viewModel.popularTracks,
        owners: viewModel.owners,
        heroSlides: viewModel.heroSlides,
        videos: viewModel.videos,
        currentPlayingTrackId: viewModel.playerEngine.playerState.currentTrack?.id,
        onSelectAlbum: (album) => viewModel.selectHomeAlbum(album),
        onPlayVideo: (video) {
          // Pause any audio so it never plays over the video (YouTube ToS:
          // no background/overlapping playback).
          viewModel.playerEngine.pausePlayback();
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
          );
        },
        onPlayTrack: (track, ctx) => viewModel.playTrack(track, playlistContext: ctx),
        onToggleDownload: viewModel.toggleDownload,
        onToggleFavorite: viewModel.toggleFavorite,
        onAddToPlaylist: (track) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playlists removed - use Favorites (heart)')));
        },
        onShare: (track) => showShareDialog(context, track),
        onlineCount: viewModel.onlineCount,
        onOpenAddSongDialog: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ContributeScreen()),
          );
        },
        onFilterByOwner: (filter) {
          if (filter == "ALL") {
            viewModel.setOwnerFilter("ALL");
          } else {
            viewModel.setOwnerNameFilter(filter);
          }
          viewModel.selectTab(AppTab.albums);
        },
        onSeeAllOwners: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OwnersScreen(owners: viewModel.owners),
            ),
          );
        },
      ),

      // AppTab.albums (index 1)
      viewModel.selectedAlbum != null
          ? AlbumDetailScreen(
              album: viewModel.selectedAlbum!,
              tracks: viewModel.currentAlbumTracks,
              currentPlayingTrackId: viewModel.playerEngine.playerState.currentTrack?.id,
              onBack: () => viewModel.selectAlbum(null),
              onPlayTrack: (track, ctx) => viewModel.playTrack(track, playlistContext: ctx),
              onPlayAll: () {
                if (viewModel.currentAlbumTracks.isNotEmpty) {
                  viewModel.playTrack(viewModel.currentAlbumTracks.first, playlistContext: viewModel.currentAlbumTracks);
                }
              },
              onDownloadAlbum: () {},
              onToggleDownload: viewModel.toggleDownload,
              onToggleFavorite: viewModel.toggleFavorite,
              onAddToPlaylist: (track) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playlists removed - use Favorites (heart)')));
              },
              onShare: (track) => showShareDialog(context, track),
            )
          : AlbumsScreen(
              albums: viewModel.filteredAlbums,
              tracks: viewModel.tracks,
              searchQuery: viewModel.searchQuery,
              selectedOwnerFilter: viewModel.selectedOwnerFilter,
              onSearchQueryChange: viewModel.updateSearchQuery,
              onOwnerFilterChange: viewModel.setOwnerFilter,
              onSelectAlbum: viewModel.selectAlbum,
            ),

      // AppTab.offline (index 2) - Favorites + Downloaded fused, playlists discarded
      OfflineScreen(
        downloadedTracks: viewModel.downloadedTracks,
        favoriteTracks: viewModel.favoriteTracks,
        currentPlayingTrackId: viewModel.playerEngine.playerState.currentTrack?.id,
        onPlayTrack: (track, ctx) => viewModel.playTrack(track, playlistContext: ctx),
        onToggleDownload: viewModel.toggleDownload,
        onToggleFavorite: viewModel.toggleFavorite,
        onShare: (track) => showShareDialog(context, track),
      ),

      // AppTab.chat (index 3)
      CommunityChatScreen(
        messages: chatViewModel.messages,
        onSendMessage: chatViewModel.sendMessage,
        onLoadMore: chatViewModel.loadMoreMessages,
      ),

      // AppTab.settings (index 4) - last right, Login/Logout
      const SettingsScreen(),
    ];
  }
}
