#!/bin/sh
set -eu
ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"
mkdir -p .build/model-check-cache
xcrun swiftc -module-cache-path .build/model-check-cache \
    Sources/OpenNookStarter/Music/ArtworkPalette.swift Tests/ArtworkPaletteChecks.swift \
    -o .build/ArtworkPaletteChecks
.build/ArtworkPaletteChecks
