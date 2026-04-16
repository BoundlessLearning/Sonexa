import 'package:flutter/material.dart';

import 'package:sonexa/features/library/domain/entities/song.dart';
import 'package:sonexa/features/library/presentation/widgets/song_actions_sheet.dart';

/// 歌曲右键/长按上下文菜单。
///
/// 当前统一复用播放页的歌曲动作面板，保证歌曲列表和播放页体验一致。
class SongContextMenu {
  SongContextMenu._();

  static Future<void> show(
    BuildContext context, {
    required Song song,
    String? coverUrl,
    Offset? tapPosition,
  }) {
    return showSongActionsSheet(
      context,
      song: song,
      coverUrl: coverUrl,
      showAddToQueueAction: true,
    );
  }
}
