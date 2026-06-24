import { Controller } from "@hotwired/stimulus"

// Warns the admin when the same team has been dropped into more than one
// Round-of-32 slot. A team can only advance from a single spot, so duplicates
// almost always mean a mistake. Purely advisory — it never blocks saving.
export default class extends Controller {
  static targets = ["select", "warning", "warningText"]

  connect() {
    this.check()
  }

  check() {
    const counts = new Map()
    this.selectTargets.forEach((sel) => {
      const value = sel.value
      if (!value) return
      const label = sel.options[sel.selectedIndex]?.text || value
      counts.set(value, { label, n: (counts.get(value)?.n || 0) + 1 })
    })

    const dupes = [...counts.values()].filter((c) => c.n > 1).map((c) => c.label.trim())

    // Highlight the offending selects so the admin can spot them quickly.
    const dupeValues = new Set([...counts.entries()].filter(([, c]) => c.n > 1).map(([v]) => v))
    this.selectTargets.forEach((sel) => {
      sel.classList.toggle("ring-2", sel.value && dupeValues.has(sel.value))
      sel.classList.toggle("ring-amber-400", sel.value && dupeValues.has(sel.value))
      sel.classList.toggle("border-amber-400", sel.value && dupeValues.has(sel.value))
    })

    if (dupes.length === 0) {
      this.warningTarget.classList.add("hidden")
    } else {
      this.warningTextTarget.textContent = dupes.join(", ")
      this.warningTarget.classList.remove("hidden")
    }
  }
}
