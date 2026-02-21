---
title: Installation
description: Install the Trifle CLI.
nav_order: 1
---

# Installation

:::tabs
@tab Homebrew
```sh
brew install trifle-io/trifle/trifle
```

@tab Shell
```sh
curl -sSL https://get.trifle.io | sh
```
Detects your OS and architecture, downloads the latest binary to `/usr/local/bin`.

@tab Go
```sh
go install github.com/trifle-io/trifle-cli@latest
```
Requires Go `1.24+`. Installs to `$GOPATH/bin`.
:::
