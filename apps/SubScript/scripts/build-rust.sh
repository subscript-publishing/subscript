set -e

# TODO

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# BASICS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# CRATE DIRS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
SS_IOS_RUNTIME_RS="$SCRIPT_DIR/../crates/ss-ios-runtime-rs"
SS_MACOS_RUNTIME_RS="$SCRIPT_DIR/../crates/ss-macos-runtime-rs"
SUBSCRIPT_APP_RS="$SCRIPT_DIR/../crates/subscript-app-rs"

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# CRATE - SCRIPT DIRS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
SS_IOS_RUNTIME_RS="$SS_IOS_RUNTIME_RS/scripts/build.sh"
SS_MACOS_RUNTIME_RS="$SS_MACOS_RUNTIME_RS/scripts/build.sh"
SUBSCRIPT_APP_RS="$SUBSCRIPT_APP_RS/scripts/build.sh"

$SS_IOS_RUNTIME_RS
$SS_MACOS_RUNTIME_RS
$SUBSCRIPT_APP_RS

# TODO - CALL OTHER SCRIPTS
echo "TODO - CALL OTHER SCRIPTS"
exit(1)
