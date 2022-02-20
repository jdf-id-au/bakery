import std / math
import bakery / measure

let
  intTS = thresholdScale(steps(0, 1), steps(0, 1, 5))
  floatTS = thresholdScale(steps(0.5, 1.0), steps(0, 1, 5))
  ifLS = linearScale(bounds(10, 20), bounds(5.0, 55.0))
  fiLS = linearScale(bounds(5.0, 55.0), bounds(10, 20))
  invLS = linearScale(bounds(0, 10), bounds(100, 90))
  flipLS = linearScale(lowerBound(1.0), upperBound(10.0))
                       
doAssertRaises(AssertionDefect):
  discard thresholdScale(steps(0, 1, 4), steps(0, 1, 4))
             
doAssert intTS.bin(7) == 4
doAssert floatTS.bin(1.5) == 2
doAssert ifLS.scale(15) ~= 30.0
doAssert fiLS.scale(30.0) == 15
doAssert invLS.scale(4) == 96
doAssert flipLS.scale(3.0) ~= 8.0
doAssert ifLS.clampScale(30) ~= 55.0
