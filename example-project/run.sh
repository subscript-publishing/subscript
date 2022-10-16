set -e

cd ../subscript-compiler

# ./scripts/build.sh

cargo run --release -- build --project-dir ../example-project --watch
# cargo run --release -- build --project-dir ../example-project
# ../target/release/subscript-compiler build --project-dir ../example-project
