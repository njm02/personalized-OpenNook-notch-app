#!/bin/sh
set -eu
ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT_DIR"
mkdir -p .build/model-check-cache
xcrun swiftc -module-cache-path .build/model-check-cache \
    Sources/OpenNookStarter/Widgets/WidgetStore.swift \
    Sources/OpenNookStarter/Widgets/FocusDuration.swift \
    Sources/OpenNookStarter/Calendar/MonthGrid.swift \
    Sources/OpenNookStarter/Music/PlaybackMotion.swift \
    Tests/ModelChecks.swift -o .build/NotchModelChecks
.build/NotchModelChecks
