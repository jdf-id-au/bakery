import std / [options, tables, sugar]

import ingredients

type
  OptionalPair[X, Y] = tuple
    x: Option[X]
    y: Option[Y]
    
  Grouped[K, V] = OrderedTable[Option[K], seq[Option[V]]]

proc points*[X, Y](sh: Shopping; x, y: string): seq[OptionalPair[X, Y]] =
  ## TODO generalise to >2 vals?
  for r in sh.data.getElems:
    result.add((get[X](sh, r, x), get[Y](sh, r, y)))

proc group*[K, V](data: seq[OptionalPair[K, V]]): Grouped[K, V] =
  ## Keys in order of first insertion for the moment. Can use OrderedTable.sort.
  for (k, v) in data:
    if result.hasKey(k):
      result[k].add(v)
    else:
      result[k] = @[v]

proc mean*[V: int|float](vs: seq[Option[V]]): float =
  var
    sum: float
    n: int
  for v in vs:
    if v.isSome:
      sum += v.get
      inc n
  if n > 0:  
    return sum/n.float
  return n.float

proc meanVal*[K, V](a, b: (Option[K], seq[Option[V]])): int =
  ## For use with Grouped.sort (which comes from OrderedTable.sort)
  cmp(a[1].mean, b[1].mean)
