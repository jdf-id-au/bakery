## Render static visualisation, to be picked up by DOM manipulation when js available.

import std / [json, options, tables]
import karax / [karaxdsl, vdom]
import .. / bakery / [ingredients, mixer]

proc bake*(sh: Shopping): string =
  let ps = points[int, float](sh, "ANAESTHETIST", "TEMPERATURE_INITIAL")
  let vnode = buildHtml(tdiv()):
    ul:
      for (a,t) in ps.grouped.pairs:
        li: text $a & $t
  result = $vnode
