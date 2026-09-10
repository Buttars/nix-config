# Instrument-Grade Dark UI

A design system for dark interfaces that read like instruments: flight decks,
signal analysers, declassified dossiers. It is not tied to any one program or
toolkit — the rules below are about structure, hierarchy and colour discipline,
and hold equally in GTK CSS, on the web, in a TUI, or in native UI code.

> A rendered version of this document lives at
> <https://claude.ai/code/artifact/f6d20bc4-343a-47d8-9ea4-2bd27e7b3d4c>.

It draws on four traditions, and each contributes something specific:

| Influence                        | What it contributes                                                                     |
| -------------------------------- | --------------------------------------------------------------------------------------- |
| **Declassified / dossier**       | Uppercase micro-labels, header cells that own a cluster, hairline rules, mono metadata. |
| **High-tech brutalism**          | Zero radius, exposed structure, blocks that abut, no ornament and no gradients.         |
| **Fantasy User Interface (FUI)** | Channel colour, HUD rules, telemetry density, the sense of a system reporting itself.   |
| **Form follows function**        | Every mark encodes state or hierarchy. Anything that encodes nothing gets deleted.      |

The four pull in compatible directions but not identical ones. Where they
conflict, **form follows function wins** — FUI is the influence most likely to
tempt you into decoration, and it is the one to discipline.

---

## Principles

### 1. Hard geometry

`border-radius: 0`, everywhere, without exception. Rounded corners soften; this
system does not soften. Structure is expressed by 1px rules and by blocks that
sit adjacent, not by floating pills with drop shadows.

Corollary: no gradients, no glows, no blur. If you want emphasis, use contrast,
weight, or a rule — not a light source.

### 2. Build the ground in five steps

Most dark UIs use two values (background, text) and then look flat. Use five,
and derive them all from one palette rather than inventing colours per component:

| Step      | Role                                              |
| --------- | ------------------------------------------------- |
| `ground`  | The page or bar behind everything.                |
| `surface` | Blocks lifted off the ground. The depth cue.      |
| `rule`    | Borders and dividers. Never used for text.        |
| `dim`     | Labels, units, inactive items, secondary text.    |
| `ink`     | Values, active items, anything you actually read. |

A common failure is having the palette but not exposing it. If you are on a
base16 scheme you already own all five — `base00`, `base01`, `base02`, `base03`,
`base05` — and most themes ship with only two of them wired up. Check before you
invent a colour.

### 3. Labels dim, values bright

Within a single readout, the label and the value are not equal. The label is
context you read once; the value is what you came for.

Render the label at `dim` and the value at `ink`. Where the medium won't let you
colour part of a string, use **relative alpha** on the label rather than a second
hardcoded colour — a 55% alpha label stays correct when the theme changes, while
a hardcoded grey does not.

### 4. Monospace every number

Anything numeric — percentages, temperatures, counts, timestamps, byte rates —
is set in a monospace face with tabular figures. This is functional, not
stylistic: proportional digits change width as values change, so a readout that
ticks from `9%` to `10%` shifts everything beside it.

Pair this with a **minimum width** on the cell, sized for the widest value the
field can hold. A readout that jitters is a readout you learn to distrust.

Labels and prose can stay in the sans face. The split is by role, not by region.

### 5. Colour identifies a channel

Group related readouts into a cluster, give the cluster one hue, and carry that
hue in exactly two places: a rule along the block's leading edge, and the
cluster's header cell. Everything inside the cluster stays neutral.

This is what keeps the design from becoming a rainbow. Colour answers _which
subsystem is this_, and nothing else. The values stay `ink` because they are the
thing being read.

Four or five channels is the practical ceiling. Past that the hues stop being
distinguishable at a glance and you have decoration again.

### 6. Semantic colour is reserved

Warning, critical and good are **not available** as channel colours or accents.
They must mean exactly one thing, always, so that a red cell is instantly
legible as a problem rather than as a design flourish.

When a readout enters a state, it overrides its channel colour: the text takes
the semantic hue and the cell takes a low-alpha tint of the same hue. Tint plus
text, not text alone — see principle 8.

