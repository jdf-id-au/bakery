import std / [os, strformat]
import mustache
import bakery / ingredients
import examples / oven

proc accessors(headers: seq[string]): string =
  for i, h in headers.pairs:
    var comma = if i!=headers.high: "," else: ""
    result.add(fmt"{h}=a=>a[{i}]{comma}")

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
  ctx["accessors"] = shopping.headers.accessors
  ctx["data"] = $shopping.data
  ctx["noscript"] = "Static preview. Please download and view in a web browser for full interactivity."
  ctx["script"] = script
  writeFile("output" / "out.html", render(tin, ctx))
  echo shopping.bake
