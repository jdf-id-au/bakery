import bakery/ingredients

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

assert "1".inferType == ctInt
assert inferType("9007199254740991") == ctInt
raises inferType("9007199254740992") == ctInt, RangeDefect
raises inferType("-9007199254740992") == ctInt, RangeDefect
assert "1.0".inferType == ctInt
assert "1.1".inferType == ctFloat
assert "".inferType == ctNull
assert "a".inferType == ctString

assert @["1.0","2"," 3 "].inferType == ctInt
assert @[" 1.0","1.1"," "].inferType == ctFloat
raises @["1","a"].inferType == ctNull, ValueError
