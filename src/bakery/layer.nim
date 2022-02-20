## Layer recipe.

import std / [json, options, tables, strformat, sugar]
import karax / [karaxdsl, vdom]
import .. / bakery / [mixer, measure]

type
  Mark[C,L] = object
    x, y, w, h: float
    c: C
    l: L
    n: int

proc layerPlot*[K, V, B](ps: seq[Pair[Option[K], Option[V]]],
                         # TODO contemplate whether to pass in colBin and layerSort
                         colSort: ((Option[K], seq[Option[V]]),
                                   (Option[K], seq[Option[V]])) -> int,
                         layerBin: (V) -> B,
                         X, Y: LinearScale[float, float],
                         C: OrdinalScale[B, string]): VNode =
  ## Return an svg `g` node containing whole plot.
  let dataCount = ps.len
  var groupedPoints = ps.groupValsByKey
  groupedPoints.sort(colSort)

  var
    colOffset: int
    marks: seq[Mark[Option[K], B]]

  for (col, vals) in groupedPoints.pairs:
    var layerOffset: int
    let
      entryCount = vals.len
      valueCount = vals.somelen
      missingProp = 1.0 - valueCount.float/entryCount.float

    var binned = vals.groupSomeBy(layerBin)
    binned.sort(cmpKey)

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
      marks.add(Mark[Option[K], B](x: x, y: 1.0-(yy+hh), w: w, h: hh, c: col, l: layer, n: layerEntryCount))
      layerOffset += layerEntryCount
    colOffset += entryCount

  proc f(v:float): string =
    fmt"{v:.1f}"
        
  buildHtml(g(class = "marks")):
    for m in marks:
      let c = if m.c.isSome: $m.c.get else: ""
      rect(x = X.scale(m.x).f, y = Y.scale(m.y).f,
           width = X.scale(m.w).f, height = Y.scale(m.h).f, fill = C.bin(m.l),
           #`data-c` = c, `data-l` = $m.l, `data-n` = $m.n
      )#: title: text fmt"{m.n} cases"
  
proc labelLayerPlot*[B](m: Margin,
                        X, Y: LinearScale[float, float],
                        C, L: OrdinalScale[B, string]): VNode =
    buildHtml(g(class = "labels")):
      # special case `stext` from karax/vdom
#      g(transform = fmt"translate(0, {Y.range.upper.get + m.b"
