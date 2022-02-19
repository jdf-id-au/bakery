## Render static visualisation, to be picked up by DOM manipulation when js available.

import std / [json, options, tables, strformat, sequtils]
import itertools
import karax / [karaxdsl, vdom]
import .. / bakery / [ingredients, mixer]

type
  Mark[C,L] = object
    x, y, w, h: float
    c: C
    l: L # TODO add raw data

proc binTemp(t: float): float =
  result = int(t/0.5).float*0.5
  if result < 34.5:
    result = 34.5
  elif result > 38.5:
    result = 38.5

#proc scaleTemp(t: float): 
    
proc bake*(sh: Shopping): string =
  let
    d = (w: 1000, h: 500) # dimension
    m = (t: 30, r: 150, b: 0, l: 20) # margin
    s = (w: d.w + m.l + m.r, h: d.h + m.t + m.b) # svg
    
    ps = points[int, float](sh, "ANAESTHETIST", "TEMPERATURE_INITIAL").toSeq
    dataCount = ps.len
    
  var groupedPoints = ps.group
#  groupedPoints.sort(meanVal) # sort in place!

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
