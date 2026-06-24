#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8" as fletcher: edge, node
#import "@preview/touying:0.6.1": *
#import "../lib.typ": * // i.e. "@preview/touying-simpl-ecnu:<latest>"

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: ecnu-theme.with(
  // Lang and font configuration
  lang: "en",
  font: ("Libertinus Serif", "Source Han Sans SC", "Source Han Sans"),

  // Basic information
  config-info(
    title: [Numerical Methods for the double pendulum],
    short-title: [],
    subtitle: [Runge-Kutta, Adaptive, High Order],
    author: [Jorge Munoz Laredo],
    date: datetime.today(),
    institution: [National University of Engineering],
  ),
)
#title-slide()

#outline-slide()

= The physical system that actually matter


#image("images/dp.webp")

== The double pendulum

== Phase Space and Hamiltonian

== Why this thing is hard? (Formally)

= Numerical Methods

== From Taylor to Runge-Kutta

== Runge-Kutta

== Adaptive Size Control



==

=

== Llorando

vamos
