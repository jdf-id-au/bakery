## Render static visualisation, to be picked up by DOM manipulation when js available.

import std / [json, options]
import karax / [karaxdsl, vdom]
import .. / bakery / ingredients

proc get(headers: seq[string], row: JsonNode, col: string): JsonNode =
  let i = headers.find(col)
  return row.getElems[i]

proc bake*(sh: Shopping): string =
  let rows = sh.data.getElems

  proc TEMPERATURE_INITIAL(r: JsonNode): Option[float] =
    ## Scope for eventual macroification...
    let e = sh.headers.get(r, "TEMPERATURE_INITIAL")
    if e.kind == JNull:
      return none(float)
    else:
      return some(e.getFloat)
      
  let vnode = buildHtml(tdiv()):
    svg:
      for r in rows:
        let p = r.TEMPERATURE_INITIAL
        if p.isSome:
          circle(cx= $p.get, cy="5", r="10")
        else:
          rect(x= $0, y= $0, width= $10, height= $10)
  result = $vnode
