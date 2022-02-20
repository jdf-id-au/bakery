import std / [options, tables, sugar, stats, sequtils]
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

func somelen*[T](a: openArray[Option[T]]): int =
  for v in a:
    if v.isSome:
      result.inc

template groupBy*[V, G](s: iterable[V], f: proc(a: V): G): Grouped[G, V] =
  # https://nim-lang.org/docs/manual.html#overload-resolution-iterable
  var ret: Grouped[G, V]
  for v in s:
    let g = f(v)
    if ret.hasKey(g):
      ret[g].add(v)
    else:
      ret[g] = @[v]
  ret

# Can't get these working for ps.groupBy(key) -- confusing type mismatch for `sort` proc
# proc groupBy*[V, G](s: seq[V], f: proc(a: V): G): Grouped[G, V] =
#   return groupBy(s.items, f)
# proc key*[K, V](p: Pair[K, V]): K =
#   p.x

func groupByKey*[K, V](a: openArray[Pair[K, V]]): Grouped[K, V] =
  for (k, v) in a:
    if result.hasKey(k):
      result[k].add(v)
    else:
      result[k] = @[v]

# background https://nullbuffer.com/articles/welford_algorithm.html
func someMeanVal*[K, V](a, b: (Option[K], seq[Option[V]])): int = # needs to be seq, not openArray; learn why...
  ## For use with Grouped.sort (which comes from OrderedTable.sort)
  cmp(a[1].someitems.toSeq.mean, b[1].someitems.toSeq.mean)

func meanVal*[K, V](a, b: (K, seq[V])): int =
  cmp(a[1].mean, b[1].mean)
