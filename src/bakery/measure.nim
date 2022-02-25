## Scale and bin (pale imitation of d3js).

import std / [sequtils, tables, options, sugar, math, strformat, logging]

# Can imagine needing to refactor completely once requirements expand.
# Only implement exactly what's needed at this stage to minimise busywork.

type
# Try distinct types rather than object variants (tagged unions) which need distinct field names.
  OrdinalScale*[D, R] = OrderedTable[D, R]
  ThresholdScale[D, R] = tuple
    domain: seq[D]
    range: seq[R]
  Bounds[T] = tuple
    lower, upper: Option[T]
  LinearScale*[D, R] = object
    domain*: Bounds[D]
    range*: Bounds[R]
    # y = mx + b
    m: float
    b: R
  Margin* = tuple
    t, r, b, l: int

# NB diverging from `initOrdinalScale` naming convention, may regret this.
    
func ordinalScale*[D, R](d: seq[D], r: seq[R]): OrdinalScale[D, R] =
  doAssert d.len == r.len
  zip(d, r).toOrderedTable
  
func ordinalScale*[T, D, R](s: ThresholdScale[T, D], r: seq[R]): OrdinalScale[D, R] =
  ordinalScale(s.range, r)

func domain*[D, R](s: OrdinalScale[D, R]): seq[D] =
  s.keys.toSeq

func range*[D, R](s: OrdinalScale[D, R]): seq[R] =
  s.values.toSeq
                                   
func thresholdScale*[D, R](d: seq[D], r: seq[R]): ThresholdScale[D, R] =
  doAssert d.len == r.len - 1
  result.domain = d
  result.range = r

func thresholdScale*[D, R](d: (int) -> D, r: seq[R]): ThresholdScale[D, R] =
  result.domain = collect(for i in 0..r.len: d(i))
  result.range = r

func thresholdScale*[R](r: seq[R]): ThresholdScale[R, R] =
  result.domain = r[0..^2]
  result.range = r
  
func bounds*[T](lower, upper: T): Bounds[T] =
  result.lower = some(lower)
  result.upper = some(upper)

func lowerBound*[T](v: T): Bounds[T] =
  result.lower = some(v)

func upperBound*[T](v: T): Bounds[T] =
  result.upper = some(v)
  
func linearScale*[D, R](d: Bounds[D], r: Bounds[R]): LinearScale[D, R] =
  ## Calculate scale and offset according to supplied "bounds" (really reference points).
  ## If one domain bound and the other range bound is defined, flip using db + delta -> rb - delta.
  let invalidRange = newException(RangeDefect, "Invalid range combination: " & $d & ", " & $r)
  
  if d.lower.isSome and d.upper.isSome:
    doAssert d.lower.get < d.upper.get, "Lower domain bound must be less than upper."

  # Needed for clamping.
  result.domain = d
  result.range = r

  # Calculate m and b now rather than on each `scale` call.
  var m: float
  if d.lower.isSome:
     if d.upper.isSome: # may flip if r bounds in reverse order
       if r.lower.isNone and r.upper.isNone:
         raise invalidRange
       else:
         m = (r.upper.get - r.lower.get).float / (d.upper.get - d.lower.get).float
     elif r.upper.isSome: # flip
       m = -1.0
     else:
       m = 1.0
  elif d.upper.isSome and r.lower.isSome: # flip
    m = -1.0
  else:
    m = 1.0
  result.m = m
  
  proc b(r: Option[R], d: Option[D]): R =
    R(r.get.float - d.get.float * m)
  if d.lower.isSome:               
    if r.lower.isSome:
      result.b = b(r.lower, d.lower)
    elif r.upper.isSome: # flip
      result.b = b(r.upper, d.lower)
    else:
      raise invalidRange
  elif d.upper.isSome:
    if r.upper.isSome:
      result.b = b(r.upper, d.upper)
    elif r.lower.isSome: # flip
      result.b = b(r.lower, d.upper)
    else:
      raise invalidRange
  else:
    result.b = R(0)
               
func `~=`*[T: SomeFloat](x, y: T): bool =
  almostEqual(x, y)
  
func steps*[T](low, step: T): (int) -> T =
  (i: int) => low + i.T*step
 
proc steps*[T](low, step: T; n: int): seq[T] =
  let fn = steps(low, step)
  # This use of `fn` trips side effect detector hence `proc`:
  collect(for i in 0..<n: fn(i))
    
func bin*[D, R](s: ThresholdScale[D, R], v: D): R =
  ## Bin using <=
  for i, lim in s.domain:
    if v <= lim:
      return s.range[i]
  return s.range[^1]

proc label*[D, R](s: ThresholdScale[D, R]): OrdinalScale[D, string] =
  var labels = collect(for step in s.range[0..^2]: fmt"≤ {step}")
  labels.add(fmt"> {s.range[^1]}")
  ordinalScale(s.range, labels)
  
func bin*[D, R](s: OrdinalScale[D, R], v: D): R {.raises: [KeyError].} =
  return s[v]
  
proc scale*[D, R](s: LinearScale[D, R], x: D): R =
  ## Does not enforce bounds.
  result = R(s.m * x.float) + s.b
  #echo fmt"{result} = {s.m}·{x} + {s.b}"

proc clampScale*[D, R](s: LinearScale[D, R], x: D): R =
  ## Enforces bounds.
  let
    l = s.domain.lower
    u = s.domain.upper
  if l.isSome and x < l.get:
    s.scale(l.get)
  elif u.isSome and x > u.get:
    s.scale(u.get)
  else:
    s.scale(x)

func centre*[T](b: Bounds[T]): T =
  (b.upper.get - b.lower.get)/2 + b.lower.get
