import std / [options, tables, sugar, stats, sequtils]
import itertools
import ingredients

type
  Pair[X, Y] = tuple[x: X, y: Y]
  Grouped[K, V] = OrderedTable[K, seq[V]]

iterator points*[X, Y](sh: Shopping; x, y: string): Pair[Option[X], Option[Y]] =
  ## TODO generalise to >2 vals? varargs and typedesc?
  for r in sh.data.getElems:
    yield ((get[X](sh, r, x), get[Y](sh, r, y)))

iterator someitems*[T](a: openArray[Option[T]]): T =
  # TODO learn about lent2 and {.inline.}
  for v in a:
    if v.isSome:
      yield v.get

proc somelen*[T](a: openArray[Option[T]]): int =
  for v in a:
    if v.isSome:
      result.inc

template groupBy*[T, U](s: iterable[T], f: proc(a: T): U): Grouped[T, U] =
  # TODO could this return an iterable??
  # TODO submit to itertools if it works??
  # https://nim-lang.org/docs/manual.html#overload-resolution-iterable
  var ret: Grouped[T, U]
  for v in s:
    let g = f(v)
    if ret.hasKey(g):
      ret[g].add(v)
    else:
      ret[g] = @[v]
  ret
      
proc group*[K, V](a: openArray[Pair[K, V]]): Grouped[K, V] =
  for (k, v) in a:
    if result.hasKey(k):
      result[k].add(v)
    else:
      result[k] = @[v]

# proc meanVal*(a, b: (Option[int], openArray[Option[float]])): int =
#   cmp(a[1].someitems.toSeq.mean, b[1].someitems.toSeq.mean)
    
proc meanVal*[K, V](a, b: (Option[K], openArray[Option[V]])): int =
  ## For use with Grouped.sort (which comes from OrderedTable.sort)
  cmp(a[1].someitems.toSeq.mean, b[1].someitems.toSeq.mean)

# proc meanVal*[K, V](a, b: (K, openArray[V])): int =
#   cmp(a[1].mean, b[1].mean)
