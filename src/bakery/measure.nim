import std / [sequtils, tables, options, sugar, math, strformat, logging]

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
    m: float
    b: T

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
  ## Calculate scale and offset according to supplied "bounds" (really reference points).
  ## If one lower and one upper bound is defined, flip using lower + delta -> upper - delta.
  let invalidRange = newException(RangeDefect, "Invalid range combination: " & $d & ", " & $r)
  var
    m: float
    b: R
  if d.lower.isSome:
     if d.upper.isSome: # may flip if r bounds in reverse order
       if r.lower.isNone and r.upper.isNone:
         raise invalidRange
       else:
         m = (r.upper.get - r.lower.get).float / (d.upper.get - d.lower.get).float
     elif r.upper.isSome: # flip
       m = -1.0
  elif d.upper.isSome and r.lower.isSome: # flip
    m = -1.0
  else:
    m = 1.0
  result.m = m
  # proc calcB(r: R, d: D): R =
  #   R(r.float - d.float * m)
  if d.lower.isSome:               
    if r.lower.isSome:
      b = R(r.lower.get.float - d.lower.get.float * result.m)
    elif r.upper.isSome: # flip only
      b = R(r.upper.get.float - d.lower.get.float * result.m)
    else:
      raise invalidRange
  elif d.upper.isSome:
    if r.upper.isSome:
      b = R(r.upper.get.float - d.upper.get.float * result.m)
    elif r.lower.isSome:
      b = R(r.lower.get.float - d.upper.get.float * result.m)
    else:
      raise invalidRange
  else:
    b = R(0)
  result.b = b
               
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

proc scale*[D, R](s: LinearScale[R], x: D): R =
  ## Does not enforce bounds.
  result = R(s.m * x.float) + s.b
  echo fmt"{s} {x} -> {result}"
