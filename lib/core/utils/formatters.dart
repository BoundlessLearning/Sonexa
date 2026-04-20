import 'dart:math' as math;

import 'package:intl/intl.dart';

String formatDuration(int seconds) {
  final duration = Duration(seconds: seconds);
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final remainingSeconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  return '${duration.inMinutes}:${remainingSeconds.toString().padLeft(2, '0')}';
}

String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  }

  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  final exponent = math.min(
    bytes == 0 ? 0 : (math.log(bytes) / math.log(1024)).floor(),
    units.length - 1,
  );
  final size = bytes / math.pow(1024, exponent);
  final fractionDigits = size >= 10 || exponent == 0 ? 0 : 1;

  return '${size.toStringAsFixed(fractionDigits)} ${units[exponent]}';
}

String formatDate(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}
