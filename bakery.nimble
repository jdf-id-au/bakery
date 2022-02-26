# Package

version       = "0.1.0"
author        = "Jeremy Field <jeremy.field@gmail.com>"
description   = "Create self-contained data visualisations"
license       = "MIT"

# Dependencies

requires "nim >= 1.6.0"
requires "mustache >= 0.4.3"
requires "karax >= 1.2.1"
requires "chroma >= 0.2.5"

# Default `nimble test` runs `tests/t*.nim`.
# Alternative is `testament pattern "tests/*.nim"`.

# `nim js examples/layer/service`
# `nim r examples/layer/oven data/*`
