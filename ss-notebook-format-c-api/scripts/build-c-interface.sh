set -e

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# BASICS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# CRATE NAME
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
CRATE_AR_ARCHIVE_NAME="libss_notebook_format_c_api.a"

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# FFI DIRS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
OUTOUT_DIR="$SCRIPT_DIR/../ffi"
RUST_PROJECT_DIR="$SCRIPT_DIR/.."
RUST_TARGET_DIR="$SCRIPT_DIR/../../target"
SWIFT_C_INCLUDE_DIR="$OUTOUT_DIR/include"
SWIFT_C_IOS_LIB_DIR="$OUTOUT_DIR/IOS/lib"
SWIFT_C_MACOS_LIB_DIR="$OUTOUT_DIR/MacOS/lib"
SWIFT_C_CATALYST_LIB_DIR="$OUTOUT_DIR/Catalyst/lib"
SWIFT_INCLUDE_HEADER_FILE_PATH="$SWIFT_C_INCLUDE_DIR/ss-notebook-format.h"

# We (Maybe) need the SDK Root
export SDKROOT=`xcrun --sdk macosx --show-sdk-path`

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# BUILD
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
cd $RUST_PROJECT_DIR

cargo build --release --target aarch64-apple-ios
cargo build --release --target x86_64-apple-darwin
cbindgen --config cbindgen.toml --output $SWIFT_INCLUDE_HEADER_FILE_PATH

# cargo +nightly build -Z build-std --release --lib --target aarch64-apple-ios-macabi

# TODO - GET THIS WORKING:
# cargo +nightly build -Z build-std --release --lib --target x86_64-apple-ios-macabi

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# BUILD - POST-PROCESSING
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
if [ ! -f $OUTOUT_DIR ]
then
	mkdir -p $OUTOUT_DIR
fi
if [ ! -f $SWIFT_C_INCLUDE_DIR ]
then
	mkdir -p $SWIFT_C_INCLUDE_DIR
fi
if [ ! -f $SWIFT_C_IOS_LIB_DIR ]
then
	mkdir -p $SWIFT_C_IOS_LIB_DIR
fi
if [ ! -f $SWIFT_C_CATALYST_LIB_DIR ]
then
	mkdir -p $SWIFT_C_CATALYST_LIB_DIR
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
# Catalyst
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

CATALYST_STATIC_LIB_SRC="$RUST_TARGET_DIR/x86_64-apple-ios-macabi/release/$CRATE_AR_ARCHIVE_NAME"
CATALYST_STATIC_LIB_DEST="$SWIFT_C_CATALYST_LIB_DIR/$CRATE_AR_ARCHIVE_NAME"
if [ ! -f $CATALYST_STATIC_LIB_DEST ]
then
	ln -s $CATALYST_STATIC_LIB_SRC $CATALYST_STATIC_LIB_DEST
fi

# lipo -create -output libs/my-rust-library-maccatalyst.a \
# 	../target/aarch64-apple-ios-macabi/release/libmy-rust-library.a \
# 	target/x86_64-apple-ios-macabi/release/libmy-rust-library.a

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# IOS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
IOS_STATIC_LIB_SRC="$RUST_TARGET_DIR/aarch64-apple-ios/release/$CRATE_AR_ARCHIVE_NAME"
IOS_STATIC_LIB_DEST="$SWIFT_C_IOS_LIB_DIR/$CRATE_AR_ARCHIVE_NAME"
if [ ! -f $IOS_STATIC_LIB_DEST ]
then
	ln -s $IOS_STATIC_LIB_SRC $IOS_STATIC_LIB_DEST
fi

