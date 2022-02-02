# Tips for using cargo-bisect-rustc and "--release"

I've got a [program](https://github.com/gregbuchholz/wasm_threads) that
compiles fine with the nightly from 2021-12-06 (v1.59.0), but that fails with
the nightly from 2022-01-29 (1.60.0).  The catch is that it only fails when
compiled with `--release`. (this is using the `wasm-unknown-emscripten` target).

After a little searching, I found
[cargo-bisect-rustc](https://github.com/rust-lang/cargo-bisect-rustc), which
seems like it should be a useful tool for narrowing down the regression.  But
when I try to use it, it complains about not liking the `--release` argument:

```
$ cargo bisect-rustc -vv --start=2021-12-06 -- --release
installing nightly-2021-12-06
cargo for x86_64-unknown-linux-gnu: 6.20 MB / 6.20 MB [====================================] 100.00 % 11.83 MB/s testing...
error: Found argument '--release' which wasn't expected, or isn't valid in this context

USAGE:
    cargo [+toolchain] [OPTIONS] [SUBCOMMAND]

For more information try --help
RESULT: nightly-2021-12-06, ===> Yes
uninstalling nightly-2021-12-06

ERROR: the start of the range (nightly-2021-12-06) must not reproduce the regression
```

...is there a different way to invoke that command, so that it uses
"--release"?  Maybe a way to specify the "--release" in `.cargo/config`?

Thanks,
Greg

