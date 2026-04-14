import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/core/utils/formatters.dart';
import 'package:sonexa/core/widgets/app_image.dart';
import 'package:sonexa/features/library/domain/entities/song.dart';
import 'package:sonexa/features/library/presentation/widgets/song_context_menu.dart';

class SongListTile extends ConsumerWidget {
  const SongListTile({
    super.key,
    required this.song,
    this.coverArtUrl,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.onDownload,
    this.isDownloaded = false,
    this.showContextMenu = true,
  });

  final Song song;
  final String? coverArtUrl;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDownload;
  final bool isDownloaded;

  /// 是否显示右键/长按上下文菜单（默认开启）
  final bool showContextMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      // 桌面端：右键弹出上下文菜单
      onSecondaryTapUp:
          showContextMenu
              ? (details) => SongContextMenu.show(
                context,
                ref,
                song: song,
                tapPosition: details.globalPosition,
              )
              : null,
      // 移动端：长按弹出底部菜单
      onLongPress:
          showContextMenu
              ? () => SongContextMenu.show(context, ref, song: song)
              : null,
      child: ListTile(
        leading: AppImage(url: coverArtUrl, size: 48, borderRadius: 8),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodyLarge,
        ),
        subtitle: Text(
          '${song.artist} - ${song.album}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 更多按钮（触发上下文菜单）
            if (showContextMenu)
              IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
                iconSize: 20,
                onPressed: () => SongContextMenu.show(context, ref, song: song),
                tooltip: AppLocalizations.of(context).more,
              ),
            Text(
              formatDuration(song.duration),
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
