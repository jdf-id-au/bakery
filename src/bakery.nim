import std / os
import mustache

const
  templateDir = "../templates"
  tin = staticRead(templateDir / "tin.html")
  script = staticRead("bakery" / "viewer.js")

when isMainModule:
  let ctx = newContext()
  ctx["title"] = "Proof of concept"
  ctx["script"] = script
  ctx["noscript"] = "Static preview. Please download and view in a web browser for full interactivity."
  writeFile("output" / "out.html", render(tin, ctx))
