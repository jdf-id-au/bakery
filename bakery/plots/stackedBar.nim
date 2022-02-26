import std / [json, options, tables, strformat, sugar]
import karax / [karaxdsl, vdom]
import .. / .. / bakery / [mixer, measure]

type
  Mark[C, L] = object
    x, y, w, h: float
    c: C # column (after layerPlot work)
    l: L # layer (might need to rename both)
    n: int

proc plot*[X, Y](ps: seq[Triple[Option[X], Option[Y], Option[int]], # third element of triple is count
                 xs, ys: LinearScale[float, float],
                 cs: OrdinalScale[Y, string]): VNode = # ordinal scale defines stacking order and colour
    var
      colOffset: int
      marks: seq[Mark[X,Y]]
    buildHtml(g(class = "marks")):
      for m in marks:
        rect(x = xs.scale().f1, y = ys.scale().f1,
                 width = xs.scale().f1, height = ys.scale().f1, fill = cs.bin(m.l))
