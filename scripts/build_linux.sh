#!/bin/bash
# OhMyMusic Linux 构建脚本
# 自动完成: flutter build → 复制 libmpv 及依赖 → patchelf 设置 RPATH
# 用法: ./scripts/build_linux.sh [--release]

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LIBMPV_DIR="$HOME/.local/libmpv/usr/lib/x86_64-linux-gnu"
PATCHELF="$HOME/.local/patchelf/usr/bin/patchelf"

# 解析参数
BUILD_MODE="debug"
if [[ "${1:-}" == "--release" ]]; then
  BUILD_MODE="release"
fi

BUNDLE_DIR="$PROJECT_ROOT/build/linux/x64/$BUILD_MODE/bundle"
BUNDLE_LIB="$BUNDLE_DIR/lib"

# 设置环境变量
export PATH="$PATH:$HOME/flutter/bin:$HOME/.local/bin"
export JAVA_HOME="$HOME/jdk/jdk-21.0.7"
export PKG_CONFIG_PATH="$HOME/.local/gtk3-dev/usr/lib/x86_64-linux-gnu/pkgconfig:$HOME/.local/gtk3-dev/usr/share/pkgconfig"

echo "=== OhMyMusic Linux Build ==="
echo "模式: $BUILD_MODE"
echo "项目: $PROJECT_ROOT"
echo ""

# Step 1: Flutter build
echo "[1/3] 构建 Flutter Linux 应用..."
cd "$PROJECT_ROOT"
if [[ "$BUILD_MODE" == "release" ]]; then
  flutter build linux --release
else
  flutter build linux --debug
fi
echo ""

# Step 2: 复制 libmpv 及依赖
echo "[2/3] 复制 libmpv 及依赖到 bundle..."

# libmpv
cp "$LIBMPV_DIR/libmpv.so.1.107.0" "$BUNDLE_LIB/"
cd "$BUNDLE_LIB"
ln -sf libmpv.so.1.107.0 libmpv.so.1
ln -sf libmpv.so.1 libmpv.so

# liblua5.2
cp "$LIBMPV_DIR/liblua5.2.so.0.0.0" "$BUNDLE_LIB/"
ln -sf liblua5.2.so.0.0.0 liblua5.2.so.0

# libdvdnav
cp "$LIBMPV_DIR/libdvdnav.so.4.2.0" "$BUNDLE_LIB/"
ln -sf libdvdnav.so.4.2.0 libdvdnav.so.4

# libva-wayland
cp "$LIBMPV_DIR/libva-wayland.so.2.700.0" "$BUNDLE_LIB/"
ln -sf libva-wayland.so.2.700.0 libva-wayland.so.2

# libdvdread
cp "$LIBMPV_DIR/libdvdread.so.7" "$BUNDLE_LIB/"

echo "  已复制 5 个库文件"
echo ""

# Step 3: patchelf 设置 RPATH
echo "[3/3] 设置 RPATH (\$ORIGIN) ..."
for so in \
  "$BUNDLE_LIB/libmpv.so.1.107.0" \
  "$BUNDLE_LIB/liblua5.2.so.0.0.0" \
  "$BUNDLE_LIB/libdvdnav.so.4.2.0" \
  "$BUNDLE_LIB/libva-wayland.so.2.700.0" \
  "$BUNDLE_LIB/libdvdread.so.7"; do
  if [[ -f "$so" ]]; then
    "$PATCHELF" --set-rpath '$ORIGIN' "$so"
    echo "  ✓ $(basename "$so")"
  fi
done
echo ""

echo "=== 构建完成 ==="
echo "可执行文件: $BUNDLE_DIR/ohmymusic"
echo "运行: cd $BUNDLE_DIR && ./ohmymusic"
