set -e

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# BASICS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# CRATE NAME
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
CRATE_AR_ARCHIVE_NAME="libsubscript_app_rs.a"

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# FFI DIRS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
SWIFT_FFI_DIR="$SCRIPT_DIR/../../ffi"
RUST_PROJECT_DIR="$SCRIPT_DIR/.."
RUST_TARGET_DIR="$SCRIPT_DIR/../../../../target"
SWIFT_C_INCLUDE_DIR="$SWIFT_FFI_DIR/include"
SWIFT_C_IOS_LIB_DIR="$SWIFT_FFI_DIR/IOS/lib"
SWIFT_C_MACOS_LIB_DIR="$SWIFT_FFI_DIR/MacOS/lib"
SWIFT_INCLUDE_HEADER_FILE_PATH="$SWIFT_C_INCLUDE_DIR/ffi-bridge.h"

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# BUILD
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
cd $RUST_PROJECT_DIR

cargo build --release --target aarch64-apple-ios
cargo build --release --target x86_64-apple-darwin
cbindgen --lang c --output $SWIFT_INCLUDE_HEADER_FILE_PATH

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# BUILD - POST-PROCESSING
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
if [ ! -f $SWIFT_FFI_DIR ]
then
	mkdir -p $SWIFT_FFI_DIR
fi
if [ ! -f $SWIFT_C_INCLUDE_DIR ]
then
	mkdir -p $SWIFT_C_INCLUDE_DIR
fi
if [ ! -f $SWIFT_C_IOS_LIB_DIR ]
then
	mkdir -p $SWIFT_C_IOS_LIB_DIR
fi
if [ ! -f $SWIFT_C_MACOS_LIB_DIR ]
then
	mkdir -p $SWIFT_C_MACOS_LIB_DIR
fi

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# MAC-OS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
MACOS_STATIC_LIB_SRC="$RUST_TARGET_DIR/x86_64-apple-darwin/release/$CRATE_AR_ARCHIVE_NAME"
MACOS_STATIC_LIB_DEST="$SWIFT_C_MACOS_LIB_DIR/$CRATE_AR_ARCHIVE_NAME"
if [ ! -f $MACOS_STATIC_LIB_DEST ]
then
	ln -s $MACOS_STATIC_LIB_SRC $MACOS_STATIC_LIB_DEST
fi

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# IOS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
IOS_STATIC_LIB_SRC="$RUST_TARGET_DIR/aarch64-apple-ios/release/$CRATE_AR_ARCHIVE_NAME"
IOS_STATIC_LIB_DEST="$SWIFT_C_IOS_LIB_DIR/$CRATE_AR_ARCHIVE_NAME"
if [ ! -f $IOS_STATIC_LIB_DEST ]
then
	ln -s $IOS_STATIC_LIB_SRC $IOS_STATIC_LIB_DEST
fi
