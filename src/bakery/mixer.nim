import std / [options, tables]

import ingredients

type
  OptionalPair[X, Y] = tuple
    x: Option[X]
    y: Option[Y]
    
  Grouped[K, V] = OrderedTable[Option[K], seq[Option[V]]]

proc points*[X, Y](sh: Shopping, x, y: string): seq[OptionalPair[X, Y]] =
  ## TODO generalise to >2 vals?
  for r in sh.data.getElems:
    result.add((get[X](sh, r, x), get[Y](sh, r, y)))

proc grouped*[K, V](data: seq[OptionalPair[K, V]]): Grouped[K, V] =
  ## Keys in order of first insertion for the moment.
  for (k, v) in data:
    if result.hasKey(k):
      result[k].add(v)
    else:
      result[k] = @[v]
