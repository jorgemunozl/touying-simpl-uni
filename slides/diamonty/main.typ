#import "@preview/cetz:0.4.2"
#import "@preview/fletcher:0.5.8" as fletcher: edge, node
#import "@preview/touying:0.6.1": *
#import "../../lib.typ": * // i.e. "@preview/touying-simpl-ecnu:<latest>"

// cetz and fletcher bindings for touying
#let cetz-canvas = touying-reducer.with(reduce: cetz.canvas, cover: cetz.draw.hide.with(bounds: true))
#let fletcher-diagram = touying-reducer.with(reduce: fletcher.diagram, cover: fletcher.hide)

#show: ecnu-theme.with(
  // Lang and font configuration
  lang: "en",
  font: "Libertinus Serif",

  // Basic information
  config-info(
    title: [Diamonty: NV Center in Diamond],
    short-title: [Diamonty: NV Center in Diamond],
    subtitle: [A study on punctual defects on materials with a high band-gap: Research Sprint],
    author: [Munoz Laredo Jorge],
    date: datetime.today(),
    institution: [National University of Engineering],
  ),
)
#title-slide()

//#outline-slide()

= Part One: Theoretical Background

== Many Electrons problem set up

We are trying to find the wave function $Psi(r_1, r_2, ..., r_(N e))$ for a many body system in his *ground state*, with it we could obtain all the information of a system, and create any kind of material with desired property.

Analytic is extremely hard, then we use the *BO aproximation* and a Hartree product, and limit ourselves to find the *electronic density* $n_0(r)=sum_j |psi_j^(K S)(r_j)|²$. _(Hokenberg Khon Theorem)_.

You end with a functional of the energy as:

$ E[n]=T_H [n] + U_H [n] + E_(X C)[n]+U_(e E)[n] $

Where:  $E_(X C) = Delta T + Delta U$ where

$T_H [n] = sum_i ⟨ psi_j^(K S) | -frac(nabla^2, 2) | psi_j^(K S) ⟩ quad and quad U_H [n] = 1/2 integral integral frac(n(bold(r)) n(bold(r)'), |bold(r) - bold(r)'|) dif bold(r) dif bold(r)'$

== Influent terms for the Kohn Sham equations

The choosing of, effective potential

$ V_(text("eff")) = V_H (r) + V_(e E) (r) + V_(x c)(r) $

By performing optimization using the *Variational Principle* you end up with the Kohn Sham equations.

$ H_"KS"[n] psi_j^(K S)(r) = epsilon_i psi_j^(K S)(r) $

Where the Khons Sham Hamiltonian can be written as

$
  H_"KS"[n] = -frac(1, 2) nabla^2 + V_"ext"(bold(r)) + V_H[n](bold(r)) + V_(x c)[n](bold(r))
$

where each term is: $V_H[n] = integral frac(n(bold(r)'), |bold(r) - bold(r)'|) dif bold(r)'$ is the Hartree potential,
$V_(x c)[n] = frac(delta E_(x c)[n], delta n(bold(r)))$ the exchange-correlation potential,
and $V_"ext"$ the external potential from the nuclei.


== The Problem: A Self-Referential Equation

The Kohn--Sham (KS) equations map an interacting many-body problem onto a
non-interacting system with the same ground-state density:


#tblock(title: [The Self-Consistency Problem])[
  The effective Hamiltonian $H_"KS"$ depends on the electron density $n(bold(r))$,
  but the density is itself constructed from the KS orbitals:

  $
    n(bold(r)) = sum_i f_i |psi_i(bold(r))|^2
  $

  #highlight["The Hamiltonian determines the density, and the density determines
    the Hamiltonian."] This circular dependence means the KS equations must be
  solved *iteratively* until the input and output densities agree.
]


#tblock(title: [Why can't we solve it directly?])[
  Unlike the Schrödinger equation, where $hat(H)$ is fixed by the external
  potential alone, $H_"KS"$ contains terms that are functionals of the unknown
  density:

  $
    H_"KS"[n] = -frac(1, 2) nabla^2 + V_"ext"(bold(r)) + V_"Hartree"[n] + V_"xc"[n]
  $

  Each term in red ($V_"Hartree"$, $V_"xc"$) must be recomputed every time the
  density changes — we cannot write down $H_"KS"$ until we already know $n(bold(r))$.
]

