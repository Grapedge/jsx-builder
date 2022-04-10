// Babel 插件
open Babel

external toObj: 'a => Js.t<'b> = "%identity"

@ocaml.doc("Babel 插件：将 JSX 相关元素包裹 JsxUnitElement")
let wrapJsxUnitElement = Plugin.make((api, _) => {
  api->Api.assertVersion(#Major(7))
  let template = api->Api.templateAst
  let types = api->Api.types
  let buildWrapper = (path: string) =>
    template(
      `<JsxUnitElement path="${path}"></JsxUnitElement>`,
      {
        plugins: [#jsx],
      },
    )
  let isJsxUnitElement = node => {
    open Js.Nullable
    switch node->return->toOption {
    | Some(node) =>
      types["isJSXElement"](. node) && node["openingElement"]["name"]["name"] == "JsxUnitElement"
    | None => false
    }
  }
  let replaceWrapper = path => {
    let wrapper = (path->Path.getPathLocation->buildWrapper)["expression"]
    wrapper["children"] = [path->Path.node]
    path->Path.replaceWith(wrapper)
  }
  {
    "visitor": {
      "JSXElement": {
        "exit": path => {
          let node = path->Path.node
          let parent = path->Path.parent
          if !(parent->isJsxUnitElement || node->isJsxUnitElement) {
            path->replaceWrapper
          }
        },
      },
      "JSXText": {
        "exit": path => {
          let node = path->Path.node
          let parent = path->Path.parent
          if !(parent->isJsxUnitElement) && !(%re("/^\s*$/g")->Js.Re.test_(node["value"])) {
            path->replaceWrapper
          }
        },
      },
      "JSXExpressionContainer": {
        "exit": path => {
          let parent = path->Path.parent
          if (
            !(parent->isJsxUnitElement) &&
            (types["isJSXElement"](. parent) || types["isJSXFragment"](. parent))
          ) {
            path->replaceWrapper
          }
        },
      },
      "JSXFragment": {
        "exit": path => {
          if !(path->Path.parent->isJsxUnitElement) {
            path->replaceWrapper
          }
        },
      },
    },
  }
})

@ocaml.doc("Babel 插件：将所有导入替换为从 SCOPE 变量中读取")
let importFromSCOPE = Plugin.make((api, _) => {
  api->Api.assertVersion(#Major(7))
  let template = api->Api.templateAst
  let makeRead = name => template(`var ${name} = SCOPE["${name}"]`, {plugins: []})
  let vars = []
  let pushRead = path => {
    let _ = Js.Array2.push(vars, (path->Path.node)["local"]["name"]->makeRead)
    ()
  }
  {
    "visitor": {
      "ImportDefaultSpecifier": pushRead,
      "ImportSpecifier": pushRead,
      "ImportDeclaration": {
        "exit": Path.remove,
      },
      "Program": {
        "exit": path => {
          %raw("path.node.body.unshift(...vars)")
          ()
        }
      }
    },
  }
})
