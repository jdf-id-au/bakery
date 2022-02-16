import std / [dom, jscore, jsconsole]

let
  b = document.querySelector("body")
  p = document.createElement("p")
p.innerHTML = "hello"
b.appendChild(p)
