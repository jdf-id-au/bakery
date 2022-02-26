import std / [os, strformat]
import mustache
import .. / bakery / ingredients
import oven

const
  templ = staticRead("layer.html")
  script = staticRead("viewer.js")

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
  writeFile("output" / "layer.html", render(templ, ctx))
