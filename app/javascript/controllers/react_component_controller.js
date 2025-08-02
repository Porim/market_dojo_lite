import { Controller } from "@hotwired/stimulus"
import React from "react"
import { createRoot } from "react-dom/client"
import RFQSearchFilter from "components/RFQSearchFilter"

// Connects to data-controller="react-component"
export default class extends Controller {
  static values = { 
    component: String,
    props: Object
  }

  connect() {
    this.mount()
  }

  disconnect() {
    this.unmount()
  }

  mount() {
    const Component = this.getComponent()
    if (Component) {
      this.root = createRoot(this.element)
      this.root.render(React.createElement(Component, this.propsValue))
    }
  }

  unmount() {
    if (this.root) {
      this.root.unmount()
    }
  }

  getComponent() {
    switch (this.componentValue) {
      case "RFQSearchFilter":
        return RFQSearchFilter
      default:
        console.error(`Unknown React component: ${this.componentValue}`)
        return null
    }
  }
}