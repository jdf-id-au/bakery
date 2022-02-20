## Render static visualisation, to be picked up by DOM manipulation when js available.

import std / [json, options, tables, strformat, sequtils, sugar]
import karax / [karaxdsl, vdom]
import .. / bakery / [ingredients, mixer, measure]

type
  Mark[C,L] = object
    x, y, w, h: float
    c: C
    l: L
    n: int

const
  tempBins = thresholdScale(steps(34.5, 0.5, 9))
  tempRepr = ordinalScale(tempBins,
    ["#4575b4", "#74add1", "#abd9e9", "#e0f3f8", "#ffffbf",
     "#fee090", "#fdae61", "#f46d43", "#d73027"].toSeq)
  painBins = thresholdScale(steps(0.5, 1.0), steps(0, 1, 11))
  painRepr = ordinalScale(painBins,
    ["#006837", "#1a9850", "#66bd63", "#a6d96a", "#d9ef8b",
     "#ffffbf", "#fee08b", "#fdae61", "#f46d43", "#d73027",
     "#a50026"].toSeq)

# TODO now factor out layerPlot to suit different inputs...
proc layerPlot*[K, V](ps: seq[Pair[Option[K], Option[V]]],
                      colSort: ((Option[K], seq[Option[V]]),
                                (Option[K], seq[Option[V]])) -> int,
                      layerSort: (V) -> V, # FIXME what about ordinal layers with text?
                      X, Y: LinearScale[float, float],
                      Z: OrdinalScale[float, string]): VNode =
  ## Return an svg `g` node containing whole plot.
  let dataCount = ps.len
  var groupedPoints = ps.groupValsByKey
  groupedPoints.sort(colSort)

  var
    colOffset: int
    marks: seq[Mark[Option[K], V]]

  for (col, vals) in groupedPoints.pairs:
    var layerOffset: int
    let
      entryCount = vals.len
      valueCount = vals.somelen
      missingProp = 1.0 - valueCount.float/entryCount.float

    var binned = vals.groupSomeBy(layerSort)
    binned.sort(cmpKey) # unnecessary to pass in?

    for (layer, lvals) in binned.pairs:
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
      marks.add(Mark[Option[K], V](x: x, y: 1.0-(yy+hh), w: w, h: hh, c: col, l: layer, n: layerEntryCount))
      layerOffset += layerEntryCount
    colOffset += entryCount

  proc f(v:float): string =
    fmt"{v:.1f}"
        
  buildHtml(g()):
    for m in marks:
      rect(x = X.scale(m.x).f, y = Y.scale(m.y).f,
           width = X.scale(m.w).f, height = Y.scale(m.h).f,
           fill = Z.bin(m.l))
  
proc bake*(sh: Shopping): string =
  const
    d = (w: 1000, h: 500) # dimension
    m = (t: 30, r: 150, b: 0, l: 20) # margin
    s = (w: d.w + m.l + m.r,
         h: d.h + m.t + m.b) # svg
    X = linearScale(bounds(0.0, 1.0), bounds(0.float, d.w.float))
    Y = linearScale(bounds(0.0, 1.0), bounds(0.float, d.h.float))
  let
    ps = points[int, float](sh, "ANAESTHETIST", "TEMPERATURE_INITIAL").toSeq

  let vnode = buildHtml(svg(width="100%", viewBox=fmt"{-m.l} {-m.t} {s.w} {s.h}")):
    layerPlot(ps, someValsMean, (t) => tempBins.bin(t), X, Y, tempRepr)
  
  result = $vnode
