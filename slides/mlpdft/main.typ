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
  font: ("Libertinus Serif", "Noto Sans"),

  // Basic information
  config-info(
    title: [Proof of Concept: Use and Fine-Tune MACE],
    short-title: [MACE],
    subtitle: [],
    author: [Jorge Munoz Laredo],
    date: datetime.today(),
    institution: [National University of Engineering],
  ),
)
#title-slide()

== Outline

#outline()

= Dataset we already have

== Examples of configuration-group names (catalog)

#text(size: 0.85em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 1em,
    [
      *LiF / Li-rich*
      - `LiF64_kjpaw`, `LiF64_kjpaw_v2`
      - `LiF64_kjpaw_NPT_v3`, `LiF64_kjpaw_final`
      - `LiFinterface_kjpaw_v1`, `LiFinterface_kjpaw_v2`
      - `LiwithF_NPT_final`, `LiwithF_isolated`
      - `LiwithBF`, `LiwithBF_NPT_final`
    ],
    [
      *Salts, B--Li, cells, ionics*
      - `LiBF4`, `LiBF4_NPT_final`, `LiBF4v4`
      - `LiBF4_relax`
      - `BLi3_interface_NPT`, `BLi3_isolated`
      - `BCC_54_kjpaw_NPT`, `BCC54_isolated`
      - `EMIM_TFSI_BF4`, `EMIMLiTFSI_anode_rv2`
      - `special`
    ],
  )
]

= FitSNAP model

== The FitSNAP model we have

- *FitSNAP stack* in words:
  - *Scraper* — reads quantum-chemistry frames (e.g. JSON) into structures.
  - *Calculator* — builds *SNAP bispectrum* descriptors per atom in LAMMPS (radial cutoff, `twojmax`, chemical channels, etc.).
  - *Solver* — *PyTorch* MLP.
  - *Layers:* PyTorch MLP `num_desc → 256 → 128 → 64 → 64 → 1`, `multi_element_option = 2` (per-element nets).
  - *Training:* learning rate `5e-6`, `70` epochs, batch `50`.

== Metrics

#figure(
  image("images/Metrics MLPDFT.png", width: 80%),
  caption: [Metrics obtained by two models],
)

= MACE model

== What the MACE model is

#figure(
  image("images/image.png", width: 80%),
  caption: [I. Batatia et al. 2022],
)

== Message Passing Neural Networks

#figure(
  image("images/mpnn.png", width: 80%),
  caption: [Message Passing Neural Network Concept],
)

== MACE Step (1): Atom Embedding

A molecule or crystal is represented as a *graph*:
atoms are nodes, edges connect pairs within a cutoff radius $r_c$.

Each atom $i$ is assigned an initial feature vector:
$ bold(h)_i^((0)) = bold(W)_(Z_i) $

a learned embedding indexed by atomic number $Z_i$ (lookup table).

*Goal:* produce, for each atom, a scalar energy $E_i$
that reflects its local chemical environment.
The total energy is $E = sum_i E_i$.

== Depth on MPNN

- $t=0$, the atom/node only can see itself.
- $t=1$, the atom can see its neighborhoods — *TWO BODY*.
- $t=2$, the atom can see the neighborhoods from its neighborhoods — TRIPLETS — *THREE BODY*

Three and higher order bodies are computationally expensive.

== MACE Step (2): Interaction Block

For each atom $i$, messages from neighbors $j$ are built as:
$ bold(m)_(i j) = sum_k W_k R_k(r_(i j)) dot Y_l^m(hat(r)_(i j)) ⊗ bold(h)_j^((t)) $

$W_k$ learned matrix.

- $Y_l^m(hat(r)_(i j))$: *spherical harmonics* — fixed geometric
  functions encoding the _direction_ to neighbor $j$.
- $R_k(r_(i j))$: *radial network* — a small MLP acting on the
  scalar distance. _This is where most parameters live._
- $⊗$: tensor product combining neighbor features with
  edge geometry, preserving equivariance via
  Clebsch--Gordan coefficients.

Messages are aggregated: $bold(m)_i = sum_(j in cal(N)(i)) bold(m)_(i j)$

== MACE Step (3): Equivariant Product Block

After aggregating neighbors, atom $i$ holds a feature vector
$bold(m)_i$ encoding its local environment.

*The problem:* one message passing layer only captures
pairwise $(i,j)$ interactions — that is *2-body*.

*The MACE idea:* take tensor products of $bold(m)_i$
with itself $nu$ times:
$
  bold(m)_i ⊗ bold(m)_i ⊗ dots.h.c
  quad (nu " times")
$

This mixes contributions from _different_ neighbors $j, k$
simultaneously, producing *$(nu+1)$-body correlations*
without any extra message passing.

- With $nu = 2$: reaches *3-body* after layer 1,
  compounding across layers.
- The CG coefficients ensure the result stays
  *equivariant* — no parameters, fixed by symmetry.

