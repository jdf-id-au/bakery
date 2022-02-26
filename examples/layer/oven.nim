## Render static visualisation, to be picked up by DOM manipulation when js available.

import std / [os, json, options, tables, strformat, sequtils, sugar]
import karax / [karaxdsl, vdom]
import mustache
import .. / .. / bakery / [ingredients, mixer, measure]
import .. / .. / bakery / plots / layer

const
  tempBins = thresholdScale(steps(34.5, 0.5, 9))
  tempRepr = ordinalScale(tempBins,
    ["#4575b4", "#74add1", "#abd9e9", "#e0f3f8", "#ffffbf",
     "#fee090", "#fdae61", "#f46d43", "#d73027"].toSeq)
  tempLabels = label(tempBins)
  painBins = thresholdScale(steps(0.5, 1.0), steps(0, 1, 11))
  painRepr = ordinalScale(painBins,
    ["#006837", "#1a9850", "#66bd63", "#a6d96a", "#d9ef8b",
     "#ffffbf", "#fee08b", "#fdae61", "#f46d43", "#d73027",
     "#a50026"].toSeq)
  
proc bake*(sh: Shopping): string =
  const
    d = (w: 1000, h: 500) # dimension
    m = (t: 30, r: 150, b: 20, l: 20) # margin
    s = (w: d.w + m.l + m.r,
         h: d.h + m.t + m.b) # svg
    X = linearScale(bounds(0.0, 1.0), bounds(0.float, d.w.float))
    Y = linearScale(bounds(0.0, 1.0), bounds(0.float, d.h.float))
  let
    ps = points[int, float](sh, "ANAESTHETIST", "TEMPERATURE_INITIAL").toSeq

  let vnode = buildHtml(svg(width="100%", viewBox=fmt"{-m.l} {-m.t} {s.w} {s.h}")):
    layer.plot(ps, someValsMean, (t) => tempBins.bin(t), X, Y, tempRepr)
    layer.labels("Initial temperature", "anaesthetist", "temperature", m, X, Y, tempRepr, tempLabels, "°C")
  
  $vnode

const
  templ = staticRead("platter.html")
  script = staticRead("service.js")

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
