import { Controller } from "@hotwired/stimulus"

// Drives the interactive knockout bracket.
//
// Round-of-32 matches show the real teams the admin entered. Every later round
// is a "match_winner" matchup: each competitor is whichever team the user
// predicted to win one specific earlier match. Clicking a winner therefore
// advances that team into its exact spot in the next round, and changing an
// earlier pick re-flows the bracket downstream — clearing any pick that is no
// longer valid because its team didn't "advance" anymore.
//
// Match elements carry:
//   data-match-id / data-number
//   data-{home,away}-team-id|label|flag  (fixed R32 competitor), OR
//   data-{home,away}-feeder              (match NUMBER whose winner fills the slot)
//   data-{home,away}-placeholder         (label shown while the slot is empty)
export default class extends Controller {
  static targets = ["match"]
  static values = { picks: Object, locked: Boolean }

  connect() {
    // matchId -> selected teamId (both stored as strings).
    this.selections = new Map()
    for (const [matchId, teamId] of Object.entries(this.picksValue || {})) {
      if (teamId !== null && teamId !== undefined && teamId !== "") {
        this.selections.set(String(matchId), String(teamId))
      }
    }

    // Index matches by their number so feeders can be looked up cheaply, and
    // process them in number order (feeders always precede the matches they feed).
    this.byNumber = new Map()
    this.matchTargets.forEach((el) => this.byNumber.set(el.dataset.number, el))
    this.ordered = [...this.matchTargets].sort(
      (a, b) => Number(a.dataset.number) - Number(b.dataset.number)
    )

    this.render()
  }

  pick(event) {
    const input = event.target
    if (!input.checked) return
    const matchEl = input.closest("[data-bracket-target='match']")
    if (!matchEl) return
    this.selections.set(matchEl.dataset.matchId, input.value)
    this.render()
  }

  render() {
    this.ordered.forEach((matchEl) => {
      const home = this.resolveSide(matchEl, "home")
      const away = this.resolveSide(matchEl, "away")
      this.applySide(matchEl, "home", home)
      this.applySide(matchEl, "away", away)

      // Drop a stored pick whose team no longer competes in this match.
      const id = matchEl.dataset.matchId
      const sel = this.selections.get(id)
      const valid = (home && sel === home.id) || (away && sel === away.id)
      if (sel && !valid) this.selections.delete(id)

      const current = this.selections.get(id)
      this.setChecked(matchEl, "home", !!home && current === home.id)
      this.setChecked(matchEl, "away", !!away && current === away.id)
    })
  }

  // Returns { id, label, flag } for one competitor, or null if not known yet.
  resolveSide(matchEl, side) {
    const fixedId = matchEl.dataset[`${side}TeamId`]
    if (fixedId) {
      return {
        id: fixedId,
        label: matchEl.dataset[`${side}TeamLabel`] || "",
        flag: matchEl.dataset[`${side}TeamFlag`] || ""
      }
    }

    const feederNumber = matchEl.dataset[`${side}Feeder`]
    if (!feederNumber) return null
    const feederEl = this.byNumber.get(feederNumber)
    if (!feederEl) return null
    const winnerId = this.selections.get(feederEl.dataset.matchId)
    if (!winnerId) return null
    return this.teamOf(feederEl, winnerId)
  }

  // Reads a team's label/flag from a feeder match that has already been rendered.
  teamOf(matchEl, teamId) {
    const input = matchEl.querySelector(`input[data-side][value="${teamId}"]`)
    if (!input || !input.value) return null
    return {
      id: input.value,
      label: input.dataset.teamLabel || "",
      flag: input.dataset.teamFlag || ""
    }
  }

  applySide(matchEl, side, team) {
    const input = matchEl.querySelector(`input[data-side="${side}"]`)
    const label = matchEl.querySelector(`[data-bracket-label="${side}"]`)
    if (!input || !label) return

    if (team) {
      // setAttribute keeps the value attribute in sync so feeder lookups by
      // [value="…"] match even after we change it from JS.
      input.setAttribute("value", team.id)
      input.value = team.id
      input.dataset.teamLabel = team.label
      input.dataset.teamFlag = team.flag
      input.disabled = this.lockedValue
      input.classList.remove("hidden")
      label.textContent = `${team.flag ? team.flag + " " : ""}${team.label}`
      label.classList.remove("text-slate-500", "italic")
    } else {
      input.checked = false
      input.setAttribute("value", "")
      input.value = ""
      input.disabled = true
      input.classList.add("hidden")
      label.textContent = matchEl.dataset[`${side}Placeholder`] || "TBD"
      label.classList.add("text-slate-500", "italic")
    }
  }

  setChecked(matchEl, side, on) {
    const input = matchEl.querySelector(`input[data-side="${side}"]`)
    if (input) input.checked = !!on
  }
}
