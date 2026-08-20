import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:rawang_melodies/player/audio_player_engine.dart';
import 'package:rawang_melodies/ui/components/dialogs.dart';
import 'package:rawang_melodies/ui/components/full_screen_player_modal.dart';
import 'package:rawang_melodies/ui/components/mini_player_bar.dart';
import 'package:rawang_melodies/ui/screens/album_detail_screen.dart';
import 'package:rawang_melodies/ui/screens/albums_screen.dart';
import 'package:rawang_melodies/ui/screens/community_chat_screen.dart';
import 'package:rawang_melodies/ui/screens/home_screen.dart';
import 'package:rawang_melodies/ui/screens/offline_screen.dart';
import 'package:rawang_melodies/ui/screens/owners_screen.dart';
import 'package:rawang_melodies/ui/screens/playlists_screen.dart';
import 'package:rawang_melodies/ui/theme.dart';
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
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final musicViewModel = context.watch<MusicViewModel>();
    final chatViewModel = context.watch<ChatViewModel>();
    final playerState = musicViewModel.playerEngine.playerState;

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
                            onShare: () => mvm.setTrackToShare(state.currentTrack!),
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
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.album),
            label: 'Albums',
          ),
          NavigationDestination(
            icon: Icon(Icons.queue_music),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.offline_pin),
            label: 'Offline',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllScreens(BuildContext context, MusicViewModel viewModel, ChatViewModel chatViewModel) {
    return [
      // AppTab.home (index 0)
      HomeScreen(
        albums: viewModel.albums,
        tracks: viewModel.tracks,
        popularTracks: viewModel.popularTracks,
        owners: viewModel.owners,
        currentPlayingTrackId: viewModel.playerEngine.playerState.currentTrack?.id,
        onSelectAlbum: (album) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => Scaffold(
                body: SafeArea(
                  child: Consumer<MusicViewModel>(
                    builder: (context, mvm, child) {
                      final albumTracks = mvm.tracks.where((t) => t.albumId == album.id).toList();
                      return AlbumDetailScreen(
                        album: album,
                        tracks: albumTracks,
                        currentPlayingTrackId: mvm.playerEngine.playerState.currentTrack?.id,
                        onBack: () => Navigator.pop(ctx),
                        onPlayTrack: (track, playlistCtx) => mvm.playTrack(track, playlistContext: playlistCtx),
                        onPlayAll: () {
                          if (albumTracks.isNotEmpty) {
                            mvm.playTrack(albumTracks.first, playlistContext: albumTracks);
                          }
                        },
                        onDownloadAlbum: () {},
                        onToggleDownload: mvm.toggleDownload,
                        onToggleFavorite: mvm.toggleFavorite,
                        onAddToPlaylist: (track) {
                          showAddToPlaylistDialog(
                            context,
                            track,
                            mvm.playlists,
                            mvm.addTrackToPlaylist,
                            () => showCreatePlaylistDialog(context, mvm.createPlaylist),
                          );
                        },
                        onShare: (track) => showShareDialog(context, track),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
        onPlayTrack: (track, ctx) => viewModel.playTrack(track, playlistContext: ctx),
        onToggleDownload: viewModel.toggleDownload,
        onToggleFavorite: viewModel.toggleFavorite,
        onAddToPlaylist: (track) {
          showAddToPlaylistDialog(
            context,
            track,
            viewModel.playlists,
            viewModel.addTrackToPlaylist,
            () => showCreatePlaylistDialog(context, viewModel.createPlaylist),
          );
        },
        onShare: (track) => showShareDialog(context, track),
        onOpenAddSongDialog: () {
          showAddSongDialog(
            context,
            viewModel.contributeTrack,
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
                showAddToPlaylistDialog(
                  context,
                  track,
                  viewModel.playlists,
                  viewModel.addTrackToPlaylist,
                  () => showCreatePlaylistDialog(context, viewModel.createPlaylist),
                );
              },
              onShare: (track) => showShareDialog(context, track),
            )
          : AlbumsScreen(
              albums: viewModel.filteredAlbums,
              searchQuery: viewModel.searchQuery,
              selectedOwnerFilter: viewModel.selectedOwnerFilter,
              onSearchQueryChange: viewModel.updateSearchQuery,
              onOwnerFilterChange: viewModel.setOwnerFilter,
              onSelectAlbum: viewModel.selectAlbum,
            ),

      // AppTab.playlists (index 2)
      PlaylistsScreen(
        playlists: viewModel.playlists,
        favoriteTracks: viewModel.favoriteTracks,
        selectedPlaylist: viewModel.selectedPlaylist,
        selectedPlaylistTracks: viewModel.selectedPlaylistTracks,
        currentPlayingTrackId: viewModel.playerEngine.playerState.currentTrack?.id,
        onSelectPlaylist: viewModel.selectPlaylist,
        onPlayTrack: (track, ctx) => viewModel.playTrack(track, playlistContext: ctx),
        onToggleDownload: viewModel.toggleDownload,
        onToggleFavorite: viewModel.toggleFavorite,
        onShare: (track) => showShareDialog(context, track),
      ),

      // AppTab.offline (index 3)
      OfflineScreen(
        downloadedTracks: viewModel.downloadedTracks,
        currentPlayingTrackId: viewModel.playerEngine.playerState.currentTrack?.id,
        onPlayTrack: (track, ctx) => viewModel.playTrack(track, playlistContext: ctx),
        onToggleDownload: viewModel.toggleDownload,
        onToggleFavorite: viewModel.toggleFavorite,
        onAddToPlaylist: (track) {
          showAddToPlaylistDialog(
            context,
            track,
            viewModel.playlists,
            viewModel.addTrackToPlaylist,
            () => showCreatePlaylistDialog(context, viewModel.createPlaylist),
          );
        },
        onShare: (track) => showShareDialog(context, track),
      ),

      // AppTab.chat (index 4)
      CommunityChatScreen(
        messages: chatViewModel.messages,
        onSendMessage: chatViewModel.sendMessage,
        onLoadMore: chatViewModel.loadMoreMessages,
      ),
    ];
  }
}
