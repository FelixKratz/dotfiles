---
name: pdf-annotations
description: Extract handwritten or flattened annotations from a marked-up PDF and turn them into a review write-up a co-author can act on. Use when given an annotated manuscript, report, thesis or contract PDF and asked to pull out the comments, check them, or prepare them for an issue, email or PR.
---

# Extracting review comments from an annotated PDF

Aim for a write-up whose recipient never opens the PDF, and a completeness
claim that can be checked.

1. Establish the annotation type with PyMuPDF: a non-zero count from
   `page.annots()` means real annotations, so read `type`, `info["content"]`
   and `vertices` and go to step 4. Zero means flattened ink, which is what
   Apple Markup, tablet apps and "print to PDF" produce.
2. For flattened ink, find the pen colour through `page.get_drawings()`. Body
   pages carrying exactly one colour are the annotated ones; a second colour
   marks a page not yet looked at.
3. Census the marks before reading them. Rasterise, mask the ink colour, mask
   out coloured text spans so links and cross-references are not counted as
   pen, dilate to merge strokes, and label with `scipy.ndimage`. Keep small
   clusters; reconcile the totals in step 7.
4. Read the pages as images at roughly 2.6x, cropping to 4-5x for ambiguous
   strikes, margin notes and arrow tails. Any handwriting recognition text
   surviving in a system font is an index into the pages, never the comment
   itself. A margin note attaches to whatever its arrow or bracket touches; a
   strike with a word above it is one replacement; several strokes are often
   one comment. List anything unreadable for the annotator rather than guessing.
5. Check every comment against the current source, drop what is already fixed,
   and quote the wording as it now stands. Resolve whatever the repository or
   document already answers, and batch the genuinely open questions.
6. Write the deliverable to the working tree as markdown, ready for an issue,
   PR, email or journal reply. Separate wording suggestions from substantive
   comments, index every item (A1, B1, ...), quote the text and give the
   concrete replacement, and locate by page number from a fresh render of the
   current source. Keep open questions in an author-only section.
7. Reconcile before sending: N marks across M pages mapping to K items, plus
   every mark that maps to nothing. Numbers that do not add up mean a missed
   comment.

Never post, email or push as part of the extraction. Hand over the markdown,
and on an explicit instruction to send it, strip the author-only section and
confirm which account the CLI is authenticated as.
