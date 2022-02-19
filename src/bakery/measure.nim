import std / [sequtils, sugar, math]

# Can imagine needing to refactor completely once requirements expand.
# Only implement exactly what's needed at this stage to minimise busywork.

type
  SequentialType = array | seq
  
  # Cribbing a bit from d3.js.
  
  ScaleKind* = enum
    Ordinal, Threshold, Linear
    
  Scale*[D,R] = object
    kind: ScaleKind
    d: D # domain
    r: R # range

proc initScale*[D, R](k: ScaleKind, d: D, r: R): Scale[D, R] =
  result.kind = k
  # TODO type checking
  if result.kind == Threshold:
    if D is SequentialType:
      doAssert d.len == r.len - 1
  result.d = d
  result.r = r

proc `~=`*[T: SomeFloat](x, y: T): bool =
  almostEqual(x, y)
  
proc steps*[T](low, step: T; n: int): seq[T] =
  for i in 0..<n:
    result.add(low + step * i.T)
    
proc bin*[T](lims: seq[T], v: T): T =
  ## Identify range-determined bin into which the value falls (identified by exclusive upper limit).
  for s in lims:
    when T is int:
      if v <= s:
        return s
    else:
      if v < s:
        return s
  return lims[^1]

