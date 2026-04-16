import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:sonexa/features/lyrics/data/lyrics_text_normalizer.dart';
import 'package:sonexa/features/lyrics/domain/entities/lyrics.dart';

void main() {
  group('LyricsTextNormalizer', () {
    test('repairs utf8 text decoded as Windows-1252', () {
      final mojibake = String.fromCharCodes(utf8.encode('\u6211\u7231\u4F60'));

      expect(LyricsTextNormalizer.normalize(mojibake), '\u6211\u7231\u4F60');
    });

    test('repairs common smart quote mojibake', () {
      final mojibake = String.fromCharCodes(utf8.encode('It\u2019s alright'));

      expect(LyricsTextNormalizer.normalize(mojibake), 'It\u2019s alright');
    });

    test('keeps normal mixed lyrics unchanged', () {
      const text = '\u6211\u60F3\u548C\u4F60\u4E00\u8D77\u542C\nLet it be';

      expect(LyricsTextNormalizer.normalize(text), text);
    });

    test('detects unusable garbled lyric samples', () {
      expect(
        LyricsTextNormalizer.looksGarbled('\u00C3 \u00C2 \uFFFD \uFFFD'),
        isTrue,
      );
    });

    test('normalizes lyric lines before garbled detection', () {
      final mojibake = String.fromCharCodes(utf8.encode('\u6211\u7231\u4F60'));
      final lines = LyricsTextNormalizer.normalizeLines([
        LyricLine(timeMs: 0, text: mojibake),
      ]);

      expect(lines.single.text, '\u6211\u7231\u4F60');
      expect(LyricsTextNormalizer.linesLookGarbled(lines), isFalse);
    });
  });
}
