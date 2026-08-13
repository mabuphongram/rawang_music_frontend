import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';

class AlbumCard extends StatelessWidget {
  final AlbumEntity album;
  final VoidCallback onClick;
  final double? width;

  const AlbumCard({
    super.key,
    required this.album,
    required this.onClick,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Builder(builder: (context) {
                    final imageUrl = ApiService.resolveMediaUrl(album.coverImage);
                    if (imageUrl.isEmpty) {
                      return Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Icon(Icons.album, size: 48, color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.5)),
                      );
                    }
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Theme.of(context).colorScheme.secondaryContainer,
                          child: Icon(Icons.album, size: 48, color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.5)),
                        );
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                album.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                "${album.ownerName} • ${album.trackCount} ${album.trackCount == 1 ? 'track' : 'tracks'}",
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