== MACE Step (4): Readout

After $T$ interaction layers, each atom $i$ holds a feature vector
$bold(h)_i^((t))$ with components of different equivariance order $L$.

Each layer contributes a partial atomic energy via its $L=0$ features:
$ E_i = E_i^((0)) + E_i^((1)) + ... + E_i^((T)) $

where each $E_i^((t))$ is a linear projection of
$bold(h)_i^((t))|_(L=0)$,
except the last layer which uses a small MLP.

The total energy and forces are then:
$
  E = sum_i E_i, \
  bold(F)_i = - (partial E) / (partial bold(r)_i)
$

*Forces are free* — no extra network needed, just
automatic differentiation through the entire graph.

== Parameters Distribution

#text(size: 0.8em)[
  #figure(
    table(
      columns: (2fr, auto, auto),
      stroke: 0.4pt,
      inset: 5pt,
      align: (left, center, center),

      table.cell(fill: luma(230))[*Block*],
      table.cell(fill: luma(230))[*Parameters*],
      table.cell(fill: luma(230))[*Share*],

      [`interactions` (2 layers)], [3 163 392], [\~82%],
      [`products` (2 layers, corr. / sym. contraction)], [670 720], [\~17%],
      [`node_embedding`], [11 392], [\~0.3%],
      [`readouts`], [2 192], [\~0.1%],
      table.cell(fill: luma(220))[*Total*],
      table.cell(fill: luma(220))[*3 847 696*],
      table.cell(fill: luma(220))[*100%*],
    ),
    caption: [Parameter count by block — MACE-MP-0 Small],
  )

  #v(0.6em)

  #figure(
    table(
      columns: (auto, auto, 3fr),
      stroke: 0.4pt,
      inset: 5pt,
      align: (left, center, left),

      table.cell(fill: luma(230))[*Submodule (layer 0)*],
      table.cell(fill: luma(230))[*Params*],
      table.cell(fill: luma(230))[*Role*],

      [`skip_tp`], [\~1.46 M], [Main equivariant tensor-product / mixing path],
      [`linear`], [\~65 k], [Channel mixing linear on node features],
      [`conv_tp_weights`], [\~42 k], [Radial MLP output → weights for the convolution],
      [`linear_up`], [\~16 k], [Projection up in channels],
    ),
    caption: [Dominant submodules inside one interaction layer],
  )
]

== MACE Flavors: Training Dataset

#text(size: 0.8em)[
  #figure(
    table(
      columns: (auto, auto, auto, auto, auto, auto),
      stroke: 0.4pt,
      inset: 5pt,
      align: (left, center, center, center, center, center),

      table.cell(fill: luma(230))[*Model*],
      table.cell(fill: luma(230))[*Parameters*],
      table.cell(fill: luma(230))[*Training dataset*],
      table.cell(fill: luma(230))[*Structures*],
      table.cell(fill: luma(230))[*DFT level*],
      table.cell(fill: luma(230))[*License*],

      [`MACE-MP-0`], [3 847 696], [MPTrj], [1.58 M], [PBE+U], [MIT],
      [`MACE-MP-0B3`], [9 063 204], [MPTrj], [1.58 M], [PBE+U], [MIT],
      [`MACE-OMAT`], [9 063 204], [OMat24], [\~100 M], [PBE+U VASP], [ASL],
    ),
    caption: "MACE foundation model variants and their training datasets",
  )
]

= Zero-shot evaluation

== Zero-Shot MACE-MP Evaluation on LiF 54

== Challenges of Fine-Tuning MACE on a Specific Dataset

- *Reference energy mismatch ($E_0$ problem)*
  The foundation model and the target DFT dataset use different
  atomic reference energies. A linear regression over the
  training set is required to align them before fine-tuning.

- *DFT functional mismatch*
  MACE-MP was trained with very specific data, if different
  functional (DFT), the model must _unlearn_ systematic
  biases — which can hurt generalization.

- *Out-of-domain chemistry*
  LiBF#sub[4] contains ionic species and Li, which are outside
  the MACE-OFF23 organic training domain. The model has no
  prior knowledge of ionic interactions, charge transfer,
  or metal coordination.

== Challenges

- *Data scarcity*
  Fine-tuning on a small dataset risks *catastrophic
  forgetting* — the model overfits to the new data and
  loses the general knowledge from pretraining.

- *Force/energy weight balance*
  The loss $cal(L) = lambda_E cal(L)_E +
  lambda_F cal(L)_F$ is sensitive to the choice of
  $lambda_E, lambda_F$. Wrong balance leads to models
  that predict energies well but produce unphysical forces
  or vice versa.

== Iterative Learning

#figure(
  image("images/iterative_training.png", width: 45%),
)

== Active Learning

#figure(
  image("images/pic_044.png", width: 45%),
)

== FitSnap First Metrics Obtained

