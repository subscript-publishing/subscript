set -e

./scripts/build.sh

# cargo run -- compile-file --source sample.ss --output sample.html --watch
cargo run -- compile-file --source sample.ss --output sample.html


