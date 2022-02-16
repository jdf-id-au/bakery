# Package

version       = "0.1.0"
author        = "Jeremy Field"
description   = "Create self-contained data visualisations"
license       = "MIT"
srcDir        = "src"
bin           = @["bakery"]


# Dependencies

requires "nim >= 1.6.0"
requires "mustache >= 0.4.3"


# Tasks

task viewer, "Compile viewer.":
  #exec("nimble -d:release -o:build/viewer.js js src/bakery/viewer")
  exec("nimble -o:build/viewer.js js src/bakery/viewer")

# Default `nimble test` runs `tests/t*.nim`.
# Alternative is `testament pattern "tests/*.nim"`.
# Note `tests/nim.cfg` to set path.
