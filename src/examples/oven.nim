## Render static visualisation, to be picked up by DOM manipulation when js available.

import std / [json, options, tables, strformat]
import karax / [karaxdsl, vdom]
import .. / bakery / [ingredients, mixer]

proc bake*(sh: Shopping): string =
  let
    d = (w: 1000, h: 500)
    m = (t: 30, r: 150, b: 0, l: 20)
    s = (w: d.w + m.l + m.r, h: d.h + m.t + m.b)
    
    ps = points[int, float](sh, "ANAESTHETIST", "TEMPERATURE_INITIAL")
    
  var psg = ps.group # sort in place!
  psg.sort(meanVal)
  
  let vnode = buildHtml(svg(width="100%", viewBox=fmt"{-m.l} {-m.t} {s.w} {s.h}")):
    g:
      # OrderedTable.sort only sorts keys; will need to impl own to sort by vals.
      for (k, vs) in psg.pairs:
        for (i, v) in vs.pairs:
          circle(cx = $i, cy = $i, r = $4)
  result = $vnode
