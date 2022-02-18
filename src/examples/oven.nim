## Render static visualisation, to be picked up by DOM manipulation when js available.

import std / [json, options, tables]
import karax / [karaxdsl, vdom]
import .. / bakery / ingredients

type
  OPair[X, Y] = tuple
    x: Option[X]
    y: Option[Y]
  Grouped[K, V] = OrderedTable[Option[K], seq[Option[V]]]

proc anaes_temp(sh: Shopping): seq[OPair[int, float]] =
  for r in sh.data.getElems:
    result.add((get[int](sh, r, "ANAESTHETIST"), get[float](sh, r, "TEMPERATURE_INITIAL")))

proc grouped[K,V](data: seq[OPair[K,V]]): Grouped[K,V] =
  ## Keys in order of first insertion for the moment.
  for (k, v) in data:
    if result.hasKey(k):
      result[k].add(v)
    else:
      result[k] = @[v]
      
proc bake*(sh: Shopping): string =
  let vnode = buildHtml(tdiv()):
    ul:
      for (a,t) in sh.anaes_temp.grouped.pairs:
        li: text $a & $t
  result = $vnode
