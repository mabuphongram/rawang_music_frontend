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

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildCurrentScreen(context, musicViewModel, chatViewModel),
            ),
            if (playerState.currentTrack != null)
              MiniPlayerBar(
                playerState: playerState,
                onTogglePlayPause: musicViewModel.playerEngine.togglePlayPause,
                onNext: musicViewModel.playerEngine.playNext,
                onExpandPlayer: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => FullScreenPlayerModal(
                      playerState: playerState,
                      onDismiss: () => Navigator.pop(context),
                      onTogglePlayPause: musicViewModel.playerEngine.togglePlayPause,
                      onNext: musicViewModel.playerEngine.playNext,
                      onPrevious: musicViewModel.playerEngine.playPrevious,
                      onSeekTo: musicViewModel.playerEngine.seekTo,
                      onSeekRelative: musicViewModel.playerEngine.seekRelative,
                      onToggleLoop: musicViewModel.playerEngine.toggleLoop,
                      onToggleShuffle: musicViewModel.playerEngine.toggleShuffle,
                      onToggleDownload: () => musicViewModel.toggleDownload(playerState.currentTrack!),
                      onToggleFavorite: () => musicViewModel.toggleFavorite(playerState.currentTrack!),
                      onToggleKaraokeMode: musicViewModel.toggleKaraokeMode,
                      onShare: () => musicViewModel.setTrackToShare(playerState.currentTrack!),
                    ),
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

  Widget _buildCurrentScreen(BuildContext context, MusicViewModel viewModel, ChatViewModel chatViewModel) {
    switch (viewModel.currentTab) {
      case AppTab.home:
        return HomeScreen(
          albums: viewModel.albums,
          tracks: viewModel.tracks,
          owners: viewModel.owners,
          currentPlayingTrackId: viewModel.playerEngine.playerState.currentTrack?.id,
          onSelectAlbum: viewModel.selectAlbum,
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
        );
      case AppTab.albums:
        if (viewModel.selectedAlbum != null) {
          return AlbumDetailScreen(
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
          );
        }
        return AlbumsScreen(
          albums: viewModel.filteredAlbums,
          searchQuery: viewModel.searchQuery,
          selectedOwnerFilter: viewModel.selectedOwnerFilter,
          onSearchQueryChange: viewModel.updateSearchQuery,
          onOwnerFilterChange: viewModel.setOwnerFilter,
          onSelectAlbum: viewModel.selectAlbum,
        );
      case AppTab.playlists:
        return PlaylistsScreen(
          playlists: viewModel.playlists,
          favoriteTracks: viewModel.favoriteTracks,
          selectedPlaylist: viewModel.selectedPlaylist,
          selectedPlaylistTracks: viewModel.selectedPlaylistTracks,
          currentPlayingTrackId: viewModel.playerEngine.playerState.currentTrack?.id,
          onSelectPlaylist: viewModel.selectPlaylist,
          onOpenCreatePlaylistDialog: () => showCreatePlaylistDialog(context, viewModel.createPlaylist),
          onPlayTrack: (track, ctx) => viewModel.playTrack(track, playlistContext: ctx),
          onToggleDownload: viewModel.toggleDownload,
          onToggleFavorite: viewModel.toggleFavorite,
          onRemoveFromPlaylist: viewModel.removeTrackFromPlaylist,
          onShare: (track) => showShareDialog(context, track),
        );
      case AppTab.offline:
        return OfflineScreen(
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
        );
      case AppTab.chat:
        return CommunityChatScreen(
          messages: chatViewModel.messages,
          allTracks: viewModel.tracks,
          currentPlayingTrack: viewModel.playerEngine.playerState.currentTrack,
          onSendMessage: chatViewModel.sendMessage,
          onPlayTrackById: (trackId) {
            final track = viewModel.tracks.firstWhere((t) => t.id == trackId);
            viewModel.playTrack(track, playlistContext: [track]);
          },
        );
    }
  }
}
