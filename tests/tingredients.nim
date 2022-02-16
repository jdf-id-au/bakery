import bakery/ingredients
import std/json

template raises(p, e: untyped): untyped =
  try:
    if p:
      echo $e, " was expected but not raised." # TODO move to assert message
      assert false
  except e:
    assert true
  except:
    let
      ex = getCurrentException()
      msg = getCurrentExceptionMsg()
    echo $e, " was expected but ", ex.name, " was raised instead with \"", msg, "\"."
    assert false

assert "1".inferType == JInt
assert inferType("9007199254740991") == JInt # Javascript MAX_SAFE_INTEGER
raises inferType("9007199254740992") == JInt, RangeDefect
raises inferType("-9007199254740992") == JInt, RangeDefect
assert "1.0".inferType == JInt
assert "1.1".inferType == JFloat
assert "".inferType == JNull
assert "a".inferType == JString
assert "TRUE".inferType == JBool

assert @["1.0","2"," 3 "].inferType == JInt # NB
assert @[" 1.0","1.1"," "].inferType == JFloat
raises @["1","a"].inferType == JNull, ValueError
