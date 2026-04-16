import 'dart:convert';

import 'package:sonexa/features/lyrics/domain/entities/lyrics.dart';

class LyricsTextNormalizer {
  const LyricsTextNormalizer._();

  static String normalize(String value) {
    final stripped = _stripBom(value).replaceAll('\u0000', '');
    final repaired = _repairUtf8DecodedAsWindows1252(stripped);
    if (repaired == null) {
      return stripped;
    }

    return _qualityScore(repaired) > _qualityScore(stripped)
        ? repaired
        : stripped;
  }

  static LyricLine normalizeLine(LyricLine line) {
    final normalizedText = normalize(line.text);
    final normalizedTranslation =
        line.translation == null ? null : normalize(line.translation!);
    if (normalizedText == line.text &&
        normalizedTranslation == line.translation) {
      return line;
    }

    return line.copyWith(
      text: normalizedText,
      translation: normalizedTranslation,
    );
  }

  static List<LyricLine> normalizeLines(List<LyricLine> lines) {
    return lines.map(normalizeLine).toList(growable: false);
  }

  static bool looksGarbled(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      return false;
    }

    if (text.contains('\uFFFD')) {
      return true;
    }

    final suspiciousHits =
        _suspiciousPatterns.where((pattern) => text.contains(pattern)).length;
    if (suspiciousHits >= 2) {
      return true;
    }

    final runes = text.runes.toList(growable: false);
    final suspiciousRunes =
        runes.where((rune) => _suspiciousRuneCodes.contains(rune)).length;
    return suspiciousRunes >= 4 && suspiciousRunes / runes.length > 0.08;
  }

  static bool linesLookGarbled(List<LyricLine> lines) {
    final sample = lines
        .take(12)
        .map((line) => '${line.text}\n${line.translation ?? ''}')
        .join('\n');
    return looksGarbled(sample);
  }

  static String _stripBom(String value) {
    var result = value;
    if (result.startsWith('\uFEFF')) {
      result = result.substring(1);
    }
    return result.replaceAll('\u00EF\u00BB\u00BF', '');
  }

  static String? _repairUtf8DecodedAsWindows1252(String value) {
    final bytes = <int>[];
    for (final rune in value.runes) {
      final byte = _windows1252ByteForRune(rune);
      if (byte == null) {
        return null;
      }
      bytes.add(byte);
    }

    try {
      return utf8.decode(bytes, allowMalformed: false);
    } on FormatException {
      return null;
    }
  }

  static int? _windows1252ByteForRune(int rune) {
    if (rune <= 0xFF) {
      return rune;
    }

    return _windows1252ReverseMap[rune];
  }

  static int _qualityScore(String value) {
    var score = 0;
    for (final rune in value.runes) {
      if (rune == 0xFFFD) {
        score -= 50;
      } else if (_suspiciousRuneCodes.contains(rune)) {
        score -= 4;
      } else if (_isCjk(rune)) {
        score += 3;
      } else if (_isReadableAscii(rune)) {
        score += 1;
      }
    }

    for (final pattern in _suspiciousPatterns) {
      if (value.contains(pattern)) {
        score -= 12;
      }
    }

    return score;
  }

  static bool _isCjk(int rune) {
    return (rune >= 0x3400 && rune <= 0x4DBF) ||
        (rune >= 0x4E00 && rune <= 0x9FFF) ||
        (rune >= 0xF900 && rune <= 0xFAFF);
  }

  static bool _isReadableAscii(int rune) {
    return rune == 0x0A ||
        rune == 0x0D ||
        rune == 0x09 ||
        (rune >= 0x20 && rune <= 0x7E);
  }

  static const Map<int, int> _windows1252ReverseMap = {
    0x20AC: 0x80,
    0x201A: 0x82,
    0x0192: 0x83,
    0x201E: 0x84,
    0x2026: 0x85,
    0x2020: 0x86,
    0x2021: 0x87,
    0x02C6: 0x88,
    0x2030: 0x89,
    0x0160: 0x8A,
    0x2039: 0x8B,
    0x0152: 0x8C,
    0x017D: 0x8E,
    0x2018: 0x91,
    0x2019: 0x92,
    0x201C: 0x93,
    0x201D: 0x94,
    0x2022: 0x95,
    0x2013: 0x96,
    0x2014: 0x97,
    0x02DC: 0x98,
    0x2122: 0x99,
    0x0161: 0x9A,
    0x203A: 0x9B,
    0x0153: 0x9C,
    0x017E: 0x9E,
    0x0178: 0x9F,
  };

  static const Set<int> _suspiciousRuneCodes = {
    0x00C2,
    0x00C3,
    0x00C4,
    0x00C5,
    0x00C6,
    0x00C7,
    0x00C8,
    0x00E2,
    0xFFFD,
  };

  static const List<String> _suspiciousPatterns = [
    '\u00C3',
    '\u00C2',
    '\u00E2\u20AC\u2122',
    '\u00E2\u20AC\u0153',
    '\u00E2\u20AC\uFFFD',
    '\u00E2\u20AC\u201C',
    '\u00E2\u20AC\u201D',
    '\u00EF\u00BB\u00BF',
  ];
}
