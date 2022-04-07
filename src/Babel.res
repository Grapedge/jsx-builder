// Babel 的 ReScript 绑定
module Node = {
  type t
}

@deriving(abstract)
type options = {@optional ast: bool}

@module("@bable/standalone")
external transform: (string, options) => Node.t = "transform"

module Path = {
  type t
  @send external getPathLocation: t => string = "getPathLocation"

  @ocaml.doc("给定 Babel 路径，计算该路径对应的片段")
  @genType
  let getSegments = (path: t): array<string> => {
    open Js.String2
    path
    ->getPathLocation
    ->replaceByRe(%re("/\[(\w+)\]/g"), ".$1")
    ->replaceByRe(%re("/^\./"), "")
    ->split(".")
  }
}
