Uaflex
========

[![Build with Alire](https://github.com/reznikmm/uaflex/actions/workflows/alire.yml/badge.svg)](https://github.com/reznikmm/uaflex/actions/workflows/alire.yml)
[![REUSE status](https://api.reuse.software/badge/github.com/reznikmm/uaflex)](https://api.reuse.software/info/github.com/reznikmm/uaflex)

> Unicode-aware lexical analyzer generator for Ada, similar to lex.

## What Is it

TBD

Key directories and files:

- `source/` - library units (`Uaflex` package)
- `uaflex.gpr` - root GPR project file for the library
- `alire.toml` - root crate metadata and test action
- `testsuite/` - separate Alire crate for tests
- `AGENTS.md` - repository-specific instructions for coding agents

## Requirements

- [Alire](https://alire.ada.dev/)
- GNAT toolchain compatible with Ada 2022

## Build And Test

From repository root:

```sh
alr build
alr test
```

Run testsuite crate directly:

```sh
alr -C testsuite run
```

## Using This Uaflex

TBD

## Maintainer

[Max Reznik](https://github.com/reznikmm)

## License

Licensed under Apache-2.0 WITH LLVM-exception. See `LICENSES/` and `REUSE.toml`.

