module Api = {
  type t
  type parseOptions = {plugins: array<[#jsx]>}
  @get external version: t => string = "version"
  @send external assertVersion: (t, @unwrap [#Major(int) | #Str(string)]) => unit = "assertVersion"
  @send @scope("template") external templateAst: (t, string, parseOptions) => 'node = "ast"
  @get external types: t => 'a = "types"
}

module Plugin = {
  type t
  external make: (@uncurry (Api.t, 'options) => 'a) => t = "%identity"
}

module TransformOptions = {
  type t
  type pluginOption
  external builtPlugin: [>
    | #"external-helpers"
    | #"syntax-async-generators"
    | #"syntax-class-properties"
    | #"syntax-class-static-block"
    | #"syntax-decimal"
    | #"syntax-decorators"
    | #"syntax-destructuring-private"
    | #"syntax-do-expressions"
    | #"syntax-export-default-from"
    | #"syntax-flow"
    | #"syntax-function-bind"
    | #"syntax-function-sent"
    | #"syntax-module-blocks"
    | #"syntax-import-meta"
    | #"syntax-jsx"
    | #"syntax-import-assertions"
    | #"syntax-object-rest-spread"
    | #"syntax-optional-catch-binding"
    | #"syntax-pipeline-operator"
    | #"syntax-record-and-tuple"
    | #"syntax-top-level-await"
    | #"syntax-typescript"
    | #"proposal-async-generator-functions"
    | #"proposal-class-properties"
    | #"proposal-class-static-block"
    | #"proposal-decorators"
    | #"proposal-do-expressions"
    | #"proposal-dynamic-import"
    | #"proposal-export-default-from"
    | #"proposal-export-namespace-from"
    | #"proposal-function-bind"
    | #"proposal-function-sent"
    | #"proposal-json-strings"
    | #"proposal-logical-assignment-operators"
    | #"proposal-nullish-coalescing-operator"
    | #"proposal-numeric-separator"
    | #"proposal-object-rest-spread"
    | #"proposal-optional-catch-binding"
    | #"proposal-optional-chaining"
    | #"proposal-pipeline-operator"
    | #"proposal-private-methods"
    | #"proposal-private-property-in-object"
    | #"proposal-throw-expressions"
    | #"proposal-unicode-property-regex"
    | #"transform-async-to-generator"
    | #"transform-arrow-functions"
    | #"transform-block-scoped-functions"
    | #"transform-block-scoping"
    | #"transform-classes"
    | #"transform-computed-properties"
    | #"transform-destructuring"
    | #"transform-dotall-regex"
    | #"transform-duplicate-keys"
    | #"transform-exponentiation-operator"
    | #"transform-flow-comments"
    | #"transform-flow-strip-types"
    | #"transform-for-of"
    | #"transform-function-name"
    | #"transform-instanceof"
    | #"transform-jscript"
    | #"transform-literals"
    | #"transform-member-expression-literals"
    | #"transform-modules-amd"
    | #"transform-modules-commonjs"
    | #"transform-modules-systemjs"
    | #"transform-modules-umd"
    | #"transform-named-capturing-groups-regex"
    | #"transform-new-target"
    | #"transform-object-assign"
    | #"transform-object-super"
    | #"transform-object-set-prototype-of-to-assign"
    | #"transform-parameters"
    | #"transform-property-literals"
    | #"transform-property-mutators"
    | #"transform-proto-to-assign"
    | #"transform-react-constant-elements"
    | #"transform-react-display-name"
    | #"transform-react-inline-elements"
    | #"transform-react-jsx"
    | #"transform-react-jsx-compat"
    | #"transform-react-jsx-development"
    | #"transform-react-jsx-self"
    | #"transform-react-jsx-source"
    | #"transform-regenerator"
    | #"transform-reserved-words"
    | #"transform-runtime"
    | #"transform-shorthand-properties"
    | #"transform-spread"
    | #"transform-sticky-regex"
    | #"transform-strict-mode"
    | #"transform-template-literals"
    | #"transform-typeof-symbol"
    | #"transform-typescript"
    | #"transform-unicode-escapes"
    | #"transform-unicode-regex"
  ] => pluginOption = "%identity"

  external pluginFn: Plugin.t => pluginOption = "%identity"

  external pluginFnWith: ((Plugin.t, 'option)) => pluginOption = "%identity"

  @obj
  external make: (
    ~ast: bool=?,
    ~code: bool=?,
    ~retainLines: bool=?,
    ~sourceType: [#script | #"module" | #unambiguous]=?,
    ~plugins: array<pluginOption>=?,
    ~presets: array<
      [>
        | #env
        | #react
        | #typescript
        | #flow
        | #es2015
        | #es2016
        | #es2017
        | #"stage-0"
        | #"stage-1"
        | #"stage-2"
        | #"stage-3"
        | #"es2015-loose"
        | #"es2015-no-commonjs"
      ],
    >=?,
    unit,
  ) => t = ""
}

type transformOptions

type fileResult<'node> = {
  metadata: {.},
  options: {.},
  ast: Js.Null.t<'node>,
  code: Js.Null.t<string>,
  map: {.},
  sourceType: [#string | #"module"],
}

@module("@babel/standalone")
external transform: string => fileResult<'node> = "transform"

@module("@babel/standalone")
external transformWith: (string, TransformOptions.t) => fileResult<'node> = "transform"

module Path = {
  type t
  @send external getPathLocation: t => string = "getPathLocation"

  @ocaml.doc("给定 Babel 路径，计算该路径对应的片段") @genType
  let getSegments = (path: t): array<string> => {
    open Js.String2
    path
    ->getPathLocation
    ->replaceByRe(%re("/\[(\w+)\]/g"), ".$1")
    ->replaceByRe(%re("/^\./"), "")
    ->split(".")
  }

  @get external node: t => 'node = "node"
  @send external replaceWith: (t, 'node) => unit = "replaceWith"
  @get external parent: t => 'node = "parent"
  @send external remove: t => unit = "remove"
}
