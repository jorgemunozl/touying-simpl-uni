// functions/tables.typ – reusable table templates for slides
//
// All functions accept pre-built rows (arrays of content) so the caller
// controls data loading (JSON, inline, CSV, etc.).  Styling is kept minimal
// to let the slide theme's fonts/colors shine through.

// ============================================================
// 1. prop-table — two-column key-value, no styling
//    Use for: dumping computed properties per functional
// ============================================================
#let prop-table(title, rows) = {
  table(
    columns: (auto, auto),
    table.header([*#title*], []),
    ..rows.flatten(),
  )
}

// ============================================================
// 2. comparison-table — multi-column side-by-side with header
//    Use for: PBE vs HSE06 vs Experiment, etc.
// ============================================================
#let comparison-table(header, rows) = {
  let n = header.len()
  table(
    columns: (auto,) * n,
    table.header(..header),

    ..rows.flatten(),
  )
}

// ============================================================
// 3. data-table — generic table with zebra striping
//    Use for: presenting raw data with many rows
// ============================================================
#let data-table(header, rows, zebra: true) = {
  let fill-fn = if zebra {
    (x, y) => if y == 0 { rgb("#e8ecf1") } else if calc.odd(y) { rgb("#f5f6f8") }
  } else {
    none
  }
  let n = header.len()
  table(
    columns: (auto,) * n,
    fill: fill-fn,
    table.header(..header),
    ..rows.flatten(),
  )
}

// ============================================================
// 4. error-table — color-coded cells by deviation
//    Use for: highlighting over/under-estimation vs experiment
//
//    rows: array of (label, value, diff%, [thresholds])
//    thresholds: (good, warn) – defaults to (1, 5) percent
// ============================================================
#let error-table(header, rows, thresholds: (1.0, 5.0)) = {
  let (good, warn) = thresholds

  let color-cell(val) = {
    if type(val) == str or val == none {
      return val
    }
    let abs = calc.abs(val)
    if abs <= good {
      text(fill: rgb("#16a34a"), val)
    } else if abs <= warn {
      text(fill: rgb("#d97706"), val)
    } else {
      text(fill: rgb("#dc2626"), val)
    }
  }

  let colored-rows = rows.map(row => {
    let label = row.at(0)
    let rest = row.slice(1).map(color-cell)
    (label,) + rest
  })

  data-table(header, colored-rows)
}

// ============================================================
// 5. convergence-table — specialised for ENCUT / k-point studies
//    Use for: "parameter | E0 | ΔE (meV) | converged?"
//    highlight: array of 0‑based row indices to color
// ============================================================
#let convergence-table(header, rows, highlight: ()) = {
  let n = header.len()

  let fill-fn = if highlight.len() > 0 {
    (x, y) => {
      if y == 0 { return none }
      let ri = y - 1 // row index  (0‑based, below header)
      if ri in highlight { rgb("#dcfce7") } // green‑tinted
      else { none }
    }
  } else {
    none
  }

  table(
    columns: (auto,) * n,
    fill: fill-fn,
    table.header(..header),
    ..rows.flatten(),
  )
}
