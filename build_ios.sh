#!/usr/bin/env bash
# Build an unsigned ARM64 iOS dynamic library on macOS with Xcode installed.
set -euo pipefail
cd "$(dirname "$0")"
if ! command -v xcrun >/dev/null 2>&1; then
  echo 'ERROR: xcrun / iPhoneOS SDK not available. Build on macOS with Xcode.' >&2
  exit 2
fi
SDK="$(xcrun --sdk iphoneos --show-sdk-path)"
CLANG="$(xcrun --sdk iphoneos --find clang)"
mkdir -p build
EXTRA_CFLAGS=()
if [[ "${DLS_ENABLE_EXPERIMENTAL_CLOCK:-0}" == "1" ]]; then
  EXTRA_CFLAGS+=( -DDLS_ENABLE_EXPERIMENTAL_CLOCK=1 )
fi
"$CLANG" \
  -target arm64-apple-ios13.0 -isysroot "$SDK" \
  -fobjc-arc -fobjc-weak -fblocks -O2 ${EXTRA_CFLAGS+"${EXTRA_CFLAGS[@]}"} \
  -dynamiclib -Wl,-install_name,@rpath/DLSMatchMenu.dylib \
  -framework Foundation -framework UIKit -framework QuartzCore -framework CoreGraphics \
  source/DLSFloatingMenu.m source/DLSGameBridge.m \
  -o build/DLSMatchMenu.dylib
file build/DLSMatchMenu.dylib
printf '%s\n' 'Build complete: build/DLSMatchMenu.dylib (unsigned; gameplay/anti bridge not connected)'