#figure(
  image("images/fitsnap_metrics_table.pdf", width: 100%),
  caption: "FitSnap first metrics obtained",
)

== MACE OMAT First Metrics Obtained

#figure(
  image("images/mace_metrics_table.pdf", width: 80%),
  caption: "MACE OMAT first metrics obtained",
)


== MACE Results

#figure(
  image("images/mace_results.png", width: 70%),
  caption: "Mace Training Supervision",
)


== Dataset

#align(center)[
  #table(
    columns: (auto, 2fr, auto),
    stroke: 0.5pt,
    inset: 6pt,
    align: (center, left, center),

    table.cell(fill: luma(230))[*\#*],
    table.cell(fill: luma(230))[*Group*],
    table.cell(fill: luma(230))[*Frame count*],

    [1], [`LIFINTERFACE_KJPAW_V1`], [149],
    [2], [`LIFINTERFACE_KJPAW_NPT_V2`], [477],
    [3], [`LIFINTERFACE_KJPAW_NPT`], [258],
    [4], [`LIWITHF_NPT_FINAL`], [3236],
    [5], [`LIWITHF_ISOLATED`], [38],
    [6], [`LIF64_KJPAW_V2`], [2000],
    [7], [`LIWITHF_V3`], [1195],
    [8], [`LIF64_ISOLATED`], [56],
  )

  #v(0.5em)
  *Total frames:* 7409
]

== Hyperparameter Selection for First Training

#show table.cell.where(y: 0): set text(size: 0.8em, weight: "bold")

#text(size: 0.8em)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 0.5em,

    // LEFT — second part: Scheduler, Regularization, LoRA
    align(center, table(
      columns: (auto, auto),
      stroke: 0.4pt,
      inset: 3pt,

      table.cell(fill: luma(230))[*Hyperparameter*],
      table.cell(fill: luma(230))[*Value*],

      // === Model Architecture ===
      table.cell(fill: luma(220), colspan: 2)[*Model Architecture*],

      [Cutoff radius ($r_max$)], [$5$],
      [Channels], [$128$],
      [Max $L$], [$1$],
      [Max $ell$], [$3$],
      [Interactions], [$2$],
      [Correlation], [$3$],
      [Radial basis functions], [$8$],
      [Cutoff basis functions], [$5$],

      // === Training ===
      table.cell(fill: luma(220), colspan: 2)[*Training*],

      [Batch size], [$4$],
      [Max epochs], [$10$],
      [Validation fraction], [$0.5$],
      [Loss function], [`weighted`],
      [$lambda_(text("forces"))$], [$1.0$],
      [$lambda_(text("energy"))$], [$1.0$],
    )),

    // RIGHT — first part: Model Architecture, Training, Optimizer
    align(center, table(
      columns: (auto, auto),
      stroke: 0.4pt,
      inset: 3pt,

      table.cell(fill: luma(230))[*Hyperparameter*],
      table.cell(fill: luma(230))[*Value*],

      // === Optimizer ===
      table.cell(fill: luma(220), colspan: 2)[*Optimizer*],

      [Optimizer], [`adam`],
      [Learning rate], [$0.01$],
      [AMSGrad], [`true`],
      [Weight decay], [$5 times 10^(-7)$],
      [Gradient clip], [$10.0$],

      // === Scheduler ===
      table.cell(fill: luma(220), colspan: 2)[*Scheduler*],

      [Type], [`ReduceLROnPlateau`],
      [LR factor], [$0.8$],
      [Patience], [$50$],

      // === Regularization ===
      table.cell(fill: luma(220), colspan: 2)[*Regularization*],

      [EMA], [`true`],
      [EMA decay], [$0.99$],
      [Early stopping patience], [$4$],

      // === LoRA ===
      table.cell(fill: luma(220), colspan: 2)[*LoRA*],

      [LoRA enabled], [`true`],
      [LoRA rank], [$8$],
    )),
  )
]
== Model after FT performance / per atom

#figure(
  image("images/metrics_mock_per.pdf", width: 100%),
  caption: "Model performance metrics after fine-tuning / per atom",
)

== Model after FT performance / whole

#figure(
  image("images/metrics_mock.pdf", width: 100%),
  caption: "Model performance metrics after fine-tuning",
)

== Mace Own Inference

#align(center, table(
  columns: (auto, auto, auto, auto),
  stroke: 0.5pt,
  inset: 6pt,

  table.cell(fill: luma(230))[*config\_type*],
  table.cell(fill: luma(230))[*RMSE E (meV / atom)*],
  table.cell(fill: luma(230))[*RMSE F (meV / Å)*],
  table.cell(fill: luma(230))[*relative F RMSE (%)*],

  [`train_Default`],
  [$193.8$],
  [$142.2$],
  [$21.50$],

  [`valid_Default`],
  [$178.7$],
  [$143.4$],
  [$23.19$],
))
