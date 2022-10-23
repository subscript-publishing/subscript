# macos:
# 	@cargo +nightly build -Z build-std --release --lib --target aarch64-apple-ios-macabi
# 	@cargo +nightly build -Z build-std --release --lib --target x86_64-apple-ios-macabi
# 	@$(RM) -rf libs/my-rust-library-maccatalyst.a
# 	@lipo -create -output libs/my-rust-library-maccatalyst.a \
# 		../target/aarch64-apple-ios-macabi/release/libmy-rust-library.a \
# 		target/x86_64-apple-ios-macabi/release/libmy-rust-library.a
# 
# ios:
# 	@cargo +ios-arm64-1.57.0 build --release --lib --target aarch64-apple-ios
# 	@$(RM) -rf libs/my-rust-library-ios.a
# 	@cp ../target/aarch64-apple-ios/release/libmy-rust-library.a libs/my-rust-library-ios.a