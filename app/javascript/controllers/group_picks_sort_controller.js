import { Controller } from "@hotwired/stimulus"

// Toggles the group picks list between "grouped" (by group letter, the default)
// and "chronological" (all games sorted by kickoff). Match cards are physically
// moved between containers rather than re-rendered, so any unsaved picks the
// user has already selected are preserved across toggles.
export default class extends Controller {
  static targets = ["grouped", "chronological", "chronoList", "match", "badge", "groupedBtn", "chronoBtn"]

  connect() {
    this.mode = "chronological"
    this.render()
  }

  showGrouped() {
    this.mode = "grouped"
    this.render()
  }

  showChronological() {
    this.mode = "chronological"
    this.render()
  }

  render() {
    if (this.mode === "chronological") {
      const matches = [...this.matchTargets].sort((a, b) => {
        const ka = Number(a.dataset.kickoff)
        const kb = Number(b.dataset.kickoff)
        if (ka !== kb) return ka - kb
        return Number(a.dataset.order) - Number(b.dataset.order)
      })
      matches.forEach((m) => this.chronoListTarget.appendChild(m))
      this.badgeTargets.forEach((b) => b.classList.remove("hidden"))
      this.groupedTarget.classList.add("hidden")
      this.chronologicalTarget.classList.remove("hidden")
    } else {
      // Restore each match to its original group list, in match-number order.
      const matches = [...this.matchTargets].sort(
        (a, b) => Number(a.dataset.order) - Number(b.dataset.order)
      )
      matches.forEach((m) => {
        const list = document.getElementById(`group-list-${m.dataset.group}`)
        if (list) list.appendChild(m)
      })
      this.badgeTargets.forEach((b) => b.classList.add("hidden"))
      this.chronologicalTarget.classList.add("hidden")
      this.groupedTarget.classList.remove("hidden")
    }
    this.updateButtons()
  }

  updateButtons() {
    const active = "bg-emerald-600 text-white"
    const inactive = "bg-white text-slate-600"
    const set = (btn, on) => {
      if (!btn) return
      active.split(" ").forEach((c) => btn.classList.toggle(c, on))
      inactive.split(" ").forEach((c) => btn.classList.toggle(c, !on))
      btn.setAttribute("aria-pressed", on ? "true" : "false")
    }
    set(this.groupedBtnTarget, this.mode === "grouped")
    set(this.chronoBtnTarget, this.mode === "chronological")
  }
}
