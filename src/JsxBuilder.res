module Renderer: {
  type t
  @ocaml.doc("
  将原始代码转为可渲染的代码。这会进行：
  1. 将所有导入替换为从 SCOPE 变量中读取；
  2. 将 export default 的内容使用容器包裹；
  3. 将 named export 转为变量声明；
  4. 将 JSX 转为 React.createElement
  5. 最关键的一步，为以下节点包裹 JsxUnitElement 标签：
      - JSXText：文本节点
      - JSXElement：JSX 元素节点
      - JSXFragment：JSX 片段节点
      - JSXExpressionContainer：表达式节点，同时表达式容器不应为 JSX Attribute 中的内容
  6. 如果组件传入了 `PropsSchema` 配置，则检测组件的属性是否可以传入 `ReactNode`，可以的话确定该属性是否已存在，如不存在，则包裹 `JsxSlot` 组件。
  ")
  @genType
  let render: string => t
} = {
  type t = (string, string)
  let render = (code: string): t => {
    ("", code)
  }
}

// 命令模块，给定命令，对 AST 进行变换
module Commands = {

}
