set -e

cd ../subscript-compiler

./scripts/build.sh

cargo run -- build --project-dir ../example-project

