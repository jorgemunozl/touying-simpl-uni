#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8" as fletcher: edge, node
#import "@preview/touying:0.6.1": *
#import "../lib.typ": * // i.e. "@preview/touying-simpl-ecnu:<latest>"

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: ecnu-theme.with(
  // Language and font configuration
  lang: "en",
  font: "Libertinus Serif",

  // Basic information
  config-info(
    title: [National University of Engineering Touying Slides for Typst],
    short-title: [Touying Typst Slides],
    subtitle: [Typst Slide Theme for National University of Engineering Based on Touying],
    author: [Jorge Alvaro Munoz Laredo],
    date: datetime.today(),
    institution: [National University of Engineering],
  ),

  // Pdfpc configuration
  // typst query --root . ./examples/main.typ --field value --one "<pdfpc-file>" > ./examples/main.pdfpc
  config-common(
    preamble: pdfpc.config(
      duration-minutes: 30,
      start-time: datetime(hour: 14, minute: 10, second: 0),
      end-time: datetime(hour: 14, minute: 40, second: 0),
      last-minutes: 5,
      note-font-size: 12,
      disable-markdown: false,
      default-transition: (
        type: "push",
        duration-seconds: 2,
        angle: ltr,
        alignment: "vertical",
        direction: "inward",
      ),
    ),
  ),
)

#title-slide()

#outline-slide()

= Typst and Touying

== Typst and Touying

#tblock(title: [Typst])[
  Typst is a new markup-based typesetting system that is powerful and easy to learn. This presentation does not go into detail about using Typst; you can find more information in the Typst #link("https://typst.app/docs")[documentation].
]

#tblock(title: [Touying])[
  Touying is a slide/presentation package developed for Typst. Touying is similar to LaTeX's Beamer, but thanks to Typst, you get faster rendering and more concise syntax. You can learn more about Touying in its #link("https://touying-typ.github.io/touying/zh/docs/intro")[documentation].

  "Touying" comes from the Chinese word for "projection." In comparison, "beamer" in LaTeX is the German word for projector.
]

= Touying Slide Animations
---
#slide[
  Touying supports a variety of slide animations and transitions:

  #list(
    [Simple pause animations with `#pause`],
    [Complex overlay specifications with `< >` syntax],
    [Slide-level transitions between sections],
    [Custom animation callbacks for advanced use cases],
  )

  This makes your presentations more dynamic and engaging.
]

= Other Features

== Two-Column Layout

#slide(composer: (1fr, 1fr))[
  *When I Heard the Learn'd Astronomer* --- Walt Whitman

  When I heard the learn'd astronomer,\
  When the proofs, the figures, were ranged in columns before me,\
  When I was shown the charts and diagrams, to add, divide,
  and measure them,
][
  When I sitting heard the astronomer where he lectured with
  much applause in the lecture-room,\
  How soon unaccountable I became tired and sick,\
  Till rising and gliding out I wander'd off by myself,\
  In the mystical moist night-air, and from time to time,\
  Look'd up in perfect silence at the stars.
]

== Content Across Pages

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod
tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam,
quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo
consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse
cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat
non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium
doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore
veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim
ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia
consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt.

Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur,
adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et
dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis
nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex
ea commodi consequatur.

Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam
nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas
nulla pariatur. At vero eos et accusamus et iusto odio dignissimos ducimus
qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores.

#align(center)[
  "The only way to do great work is to love what you do."\
  --- Steve Jobs\
  "Stay hungry, stay foolish."\
  --- Steve Jobs\
  "Innovation distinguishes between a leader and a follower."\
  --- Steve Jobs\
]

// appendix by freezing last-slide-number
#show: appendix

== Appendix

#slide[
  - You can use:
    ```sh
    typst init @preview/touying-simpl-ecnu
    ```
    to create a presentation project based on this template.

  - This template is adapted from #link("https://github.com/Coekjan/touying-buaa")[touying-buaa]. Contributions are welcome.
  - The template repository is at #link("https://github.com/ccyoung3/touying-simpl-ecnu")[touying-simpl-ecnu]. Contributions are welcome.
]
