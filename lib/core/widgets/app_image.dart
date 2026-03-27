import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.url,
    this.size,
    this.borderRadius = 8,
    this.heroTag,
  });

  final String? url;
  final double? size;
  final double borderRadius;

  /// 当提供 heroTag 时，会用 Hero 包裹图片以实现跨页面过渡动画
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final dimension = size ?? 48;

    Widget image = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: dimension,
        height: dimension,
        child: (url == null || url!.isEmpty)
            ? _IconPlaceholder(size: dimension)
            : CachedNetworkImage(
                imageUrl: url!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  highlightColor: Theme.of(context).colorScheme.surface,
                  child: Container(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                errorWidget: (context, url, error) =>
                    _IconPlaceholder(size: dimension),
              ),
      ),
    );

    if (heroTag != null) {
      image = Hero(tag: heroTag!, child: image);
    }

    return image;
  }
}

class _IconPlaceholder extends StatelessWidget {
  const _IconPlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.music_note,
        size: size * 0.5,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
