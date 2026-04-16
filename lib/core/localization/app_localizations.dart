import 'package:flutter/material.dart';

import 'package:sonexa/core/constants/app_branding.dart';
import 'package:sonexa/core/error/app_error.dart';

enum AppLanguage {
  system,
  zh,
  en;

  String get storageValue {
    return switch (this) {
      AppLanguage.system => 'system',
      AppLanguage.zh => 'zh',
      AppLanguage.en => 'en',
    };
  }

  Locale? get locale {
    return switch (this) {
      AppLanguage.system => null,
      AppLanguage.zh => const Locale('zh'),
      AppLanguage.en => const Locale('en'),
    };
  }

  static AppLanguage fromLocale(Locale locale) {
    return locale.languageCode.toLowerCase().startsWith('zh')
        ? AppLanguage.zh
        : AppLanguage.en;
  }

  static AppLanguage fromStorageValue(String? value) {
    return switch (value) {
      'zh' => AppLanguage.zh,
      'en' => AppLanguage.en,
      _ => AppLanguage.system,
    };
  }
}

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static String appTitleFor(AppLanguage language) {
    if (language == AppLanguage.system) {
      return appTitleFor(
        AppLanguage.fromLocale(
          WidgetsBinding.instance.platformDispatcher.locale,
        ),
      );
    }
    return language == AppLanguage.zh
        ? AppBranding.chineseName
        : AppBranding.name;
  }

  bool get isZh => locale.languageCode.toLowerCase().startsWith('zh');

  String text(String zh, String en) => isZh ? zh : en;

  String get appName => text(AppBranding.chineseName, AppBranding.name);
  String get slogan => text('你的音乐，随处可听。', AppBranding.slogan);
  String get positioning => text('连接你私人音乐服务器的音乐播放器。', AppBranding.positioning);
  String get description =>
      text('为自托管音乐用户打造的开放音乐客户端。', AppBranding.description);

  String get homeTab => text('首页', 'Home');
  String get libraryTab => text('音乐库', 'Library');
  String get searchTab => text('搜索', 'Search');
  String get settingsTab => text('设置', 'Settings');

  String get refresh => text('刷新', 'Refresh');
  String get seeMore => text('查看更多', 'See more');
  String get retry => text('重试', 'Retry');
  String get failedToLoad => text('加载失败', 'Failed to load');
  String get songs => text('歌曲', 'Songs');
  String get albums => text('专辑', 'Albums');
  String get artists => text('艺术家', 'Artists');
  String get playlists => text('播放列表', 'Playlists');
  String get songLists => text('歌单', 'Playlists');
  String songCount(int count) => text('$count 首歌曲', '$count songs');
  String albumCount(int count) => text('$count 张专辑', '$count albums');

  String get albumSongs => text('专辑歌曲', 'Album Songs');
  String get artistSongs => text('歌手歌曲', 'Artist Songs');
  String get randomSongs => text('随机推荐', 'Random Picks');
  String get noRandomSongs => text('暂无推荐', 'No recommendations yet');
  String get starredSongs => text('我的收藏', 'Favorites');
  String get noStarredSongs => text('暂无收藏歌曲', 'No favorite songs yet');
  String get similarSongs => text('猜你喜欢', 'Similar Songs');
  String get noSimilarSongs => text('暂无相似推荐', 'No similar songs yet');
  String get newestAlbums => text('最新专辑', 'New Albums');
  String get recentlyPlayed => text('最近播放', 'Recently Played');
  String get noPlayHistory => text('暂无播放记录', 'No playback history yet');
  String get pressBackAgainToExit =>
      text('再按一次退出应用', 'Press back again to exit');
  String get noAlbums => text('暂无专辑', 'No albums yet');
  String get noSongs => text('暂无歌曲', 'No songs yet');
  String get songsLoadFailed => text('歌曲加载失败', 'Failed to load songs');
  String get noArtists => text('暂无艺术家', 'No artists yet');
  String get noPlaylists => text('暂无播放列表', 'No playlists yet');
  String get noSongLists => text('暂无歌单', 'No playlists yet');

  String get searchHint =>
      text('搜索歌曲、专辑、艺术家...', 'Search songs, albums, artists...');
  String get searchEmptyHint => text('输入关键词搜索音乐', 'Type to search your music');
  String searchFailed(Object error) =>
      text('搜索出错: $error', 'Search failed: $error');
  String searchSongsTab(int count) => text('歌曲 ($count)', 'Songs ($count)');
  String searchAlbumsTab(int count) => text('专辑 ($count)', 'Albums ($count)');
  String searchArtistsTab(int count) =>
      text('艺术家 ($count)', 'Artists ($count)');
  String get noSearchResults => text('未找到相关结果', 'No results found');

  String get createPlaylist => text('新建播放列表', 'New Playlist');
  String get createSongList => text('新建歌单', 'New Playlist');
  String get playlistName => text('播放列表名称', 'Playlist name');
  String get songListName => text('歌单名称', 'Playlist name');
  String get enterName => text('请输入名称', 'Enter a name');
  String get cancel => text('取消', 'Cancel');
  String get create => text('创建', 'Create');
  String createFailed(Object error) =>
      text('创建失败：$error', 'Create failed: $error');
  String get playlistCreated => text('播放列表已创建', 'Playlist created');
  String get songListCreated => text('歌单已创建', 'Playlist created');
  String get clearAll => text('清空全部', 'Clear all');
  String get clearAllDownloads => text('清空全部下载', 'Clear all downloads');
  String get clearAllDownloadsMessage => text(
    '确定要删除所有下载任务吗？此操作不可撤销。',
    'Delete all download tasks? This cannot be undone.',
  );
  String get confirm => text('确定', 'OK');
  String get noDownloads => text('暂无下载', 'No downloads yet');
  String get downloadingSection => text('进行中', 'In Progress');
  String get completedSection => text('已完成', 'Completed');
  String downloadingStatus(int percent) =>
      text('下载中 $percent%', 'Downloading $percent%');
  String get completedStatus => text('已完成', 'Completed');
  String get failedStatus => text('失败', 'Failed');
  String get pendingStatus => text('等待中', 'Pending');
  String get pausedStatus => text('已暂停', 'Paused');
  String get delete => text('删除', 'Delete');
  String get resume => text('继续', 'Resume');
  String get queueTitle => text('播放队列', 'Queue');
  String get queueEmpty => text('播放队列为空', 'Queue is empty');
  String get playHistoryTitle => text('播放历史', 'Playback History');
  String get playHistoryLoadFailed =>
      text('加载播放历史失败', 'Failed to load playback history');
  String get playHistoryEmpty => text('暂无播放历史', 'No playback history yet');
  String get justNow => text('刚刚', 'Just now');
  String minutesAgo(int minutes) => text('$minutes分钟前', '$minutes min ago');
  String hoursAgo(int hours) => text('$hours小时前', '$hours h ago');
  String get yesterday => text('昨天', 'Yesterday');
  String daysAgo(int days) => text('$days天前', '$days d ago');
  String get searchLyrics => text('搜索歌词', 'Search Lyrics');
  String get artist => text('歌手', 'Artist');
  String get songTitle => text('歌曲名', 'Song title');
  String get search => text('搜索', 'Search');
  String get lyricsSearchHint =>
      text('输入歌手和歌曲名进行搜索', 'Enter artist and song title to search');
  String lyricsSearchFailed(Object error) =>
      text('搜索失败: $error', 'Search failed: $error');
  String get noLyricsFound => text('未找到歌词', 'No lyrics found');
  String get noLyrics => text('暂无歌词', 'No lyrics');
  String lyricsCandidateTitle({
    required bool isSynced,
    required int lineCount,
  }) {
    final type =
        isSynced ? text('[同步] ', '[Synced] ') : text('[纯文本] ', '[Plain] ');
    return '$type${text('$lineCount 行', '$lineCount lines')}';
  }

  String get use => text('使用', 'Use');
  String get lyricsReplaced => text('歌词已替换', 'Lyrics replaced');
  String lyricsReplaceFailed(Object error) =>
      text('替换失败: $error', 'Replace failed: $error');
  String get more => text('更多', 'More');
  String get moreActions => text('更多操作', 'More actions');
  String get addToPlaylist => text('添加到播放列表', 'Add to Playlist');
  String get addToPlaylistShort => text('添加到歌单', 'Add to Playlist');
  String get playAll => text('播放全部', 'Play All');
  String get noTrackPlaying => text('未播放', 'Not playing');
  String get favorite => text('收藏', 'Favorite');
  String get unfavorite => text('取消收藏', 'Unfavorite');
  String get download => text('下载', 'Download');
  String get downloadSong => text('下载歌曲', 'Download Song');
  String get downloaded => text('已下载', 'Downloaded');
  String get checking => text('检查中', 'Checking');
  String downloadStarted(String title) =>
      text('已开始下载: $title', 'Download started: $title');
  String getPlaylistFailed(Object error) =>
      text('获取播放列表失败: $error', 'Failed to load playlists: $error');
  String songListLoadFailed(Object error) =>
      text('获取歌单失败: $error', 'Failed to load playlists: $error');
  String get noPlaylistCreateFirst =>
      text('暂无播放列表，请先创建一个。', 'No playlists yet. Create one first.');
  String get noSongListCreateFirst =>
      text('暂无歌单，请先创建一个歌单。', 'No playlists yet. Create one first.');
  String addedToPlaylist(String name) =>
      text('已添加到「$name」', 'Added to "$name"');
  String addFailed(Object error) => text('添加失败: $error', 'Add failed: $error');
  String get createAndAdd => text('创建并添加', 'Create and Add');
  String createdAndAdded(String name) =>
      text('已创建「$name」并添加歌曲', 'Created "$name" and added the song');
  String get topSongs => text('热门歌曲', 'Top Songs');
  String get topSongsLoadFailed => text('无法加载热门歌曲', 'Failed to load top songs');
  String get noTopSongs => text('暂无热门歌曲', 'No top songs yet');
  String get albumsLoadFailed => text('无法加载专辑', 'Failed to load albums');
  String get editName => text('编辑名称', 'Edit name');
  String get editPlaylist => text('编辑播放列表', 'Edit Playlist');
  String get editSongList => text('编辑歌单', 'Edit Playlist');
  String get deletePlaylist => text('删除播放列表', 'Delete Playlist');
  String get deleteSongList => text('删除歌单', 'Delete Playlist');
  String get save => text('保存', 'Save');
  String updateFailed(Object error) =>
      text('更新失败：$error', 'Update failed: $error');
  String get playlistUpdated => text('播放列表已更新', 'Playlist updated');
  String get songListUpdated => text('歌单已更新', 'Playlist updated');
  String get deleteCannotUndo =>
      text('删除后无法恢复，确定继续吗？', 'This cannot be undone. Continue?');
  String deleteFailed(Object error) =>
      text('删除失败：$error', 'Delete failed: $error');
  String get playlistDeleted => text('播放列表已删除', 'Playlist deleted');
  String get songListDeleted => text('歌单已删除', 'Playlist deleted');
  String get adjustLyrics => text('调整歌词', 'Adjust Lyrics');
  String get adjustLyricsDescription =>
      text('微调歌词与歌曲进度的同步', 'Fine-tune lyrics timing');
  String get switchLyrics => text('切换歌词', 'Switch Lyrics');
  String get switchLyricsDescription =>
      text('重新搜索并替换当前歌词', 'Search again and replace current lyrics');
  String get lyricsCalibration => text('歌词校准', 'Lyrics Calibration');
  String get delayHalfSecond => text('延后 0.5s', 'Delay 0.5s');
  String get delayTenthSecond => text('延后 0.1s', 'Delay 0.1s');
  String get advanceTenthSecond => text('提前 0.1s', 'Advance 0.1s');
  String get advanceHalfSecond => text('提前 0.5s', 'Advance 0.5s');
  String get reset => text('重置', 'Reset');
  String get album => text('专辑', 'Album');
  String get unknownAlbum => text('未知专辑', 'Unknown album');
  String get unknownArtist => text('未知歌手', 'Unknown artist');
  String get publicDownloadDirectory =>
      text('公开下载目录', 'Public downloads folder');
  String get privateAppDirectory => text('应用私有目录', 'App private folder');
  String get sequentialPlay => text('顺序播放', 'Sequential');
  String get shufflePlay => text('随机播放', 'Shuffle');
  String get repeatOne => text('单曲循环', 'Repeat One');
  String get repeatAll => text('列表循环', 'Repeat All');
  String get noLyricsOffset => text('当前无偏移', 'No lyrics offset');
  String lyricsAdvanced(String seconds) =>
      text('歌词提前 $seconds 秒', 'Lyrics advanced by ${seconds}s');
  String lyricsDelayed(String seconds) =>
      text('歌词延后 $seconds 秒', 'Lyrics delayed by ${seconds}s');

  String get settingsTitle => settingsTab;
  String get serverInfo => text('服务器信息', 'Server');
  String get loading => text('加载中...', 'Loading...');
  String loadFailed(Object error) =>
      text('加载失败: $error', 'Load failed: $error');
  String get noServer => text('未连接服务器', 'No server connected');
  String get serverAddress => text('服务器地址', 'Server URL');
  String get username => text('用户名', 'Username');
  String get password => text('密码', 'Password');
  String get appearance => text('外观', 'Appearance');
  String get appLanguage => text('界面语言', 'Language');
  String get followSystem => text('跟随系统', 'System');
  String get chinese => text('中文', 'Chinese');
  String get english => text('English', 'English');
  String get themeMode => text('主题模式', 'Theme');
  String get lightTheme => text('浅色', 'Light');
  String get darkTheme => text('深色', 'Dark');
  String get downloadsAndCache => text('下载与缓存', 'Downloads & Cache');
  String get downloadDirectory => text('下载目录', 'Download Folder');
  String get copyPath => text('复制路径', 'Copy path');
  String get downloadDirectoryCopied =>
      text('下载目录已复制', 'Download folder copied');
  String get clearImageCache => text('清除图片缓存', 'Clear image cache');
  String get cacheCleared => text('缓存已清除', 'Cache cleared');
  String get downloadManager => text('下载管理', 'Downloads');
  String get diagnostics => text('诊断与反馈', 'Diagnostics');
  String get diagnosticLogging => text('诊断日志', 'Diagnostic logging');
  String get diagnosticLoggingDescription => text(
    '遇到问题时打开，复现后将日志文件路径反馈给开发者。',
    'Turn this on to capture logs, reproduce the issue, then send the log path to the developer.',
  );
  String get exportDiagnosticLog => text('导出日志', 'Export diagnostic log');
  String get exportDiagnosticLogDescription => text(
    '将当前诊断日志导出到下载目录，方便反馈问题。',
    'Export the current diagnostic log to the downloads folder for sharing.',
  );
  String get noDiagnosticLogToExport =>
      text('暂无可导出的诊断日志', 'No diagnostic log available to export');
  String diagnosticLogExported(String path) =>
      text('日志已导出到：$path', 'Diagnostic log exported to: $path');
  String diagnosticLogExportFailed(Object error) =>
      text('导出日志失败：$error', 'Failed to export diagnostic log: $error');
  String get account => text('账号', 'Account');
  String get logout => text('退出登录', 'Log out');
  String get about => text('关于', 'About');
  String get version => text('版本 1.0.0-dev', 'Version 1.0.0-dev');
  String get projectInfo => text('项目信息', 'Project Info');

  String get enterServerAddress =>
      text('请输入服务器地址', 'Please enter the server URL');
  String get serverAddressProtocolRequired => text(
    '地址必须以 http:// 或 https:// 开头',
    'The URL must start with http:// or https://',
  );
  String get enterUsername => text('请输入用户名', 'Please enter your username');
  String get enterPassword => text('请输入密码', 'Please enter your password');
  String get connect => text('连接', 'Connect');
  String appErrorMessage(AppError error) {
    final detail = error.message;
    return switch (error.code) {
      AppErrorCode.connectionTimeout => text(
        '连接超时，请检查服务器地址是否可访问',
        'Connection timed out. Check whether the server URL is reachable.',
      ),
      AppErrorCode.receiveTimeout => text(
        '服务器响应超时，请稍后重试',
        'The server took too long to respond. Try again later.',
      ),
      AppErrorCode.networkConnectivity => text(
        '无法连接到服务器，请检查网络和服务器地址',
        'Could not connect to the server. Check your network and server URL.',
      ),
      AppErrorCode.sslCertificate => text(
        'SSL 证书验证失败，请检查服务器证书配置',
        'SSL certificate verification failed. Check the server certificate.',
      ),
      AppErrorCode.invalidCredentials => text(
        '用户名或密码错误',
        'Incorrect username or password.',
      ),
      AppErrorCode.userNotAuthorized => text(
        '该用户没有访问权限',
        'This user is not authorized.',
      ),
      AppErrorCode.authenticationFailed => text(
        '认证失败，请检查用户名和密码',
        'Authentication failed. Check your username and password.',
      ),
      AppErrorCode.serverError => _errorWithDetail(
        zh: '服务器错误',
        en: 'Server error',
        detail: detail,
      ),
      AppErrorCode.connectionFailed => _errorWithDetail(
        zh: '连接失败',
        en: 'Connection failed',
        detail: detail,
      ),
      AppErrorCode.downloadCancelled => text('下载已取消', 'Download cancelled'),
      AppErrorCode.downloadFileMissingOrInvalid => text(
        '下载文件缺失或无效',
        'Downloaded file is missing or invalid.',
      ),
      AppErrorCode.downloadFileMissing => text(
        '下载文件不存在',
        'Downloaded file does not exist.',
      ),
      AppErrorCode.downloadFileEmpty => text(
        '下载文件为空',
        'Downloaded file is empty.',
      ),
      AppErrorCode.downloadFileSizeMismatch => text(
        '下载文件大小不匹配',
        'Downloaded file size mismatch.',
      ),
      AppErrorCode.unknown => _errorWithDetail(
        zh: '未知错误',
        en: 'Unknown error',
        detail: detail,
      ),
    };
  }

  String errorMessageFromStorageValue(String? value) {
    final error = AppError.fromStorageValue(value);
    if (error == null) {
      return value ?? failedStatus;
    }
    return appErrorMessage(error);
  }

  String _errorWithDetail({
    required String zh,
    required String en,
    String? detail,
  }) {
    if (detail == null || detail.isEmpty) {
      return text(zh, en);
    }
    return text('$zh：$detail', '$en: $detail');
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    final languageCode = locale.languageCode.toLowerCase();
    return languageCode == 'zh' || languageCode == 'en';
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
