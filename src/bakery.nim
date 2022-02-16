import std / os
import mustache
import bakery/ingredients

const
  templateDir = "../templates"
  buildDir = "../build"
  tin = staticRead(templateDir / "tin.html")
  script = staticRead(buildDir / "viewer.js")

when isMainModule:
  let
    data = shop(commandLineParams())
    ctx = newContext()
  ctx["title"] = "Proof of concept"
  ctx["script"] = script
  ctx["data"] = $data
  ctx["noscript"] = "Static preview. Please download and view in a web browser for full interactivity."
  writeFile("output" / "out.html", render(tin, ctx))
