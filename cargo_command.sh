#!/usr/bin/sh

#using custom built rustc (1.59.0-dev)
#cargo +stage1 build --target=wasm32-unknown-emscripten --release -Z build-std=panic_abort,std

#using "stock" nightly rustc (broken on v1.60.0)
cargo +nightly build --target=wasm32-unknown-emscripten --release -Z build-std=panic_abort,std

#using older working nightly
#cargo +nightly-2021-12-06 build --target=wasm32-unknown-emscripten --release
