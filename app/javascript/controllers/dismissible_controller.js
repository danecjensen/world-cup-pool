import { Controller } from "@hotwired/stimulus"

// Hides its element and remembers the dismissal in localStorage so the banner
// stays closed on future visits. Add data-dismissible-key-value to scope it.
export default class extends Controller {
  static values = { key: String }

  connect() {
    if (this.storageKey && localStorage.getItem(this.storageKey) === "1") {
      this.element.remove()
    }
  }

  dismiss() {
    if (this.storageKey) localStorage.setItem(this.storageKey, "1")
    this.element.remove()
  }

  get storageKey() {
    return this.keyValue ? `dismissed:${this.keyValue}` : null
  }
}
