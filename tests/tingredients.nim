import bakery/ingredients
import std/json

doAssert "1".inferType == JInt
doAssert inferType("9007199254740991") == JInt # Javascript MAX_SAFE_INTEGER
doAssertRaises(RangeDefect): discard inferType("9007199254740992") == JInt
doAssertRaises(RangeDefect): discard inferType("-9007199254740992") == JInt
doAssert "1.0".inferType == JInt
doAssert "1.1".inferType == JFloat
doAssert "".inferType == JNull
doAssert "a".inferType == JString
doAssert "TRUE".inferType == JBool
doAssert @["1.0","2"," 3 "].inferType == JInt # NB
doAssert @[" 1.0","1.1"," "].inferType == JFloat
doAssertRaises(ValueError): discard @["1","a"].inferType == JNull
