#!/usr/bin/env bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCSS_INDEX_PATH="$SCRIPT_DIR/../assets/styling/index.scss"
CSS_OUT_PATH="$SCRIPT_DIR/../assets/template/index.css"

sass $SCSS_INDEX_PATH $CSS_OUT_PATH

