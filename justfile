# Justfiles are processed by the just command runner (https://just.systems/).

_default *args:
    just --list

# this is Hello
hello:
  echo "Hello, world!"

# Run a `flake.nix` package with arbitrary arguments
@run package *args:
    nix run --no-warn-dirty '.#{{ package }}' -- {{ args }}


# slowest linters on the right
[group("lint")]
lint: shellcheck lint-rustfmt clippy typos

# bash/zsh static analysis
[group("lint")]
shellcheck:
    @just run shellcheck -x $(just run fd -e sh)

# run cargo clippy, denying warnings
[group("lint")]
clippy:
    cd ./helloworld && cargo clippy --no-deps -- -D warnings

# run cargo clippy, denying warnings
[group("lint")]
typos *args:
  @just run typos

# Run rustfmt in check mode
[group("lint")]
lint-rustfmt:
    cargo fmt --all -- --check

# dockerfile lint
# [group("lint")]
hadolint:
    hadolint Dockerfile

# [group("lint")]
actionlint:
    @just run actionlint

# bash/zsh static analysis
[group("build")]
flake-install package:
    @just profile install '.#{{ package }}'


[group("test")]
test:
  cd ./helloworld && cargo nextest run

run-client:
  cd ./helloworld && cargo run --bin=hw-client

run-server:
  cd ./helloworld && cargo run --bin=hw-server

update-slides:
  marp --html -o ./docs -I ./docs

# watch slides for changes, serving on localhost:8080
watch-slides:
  marp --server --watch --html -o ./docs -I ./docs
