import { Controller } from "@hotwired/stimulus"

// Drives the "what are you posting?" tabs on the feed form. Clicking a tab sets
// the hidden post_type field and shows only the inputs relevant to that type
// (file upload for media, a URL field for link/Instagram/Threads). Inputs that
// are hidden are also disabled so the browser never tries to validate or submit
// them.
export default class extends Controller {
  static targets = ["typeField", "tab", "panel"]

  connect() {
    this.show(this.typeFieldTarget.value || "media")
  }

  select(event) {
    event.preventDefault()
    this.show(event.params.type)
  }

  show(type) {
    this.typeFieldTarget.value = type

    this.panelTargets.forEach((panel) => {
      const types = (panel.dataset.types || "").split(" ")
      const visible = types.includes(type)
      panel.classList.toggle("hidden", !visible)

      panel.querySelectorAll("input, textarea, select").forEach((field) => {
        field.disabled = !visible
      })
    })

    this.tabTargets.forEach((tab) => {
      const active = tab.dataset.type === type
      tab.classList.toggle("bg-emerald-600", active)
      tab.classList.toggle("text-white", active)
      tab.classList.toggle("shadow", active)
      tab.classList.toggle("bg-slate-100", !active)
      tab.classList.toggle("text-slate-600", !active)
    })
  }
}
