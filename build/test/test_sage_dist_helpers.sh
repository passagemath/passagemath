#!/usr/bin/env bash
# Unit tests for sage-dist-helpers build helpers (sdh_build_wheel, sdh_pip_install)
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

TEST_DIR=$(mktemp -d)
trap "rm -rf '$TEST_DIR'" EXIT

cd "$TEST_DIR"
mkdir -p bin
export PATH="$TEST_DIR/bin:$PATH"

# Create a mock python3 that records its arguments and responds to build --help
cat << 'EOF' > bin/python3
#!/usr/bin/env bash
if [ "$1" = "-m" ] && [ "$2" = "build" ]; then
    if [ "$3" = "--help" ]; then
        if [ "$MOCK_BUILD_NO_FLAGS" = "1" ]; then
            echo "usage: python -m build [--version] ..."
            exit 0
        fi
        echo "usage: python -m build [--env-dir PATH] [--sdist-extract-dir PATH] ..."
        exit 0
    fi
    shift 2
    echo "$@" > "$MOCK_BUILD_ARGS_FILE"
    mkdir -p dist
    touch dist/mock_pkg-1.0-py3-none-any.whl
    exit 0
fi
exec python3 "$@"
EOF
chmod +x bin/python3

source "$REPO_ROOT/build/bin/sage-dist-helpers"

export SAGE_SPKG_WHEELS="$TEST_DIR/wheels"
mkdir -p "$SAGE_SPKG_WHEELS"
export SAGE_BUILD_DIR="$TEST_DIR/build"
export PKG_NAME="testpkg-1.0"
mkdir -p "$SAGE_BUILD_DIR/$PKG_NAME"

export MOCK_BUILD_ARGS_FILE="$TEST_DIR/build_args.txt"

# Test 1: Default behavior passes default --env-dir
sdh_build_wheel .
ARGS=$(cat "$MOCK_BUILD_ARGS_FILE")
if [[ "$ARGS" != *"--env-dir=$SAGE_BUILD_DIR/$PKG_NAME/build-env"* ]]; then
    echo "FAIL: Test 1 failed to set default --env-dir" >&2
    exit 1
fi

# Test 2: Explicit --env-dir option (space separated)
CUSTOM_ENV="$TEST_DIR/custom-env"
sdh_build_wheel --env-dir "$CUSTOM_ENV" .
ARGS=$(cat "$MOCK_BUILD_ARGS_FILE")
if [[ "$ARGS" != *"--env-dir=$CUSTOM_ENV"* ]]; then
    echo "FAIL: Test 2 failed to pass custom --env-dir" >&2
    exit 1
fi

# Test 3: Explicit --env-dir=... option
sdh_build_wheel "--env-dir=$CUSTOM_ENV" .
ARGS=$(cat "$MOCK_BUILD_ARGS_FILE")
if [[ "$ARGS" != *"--env-dir=$CUSTOM_ENV"* ]]; then
    echo "FAIL: Test 3 failed to pass --env-dir=..." >&2
    exit 1
fi

# Test 4: Explicit --sdist-extract-dir option
CUSTOM_SDIST="$TEST_DIR/custom-sdist"
sdh_build_wheel --sdist-extract-dir "$CUSTOM_SDIST" .
ARGS=$(cat "$MOCK_BUILD_ARGS_FILE")
if [[ "$ARGS" != *"--sdist-extract-dir=$CUSTOM_SDIST"* ]]; then
    echo "FAIL: Test 4 failed to pass custom --sdist-extract-dir" >&2
    exit 1
fi

# Test 5: SAGE_BUILD_ENV_DIR env var
ENVVAR_DIR="$TEST_DIR/envvar-env"
SAGE_BUILD_ENV_DIR="$ENVVAR_DIR" sdh_build_wheel .
ARGS=$(cat "$MOCK_BUILD_ARGS_FILE")
if [[ "$ARGS" != *"--env-dir=$ENVVAR_DIR"* ]]; then
    echo "FAIL: Test 5 failed to use SAGE_BUILD_ENV_DIR" >&2
    exit 1
fi

# Test 6: SAGE_BUILD_ENV_DIR=none disables --env-dir
SAGE_BUILD_ENV_DIR="none" sdh_build_wheel .
ARGS=$(cat "$MOCK_BUILD_ARGS_FILE")
if [[ "$ARGS" == *"--env-dir"* ]]; then
    echo "FAIL: Test 6 failed to disable --env-dir when SAGE_BUILD_ENV_DIR=none" >&2
    exit 1
fi

# Test 7: --no-build-isolation suppresses --env-dir
sdh_build_wheel --no-build-isolation .
ARGS=$(cat "$MOCK_BUILD_ARGS_FILE")
if [[ "$ARGS" == *"--env-dir"* ]]; then
    echo "FAIL: Test 7 passed --env-dir despite --no-build-isolation" >&2
    exit 1
fi

# Test 8: Pre-existing env-dir is cleaned before build
PREEXISTING="$TEST_DIR/preexisting"
mkdir -p "$PREEXISTING"
touch "$PREEXISTING/dummy"
sdh_build_wheel --env-dir "$PREEXISTING" .
if [ -e "$PREEXISTING/dummy" ]; then
    echo "FAIL: Test 8 failed to clean preexisting env-dir contents" >&2
    exit 1
fi

# Test 9: --sdist-then-wheel sets default --sdist-extract-dir
sdh_build_wheel --sdist-then-wheel .
ARGS=$(cat "$MOCK_BUILD_ARGS_FILE")
if [[ "$ARGS" != *"--sdist-extract-dir=$SAGE_BUILD_DIR/$PKG_NAME/sdist-extract"* ]]; then
    echo "FAIL: Test 9 failed to set default --sdist-extract-dir" >&2
    exit 1
fi

# Test 10: When python3 -m build lacks support for flags
unset SAGE_BUILD_SUPPORTS_ENV_DIR
unset SAGE_BUILD_SUPPORTS_SDIST_EXTRACT_DIR
MOCK_BUILD_NO_FLAGS=1 sdh_build_wheel .
ARGS=$(cat "$MOCK_BUILD_ARGS_FILE")
if [[ "$ARGS" == *"--env-dir"* ]] || [[ "$ARGS" == *"--sdist-extract-dir"* ]]; then
    echo "FAIL: Test 10 passed unsupported flags to build" >&2
    exit 1
fi

echo "All sage-dist-helpers tests passed successfully."
