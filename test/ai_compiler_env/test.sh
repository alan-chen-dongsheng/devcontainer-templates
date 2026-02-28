#!/bin/bash
cd $(dirname "$0")
source test-utils.sh

# LLVM / Clang
check "clang" clang --version
check "clang++" clang++ --version
check "clangd" clangd --version
check "clang-format" clang-format --version
check "clang-tidy" clang-tidy --version
check "lldb" lldb --version
check "lld" ld.lld --version
check "llvm-ar" llvm-ar --version
check "llvm-cov" llvm-cov --version

# Build tools
check "ccache" ccache --version
check "ccache-unlimited" bash -c 'ccache --get-config max_size | grep -q "^0$"'

# Shell
check "zsh" zsh --version
check "oh-my-zsh" test -d "$HOME/.oh-my-zsh"
check "zsh-syntax-highlighting" test -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
check "zsh-autosuggestions" test -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

# Language runtimes
check "node" node --version
check "npm" npm --version
check "uv" uv --version
check "rustup" rustup --version
check "cargo" cargo --version

reportResults
