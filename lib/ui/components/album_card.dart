import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';

class AlbumCard extends StatelessWidget {
  final AlbumEntity album;
  final VoidCallback onClick;
  final double? width;
  final int? trackCount; // optional override; falls back to album.trackCount

  const AlbumCard({
    super.key,
    required this.album,
    required this.onClick,
    this.width,
    this.trackCount,
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
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      memCacheWidth: 400,
                      placeholder: (context, url) => Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        child: Icon(Icons.album, size: 48, color: Theme.of(context).colorScheme.onSecondaryContainer.withOpacity(0.5)),
                      ),
                      fadeInDuration: const Duration(milliseconds: 200),
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
                album.ownerName,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.music_note,
                          size: 11,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          "${trackCount ?? album.trackCount} ${(trackCount ?? album.trackCount) == 1 ? 'track' : 'tracks'}",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

