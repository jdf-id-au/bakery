import std / math
import bakery / measure

let
  intTS = thresholdScale(steps(0, 1), steps(0, 1, 5))
  floatTS = thresholdScale(steps(0.5, 1.0), steps(0, 1, 5))
  egLS = linearScale(bounds(0, 10), bounds(5.0, 55.0))
                       
doAssertRaises(AssertionDefect):
  discard thresholdScale(steps(0, 1, 4), steps(0, 1, 4))
             
doAssert intTS.bin(7) == 4
doAssert floatTS.bin(1.5) == 2
doAssert egLS.scale(5) == 30.0
