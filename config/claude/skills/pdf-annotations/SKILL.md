---
name: pdf-annotations
description: |
  Extract handwritten or flattened annotations from a marked-up PDF and turn
  them into a review write-up a co-author can act on. Use when given an
  annotated manuscript, report, thesis or contract PDF and asked to pull out
  the comments, check them, answer what can be answered, or prepare them as an
  issue comment, email or PR. Covers detecting flattened ink, proving the
  extraction is complete, reading ambiguous marks, and writing up for an
  audience that never sees the annotations.
---

# Extracting review comments from an annotated PDF

The goal is a write-up whose recipient never has to look at the PDF, and a
claim of completeness that is checkable rather than hopeful.

## 1. Find out what kind of annotation you have

```python
import fitz  # pymupdf
d = fitz.open("annotated.pdf")
print(sum(len(list(p.annots() or [])) for p in d))
```

Non-zero means real PDF annotations: read `annot.type`, `annot.info["content"]`
and `annot.vertices`, then go to step 5. Zero means the ink is flattened into
the page content, which is what Apple Markup, GoodNotes, most tablet apps and
"print to PDF" produce. Everything below is for that case.

## 2. Identify the ink

Flattened ink is a vector drawing in one distinctive colour. Enumerating
drawings per page finds that colour, and shows whether a second pen colour is
hiding on a page you have not looked at:

```python
for i in range(d.page_count):
    cols = {}
    for dr in d[i].get_drawings():
        c = tuple(round(v, 2) for v in (dr.get("color") or dr.get("fill")))
        cols[c] = cols.get(c, 0) + 1
    print(i + 1, cols)
```

Figure and chart pages show many colours; body pages showing exactly one are
the annotated ones. Some apps merge every stroke on a page into a single path
object, so the count per page tells you nothing about how many marks there are.
That is step 3's job.

## 3. Census the marks before reading them

Rasterise, mask the ink colour, **mask out coloured text spans**, dilate to
merge strokes into marks, and label. The masking matters: hyperlinks and
cross-references are usually blue and will otherwise be counted as pen.

```python
import numpy as np
from scipy import ndimage

Z = 2.0
pix = page.get_pixmap(matrix=fitz.Matrix(Z, Z))
a = np.frombuffer(pix.samples, dtype=np.uint8).reshape(
    pix.height, pix.width, pix.n)[:, :, :3].astype(int)
r, g, b = a[:, :, 0], a[:, :, 1], a[:, :, 2]
ink = ((b - r) > 40) & (b > 60) & (r < 150)          # tune to the ink colour
for bl in page.get_text("dict")["blocks"]:
    for l in bl.get("lines", []):
        for s in l["spans"]:
            if s["color"] != 0 and not s["font"].startswith(".SFNS"):
                x0, y0, x1, y1 = [int(v * Z) for v in s["bbox"]]
                ink[max(0, y0 - 3):y1 + 3, max(0, x0 - 3):x1 + 3] = False
lab, n = ndimage.label(ndimage.binary_dilation(ink, np.ones((25, 25))))
```

Print every cluster with its bounding box and pixel count, per page. Keep the
small ones: a 40-pixel squiggle is still a mark, even when it turns out to be a
slip of the pen. Skip pages that are wholly figures, and reconcile the totals
against the item list in step 8.

## 4. Get a rough transcript, then read the pages

Handwriting recognition often survives as text in a system font (`.SFNS` on
Apple), carrying coordinates with it:

```python
for l in bl["lines"]:
    txt = "".join(s["text"] for s in l["spans"] if s["font"].startswith(".SFNS"))
```

Use it as an index into the pages, never as the comment itself. It reliably
mangles handwriting: "Frettime" for "First time", "interval" for "internal".
Then render each annotated page at ~2.6× and read it as an image, cropping at
4–5× wherever a strike, a small margin note or an arrow tail is ambiguous.

Reading rules worth following:

- A margin note attaches to whatever its arrow, underline or bracket touches.
  Follow the stroke; the nearest line is often not the target.
- A strike plus a word above it is one replacement, not two comments.
- Several strokes are frequently one comment: a bracket, a symbol and a
  sentence. Merge them into one item and record the merge.
- Anything you cannot read confidently goes on a list for the annotator.
  Guessing wastes their time and yours.

## 5. Check every comment against the current source

The annotated render is a snapshot, and the document has moved on. Locate each
comment in the live source before writing it up, drop what has already been
fixed, and quote the wording as it stands now.

## 6. Answer what you can before asking anyone

Many marks are questions the repository or document already answers: what a
symbol means, how large a dataset was, what a library argument does, whether a
figure supports the claim made about it. Resolve those and convert them into
concrete suggestions. Only genuinely open questions should reach the annotator,
and they should be asked in one batch.

## 7. Write it up for its audience

The deliverable is a markdown file, not a posted comment. Write it to the
working tree (`review/<target>-response.md` or similar), show it, and iterate
with the annotator until they are happy. It should be ready to paste into an
issue, a PR description, an email or a reply to a journal, so keep it free of
anything tied to one destination.

- Two groups: wording suggestions, and everything beyond simple wording.
- Index every item (A1, A2, … B1, B2, …) so the recipient can pick and choose,
  and offer the wording group as a single patch or PR.
- Quote the text being commented on and give the concrete replacement.
- Locate by page number from a **fresh render of the current source**, not from
  the annotated PDF, whose pagination is out of date.
- The reader does not care that the comments began as scribbles. One line of
  attribution at the top is enough; nothing else should mention the medium.
- Keep an author-only section for open questions, and strip it before sending.

## 8. Reconcile before sending

State the arithmetic: N marks across M pages, mapping to K items, plus every
mark that maps to nothing — dropped as unclear, resolved as needing no change,
or superseded by later edits. If the numbers do not add up, a comment has been
missed.

## 9. Repaginating a computed document

When the source computes values from a pipeline whose store is not available,
copy the source, replace the setup chunk with stub assignments of the same
shape, render locally, and delete the copy. Inline numbers are a few characters
wide, so pagination is unaffected.

## 10. Sending, only when asked

Never post, comment, email or push as part of doing the extraction. Hand over
the markdown and wait for an explicit instruction to send it.

When that instruction comes: strip the author-only section, and check which
account the CLI is authenticated as before promising anything. A comment can
usually be added to a closed issue, but reopening one may need permissions a
bot account does not have.
