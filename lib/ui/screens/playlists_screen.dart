import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/ui/components/track_list_item.dart';

class PlaylistsScreen extends StatefulWidget {
  final List<PlaylistEntity> playlists;
  final List<TrackEntity> favoriteTracks;
  final PlaylistEntity? selectedPlaylist;
  final List<TrackEntity> selectedPlaylistTracks;
  final String? currentPlayingTrackId;
  final void Function(PlaylistEntity?) onSelectPlaylist;
  final VoidCallback onOpenCreatePlaylistDialog;
  final void Function(TrackEntity, List<TrackEntity>) onPlayTrack;
  final void Function(TrackEntity) onToggleDownload;
  final void Function(TrackEntity) onToggleFavorite;
  final void Function(String, String) onRemoveFromPlaylist;
  final void Function(TrackEntity) onShare;

  const PlaylistsScreen({
    super.key,
    required this.playlists,
    required this.favoriteTracks,
    this.selectedPlaylist,
    required this.selectedPlaylistTracks,
    this.currentPlayingTrackId,
    required this.onSelectPlaylist,
    required this.onOpenCreatePlaylistDialog,
    required this.onPlayTrack,
    required this.onToggleDownload,
    required this.onToggleFavorite,
    required this.onRemoveFromPlaylist,
    required this.onShare,
  });

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  int _selectedTab = 0; // 0: My Playlists, 1: Favorited Tracks

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.selectedPlaylist != null) {
      // Selected Playlist Detail View
      return Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => widget.onSelectPlaylist(null),
                ),
                Text(
                  "Playlist Details",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.queue_music,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 36,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.selectedPlaylist!.name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onBackground,
                        ),
                      ),
                      Text(
                        widget.selectedPlaylist!.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        "${widget.selectedPlaylistTracks.length} tracks saved",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (widget.selectedPlaylistTracks.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => widget.onPlayTrack(
                  widget.selectedPlaylistTracks.first,
                  widget.selectedPlaylistTracks,
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text("Play Full Playlist"),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: widget.selectedPlaylistTracks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      "No tracks in this playlist yet. Add songs from track option menus!",
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8).copyWith(bottom: 90),
                    itemCount: widget.selectedPlaylistTracks.length,
                    itemBuilder: (context, index) {
                      final track = widget.selectedPlaylistTracks[index];
                      return Row(
                        children: [
                          Expanded(
                            child: TrackListItem(
                              track: track,
                              isPlayingCurrentTrack: track.id == widget.currentPlayingTrackId,
                              onTrackClick: () => widget.onPlayTrack(track, widget.selectedPlaylistTracks),
                              onToggleDownload: () => widget.onToggleDownload(track),
                              onToggleFavorite: () => widget.onToggleFavorite(track),
                              onAddToPlaylist: () {},
                              onShare: () => widget.onShare(track),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: theme.colorScheme.error),
                            onPressed: () => widget.onRemoveFromPlaylist(widget.selectedPlaylist!.id, track.id),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      );
    }

    // Playlists Main Screen
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "My Music Library",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  Text(
                    "Personalized Playlists & Favorites",
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onBackground.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: widget.onOpenCreatePlaylistDialog,
                icon: const Icon(Icons.add, size: 16),
                label: const Text("New Playlist", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => setState(() => _selectedTab = 0),
              style: TextButton.styleFrom(
                foregroundColor: _selectedTab == 0 ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
              child: Text("Playlists (${widget.playlists.length})"),
            ),
            TextButton(
              onPressed: () => setState(() => _selectedTab = 1),
              style: TextButton.styleFrom(
                foregroundColor: _selectedTab == 1 ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
              ),
              child: Text("Favorites (${widget.favoriteTracks.length})"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _selectedTab == 0
              ? ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 90),
                  itemCount: widget.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = widget.playlists[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: theme.colorScheme.surfaceVariant,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: InkWell(
                        onTap: () => widget.onSelectPlaylist(playlist),
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.queue_music,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      playlist.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      playlist.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.play_arrow, color: theme.colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                )
              : widget.favoriteTracks.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "No favorite tracks added yet. Tap heart icon on any song!",
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 90),
                      itemCount: widget.favoriteTracks.length,
                      itemBuilder: (context, index) {
                        final track = widget.favoriteTracks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: TrackListItem(
                            track: track,
                            isPlayingCurrentTrack: track.id == widget.currentPlayingTrackId,
                            onTrackClick: () => widget.onPlayTrack(track, widget.favoriteTracks),
                            onToggleDownload: () => widget.onToggleDownload(track),
                            onToggleFavorite: () => widget.onToggleFavorite(track),
                            onAddToPlaylist: () {},
                            onShare: () => widget.onShare(track),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
