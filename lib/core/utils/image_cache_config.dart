import 'package:flutter/painting.dart';

/// 配置图片缓存限制，避免大量封面图占用过多内存
class ImageCacheConfig {
  static void configure() {
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;
  }
}
