import 'package:flutter/material.dart';
import 'package:sonexa/core/widgets/app_image.dart';
import 'package:sonexa/features/library/domain/entities/album.dart';

class AlbumGridTile extends StatelessWidget {
  const AlbumGridTile({
    super.key,
    required this.album,
    this.coverArtUrl,
    this.onTap,
    this.heroTag,
  });

  final Album album;
  final String? coverArtUrl;
  final VoidCallback? onTap;

  /// Hero 动画标签（与详情页匹配实现封面过渡）
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: SizedBox.expand(
                child: AppImage(
                  url: coverArtUrl,
                  borderRadius: 0,
                  heroTag: heroTag,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: Text(
                album.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                album.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (album.year != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 4),
                child: Text(
                  '${album.year}',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
