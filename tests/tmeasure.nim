import std / math
import bakery / measure

let
  intSteps = steps(0, 1, 10)
  floatSteps = steps(0.5, 0.5, 10)

  someBins = initScale(Threshold,
                       steps(0, 1, 4),
                       steps(0, 1, 5))
                       
doAssert intSteps  == @[0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
doAssert bin(intSteps, 4) == 4
doAssert bin(floatSteps, 0.5) ~= 1.0
#doAssertRaises(AssertionDefect): discard initScale(Threshold, steps(0, 1, 4), steps(0, 1, 4))
             
