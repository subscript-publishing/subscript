set -e

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# BASICS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# INPUT OPTIONS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
MACOS_ONLY="NO"
IOS_ONLY="NO"
CATALYST_ONLY="NO"
GEN_HEADER_ONLY="NO"

if [ "$1" = "macos" ] || [ "$1" = "MACOS" ]; then
   MACOS_ONLY="YES"
fi

if [ "$1" = "mac" ] || [ "$1" = "MAC" ]; then
   MACOS_ONLY="YES"
fi

if [ "$1" = "catalyst" ] || [ "$1" = "CATALYST" ]; then
   CATALYST_ONLY="YES"
fi

if [ "$1" = "ios" ] || [ "$1" = "IOS" ]; then
   IOS_ONLY="YES"
fi

if [ "$1" = "HEADER" ] || [ "$1" = "header" ]; then
   GEN_HEADER_ONLY="YES"
fi


#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# CRATE NAME
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
CRATE_AR_ARCHIVE_NAME_SRC="libvectorizable_demo_rs.a"
CRATE_AR_ARCHIVE_NAME_DEST_IOS="libvectorizable_demo_rs.a"
CRATE_AR_ARCHIVE_NAME_DEST_MACOS="libvectorizable_demo_rs.a"
CRATE_AR_ARCHIVE_NAME_DEST_CATALYST="libvectorizable_demo_rs.a"
BINDGEN_HEADER_FILE_NAME="vectorizable-demo.h"

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# FFI DIRS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
OUTOUT_DIR="$SCRIPT_DIR/../ffi"
RUST_PROJECT_DIR="$SCRIPT_DIR/.."
RUST_TARGET_DIR="$SCRIPT_DIR/../../../target"
SWIFT_C_INCLUDE_DIR="$OUTOUT_DIR/include"
SWIFT_C_IOS_LIB_DIR="$OUTOUT_DIR/IOS/lib"
SWIFT_C_MACOS_LIB_DIR="$OUTOUT_DIR/MacOS/lib"
SWIFT_C_CATALYST_LIB_DIR="$OUTOUT_DIR/Catalyst/lib"
SWIFT_INCLUDE_HEADER_FILE_PATH="$SWIFT_C_INCLUDE_DIR/$BINDGEN_HEADER_FILE_NAME"

# We (Maybe) need the SDK Root
# export SDKROOT=`xcrun --sdk macosx --show-sdk-path`

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# INTERNAL HELPER FUNCTIONS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
to_rel_path () {
	WORKING_DIR=$(pwd)
	perl -le 'use File::Spec; print File::Spec->abs2rel(@ARGV)' $1 $WORKING_DIR
}

canonicalize_file_path () {
	perl -MCwd -e 'print Cwd::abs_path shift' $1
}

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# BUILD FUNCTIONS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

build_macos () {
	echo "Building MacOS"
   cargo build --release --target x86_64-apple-darwin
}

build_ios () {
	echo "Building IOS"
   cargo build --release --target aarch64-apple-ios
}

build_catalyst () {
	echo "Building CATALYST: SKIPPED!"
#    cargo +nightly build -Z build-std --release --lib --target x86_64-apple-ios-macabi
}

build_c_header () {
	echo "Building C Header File"
	cbindgen --config cbindgen.toml --output $SWIFT_INCLUDE_HEADER_FILE_PATH
}

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# BUILD
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
cd $RUST_PROJECT_DIR

if [ "$MACOS_ONLY" = "YES" ] && [ "$GEN_HEADER_ONLY" != "YES" ]; then
	build_macos
elif [ "$IOS_ONLY" = "YES" ] && [ "$GEN_HEADER_ONLY" != "YES" ]; then
	build_ios
elif [ "$CATALYST_ONLY" = "YES" ] && [ "$GEN_HEADER_ONLY" != "YES" ]; then
	build_catalyst
elif [ "$GEN_HEADER_ONLY" != "YES" ]; then
	build_macos
	build_ios
	build_catalyst
fi

build_c_header


#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# BUILD - POST-PROCESSING
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
if [ ! -f $OUTOUT_DIR ]; then
	mkdir -p $OUTOUT_DIR
fi

if [ ! -f $SWIFT_C_INCLUDE_DIR ]; then
	mkdir -p $SWIFT_C_INCLUDE_DIR
