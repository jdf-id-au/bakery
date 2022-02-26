import std / [os, strformat]
import mustache
import bakery / ingredients
import examples / oven

const
  templateDir = "../templates"
  buildDir = "../build"
  tin = staticRead(templateDir / "tin.html")
  script = staticRead(buildDir / "viewer.js")

when isMainModule:
  let
    shopping = shop(commandLineParams())
    ctx = newContext()
  ctx["title"] = "Proof of concept"
  ctx["accessors"] = shopping.accessors
  ctx["data"] = $shopping.data
  ctx["noscript"] = "Static preview. Please download and view in a web browser for full interactivity."
  ctx["static"] = shopping.bake
  ctx["script"] = script
  writeFile("output" / "out.html", render(tin, ctx))
