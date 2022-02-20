import std / [sequtils, tables, options, sugar, math]

# Can imagine needing to refactor completely once requirements expand.
# Only implement exactly what's needed at this stage to minimise busywork.

type
# Try distinct types rather than object variants (tagged unions) which need distinct field names.
  OrdinalScale[D, R] = OrderedTable[D, R]
  ThresholdScale[D, R] = tuple
    domain: seq[D]
    range: seq[R]
  Bounds[T] = tuple
    lower, upper: Option[T]
  LinearScale[T] = tuple
    # y = mx + b
    m, b: T

# NB diverging from `initOrdinalScale` naming convention, may regret this.
    
func ordinalScale*[D, R](d: seq[D], r: seq[R]): OrdinalScale[D, R] =
  # TODO just use OrderedTable underneath?
  doAssert d.len == r.len
  zip(d, r).toOrderedTable
  
func ordinalScale*[T, D, R](s: ThresholdScale[T, D], r: seq[R]): OrdinalScale[D, R] =
  ordinalScale(s.range, r)
  
func thresholdScale*[D, R](d: seq[D], r: seq[R]): ThresholdScale[D, R] =
  doAssert d.len == r.len - 1
  result.domain = d
  result.range = r

func thresholdScale*[D, R](d: (int) -> D, r: seq[R]): ThresholdScale[D, R] =
  result.domain = collect(for i in 0..r.len: d(i))
  result.range = r

func bounds*[T](lower, upper: T): Bounds[T] =
  result.lower = some(lower)
  result.upper = some(upper)

func lowerBound*[T](v: T): Bounds[T] =
  result.lower = some(v)

func upperBound*[T](v: T): Bounds[T] =
  result.upper = some(v)
  
func linearScale*[D, R](d: Bounds[D], r: Bounds[R]): LinearScale[R] =
  if d.lower.isSome: doAssert r.lower.isSome
  if d.upper.isSome: doAssert r.upper.isSome
  result.m = if d.lower.isSome and d.upper.isSome:
               (r.upper.get - r.lower.get) / (d.upper.get - d.lower.get).R
             else:
               1.R
  result.b = if d.lower.isSome and r.lower.isSome:
               r.lower.get - d.lower.get.R
             elif d.upper.isSome and r.upper.isSome:
               r.upper.get - d.upper.get.R
             else:
               0.R
               
func `~=`*[T: SomeFloat](x, y: T): bool =
  almostEqual(x, y)
  
func steps*[T](low, step: T): (int) -> T =
  (i: int) => low + i.T*step
 
proc steps*[T](low, step: T; n: int): seq[T] =
  let fn = steps(low, step)
  # This use of `fn` trips side effect detector hence `proc`:
  collect(for i in 0..<n: fn(i))
    
func bin*[D, R](s: ThresholdScale[D, R], v: D): R =
  ## Call math.round instead for simple float->int conversion.
  for i, lim in s.domain:
    when D is int:
      if v <= lim:
        return s.range[i]
    else:
      if v < lim:
        return s.range[i]
  return s.range[^1]

func bin*[D, R](s: OrdinalScale[D, R], v: D): R {.raises: [KeyError].} =
  s[v]

func scale*[D, R](s: LinearScale[R], x: D): R =
  s.m * x.R + s.b