== 1.1.2 The Self-Consistent Field (SCF) Cycle

#tblock(title: [The Iterative SCF Loop])[
  The self-consistent field method turns the circular problem into a convergent
  sequence:
]

#v(0.3em)

#fletcher-diagram(
  node-stroke: 1pt,
  edge-stroke: 0.8pt,
  node((0, 0), [Initial guess $n^((0))(bold(r))$]),
  node((0, -1.5), [Build $H_"KS"[n^((k))]$]),
  node((0, -3.0), [Diagonalize: $H_"KS" psi_i = epsilon_i psi_i$]),
  node((0, -4.5), [Compute new density $n_"out"^((k))(bold(r))$]),
  node((0, -6.0), [Check: $||n_"out" - n_"in"|| < delta$?]),
  node((3, -6.0), [*Done*]),
  edge((0, 0), (0, -1.5)),
  edge((0, -1.5), (0, -3.0)),
  edge((0, -3.0), (0, -4.5)),
  edge((0, -4.5), (0, -6.0)),
  edge((0, -6.0), (3, -6.0), [yes]),
  edge((0, -6.0), (-2, -6.0), [no], "->", bend: 50deg),
  edge((-2, -6.0), (-2, 0), bend: 50deg),
  edge((-2, 0), (0, 0)),
)

#pause

#tblock(title: [Key Insight])[
  At convergence, the input and output densities are identical:
  $n_"in"(bold(r)) = n_"out"(bold(r)) = n_"SCF"(bold(r))$.

  The converged density is then used to compute total energy, forces, and all
  other observables. A single SCF cycle typically requires 10--50 iterations.
]

== 1.1.3 Convergence & Density Mixing

#tblock(title: [Naive Linear Mixing])[
  The simplest approach is to mix old and new densities:

  $
    n_"in"^((k+1)) = (1 - alpha) n_"in"^((k)) + alpha n_"out"^((k))
  $

  where $alpha in (0, 1]$ is the mixing parameter.

  #text(fill: red)[Problem:] The KS response contains long-wavelength charge
  sloshing modes. Small $alpha$ (e.g., 0.05--0.1) is stable but *very slow*;
  larger $alpha$ leads to wild oscillations — the *charge-sloshing instability*.
]

#pause

#tblock(title: [Advanced Mixing Schemes (used by VASP)])[
  Modern codes use history-aware methods that build an optimal linear combination
  of past densities and residuals:

  - *Pulay mixing* (DIIS): Minimizes the residual norm over a subspace spanned
    by previous iterations, effectively damping unstable charge modes.
  - *Broyden mixing*: A quasi-Newton approach that approximates the inverse
    dielectric matrix, accelerating convergence for "stiff" systems.

  #highlight[VASP defaults:] Broyden mixing (IMIX = 4) with AMIX ~ 0.4 and
  BMIX ~ 1.0, typically achieving convergence in 10--40 SCF steps.
]

---

#tblock(title: [Convergence Metrics])[
  SCF convergence is judged by multiple criteria:

  - *Density change:* $||n^((k+1)) - n^((k))|| < "EDIFF"/sqrt(N_"atoms")$
  - *Energy change:* $|E^((k+1)) - E^((k))| < "EDIFF"$
  - *Band energy:* $|sum_n epsilon_n^((k+1)) - sum_n epsilon_n^((k))| < delta$

  These are monitored simultaneously; all must be satisfied for convergence.
]

= How you are supposed to interpretate the data from the calculations

== Interesting

Interesint

= Interpreting the results and conclusions

== To

To
