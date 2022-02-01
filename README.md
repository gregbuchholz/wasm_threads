#Rust generating invalid wasm file on threaded program?

This repository is trying to demonstrate an issue when trying to compile a
multi-theaded Rust program targeting wasm32-unknown-emscripten.

When using a custom compiled version of rustc 1.59.0-dev, I get a wasm file
that works as expected.  When using rust 1.60.0-nightly, I get the [error]():
```
          [parse exception: attempted pop from empty stack / beyond block start boundary at 24770 (at 0:24770)]
          Fatal: error in parsing input
          emcc: error: '/home/greg/Extras/temp/emsdk/binaryen/main_64bit_binaryen/bin/wasm-emscripten-finalize --minimize-wasm-changes /home/greg/rust-examples/wasm-threads/target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm -o /home/greg/rust-examples/wasm-threads/target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm --detect-features' failed (returned 1)
```

...running `wasm-emscripten-finalize` with `--debug`:

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

[wasm-validate]() doesn't seem to like the input to `wasm-emscripten-finalize` either:

```
$ wasm-validate --enable-threads target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm

target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:00060c2: error: type mismatch in drop, expected [any] but got []
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0006494: error: type mismatch at end of function, expected [] but got [i64]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0006f27: error: type mismatch in drop, expected [any] but got []
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:00072a1: error: type mismatch at end of function, expected [] but got [i32, i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:00073b5: error: type mismatch at end of function, expected [] but got [i32, i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0007529: error: type mismatch at end of function, expected [] but got [i32, i32, i32]
target/wasm32-unknown-emscripten/release/deps/wasm_threads.wasm:0007940: error: type mismatch at end of function, expected [] but got [i32, i32, i32]
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


```
Versions:

    $ rustc +nightly --version
    rustc 1.60.0-nightly (a00e130da 2022-01-29)

    $ rustc +stage1 --version
    rustc 1.59.0-dev

    $ emcc --version
    emcc (Emscripten gcc/clang-like replacement + linker emulating GNU ld) 3.1.3-git (a1a755948a6e25c0fa62fc8fdcb89dc372618a63)
    Copyright (C) 2014 the Emscripten authors (see AUTHORS.txt)
    This is free and open source software under the MIT license.
    There is NO warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

    $ wasm-validate --version
    1.0.13
```
