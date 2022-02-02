# Rust generating invalid wasm file on threaded program (v1.6 vs. 1.59)?

This repository is trying to demonstrate an issue when trying to compile a
multi-theaded Rust program targeting wasm32-unknown-emscripten.  To reproduce
the error, you will need to have a very recent (git) version of LLVM in Emscripten,
to get around [this issue](https://github.com/emscripten-core/emscripten/issues/15891).

When using a nightly 1.59.0-dev, from 2021-12-06 I get a wasm file
that works as expected.  When using rust 1.60.0-nightly, I get the [error](https://github.com/gregbuchholz/wasm_threads/blob/main/error.txt):

```
[parse exception: attempted pop from empty stack / beyond block start boundary at 24770 (at 0:24770)]
Fatal: error in parsing input
emcc: error: '/home/greg/Extras/temp/emsdk/binaryen/main_64bit_binaryen/bin/wasm-emscripten-finalize --minimize-wasm-changes /home/greg/rust-examples/wasm-threads/target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm -o /home/greg/rust-examples/wasm-threads/target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm --detect-features' failed (returned 1)
```

...running `wasm-emscripten-finalize` with `--debug` on the "broken" \*.wasm [results in](https://github.com/gregbuchholz/wasm_threads/blob/main/w-e-f_out.txt):

```
$ wasm-emscripten-finalize --minimize-wasm-changes target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm -o target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm --detect-features --debug

<snip>

readExpression seeing 16
zz node: Call
<==
getInt8: 128 (at 24764)
getInt8: 128 (at 24765)
getInt8: 128 (at 24766)
getInt8: 128 (at 24767)
getInt8: 0 (at 24768)
getU32LEB: 0 ==>
== popExpression
== popExpression
== popExpression
zz recurse from 3 at 24769
zz recurse into 3 at 24769
getInt8: 26 (at 24769)
readExpression seeing 26
zz node: Drop
== popExpression
== popExpression
== popExpression
== popExpression
== popExpression
== popExpression
[parse exception: attempted pop from empty stack / beyond block start boundary at 24770 (at 0:24770)]
Fatal: error in parsing input
```

[wasm-validate](https://webassembly.github.io/wabt/doc/wasm-validate.1.html) doesn't seem to like the input to `wasm-emscripten-finalize` either:

```
$ wasm-validate --enable-threads target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm

target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:00060c2: error: type mismatch in drop, expected [any] but got []
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0006494: error: type mismatch at end of function, expected [] but got [i64]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0006f27: error: type mismatch in drop, expected [any] but got []
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:00072a1: error: type mismatch at end of function, expected [] but got [i32, i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:00073b5: error: type mismatch at end of function, expected [] but got [i32, i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0007529: error: type mismatch at end of function, expected [] but got [i32, i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0007940: error: type mismatch at end of function, expected [] but got [i32, i32, i32]
```
<details>
```
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000798a: error: type mismatch at end of function, expected [] but got [i32, i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0007a32: error: type mismatch in drop, expected [any] but got []
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0007db3: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0008f73: error: type mismatch in drop, expected [any] but got []
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0009169: error: type mismatch in drop, expected [any] but got []
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000952c: error: type mismatch in drop, expected [any] but got []
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0009752: error: type mismatch in drop, expected [any] but got []
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000a273: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000baaa: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000c327: error: type mismatch at end of function, expected [] but got [i32, i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000c376: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000c3f8: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000c534: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000d7e3: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000d8c2: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000d9b7: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000dea8: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000df5a: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000e00d: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000e0bd: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000e420: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000e6a3: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000f52d: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000fa38: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:000ff14: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:001053c: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0010938: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0010cab: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0010d72: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0011356: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0011a27: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0011e1b: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0011f04: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0012078: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:001232e: error: type mismatch in implicit return, expected [i32] but got [... i64]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:001232e: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0012557: error: type mismatch at end of function, expected [] but got [i32, i32, i64]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:00128d8: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0013d86: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0013f18: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:00140a3: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0014d73: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0015182: error: type mismatch at end of function, expected [] but got [... i32, i32, i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0015bea: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:00173ee: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0017802: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0017dc6: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:001817f: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0018272: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:00184ab: error: type mismatch at end of function, expected [] but got [i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:001864a: error: type mismatch at end of function, expected [] but got [i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0018c22: error: type mismatch at end of function, expected [] but got [i32, i32, i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:00191b1: error: type mismatch at end of function, expected [] but got [i32]
```
</details>

The working wasm file compiled with 1.59.0 is included in the repository, it can be run with either:

    node --experimental-wasm-threads --experimental-wasm-bulk-memory target/wasm32-unknown-emscripten/release/deps/wasm_threads.js

...or...

    emrun index-wasm.html

...and the broken version (compiled with 1.6.0) of the wasm file that chokes `wasm-emscripten-finalize` is at: [target/wasm32-unknown-emscripten/release/deps/broken_wasm_threads.wasm](https://github.com/gregbuchholz/wasm_threads/blob/main/target/wasm32-unknown-emscripten/release/deps/broken_wasm_threads.wasm)

Versions:

    $ rustc +nightly --version --verbose
    rustc 1.60.0-nightly (a00e130da 2022-01-29)
    binary: rustc
    commit-hash: a00e130dae74a213338e2b095ec855156d8f3d8a
    commit-date: 2022-01-29
    host: x86_64-unknown-linux-gnu
    release: 1.60.0-nightly
    LLVM version: 13.0.0

    $ rustc +nightly-2021-12-06 --version --verbose
    rustc 1.59.0-nightly (e2116acae 2021-12-05)
    binary: rustc
    commit-hash: e2116acae59654bfab2a9729a024f3e2fd6d4b02
    commit-date: 2021-12-05
    host: x86_64-unknown-linux-gnu
    release: 1.59.0-nightly
    LLVM version: 13.0.0 

    $ emcc --version
    emcc (Emscripten gcc/clang-like replacement + linker emulating GNU ld) 3.1.3-git (a1a755948a6e25c0fa62fc8fdcb89dc372618a63)
    Copyright (C) 2014 the Emscripten authors (see AUTHORS.txt)
    This is free and open source software under the MIT license.
    There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    $ wasm-validate --version
    1.0.13

...you will also need to compile the gxx_personality_v0_stub.cpp file in the src/ directory:

    emcc -c gxx_personality_v0_stub.cpp -pthread

