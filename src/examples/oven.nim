## Render static visualisation, to be picked up by DOM manipulation when js available.

import std / [json, options]
import karax / [karaxdsl, vdom]
import .. / bakery / ingredients

proc anaes_temp(sh: Shopping): seq[tuple[anaes: Option[int], temp: Option[float]]] =
  proc ANAESTHETIST(row: JsonNode): Option[int] =
    let e = sh.headers.get(row, "ANAESTHETIST")
    if e.kind == JNull:
      return none(int)
    else:
      return some(e.getInt)
      
  proc TEMPERATURE_INITIAL(row: JsonNode): Option[float] =
    ## Scope for eventual macroification...
    let e = sh.headers.get(row, "TEMPERATURE_INITIAL")
    if e.kind == JNull:
      return none(float)
    else:
      return some(e.getFloat)

  for r in sh.data.getElems:
    result.add((r.ANAESTHETIST, r.TEMPERATURE_INITIAL))

proc bake*(sh: Shopping): string =     
  let vnode = buildHtml(tdiv()):
    ul:
      for (a,t) in sh.anaes_temp:
        li: text $a & $t
  result = $vnode
