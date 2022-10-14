#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
RUST_DIR="$SCRIPT_DIR/.."
BUILD_SCRIPT_PATH="$RUST_DIR/../subscript-compiler/scripts/build.sh"
WORKING_DIR="$RUST_DIR/.."

cd $WORKING_DIR

watchexec --exts scss,ss --ignore target/ --ignore node_modules/ -- "$BUILD_SCRIPT_PATH && cd $RUST_DIR && cargo build && time cargo build && echo '\n==reloaded==\n'"


