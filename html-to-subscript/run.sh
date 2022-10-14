set -e

cargo run -- convert-file --input test2.html --output ../example-project/pages/auto-translated/index.ss
cargo run -- convert-file --input test2.html --output out.ss
