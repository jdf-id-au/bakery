## Coerce CSV data into JSON array of arrays of more-or-less typed values, with support for column accessors.

import std / [streams, parsecsv, json, logging]
import std / [strutils, strformat, sequtils, options, sugar, sets, math]

type
  Row = seq[string]
  Shopping* = ref object
    data*: JsonNode
    headers*: Row

const
  MAX_SAFE_INTEGER* = 2^53 - 1 # javascript, avoiding BigInt
  TRUE = "TRUE"
  FALSE = "FALSE"

var logger = newConsoleLogger()
addHandler(logger)

func inferType*(val: string): JsonNodeKind =
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
    return JFloat
  except ValueError:
    case s:
      of TRUE, FALSE:
        return JBool
      else:
        return JString

func inferType*(vals: seq[string]): JsonNodeKind =
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

func inferTypes(rows: seq[Row], header: Row): seq[JsonNodeKind] =
  result = newSeq[JsonNodeKind](header.len)
  for i, c in header.pairs: # Header column names actually unused here.
    result[i] = rows.map((r) => r[i]).inferType

func `%`(k: JsonNodeKind, val: string): JsonNode =
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

proc shop*(paths: seq[string]): Shopping = # `func` probably wouldn't allow `debug` logging
  ## Shop for ingredients (get data). Reads everything into memory!
  var
    cp: CsvParser
    headers: Row
    vals: seq[Row]
    nodes: seq[JsonNode] # will eventually be array of arrays
    
  for p in paths:
    var
      fs = openFileStream(p)
      loaded: string
    while not fs.atEnd:
      let c = fs.readChar
      if c != '\0':
        loaded.add(c)
      # else:
      #   debug "NUL at byte ", fs.getPosition, " in ", p # Thanks Cerner
    fs.close
    var ss = loaded.newStringStream
    cp.open(ss, p)
    cp.readHeaderRow
    if headers.len == 0:
      doAssert(headers.toHashSet.len == headers.len, "Repeated column names not supported.")
      headers = cp.headers
    else:
      doAssert(headers == cp.headers, "Inconsistent headers.")
    while cp.readRow:
      vals.add(cp.row)
    cp.close
    
  let types = vals.inferTypes(headers)

  for r in vals:
    var row: seq[JsonNode]
    for i, t in types.pairs:
      row.add(t%r[i])
    nodes.add(%row)

  return Shopping(data: %nodes, headers: headers)

proc accessors*(sh: Shopping): string =
  for i, h in sh.headers.pairs:
    var comma = if i!=sh.headers.high: "," else: ""
    result.add(fmt"{h}=a=>a[{i}]{comma}")

func get*[T](sh: Shopping, row: JsonNode, col: string): Option[T] =
  assert row.kind == JArray
  let i = sh.headers.find(col)
  assert i != -1
  let e = row.getElems[i]
  if e.kind == JNull:
    return none(T)
  when T is bool:
    if e.kind == JBool:
      return some(e.getBool)
  when T is int:
    if e.kind == JInt:
      return some(e.getInt)
  when T is float:
    if e.kind == JFloat:
      return some(e.getFloat)
  when T is string:        
    if e.kind == JString:
      return some(e.getString)
  raise newException(ValueError, "Unsupported node kind: " & $e.kind & " with " & $T)
