import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { kickoff: String }
  static targets = ["days", "hours", "minutes", "seconds", "kicked", "clock"]

  connect() {
    this.targetTime = new Date(this.kickoffValue).getTime()
    this.tick()
    this.timer = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  tick() {
    const diff = this.targetTime - Date.now()
    if (diff <= 0) {
      if (this.hasClockTarget) this.clockTarget.classList.add("hidden")
      if (this.hasKickedTarget) this.kickedTarget.classList.remove("hidden")
      clearInterval(this.timer)
      return
    }
    const totalSeconds = Math.floor(diff / 1000)
    const days = Math.floor(totalSeconds / 86400)
    const hours = Math.floor((totalSeconds % 86400) / 3600)
    const minutes = Math.floor((totalSeconds % 3600) / 60)
    const seconds = totalSeconds % 60

    this.daysTarget.textContent = days
    this.hoursTarget.textContent = String(hours).padStart(2, "0")
    this.minutesTarget.textContent = String(minutes).padStart(2, "0")
    this.secondsTarget.textContent = String(seconds).padStart(2, "0")
  }
}
