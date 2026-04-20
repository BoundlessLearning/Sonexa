import 'package:sonexa/features/lyrics/domain/entities/lyrics.dart';

final RegExp _lrcTimestampRegExp = RegExp(
  r'\[(\d{2}):(\d{2})\.?((?:\d{0,3}))\]',
);
final RegExp _lrcMetadataRegExp = RegExp(
  r'^\[(ti|ar|al|by):.*\]$',
  caseSensitive: false,
);

/// 解析标准 LRC 歌词文本。
List<LyricLine> parseLrc(String rawLrc) {
  if (rawLrc.trim().isEmpty) {
    return const [];
  }

  final lines = <LyricLine>[];

  for (final rawLine in rawLrc.split(RegExp(r'\r?\n'))) {
    final line = rawLine.trim();
    if (line.isEmpty || _lrcMetadataRegExp.hasMatch(line)) {
      continue;
    }

    final matches = _lrcTimestampRegExp.allMatches(line).toList();
    if (matches.isEmpty) {
      continue;
    }

    final text = line.replaceAll(_lrcTimestampRegExp, '').trim();
    for (final match in matches) {
      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final fraction = match.group(3) ?? '';
      final fractionMs =
          fraction.isEmpty ? 0 : int.parse(fraction.padRight(3, '0'));
      final timeMs = minutes * 60000 + seconds * 1000 + fractionMs;

      lines.add(LyricLine(timeMs: timeMs, text: text));
    }
  }

  lines.sort((a, b) => a.timeMs.compareTo(b.timeMs));
  return lines;
}
