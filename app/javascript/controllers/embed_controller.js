import { Controller } from "@hotwired/stimulus"

// Renders Instagram and Threads blockquote embeds. Both providers ship the same
// embed SDK: loading either script defines `window.instgrm` and registers a
// renderer for that provider's blockquote (`instagram-media` /
// `text-post-media`). Calling `window.instgrm.Embeds.process()` then swaps any
// unprocessed blockquotes for a styled iframe.
//
// Each post attaches this controller, so we:
//   1. ensure that post's provider script is loaded (once per page), and
//   2. call process() after it loads, on (re)connect (Turbo navigation), and
//      whenever the SDK is already present.
// process() is idempotent — it skips blockquotes it has already rendered.
const EMBED_SCRIPTS = {
  instagram: "https://www.instagram.com/embed.js",
  threads: "https://www.threads.com/embed.js"
}

export default class extends Controller {
  static values = { platform: String }

  connect() {
    this.ensureScriptLoaded(EMBED_SCRIPTS[this.platformValue])
    // Already-loaded case (another embed loaded the SDK, or Turbo navigation).
    this.process()
  }

  process() {
    if (window.instgrm?.Embeds?.process) {
      window.instgrm.Embeds.process()
    }
  }

  ensureScriptLoaded(src) {
    if (!src) return

    const existing = document.querySelector(`script[data-embed-src="${src}"]`)
    if (existing) {
      if (existing.dataset.loaded === "true") {
        this.process()
      } else {
        existing.addEventListener("load", () => this.process(), { once: true })
      }
      return
    }

    const script = document.createElement("script")
    script.async = true
    script.src = src
    script.dataset.embedSrc = src
    script.addEventListener("load", () => {
      script.dataset.loaded = "true"
      this.process()
    }, { once: true })
    document.body.appendChild(script)
  }
}
