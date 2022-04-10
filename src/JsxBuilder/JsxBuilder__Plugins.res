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
    },
  }
})
