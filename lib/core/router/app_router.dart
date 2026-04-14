import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ohmymusic/core/theme/page_transitions.dart';
import 'package:ohmymusic/features/auth/presentation/pages/login_page.dart';
import 'package:ohmymusic/features/auth/presentation/providers/auth_provider.dart';
import 'package:ohmymusic/features/download/presentation/pages/downloads_page.dart';
import 'package:ohmymusic/features/home/presentation/pages/home_page.dart';
import 'package:ohmymusic/features/home/presentation/pages/song_list_page.dart';
import 'package:ohmymusic/features/home/presentation/providers/home_provider.dart';
import 'package:ohmymusic/features/library/presentation/pages/album_detail_page.dart';
import 'package:ohmymusic/features/library/presentation/pages/artist_detail_page.dart';
import 'package:ohmymusic/features/library/presentation/pages/filtered_song_list_page.dart';
import 'package:ohmymusic/features/library/presentation/pages/library_page.dart';
import 'package:ohmymusic/features/library/presentation/pages/playlist_detail_page.dart';
import 'package:ohmymusic/features/lyrics/presentation/pages/lyrics_search_page.dart';
import 'package:ohmymusic/features/player/presentation/pages/now_playing_page.dart';
import 'package:ohmymusic/features/player/presentation/pages/play_history_page.dart';
import 'package:ohmymusic/features/player/presentation/pages/queue_page.dart';
import 'package:ohmymusic/features/player/presentation/widgets/mini_player.dart';
import 'package:ohmymusic/features/search/presentation/pages/search_page.dart';
import 'package:ohmymusic/features/settings/presentation/pages/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // watch activeServerProvider 以确保登录/登出时路由自动刷新
  final activeServer = ref.watch(activeServerProvider);

  return GoRouter(
    // refreshListenable 不再需要 — 通过 ref.watch 自动重建 GoRouter 实例
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';

      // 仍在加载中 — 不做重定向，等待数据就绪后 GoRouter 会重新创建
      if (activeServer.isLoading) {
        return null;
      }

      final hasActiveServer = activeServer.asData?.value != null;

      if (!hasActiveServer && !isLoginRoute) {
        return '/login';
      }

      if (hasActiveServer && isLoginRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // 首页
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          // 音乐库
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryPage(),
                routes: [
                  GoRoute(
                    path: 'album/:id',
                    builder: (context, state) => AlbumDetailPage(
                      albumId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'artist/:id',
                    builder: (context, state) => ArtistDetailPage(
                      artistId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: 'playlist/:id',
                    builder: (context, state) => PlaylistDetailPage(
                      playlistId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // 搜索
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchPage(),
              ),
            ],
          ),
          // 设置
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/now-playing',
        pageBuilder: (context, state) => slideUpTransition(
          key: state.pageKey,
          child: const NowPlayingPage(),
        ),
      ),
      GoRoute(
        path: '/queue',
        pageBuilder: (context, state) => slideUpTransition(
          key: state.pageKey,
          child: const QueuePage(),
        ),
      ),
      GoRoute(
        path: '/history',
        pageBuilder: (context, state) => fadeTransition(
          key: state.pageKey,
          child: const PlayHistoryPage(),
        ),
      ),
      GoRoute(
        path: '/downloads',
        pageBuilder: (context, state) => fadeTransition(
          key: state.pageKey,
          child: const DownloadsPage(),
        ),
      ),
      GoRoute(
        path: '/album-songs/:id',
        pageBuilder: (context, state) => fadeTransition(
          key: ValueKey(
            'album-songs-${state.pathParameters['id']}-${state.uri.query}',
          ),
          child: FilteredSongListPage.album(
            albumId: state.pathParameters['id']!,
            title: state.uri.queryParameters['title'] ?? '专辑歌曲',
          ),
        ),
      ),
      GoRoute(
        path: '/artist-songs',
        pageBuilder: (context, state) => fadeTransition(
          key: ValueKey('artist-songs-${state.uri.query}'),
          child: FilteredSongListPage.artist(
            artistId: state.uri.queryParameters['artistId'] ?? '',
            artistName: state.uri.queryParameters['artistName'] ?? '',
            title: state.uri.queryParameters['title'] ?? '歌手歌曲',
          ),
        ),
      ),
      GoRoute(
        path: '/random-songs',
        pageBuilder: (context, state) => fadeTransition(
          key: state.pageKey,
          child: SongListPage(
            title: '随机推荐',
            provider: homeRandomSongsProvider,
            emptyMessage: '暂无推荐',
          ),
        ),
      ),
      GoRoute(
        path: '/starred-songs',
        pageBuilder: (context, state) => fadeTransition(
          key: state.pageKey,
          child: SongListPage(
            title: '我的收藏',
            provider: starredSongsProvider,
            emptyMessage: '暂无收藏歌曲',
          ),
        ),
      ),
      GoRoute(
        path: '/similar-songs',
        pageBuilder: (context, state) => fadeTransition(
          key: state.pageKey,
          child: SongListPage(
            title: '猜你喜欢',
            provider: similarSongsProvider,
            emptyMessage: '暂无相似推荐',
          ),
        ),
      ),
      GoRoute(
        path: '/lyrics-search',
        pageBuilder: (context, state) {
          final queryParams = state.uri.queryParameters;
          return fadeTransition(
            key: state.pageKey,
            child: LyricsSearchPage(
              songId: queryParams['songId'] ?? '',
              artist: queryParams['artist'] ?? '',
              title: queryParams['title'] ?? '',
            ),
          );
        },
      ),
    ],
  );
});

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(child: navigationShell),
          const MiniPlayer(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_music),
            label: '音乐库',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '搜索',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
