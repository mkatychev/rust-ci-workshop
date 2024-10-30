---
marp: true
theme: default
style: @import url('https://unpkg.com/tailwindcss@^2/dist/utilities.min.css');
---


# Deploying Your Rust Code
Please, just work...

![bg right width:40em](./chi-ci.svg)

---

## What are we doing?

* Testing
* Linting
* Building
* Deploying

---
## How are we doing?

- bootstrapping
- task running
- caching
- alerting

---

## Testing

* `cargo test`
* Testing
* Building
* Deploying
---

## Linting

General/non-rust linting

* taplo (TOML)
* shellcheck (`bash`)
* hadolint (`Dockerfile`)
* typos
* ast-grep


---

## Bash can be...

- good!?
- [readable](https://explainshell.com/explain?cmd=sudo+ln+-sf+%22%241%22+%22%242%22)
- maintainable
- reliable
- not `python` or `node`!

---

## Get our task runner

github.com/mkatychev/rust-...

```bash
_just() {
  local version="1.36.0"
  curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --tag $version --to "$HOME"/.cargo/bin
}
```


---

## [Just](https://just.systems/) is...
- not `python`, `make`, or `cargo-make`!

<iframe frameborder="0" scrolling="no" style="width:100%; height:226px;" allow="clipboard-write" src="https://emgithub.com/iframe.html?target=https%3A%2F%2Fgithub.com%2Fmkatychev%2Frust-ci-workshop%2Fblob%2Ff679ee70444868d9e4ae79fc10268a60d6e00b29%2Fjustfile%23L1-L7&style=a11y-dark&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on"></iframe>


---

# CI: time is money friend!

CI has 2 basic axes: time and money

- time spent in CI
- CI runner beefiness

---

# Considerations

- is your CI runner self hosted?
- where is the best place to put the most horsepower
- is automating this really worth it???


---

# Caching

* https://github.com/Swatinem/rust-cache
* https://github.com/mozilla/sccache
* https://github.com/DeterminateSystems/magic-nix-cache
* S3/equivalent
- time is _still_ money!

---

# Compiling

Axes: Speed and reliablility (reproducibility, security)

* https://matklad.github.io//2021/09/04/fast-rust-builds.html
* https://www.musl-libc.org/how.html

---

# Compilation speed

* [distributed](https://kellnr.io/blog/compile-times-sccache#undefined)
* architecture/resources (arm/x86, CPU, RAM)

![bg right width:40em](https://kellnr.io/images/kellnr/blog/sccache/multiple-sccache.png)

---

# Compilation reliability

* [glibc security vulnerabilities](https://www.cvedetails.com/product/767/GNU-Glibc.html?vendor_id=72)

* [musl](https://www.cvedetails.com/product/39652/Musl-libc-Musl.html?vendor_id=16859)


---

# Conditional compilation

<iframe frameborder="0" scrolling="no" style="width:100%; height:184px;" allow="clipboard-write" src="https://emgithub.com/iframe.html?target=https%3A%2F%2Fgithub.com%2Fmkatychev%2Frust-ci-workshop%2Fblob%2Ff679ee70444868d9e4ae79fc10268a60d6e00b29%2F.github%2Fworkflows%2Ftest.yaml%23L1-L5&style=a11y-dark&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on"></iframe>


<iframe frameborder="0" scrolling="no" style="width:100%; height:184px;" allow="clipboard-write" src="https://emgithub.com/iframe.html?target=https%3A%2F%2Fgithub.com%2Fmkatychev%2Frust-ci-workshop%2Fblob%2F04cd83f8ed0bd9a7ee8bf173ec3a8bd00e97dca0%2Fhelloworld%2Fsrc%2Fclient.rs%23L4-L8&style=a11y-dark&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on"></iframe>

<iframe frameborder="0" scrolling="no" style="width:100%; height:121px;" allow="clipboard-write" src="https://emgithub.com/iframe.html?target=https%3A%2F%2Fgithub.com%2Fmkatychev%2Frust-ci-workshop%2Fblob%2F04cd83f8ed0bd9a7ee8bf173ec3a8bd00e97dca0%2Fhelloworld%2FCargo.toml%23L23-L24&style=a11y-dark&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on"></iframe>

---
