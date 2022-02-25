import mustache

# Actually just needed html `<meta charset="UTF-8">`

let
  s = "{{{direct}}}"
  c = newContext()
c["direct"] = "°≤"
doAssert s.render(c) == "°≤"
