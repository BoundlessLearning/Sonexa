import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/features/library/presentation/pages/albums_tab.dart';
import 'package:sonexa/features/library/presentation/pages/artists_tab.dart';
import 'package:sonexa/features/library/presentation/pages/playlists_tab.dart';
import 'package:sonexa/features/library/presentation/pages/songs_tab.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.libraryTab),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.songs, icon: const Icon(Icons.music_note_rounded)),
              Tab(text: l10n.albums, icon: const Icon(Icons.album_rounded)),
              Tab(text: l10n.artists, icon: const Icon(Icons.person_rounded)),
              Tab(
                text: l10n.playlists,
                icon: const Icon(Icons.queue_music_rounded),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [SongsTab(), AlbumsTab(), ArtistsTab(), PlaylistsTab()],
        ),
      ),
    );
  }
}