### 7. Spend boldness once

Exactly one element carries the hottest colour on the screen, and it should be
the thing you most want the eye to land on. Everything else stays quiet enough
to make that work.

A focal accent that appears in five places is not a focal accent.

### 8. Encode state in form, not colour alone

Every state that matters should be legible with the colour removed: a tint plus
a rule plus a weight change, not a hue swap on its own. This is an
accessibility requirement, and it also survives screenshots, projectors, and
low-quality displays.

### 9. Density with rhythm

The aesthetic is dense, but density without rhythm is noise. Use tight, uniform
padding inside cells, a consistent gap between cells, and a larger gap between
clusters. The eye should find cluster boundaries without reading anything.

Resist the urge to fill space. Empty ground is what makes the instrument blocks
read as instruments.

### 10. Detail on demand

Show the summary always and the detail on request — hover, tooltip, expansion,
drill-down. The surface stays scannable; the depth is one interaction away.
This is what lets you honour both "dense" and "legible" at once.

### 11. Verify by rendering

Design within the constraints of the medium you are actually shipping to, and
confirm by rendering rather than by assuming.

Toolkit CSS is usually a _subset_ of web CSS. GTK, for instance, has no flexbox,
no `gap`, no `filter`, no `:has()`, and cannot animate width — but it does have
`alpha()`, `box-shadow`, `min-width` and transitions. Icon fonts are worse:
a glyph can be present in a font's character map and still render as nothing,
so a coverage check that only tests the cmap will pass while the screen stays
blank. Render the actual thing and look at it.

---

## Type

Two faces, three roles.

- **Display / labels** — an industrial grotesque. Set uppercase, heavy
  (600–700), with 0.5–1px of letter-spacing. Used for header cells and section
  markers, never for running text.
- **Readouts / data** — a monospace with tabular figures. Every number, code
  fragment, identifier and timestamp.
- **Body** — the display face at normal weight, or a workhorse sans. Running
  text near 65 characters.

Keep the type scale short. Three or four sizes is plenty; an instrument panel
that uses eight sizes is a magazine.

---

## Patterns

**Label cell** — the cluster's name. Uppercase, mono, small, in the channel hue,
on a low-alpha tint of that hue, with a hairline rule on its trailing edge
separating it from the readouts.

**Readout cell** — an optional dimmed icon, then the value in `ink`. Mono, fixed
minimum width, uniform horizontal padding. Hover raises the cell background by a
few percent alpha and nothing else.

**Channel rule** — a 2px line in the channel hue along the block's leading edge.
This is the single strongest identifying mark in the system; keep it consistent
in weight and position across every block.

**State tint** — semantic text colour plus a 12–18% alpha wash of the same hue
across the cell. Low enough to keep the value readable, high enough to catch
peripheral vision.

**Divider** — 1px in `rule`, full height of the content, no margin. Used between
cells inside a cluster where the padding alone is ambiguous.

---

## Applying this to a new project

1. Pull five neutral steps and four or five channel hues out of the palette you
   already have. Do not invent colours; expose the ones that exist.
2. Reserve the semantic three before assigning any channel hue, so you cannot
   accidentally spend red on a category.
3. Identify the clusters. If you cannot name a cluster in three or four
   uppercase characters, it is probably two clusters.
4. Set every number in mono with a min-width. Do this before you style anything
   else — it constrains the layout more than any other decision.
5. Choose the one focal element and give it the hottest colour. One.
6. Strip anything that survives the question _what does this mark tell me that
   the marks around it don't?_
7. Render it, screenshot it, and look at it at true size before deciding it
   works.

---

## Anti-patterns

- Rounded corners "to soften it up" — this breaks the system outright.
- A hue per readout instead of per cluster.
- Semantic colours used decoratively, which makes real alerts invisible.
- Proportional digits in a live value.
- Icons at full contrast competing with the values beside them.
- Ornamental numbering (`01 / 02 / 03`) on content that is not a sequence.
- Filling empty ground because it looks empty.
