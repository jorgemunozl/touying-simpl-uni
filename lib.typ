/**
 *  Stargazer theme - adapted for ECNU
 * */

#import "@preview/touying:0.6.1": *
#import "@preview/numbly:0.1.0": numbly
#import themes.stargazer: *

// ── Table templates ─────────────────────────────────────────
#import "functions/tables.typ": comparison-table, convergence-table, data-table, error-table, prop-table

/// ->
#let ecnu-theme(
  aspect-ratio: "16-9",
  lang: "en",
  font: "Libertinus Serif",
  use-background: true,
  ..args,
  body,
) = {
  set text(lang: lang, font: font)
  // set heading(numbering: numbly("{1}.", default: "1.1"))

  show: stargazer-theme.with(
    aspect-ratio: aspect-ratio,
    header-right: grid(
      columns: 2,
      image("assets/ecnu_logo.png"), image("assets/ecnu_title.png"),
    ),
    config-colors(
      primary: rgb("#b60b2d"),
      primary-dark: rgb("#5a0718"),
      secondary: rgb("#fdd100"),
      tertiary: rgb("#004f71"),
      neutral-lightest: rgb("#ffffff"),
      neutral-darkest: rgb("#5a0718"),
    ),
    config-page(
      background: if use-background {
        place(
          center + horizon,
          dx: 13%,
          image("assets/ecnu_background.png", width: 75%),
        )
      } else {
        none
      },
    ),
    config-methods(
      init: (self: none, body) => {
        set text(size: 20pt)
        set list(marker: components.knob-marker(primary: self.colors.primary))
        show figure.caption: set text(size: 0.9em)
        show footnote.entry: set text(size: 0.6em)
        show heading: set text(fill: self.colors.primary)
        show link: it => if type(it.dest) == str {
          set text(fill: self.colors.primary)
          it
        } else {
          it
        }
        show figure.where(kind: table): set figure.caption(position: top)
        body
      },
    ),
    ..args,
  )

  body
}
