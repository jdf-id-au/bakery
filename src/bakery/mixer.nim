import std / [options, tables, sugar]

import ingredients

type
  OptionPair[X, Y] = tuple
    x: Option[X]
    y: Option[Y]
    
  OptionGrouped[K, V] = OrderedTable[Option[K], seq[Option[V]]]
  Grouped[K, V] = OrderedTable[K, seq[V]]

proc points*[X, Y](sh: Shopping; x, y: string): seq[OptionPair[X, Y]] =
  ## TODO generalise to >2 vals?
  for r in sh.data.getElems:
    result.add((get[X](sh, r, x), get[Y](sh, r, y)))

proc somelen*[T](a: openArray[Option[T]]): int =
  for v in a:
    if v.isSome:
      result.inc
    
proc group*[K, V](data: seq[OptionPair[K, V]]): OptionGrouped[K, V] =
  ## Keys in order of first insertion for the moment. Can use OrderedTable.sort.
  # bit more explicit/straightforward/flexible than itertools?
  for (k, v) in data:
    if result.hasKey(k):
      result[k].add(v)
    else:
      result[k] = @[v]

proc getsome*[T](a: openArray[Option[T]]): seq[T] =
  for v in a:
    if v.isSome:
      result.add(v.get)

proc group*[K, V](data: seq[V], by: proc(v: V): K): Grouped[K, V] =
  for v in data:
    let k = v.by
    if result.hasKey(k):
      result[k].add(v)
    else:
      result[k] = @[v]
      
proc group*[K, V](data: seq[Option[V]], by: proc(v: Option[V]): Option[K]): OptionGrouped[K, V] =
  # TODO this might be better just from itertools
  for v in data:
    let k = v.by
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
