import std/[parsecsv,json]
import std/[strutils,sequtils,sugar,sets,math]

type
  Row = seq[string]

let
  MAX_SAFE_INTEGER* = 2^53 - 1 # javascript, avoiding BigInt
    
proc inferType*(val: string): JsonNodeKind =
  var s = val.strip
  if s == "":
    return JNull
  try:
    let f = s.parseFloat
    try:
      let i = s.parseInt
      if i < -MAX_SAFE_INTEGER or i > MAX_SAFE_INTEGER:
        raise newException(RangeDefect, "Integer out of js Number range: " & s)
      return JInt
    except ValueError:
      if s.find('.') == -1:
        # Don't let overrange ints fall through as floats.
        raise newException(RangeDefect, "Integer out of range: " & s)
    if f.int.float == f:
      return JInt
    else:
      return JFloat
  except ValueError:
    return JString

proc inferType*(vals: seq[string]): JsonNodeKind =
  let ts = collect:
    for v in vals:
      {v.inferType}
  if ts == [JNull].toHashSet:
    return JNull
  elif ts <= [JInt, JNull].toHashSet:
    return JInt
  elif ts <= [JInt, JFloat, JNull].toHashSet:
    return JFloat
  elif ts <= [JString, JNull].toHashSet:
    return JString
  raise newException(ValueError, "Incompatible types: " & $ts)

proc inferTypes(rows: seq[Row], header: Row): seq[JsonNodeKind] =
  result = newSeq[JsonNodeKind](header.len)
  for i, c in header.pairs: # Header column names actually unused here.
    result[i] = rows.map((r) => r[i]).inferType

proc `%`(k: JsonNodeKind, s: string): JsonNode =
  ## Convert string to JsonNode. Sanity checking should already have been done by `inferType`.
  let ss = s.strip()
  if ss == "":
    return newJNull()
  case k:
    of JNull:
      return newJNull()
    of JBool:
      case ss:
        of "TRUE":
          return %true
        of "FALSE":
          return %false
    of JInt:
      return %ss.parseInt
    of JFloat:
      return %ss.parseFloat
    of JString:
      return %ss # TODO drop backslash and quote?
    else:
      raise newException(ValueError, "Unsupported node kind: " & $k)

proc shop*(paths: seq[string]): JsonNode =
  ## Shop for ingredients (get data). Reads everything into memory!
  var
    cp: CsvParser
    header: Row
    vals: seq[Row]
    nodes: seq[JsonNode] # will eventually be array of arrays
    
  for p in paths:
    cp.open(p)
    cp.readHeaderRow
    if header.len == 0:
      header = cp.headers
    else:
      doAssert(header == cp.headers, "Inconsistent headers.")
    while cp.readRow:
      vals.add(cp.row)
    cp.close
    
  let types = vals.inferTypes(header)

  for r in vals:
    var row: seq[JsonNode]
    for i, t in types.pairs:
      row.add(t%r[i])
    nodes.add(%row)
  return %nodes
