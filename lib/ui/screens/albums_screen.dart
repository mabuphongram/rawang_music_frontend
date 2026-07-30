import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/ui/components/album_card.dart';

class AlbumsScreen extends StatelessWidget {
  final List<AlbumEntity> albums;
  final String searchQuery;
  final String selectedOwnerFilter;
  final void Function(String) onSearchQueryChange;
  final void Function(String) onOwnerFilterChange;
  final void Function(AlbumEntity) onSelectAlbum;

  const AlbumsScreen({
    super.key,
    required this.albums,
    required this.searchQuery,
    required this.selectedOwnerFilter,
    required this.onSearchQueryChange,
    required this.onOwnerFilterChange,
    required this.onSelectAlbum,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            "Albums & Collections",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onBackground,
            ),
          ),
          Text(
            "Categorized by Singers, Organizations, & Title Collections",
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: onSearchQueryChange,
            decoration: InputDecoration(
              hintText: "Search album title, singer, or organization...",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(context, "All (${albums.length})", "ALL", null),
                const SizedBox(width: 8),
                _buildFilterChip(context, "Singers", OwnerType.singer.name, Icons.mic),
                const SizedBox(width: 8),
                _buildFilterChip(context, "Organizations", OwnerType.organization.name, Icons.corporate_fare),
                const SizedBox(width: 8),
                _buildFilterChip(context, "Title Collections", OwnerType.anonymous.name, Icons.music_note),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: albums.isEmpty
                ? Center(
                    child: Text(
                      "No albums found for this filter.",
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 90),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final album = albums[index];
                      return AlbumCard(
                        album: album,
                        onClick: () => onSelectAlbum(album),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String filter, IconData? icon) {
    return ChoiceChip(
      label: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: selectedOwnerFilter == filter,
      onSelected: (_) {
        onOwnerFilterChange(filter);
      },
    );
  }
}
