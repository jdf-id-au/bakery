import std / [math, times, options]
import bakery / measure

block intThreshold:
  let s = thresholdScale(steps(0,1,5))
  doAssert s.domain == @[0,1,2,3], "Set domain from range."
  doAssert s.bin(-1) == 0, "Handle below domain."
  doAssert s.bin(10) == 4, "Handle above domain."

block floatThreshold:
  let s = thresholdScale(steps(0.0,0.5,10))
  doAssert s.bin(3.0) ~= 3.0, "Bin float sanely."

block intIntThreshold:
  let s = thresholdScale(steps(0,1), steps(0,1,5))
  doAssert s.bin(3) == 3, "Bin int sanely."

block floatIntThreshold:
  let s = thresholdScale(steps(-0.5,1.0), steps(0,1,5))
  doAssert s.bin(1.5) == 2, "Simulate round for positive numbers."

block autoDatetimeFloatLinear:
  let s = linearScale(@[dateTime(2020, mJan, 20), dateTime(2021, mDec, 10), dateTime(2021, mFeb, 3)], bounds(0.0, 1.0))
  doAssert s.domain.lower == some(dateTime(2020, mJan, 20))
  doAssert s.domain.upper == some(dateTime(2021, mDec, 10))

block autoIntFloatLinear:
  let s = linearScale(@[3,1,2,5], bounds(0.0, 1.0))
  doAssert s.domain.lower == some(1)
  doAssert s.domain.upper == some(5)
  doAssert s.scale(3) ~= 0.5
  
# TODO reformat these as above:
let
  ifLS = linearScale(bounds(10, 20), bounds(5.0, 55.0))
  fiLS = linearScale(bounds(5.0, 55.0), bounds(10, 20))
  invLS = linearScale(bounds(0, 10), bounds(100, 90))
  flipLS = linearScale(lowerBound(1.0), upperBound(10.0))
  offsLS = linearScale(lowerBound(5), lowerBound(100))
  uoffsLS = linearScale(upperBound(5), upperBound(100))
                       
doAssertRaises(AssertionDefect):
  discard thresholdScale(steps(0, 1, 4), steps(0, 1, 4))

doAssert ifLS.scale(15) ~= 30.0
doAssert fiLS.scale(30.0) == 15
doAssert invLS.scale(4) == 96
doAssert flipLS.scale(3.0) ~= 8.0
doAssert ifLS.clampScale(30) ~= 55.0
doAssert offsLS.scale(10) == 105
doAssert uoffsLS.scale(10) == 105
