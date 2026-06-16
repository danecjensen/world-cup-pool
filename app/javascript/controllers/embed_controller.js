import { Controller } from "@hotwired/stimulus"

// Renders Instagram and Threads blockquote embeds. Both providers ship a small
// script that scans the DOM for their blockquotes and swaps in a styled iframe.
//
// The tricky part is Turbo: a normal <script async> tag only runs once, so a
// blockquote rendered after a Turbo navigation never gets processed. We handle
// that by (re)injecting the embed script on every connect — appending a script
// element always re-executes it, which re-scans the page. For Instagram we can
// take the cheaper path of calling its exposed process() API when it's already
// loaded.
const EMBED_SCRIPTS = {
  instagram: "https://www.instagram.com/embed.js",
  threads: "https://www.threads.net/embed.js"
}

export default class extends Controller {
  static values = { platform: String }

  connect() {
    if (this.platformValue === "instagram" && window.instgrm?.Embeds?.process) {
      window.instgrm.Embeds.process()
      return
    }

    this.injectScript()
  }

  injectScript() {
    const src = EMBED_SCRIPTS[this.platformValue]
    if (!src) return

    const existing = document.querySelector(`script[data-embed-platform="${this.platformValue}"]`)
    if (existing) existing.remove()

    const script = document.createElement("script")
    script.async = true
    script.src = src
    script.dataset.embedPlatform = this.platformValue
    document.body.appendChild(script)
  }
}
