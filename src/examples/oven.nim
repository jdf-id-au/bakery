## Render static visualisation, to be picked up by DOM manipulation when js available.

import std / [json, options, tables, strformat, sequtils, sugar]
import karax / [karaxdsl, vdom]
import .. / bakery / [ingredients, mixer, measure]

type
  Mark[C,L] = object
    x, y, w, h: float
    c: C
    l: L

const
  tempColours = ["#4575b4" "#74add1" "#abd9e9" "#e0f3f8" "#ffffbf" "#fee090" "#fdae61" "#f46d43" "#d73027"]
  
  tempRepr = initScale(Threshold,
                       steps(34.5, 0.5, tempColours.len.dec)
                       tempSteps,
                       tempColours)
   
  painColours = ["#006837" "#1a9850" "#66bd63" "#a6d96a" "#d9ef8b" "#ffffbf" "#fee08b" "#fdae61" "#f46d43" "#d73027" "#a50026"]
  painScore = steps(0, 1, 11)
  painBins = initScale(Threshold, steps(0.5, 1.0, 10), painScore)
  painRepr = initScale(Ordinal, painBins, painColours)
    
proc bake*(sh: Shopping): string =
  const
    d = (w: 1000, h: 500) # dimension
    m = (t: 30, r: 150, b: 0, l: 20) # margin
    s = (w: d.w + m.l + m.r, h: d.h + m.t + m.b) # svg
  let
    ps = points[int, float](sh, "ANAESTHETIST", "TEMPERATURE_INITIAL").toSeq
    dataCount = ps.len
    
  var groupedPoints = ps.groupByKey
  groupedPoints.sort(someMeanVal) # sort in place!

  var
    colOffset: int
    marks: seq[Mark[Option[int],float]]

  for (col, vals) in groupedPoints.pairs:
    var layerOffset: int
    let
      entryCount = vals.len
      valueCount = vals.somelen
      missingProp = 1.0 - valueCount.float/entryCount.float

    for (layer, lvals) in vals.someitems.groupBy(binTemp).pairs:
      let
        layerEntryCount = lvals.len
        x = colOffset.float/dataCount.float
        y = layerOffset.float/valueCount.float # y offset is proportional to known values
        w = entryCount.float/dataCount.float
        h = layerEntryCount.float/valueCount.float # height is proportion of known values
        missingHeight = h * missingProp # Calculate height which should represent missing cases
        mh2 = missingHeight/2.0 # ...halve it,
        yy = y + mh2 # ...and add to y offset so box is vertically centred.
        hh = h - missingHeight # reduce height correspondingly
      marks.add(Mark[Option[int], float](x: x, y: 1.0-(yy+hh), w: w, h: h, c: col, l: layer))
  
  let vnode = buildHtml(svg(width="100%", viewBox=fmt"{-m.l} {-m.t} {s.w} {s.h}")):
    g:
      for m in marks:
        rect(x = $m.x, y = $m.y, width = $m.w, height = $m.h)
          
  result = $vnode
