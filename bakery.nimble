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

task bake, "Compile viewer and roll html.":
  #exec("nimble -d:release js src/bakery/viewer")
  exec("nimble js src/bakery/viewer")

task go, "Build and display.":
  exec("nimble bake")
  exec("nimble run")
  exec("open output/out.html")