fi

if [ ! -f $SWIFT_C_IOS_LIB_DIR ]; then
	mkdir -p $SWIFT_C_IOS_LIB_DIR
fi

if [ ! -f $SWIFT_C_CATALYST_LIB_DIR ]; then
	mkdir -p $SWIFT_C_CATALYST_LIB_DIR
fi

if [ ! -f $SWIFT_C_MACOS_LIB_DIR ]; then
	mkdir -p $SWIFT_C_MACOS_LIB_DIR
fi

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# LINK FUNCTIONS
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

link_macos () {
	MACOS_STATIC_LIB_SRC="$RUST_TARGET_DIR/x86_64-apple-darwin/release/$CRATE_AR_ARCHIVE_NAME_SRC"
	MACOS_STATIC_LIB_DEST="$SWIFT_C_MACOS_LIB_DIR/$CRATE_AR_ARCHIVE_NAME_DEST_MACOS"
	if [ ! -f "$MACOS_STATIC_LIB_DEST" ] && [ "$IOS_ONLY" != "YES" ] && [ "$CATALYST_ONLY" != "YES" ]; then
		# NOTE: We want to create symbols links with normalized file paths
		MACOS_STATIC_LIB_SRC=$(canonicalize_file_path $MACOS_STATIC_LIB_SRC)
		MACOS_STATIC_LIB_DEST=$(canonicalize_file_path $MACOS_STATIC_LIB_DEST)
		echo "Creating Symbolic Link [MAC-OS]"
		echo "\t  SRC: $MACOS_STATIC_LIB_SRC"
		echo "\t DEST: $MACOS_STATIC_LIB_DEST"
		ln -s $MACOS_STATIC_LIB_SRC $MACOS_STATIC_LIB_DEST
	fi
}

link_ios () {
	IOS_STATIC_LIB_SRC="$RUST_TARGET_DIR/aarch64-apple-ios/release/$CRATE_AR_ARCHIVE_NAME_SRC"
	IOS_STATIC_LIB_DEST="$SWIFT_C_IOS_LIB_DIR/$CRATE_AR_ARCHIVE_NAME_DEST_IOS"
	if [ ! -f "$IOS_STATIC_LIB_DEST" ] && [ "$MACOS_ONLY" != "YES" ] && [ "$CATALYST_ONLY" != "YES" ]; then
		# NOTE: We want to create symbols links with normalized file paths
		IOS_STATIC_LIB_SRC=$(canonicalize_file_path $IOS_STATIC_LIB_SRC)
		IOS_STATIC_LIB_DEST=$(canonicalize_file_path $IOS_STATIC_LIB_DEST)
		echo "Creating Symbolic Link [IOS]"
		echo "\t  SRC: $IOS_STATIC_LIB_SRC"
		echo "\t DEST: $IOS_STATIC_LIB_DEST"
		ln -s $IOS_STATIC_LIB_SRC $IOS_STATIC_LIB_DEST
	fi
}

link_catalyst () {
	CATALYST_STATIC_LIB_SRC="$RUST_TARGET_DIR/x86_64-apple-ios-macabi/release/$CRATE_AR_ARCHIVE_NAME_SRC"
	CATALYST_STATIC_LIB_DEST="$SWIFT_C_CATALYST_LIB_DIR/$CRATE_AR_ARCHIVE_NAME_DEST_CATALYST"
	if [ ! -f "$CATALYST_STATIC_LIB_DEST" ] && [ "$IOS_ONLY" != "YES" ] && [ "$MACOS_ONLY" != "YES" ]; then
		# NOTE: We want to create symbols links with normalized file paths
		CATALYST_STATIC_LIB_SRC=$(canonicalize_file_path $CATALYST_STATIC_LIB_SRC)
		CATALYST_STATIC_LIB_DEST=$(canonicalize_file_path $CATALYST_STATIC_LIB_DEST)
		echo "Creating Symbolic Link [CATALYST]"
		echo "\t  SRC: $CATALYST_STATIC_LIB_SRC"
		echo "\t DEST: $CATALYST_STATIC_LIB_DEST"
		ln -s $CATALYST_STATIC_LIB_SRC $CATALYST_STATIC_LIB_DEST
	fi
}

#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
# LINK FILES to FFI DIR
#―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――

link_macos

link_ios
