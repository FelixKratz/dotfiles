# Slide style

Reusable style notes for talk slides. Apply across colloquia, lectures, lab seminars.

## Core principles

Ranked by leverage — get the top items right and the rest tends to follow.

### 1. Titles are claims, not labels

Every slide title is a short declarative sentence stating the takeaway. Subject + verb + claim. 4–10 words. The audience should be able to read the title and know the conclusion *before* looking at the figure.

- *"Cases are a convolution of past transmission"* — not *"The renewal equation"*
- *"Log-CRPS turns absolute error into relative error"* — not *"Bosse 2023 results"*
- *"Some diseases hit the ceiling, others don't"* — not *"Cross-disease comparison"*

Single biggest factor in slide clarity. If you only adopt one principle, adopt this one.

Section dividers and self-evident process steps are the only exceptions: *"Inference"*, *"Sample some individuals"*.

### 2. One idea per slide

If two ideas compete for attention, split into two slides. Higher slide count, lower cognitive load per slide. Audience never has to choose what to look at.

### 3. No bullet lists

Almost never. Maybe one short sentence under a figure or equation. Never nested bullets, never multi-level hierarchies. Removing bullet lists eliminates the temptation to dump notes onto the slide and forces every word to justify itself.

### 4. Whitespace is a design tool

One figure, large, centred, with empty margins. Generous space makes each object feel deliberate. Don't fill slides with everything that fits.

### 5. Colour is for data, never decoration

No brand chrome, no decorative palette. If colour appears, it encodes something — clade, magnitude, category. Otherwise monochrome.

### 6. Toy example before real example

Introduce inference on a coin flip before showing a full hierarchical Bayesian model. Introduce a scoring rule on a textbook case before the forecast-hub application. Audience builds intuition on the simple case, transfers it to the real one.

### 7. Micro-progressions for derivations and algorithms

Don't show a derivation chain on one slide. Show step 1, step 2, step 3 — three slides, one transition each. Same for any algorithmic walk-through. Audience tracks each transition; cognitive load per slide stays low.

### 8. Equations one per slide with a one-line gloss

Centre the equation. Under it, one short sentence translating the symbols or interpreting the result. No floating LaTeX. No multi-equation derivations on a single slide.

### 9. Citations inline below the figure

Format `Author Year`, hyperlinked, small font. No separate bibliography slide. No floating attribution boxes.

### 10. No slide chrome

No footers, logos, slide numbers, institutional banners. No "Outline" or "Summary" slides full of bullets. The closing is a single claim per slide, not a recap.

### 11. Caveats fold into the claim, not into a "Limitations" slide

If something needs a caveat, the title sentence carries it. *"Rare transitions and short branches increase confidence"* — implicit inversion. No Limitations slide at the end.

## Recurring templates

Four templates handle most slides:

- **Claim + Figure.** Default. Title is a declarative sentence; figure is the evidence.
- **Process step sequence.** Identical layout, identical title, one element changes per slide. For algorithmic walk-throughs.
- **Equation + one-line gloss.** Centred LaTeX, one sentence beneath.
- **Exercise / question.** Consistent frame across several slides; varying figures. Turns recognition into automatic.

## What NOT to do

- No multi-column layouts.
- No nested bullets.
- No slide footers, logos, slide numbers, institutional branding.
- No noun-phrase titles when a sentence is available.
- No callout arrows or text annotations overlaid on figures — title and verbal commentary do that work.
- No derivation chains on a single slide. One step per slide.
- No "Outline" or "Summary" slide at the end.
- No "Limitations" slide. Fold into claims.

## Where this style comes from

Distilled from observation of consistently clear scientific lecturers in mathematical biology and adjacent fields. The core principles converge across speakers; this list captures the ones that translate best across topic areas (forecasting, modelling, inference, software methodology). The principles are deliberately content-agnostic — apply equally to a colloquium on inverse problems and a lab seminar on package architecture.

## Calibrating to audience

The principles above are absolutes. The following are knobs to turn per audience:

- **Equation density.** A maths-research-institute audience tolerates higher equation density than a public-health lab; a public-health lab tolerates higher than a policy audience. Start at "one equation per slide with gloss" and dial up only when audience explicitly rewards it.
- **Pacing.** Bedford-style coalescent talks run ~1 slide per minute. Mathematical talks with equation-per-slide can comfortably run ~1.4 min/slide. Adjust slide count to match.
- **Cross-field references.** Useful at interdisciplinary colloquia (IWR-style). Less useful at field-internal venues (an epi-specific conference).
- **Personal narrative voice.** Always your own. Style principles are about slide construction; voice is about delivery.
