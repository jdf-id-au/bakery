import std/[parsecsv,json]
import std/[strutils,sequtils,sugar,sets,math]

type
  Row = seq[string]
  Shopping = object
    data*: JsonNode
    headers*: seq[string]

const
  MAX_SAFE_INTEGER* = 2^53 - 1 # javascript, avoiding BigInt
  TRUE = "TRUE"
  FALSE = "FALSE"
    
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
    case s:
      of TRUE, FALSE:
        return JBool
      else:
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
  elif ts <= [JBool, JNull].toHashSet:
    return JBool
  else:
    raise newException(ValueError, "Inconsistent types: " & $ts)

proc inferTypes(rows: seq[Row], header: Row): seq[JsonNodeKind] =
  result = newSeq[JsonNodeKind](header.len)
  for i, c in header.pairs: # Header column names actually unused here.
    result[i] = rows.map((r) => r[i]).inferType

proc `%`(k: JsonNodeKind, val: string): JsonNode =
  ## Convert string to JsonNode. Sanity checking should already have been done by `inferType`.
  let s = val.strip()
  if s == "":
    return newJNull() # Consider storing JNull as `""`: two fewer bytes than `null`?
  case k:
    of JNull:
      return newJNull()
    of JBool:
      case s:
        of TRUE:
          return %true
        of FALSE:
          return %false
    of JInt:
      return %s.parseInt
    of JFloat:
      return %s.parseFloat
    of JString:
      return %(s.multiReplace(("\\", ""), ("\"", "")))
    else:
      raise newException(ValueError, "Unsupported node kind: " & $k & " containing: " & s & ".")

proc shop*(paths: seq[string]): Shopping =
  ## Shop for ingredients (get data). Reads everything into memory!
  var
    cp: CsvParser
    headers: Row
    vals: seq[Row]
    nodes: seq[JsonNode] # will eventually be array of arrays
    
  for p in paths:
    cp.open(p)
    cp.readHeaderRow
    if headers.len == 0:
      headers = cp.headers
    else:
      doAssert(headers == cp.headers, "Inconsistent headers.")
    while cp.readRow:
      # FIXME parser can't cope with NUL between quotes. Need to pre-ingest file and fix.
      #echo cp.row
      vals.add(cp.row)
    cp.close
    
  let types = vals.inferTypes(headers)

  for r in vals:
    var row: seq[JsonNode]
    for i, t in types.pairs:
      row.add(t%r[i])
    nodes.add(%row)
  result.data = %nodes
  result.headers = headers
