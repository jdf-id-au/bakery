import std/[parsecsv,strutils,sequtils,sugar,sets,math]

type
  Row = seq[string]
  ColType* = enum
  # TODO decimal vs float
    ctInt, ctFloat, ctString, ctNull

let
  MAX_SAFE_INTEGER* = 2^53 - 1 # javascript, avoiding BigInt
    
proc inferType*(val: string): ColType =
  var s = val.strip
  if s == "":
    return ctNull
  try:
    let f = s.parseFloat
    try:
      let i = s.parseInt
      if i < -MAX_SAFE_INTEGER or i > MAX_SAFE_INTEGER:
        raise newException(RangeDefect, "Integer out of js Number range: " & s)
      return ctInt
    except ValueError:
      if s.find('.') == -1:
        # Don't represent overrange ints as floats.
        raise newException(RangeDefect, "Integer out of range: " & s)
    # integerOutOfRangeError should propagate
    if f.int.float == f:
      return ctInt
    else:
      return ctFloat
  except ValueError:
    return ctString

proc inferType*(vals: seq[string]): ColType =
  let ts = collect:
    for v in vals:
      {v.inferType}
  if ts == [ctNull].toHashSet:
    return ctNull
  elif ts <= [ctInt, ctNull].toHashSet:
    return ctInt
  elif ts <= [ctInt, ctFloat, ctNull].toHashSet:
    return ctFloat
  elif ts <= [ctString, ctNull].toHashSet:
    return ctString
  raise newException(ValueError, "Incompatible types: " & $ts)

proc inferType(rows: seq[Row], header: Row, col: string): ColType =
  result = ctNull
  let i = header.find(col)
  doAssert(i >= 0, "Invalid column name.")
  result = rows.map((r) => r[i]).inferType
  
proc shop*(paths: seq[string]) =
  ## Shop for ingredients (get data).
  var
    cp: CsvParser
    h: Row
    vals: seq[Row]
    
  for p in paths:
    cp.open(p)
    cp.readHeaderRow
    if h.len == 0:
      h = cp.headers
    else:
      doAssert(h == cp.headers, "Inconsistent headers.")
    while cp.readRow:
      vals.add(cp.row)
    cp.close
    
