import { Controller } from "@hotwired/stimulus"

// Makes the crowd bracket fun to explore. Every team row across the whole
// bracket carries data-team-id; hovering (or tapping, on touch) any one of them
// lights up that team everywhere it appears and dims the rest, so you can trace
// a single nation's support as it rises or fades round by round. Tapping pins
// the highlight so it survives moving the cursor; tapping again (or the same
// team) clears it. A floating banner reports how deep the crowd carried them.
export default class extends Controller {
  static targets = ["row", "banner", "bannerFlag", "bannerName", "bannerStat"]

  connect() {
    this.pinnedId = null
  }

  hover(event) {
    if (this.pinnedId) return
    this.highlight(event.currentTarget.dataset.teamId)
  }

  unhover() {
    if (this.pinnedId) return
    this.clear()
  }

  pin(event) {
    const id = event.currentTarget.dataset.teamId
    if (this.pinnedId === id) {
      this.pinnedId = null
      this.clear()
    } else {
      this.pinnedId = id
      this.highlight(id)
    }
  }

  highlight(teamId) {
    if (!teamId) return

    let name = ""
    let flag = ""
    let furthestRoundIndex = -1
    let furthestRoundName = ""
    let topPct = 0

    this.rowTargets.forEach((row) => {
      const active = row.dataset.teamId === teamId
      row.classList.toggle("insights-active", active)
      row.classList.toggle("insights-dim", !active)
      if (active) {
        name = row.dataset.teamName
        flag = row.dataset.teamFlag
        const idx = Number(row.dataset.roundIndex)
        if (idx > furthestRoundIndex) {
          furthestRoundIndex = idx
          furthestRoundName = row.dataset.roundName
        }
        const pct = Number(row.dataset.pct)
        if (pct > topPct) topPct = pct
      }
    })

    if (this.hasBannerTarget) {
      this.bannerFlagTarget.textContent = flag || ""
      this.bannerNameTarget.textContent = name || ""
      this.bannerStatTarget.textContent =
        `Crowd carried them to the ${furthestRoundName} · peak ${topPct}% of a match`
      this.bannerTarget.classList.remove("hidden")
      this.bannerTarget.classList.toggle("insights-banner-pinned", !!this.pinnedId)
    }
  }

  clear() {
    this.rowTargets.forEach((row) => {
      row.classList.remove("insights-active", "insights-dim")
    })
    if (this.hasBannerTarget) {
      this.bannerTarget.classList.add("hidden")
      this.bannerTarget.classList.remove("insights-banner-pinned")
    }
  }
}
