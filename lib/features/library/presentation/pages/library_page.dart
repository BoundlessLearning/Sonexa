import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ohmymusic/features/library/presentation/pages/albums_tab.dart';
import 'package:ohmymusic/features/library/presentation/pages/artists_tab.dart';
import 'package:ohmymusic/features/library/presentation/pages/playlists_tab.dart';
import 'package:ohmymusic/features/library/presentation/pages/songs_tab.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('音乐库'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '歌曲'),
              Tab(text: '专辑'),
              Tab(text: '艺术家'),
              Tab(
                text: '播放列表',
                icon: Icon(Icons.queue_music),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SongsTab(),
            AlbumsTab(),
            ArtistsTab(),
            PlaylistsTab(),
          ],
        ),
      ),
    );
  }
}
