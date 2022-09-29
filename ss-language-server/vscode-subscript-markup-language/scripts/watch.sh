set -e

watchexec --exts yaml --ignore node_modules/ -- './build.sh && echo "\n==reloaded==\n"'
