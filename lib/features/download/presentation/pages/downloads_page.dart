import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sonexa/core/localization/app_localizations.dart';
import 'package:sonexa/features/download/domain/entities/download_task.dart';
import 'package:sonexa/features/download/presentation/providers/download_provider.dart';

/// 下载管理页 — 展示所有下载任务，支持取消、重试、删除操作
class DownloadsPage extends ConsumerWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadListAsync = ref.watch(downloadListProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.downloadManager),
        actions: [
          // 仅当有下载任务时显示全部删除按钮
          downloadListAsync.whenOrNull(
                data:
                    (tasks) =>
                        tasks.isNotEmpty
                            ? IconButton(
                              icon: const Icon(Icons.delete_sweep_rounded),
                              tooltip: l10n.clearAll,
                              onPressed: () => _confirmDeleteAll(context, ref),
                            )
                            : null,
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: downloadListAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => _ErrorView(
              error: error.toString(),
              onRetry: () => ref.invalidate(downloadListProvider),
            ),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const _EmptyView();
          }
          return _DownloadListView(tasks: tasks);
        },
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(l10n.clearAllDownloads),
            content: Text(l10n.clearAllDownloadsMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  ref.read(downloadManagerProvider).valueOrNull?.deleteAll();
                  Navigator.of(ctx).pop();
                },
                child: Text(l10n.confirm),
              ),
            ],
          ),
    );
  }
}

// ── 空状态 ─────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.download_rounded,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).noDownloads,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 错误状态 ───────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: colorScheme.error),
          const SizedBox(height: 16),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    );
  }
}

// ── 下载列表视图 ───────────────────────────────────────────────
class _DownloadListView extends ConsumerWidget {
  const _DownloadListView({required this.tasks});

  final List<DownloadTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // 将下载任务分为活跃（下载中/等待中/失败）和已完成两组
    final activeTasks =
        tasks.where((t) => t.status != DownloadStatus.completed).toList();
    final completedTasks =
        tasks.where((t) => t.status == DownloadStatus.completed).toList();

    return ListView(
      children: [
        // ── 活跃下载 ──────────────────────────────────────────
        if (activeTasks.isNotEmpty) ...[
          _SectionHeader(
            title: l10n.downloadingSection,
            count: activeTasks.length,
          ),
          ...activeTasks.map(
            (task) => _DownloadTaskTile(key: ValueKey(task.id), task: task),
          ),
        ],

        // ── 已完成 ────────────────────────────────────────────
        if (completedTasks.isNotEmpty) ...[
          _SectionHeader(
            title: l10n.completedSection,
            count: completedTasks.length,
          ),
          ...completedTasks.map(
            (task) => Dismissible(
              key: ValueKey('dismiss-${task.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                color: Theme.of(context).colorScheme.error,
                child: const Icon(Icons.delete_rounded, color: Colors.white),
              ),
              onDismissed: (_) {
                ref.read(downloadManagerProvider).valueOrNull?.delete(task.id);
              },
              child: _DownloadTaskTile(task: task),
            ),
          ),
        ],

        const SizedBox(height: 32),
      ],
    );
  }
}

// ── 分组标题 ───────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        '$title ($count)',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

// ── 单个下载任务项 ─────────────────────────────────────────────
class _DownloadTaskTile extends ConsumerWidget {
  const _DownloadTaskTile({super.key, required this.task});

  final DownloadTask task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: _buildStatusIcon(colorScheme),
          title: Text(task.title, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '${task.artist} · ${_statusText(l10n)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: _buildActionButton(context, ref, colorScheme),
        ),
        // 下载中状态显示进度条
        if (task.status == DownloadStatus.downloading)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(value: task.progress, minHeight: 2),
          ),
      ],
    );
  }

  Widget _buildStatusIcon(ColorScheme colorScheme) {
    switch (task.status) {
      case DownloadStatus.downloading:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            value: task.progress > 0 ? task.progress : null,
            strokeWidth: 2.5,
          ),
        );
      case DownloadStatus.completed:
        return Icon(Icons.check_circle_rounded, color: colorScheme.primary);
      case DownloadStatus.failed:
        return Icon(Icons.error_rounded, color: colorScheme.error);
      case DownloadStatus.pending:
        return Icon(
          Icons.hourglass_empty_rounded,
          color: colorScheme.onSurfaceVariant,
        );
      case DownloadStatus.paused:
        return Icon(
          Icons.pause_circle_rounded,
          color: colorScheme.onSurfaceVariant,
        );
    }
  }

  String _statusText(AppLocalizations l10n) {
    switch (task.status) {
      case DownloadStatus.downloading:
        final percent = (task.progress * 100).toInt();
        return l10n.downloadingStatus(percent);
      case DownloadStatus.completed:
        return l10n.completedStatus;
      case DownloadStatus.failed:
        return l10n.errorMessageFromStorageValue(task.error);
      case DownloadStatus.pending:
        return l10n.pendingStatus;
      case DownloadStatus.paused:
        return l10n.pausedStatus;
    }
  }

  Widget? _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
  ) {
    switch (task.status) {
      case DownloadStatus.downloading:
      case DownloadStatus.pending:
        return IconButton(
          icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
          tooltip: AppLocalizations.of(context).cancel,
          onPressed:
              () => ref
                  .read(downloadManagerProvider)
                  .valueOrNull
                  ?.cancel(task.id),
        );
      case DownloadStatus.completed:
        return IconButton(
          icon: Icon(Icons.delete_outline_rounded, color: colorScheme.error),
          tooltip: AppLocalizations.of(context).delete,
          onPressed:
              () => ref
                  .read(downloadManagerProvider)
                  .valueOrNull
                  ?.delete(task.id),
        );
      case DownloadStatus.failed:
        return IconButton(
          icon: Icon(Icons.refresh_rounded, color: colorScheme.primary),
          tooltip: AppLocalizations.of(context).retry,
          onPressed:
              () =>
                  ref.read(downloadManagerProvider).valueOrNull?.retry(task.id),
        );
      case DownloadStatus.paused:
        return IconButton(
          icon: Icon(Icons.play_arrow_rounded, color: colorScheme.primary),
          tooltip: AppLocalizations.of(context).resume,
          onPressed:
              () => ref
                  .read(downloadManagerProvider)
                  .valueOrNull
                  ?.resume(task.id),
        );
    }
  }
}
