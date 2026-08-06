import 'package:flutter/material.dart';
import 'package:rawang_melodies/data/local/entity/entities.dart';
import 'package:rawang_melodies/data/remote/api_service.dart';

class OwnerChip extends StatelessWidget {
  final String ownerTypeString;

  const OwnerChip({super.key, required this.ownerTypeString});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    String label;
    IconData iconData;

    if (ownerTypeString == OwnerType.singer.name) {
      chipColor = Theme.of(context).colorScheme.secondary;
      label = "Singer/Artist";
      iconData = Icons.mic;
    } else if (ownerTypeString == OwnerType.organization.name) {
      chipColor = Theme.of(context).colorScheme.tertiary;
      label = "Cultural Org";
      iconData = Icons.corporate_fare;
    } else {
      chipColor = Colors.grey;
      label = "Anonymous";
      iconData = Icons.person_off;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 12, color: chipColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }
}

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
              color: Colors.black.withOpacity(0.1),
              blurRadius: 2,
              offset: const Offset(0, 1),
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
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: Icon(Icons.album, size: 40, color: Colors.white54),
                        ),
                      );
                    }
                    return Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey.shade800,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade800,
                          child: const Center(
                            child: Icon(Icons.album, size: 40, color: Colors.white54),
                          ),
                        );
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(height: 8),
              OwnerChip(ownerTypeString: album.ownerType),
              const SizedBox(height: 6),
              Text(
                album.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      album.ownerName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    "${album.trackCount} tracks",
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
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
