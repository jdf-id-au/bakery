## Layer recipe.

import std / [json, options, tables, strformat, sugar]
import karax / [karaxdsl, vdom]
import .. / bakery / [mixer, measure, decorate]

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

  buildHtml(g(class = "marks")):
    for m in marks:
      let c = if m.c.isSome: $m.c.get else: ""
      rect(x = X.scale(m.x).f1, y = Y.scale(m.y).f1,
           width = X.scale(m.w).f1, height = Y.scale(m.h).f1, fill = C.bin(m.l),
           #`data-c` = c, `data-l` = $m.l, `data-n` = $m.n
      )#: title: text fmt"{m.n} cases"

proc plotLegend*[B](transform: string; C, L: OrdinalScale[B, string]): VNode =
  let box = 20 # TODO configurable?
  buildHtml(g(class = "labels", transform = transform)):
    for (i, p) in C.pairs.toSeq.pairs:
      rect(x = $0, y = $(box * (C.len - 1 - i)), width = $box, height = $box, fill = p[1])

proc plotLabels*[B](title, x, y: string;
                        m: Margin;
                        X, Y: LinearScale[float, float];
                        C, L: OrdinalScale[B, string]): VNode =
    let
      top = -m.t/4
      right = X.range.upper.get + m.r/4
      bottom = Y.range.upper.get + m.b*3/4
      left = X.range.lower.get - m.l/4
      padding = 20
    buildHtml(g(class = "labels")):
      # special case `stext` from karax/vdom
      stext(x = $0, y = $top): text title
      stext(x = $X.range.centre, y = $bottom, class = "x"): text fmt"proportion by {x}"
      stext(x = $left, y = $Y.range.centre, class = "y", transform = fmt"rotate(-90 {left} {Y.range.centre})"):
        text fmt"proportion by {y}"
      plotLegend(transform = fmt"translate({X.range.upper.get.int + padding} 0)", C, L)
