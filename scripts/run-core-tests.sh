#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
BUILD_DIR="${TMPDIR:-/tmp}/my-gourmet-ranking-core-tests"

mkdir -p "$BUILD_DIR"
swiftc \
  "$ROOT_DIR/MyGourmetRanking/Models.swift" \
  "$ROOT_DIR/MyGourmetRanking/RankingEngine.swift" \
  "$ROOT_DIR/MyGourmetRanking/ProAccessPolicy.swift" \
  "$ROOT_DIR/Tests/CoreLogicTests/main.swift" \
  -o "$BUILD_DIR/core-logic-tests"

"$BUILD_DIR/core-logic-tests"
