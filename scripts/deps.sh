#!/usr/bin/env bash

set -o pipefail

# This script is meant to be used
# when running a container image to fetch dependencies
# such as CI or in a Dockerfile,
# THUS an x86_64 linux platrom is assumed
USAGE='
USAGE:
  '$0' <DEPS>... [--force] [--no-symlink]

DEPS:
  cargo-nextest
  flatc
  just
  protoc

FLAGS:
  --force    skip checking for dependency
'

if [[ $# -eq 0 ]]; then
  echo "$USAGE"
  exit 0
fi

case "$1" in
--help | -h)
  echo "$USAGE"
  exit 0
  ;;
esac

# Check if a `cli-command` exists within `$PATH`
# emit exit code
exists() {
  local command="$1"
  local which_err_code=0

  # if we pass in --no-symlink
  # check for the explicit filepath
  # rather than what is found in $PATH
  if [[ "$NO_SYMLINK" == "true" ]]; then
    case "$command" in
    # anything starting with cargo- is a cargo subcommand
    # thus has to lie in ~/.cargo/bin
    cargo-*) command="$HOME/.cargo/bin/$command" ;;
    *) command="$HOME/.local/bin/$command" ;;
    esac
  fi

  command -v "$command" 1> /dev/null || which_err_code=$?

  if [[ "$which_err_code" == 0 ]]; then
    # call the error function
    echo "$command found in \$PATH"
  fi

  return $which_err_code
}

# prepend with underscore to avoid accidentally triggering a function
# the snippet below would attempt to trigger a function named flatc:
# $(exists flatc)
install() {
  echo "installing $1..."
  "_$1"
}

# try_ln is mainly used for github actions where
# a partially restored cache may require sudo permissions
# to symlink into /usr/local/bin
try_ln() {
  if [[ "$NO_SYMLINK" == "true" ]]; then
    return 0
  fi

  ln -s "$1" "$2" || {
    echo "trying: sudo ln -sf $1 $2"
    sudo ln -sf "$1" "$2"
  }
}

_protoc() {
  local version=${PROTOC_VERSION:-28.3}
  local zip_file="protoc-${version}-linux-x86_64.zip"
  wget -q "https://github.com/protocolbuffers/protobuf/releases/download/v${version}/protoc-${version}-linux-x86_64.zip" &&
    unzip -o "$zip_file" -d "$HOME/.local" &&
    chmod +x "$HOME/.local/bin/protoc" &&
    try_ln "$HOME/.local/bin/protoc" /usr/local/bin/protoc
  rm "$zip_file"
}

_cargo-nextest() {
  local version=${NEXTEST_VERSION:-latest}
  wget -qO- https://get.nexte.st/latest/linux |
    tar xz -C "$HOME/.cargo/bin/" &&
    chmod +x "$HOME/.cargo/bin/cargo-nextest"

}

# https://github.com/casey/just?tab=readme-ov-file#pre-built-binaries
_just() {
  local version=${JUST_VERSION:-1.36.0}
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --tag $version --to "$HOME/.local/bin"
}

wget_script() {
  local name="$1"
  local url="${DEPS_URL[$name]}"
  # TODO impl **/bin alternative
  # when downloading files meant for an interpreter
  wget -qO "$HOME/.local/bin/$name" "$url" &&
    chmod +x "$HOME/.local/bin/$name"
  # handle symlink?
  # try_ln "$HOME/.local/bin/$name" /usr/local/bin/bootstrap
}

DEPS=()
# Replace as many `pattern` matches as possible with `replacement`:
# ${var//pattern/replacement}
# ----------------------------
# This strips commas from args:
# string "just, flatc" -> array (just flatc)
for arg in "${@//,/}"; do
  # handle --flags here
  if [[ $arg == [-]* ]]; then
    case "$arg" in
    --force) FORCE="true" ;;
    --no-symlink) NO_SYMLINK="true" ;;
    *) {
      echo "$arg is an invalid flag"
      exit 1
    } ;;
    esac
  else
    # generate an array of dependencies
    DEPS+=("$arg")
  fi
done

# handle a default argument to be passed in GH actions >:(
# https://github.com/actions/runner/issues/924#issuecomment-810666502
[[ "$1" == "" ]] && exit 0
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.cargo/bin"
for dep in "${DEPS[@]}"; do
  if [[ "$FORCE" == "true" ]]; then
    install "$dep"
  else
    exists "$dep" || install "$dep"
  fi

done

