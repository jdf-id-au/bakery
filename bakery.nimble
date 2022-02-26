# Package

version       = "0.1.0"
author        = "Jeremy Field"
description   = "Create self-contained data visualisations"
license       = "MIT"

# Dependencies

requires "nim >= 1.6.0"
requires "mustache >= 0.4.3"
requires "karax >= 1.2.1"
requires "chroma >= 0.2.5"

# Tasks

task viewer, "Compile viewer.":
  #exec("nimble -d:release js examples/viewer")
  exec("nimble js examples/viewer")
  
# Default `nimble test` runs `tests/t*.nim`.
# Alternative is `testament pattern "tests/*.nim"`.
# Note `tests/nim.cfg` to set path.

# `nim r examples/layer.nim data/*`
