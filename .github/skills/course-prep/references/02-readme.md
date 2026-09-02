# Phase 2 — Attendee-facing README

The `README.md` is the **attendee-facing** course reference page. It uses **HackMD-style** syntax
(the user publishes it on HackMD), which is *not* plain GitHub Markdown. Preserve these constructs:

- **YAML front-matter** (`image`, `tags`, Google Analytics `GA` id).
- **Admonition blocks**: `:::success`, `:::info`, `:::warning` … `:::`.
- An optional **mind map**: a ```` ```markmap ```` fenced block.

## Hard rule: attendee-only

Keep **trainer-private** content out of the README — no demo-environment details, no model-choice
rationale, no Terraform, no internal notes. Those live in `docs/` (Phase 6 and
`docs/demo-environment.md`). If you find such a section in an old README, **move** it to `docs/`.

## Required sections (adapt to the course)

1. **Front-matter + title + one-paragraph intro** — what the course teaches, in plain language.
2. **`## Course`** — `:::success` with the per-instance metadata: **Date** (`YYYYMMDD`),
   **Course ID** (the numeric ESI delivery id). `:::info` with the **Course Survey** link.
3. **`## Course Materials`** — the Microsoft Learn learning-path links (EN / `zh-cn` / `zh-tw`) and
   the Learn course page.
4. **`## Infos`** — LxP portal (`esi.microsoft.com`) and ESI support links.
5. **`## Lab`**
   - **Skillable**: ESI Labs link + `:::success` **Training key** + `:::info` redeem-once / valid
     6 months note.
   - **Instruction**: for each lab repo, link only its hosted instruction index, followed by that
     repo's single `main.zip` link. Do not enumerate individual exercises in the attendee README;
     the hosted index is the exercise list. Add Simplified Chinese / Traditional Chinese hosted
     index links only when the localized repositories actually exist and resolve correctly. If
     they don't exist, omit them.
6. **`## Links`** — curated, **module-grouped** authoritative Microsoft links: a
   `### Foundations & cross-cutting` group, then one `### Mxx - <module name>` group per course
   module. Keep it **link-only**: when the slides surface a comparison (e.g. *ChatCompletions API
   vs Responses API*, *Default vs Custom deployment settings*), add a concise `##### X vs Y` topic
   heading with the authoritative link(s) beneath — **no inline prose summaries or comparison
   tables**. The conceptual depth for those comparisons lives in `docs/teaching-guide.md`.
7. **`## Videos`** — one curated *official-only* table with a **Module** column. See **Videos**
   below.
8. *(recommended)* **`## Mind Map`** — a ```` ```markmap ```` overview placed after Videos and
   immediately before `## Applied Skills`, mirroring the finalized Links taxonomy. See **Mind map**
   below.
9. **`## Applied Skills`** — include the verified credential title/link only when Phase 1 confirms
   that a skill-based credential exists. If the course has only an Achievement Code, omit this
   entire heading rather than leaving an empty section.
10. **`## Contact`** — the trainer/contact block used by the course repo.

## Per-instance metadata to refresh every delivery

`Date`, `Course ID`, `Course Survey`, and the **Skillable Training key**. These change per class —
update them and nothing else when only re-running the same course.

## Quality bar

- **Verify every external link *semantically*, not just HTTP 200** (see "Organizing & verifying
  links"). Drop or fix dead links, and links that 200 but redirect to a generic hub/browse page.
- Prefer canonical `learn.microsoft.com/...` URLs over blog/marketing pages. End-user (business
  user) how-to pages on `support.microsoft.com` are also authoritative.
- Keep wording concise and attendee-appropriate; technical depth goes in `docs/teaching-guide.md`.
- When the slides show two competing concepts, add a concise `##### X vs Y` topic heading in the
  relevant `## Links` subsection with the authoritative link(s) beneath — keep the explanation /
  comparison table in `docs/teaching-guide.md`, **not** in the attendee README.

## Organizing & verifying links

**Group by module, not by service.** The `## Links` section mirrors the course's authoritative
module list: a `### Foundations & cross-cutting` group first (concepts that span modules), then one
`### Mxx - <module name>` group per module. Inside each group, lead with the Microsoft Learn
**module** page, then the supporting concept/how-to pages. Add `##### X vs Y` sub-headings only
where the course actually contrasts two concepts.

**Verify semantically — a 200 is not enough.** For every candidate URL, confirm:
1. **Final URL after redirects** — keep the canonical destination in the README.
2. **Page title / H1 matches the topic** — a live page can still be the *wrong* page.
3. **Locale** — a localized link must actually serve that locale, not silently fall back to EN.

Known-good redirects you should keep (the *final* URL): `aka.ms/...` short links; GitHub
`archive/refs/heads/main.zip` → `codeload.github.com`; the learn.microsoft.com
`/copilot/microsoft-365/...` → `/microsoft-365/copilot/...` move. **Drop** any link that 200s but
redirects to a generic hub (e.g. `.../training/browse/`) — that page no longer exists.

**Build one shared ledger.** Collect all candidate links + videos into a single list (label | url)
and run the checker so `## Links`, `## Videos`, the mind map, and `docs/teaching-guide.md` all cite
the *same* verified URLs. Re-run before every delivery — Microsoft rename/retire pages often.

> **Tool:** [`scripts/link_check.py`](../scripts/link_check.py) takes a `label | url` file and
> prints status + final URL + `<title>` for pages, and LIVE/OFFICIAL + channel + title for videos.
> Create the course environment with `uv venv .venv`, then run:
> `.venv\Scripts\python.exe .github\skills\course-prep\scripts\link_check.py urls.txt`.
> The checker exits non-zero for failed URLs, unavailable videos, or unapproved channel identities.
> It also rejects HTTP 200 responses that land on known generic/error destinations
> (`Fault.aspx`, `ClassID=-1`, unregistered `aka.ms` → Bing, or a generic Learn browse page).
> If the user explicitly requires a known-bad link to remain, prefix that ledger label with
> `ALLOW-SEMANTIC:` and document the exception in trainer material.

## Videos

The `## Videos` section is **one flat, official-only table**. Do not split it into Foundations or
per-module subsections. Use a 4-column table:
`| No. | Name | Module | Link |` with `youtu.be/<id>` links. Set Module to `Foundations` for
cross-cutting videos or `M01`, `M02`, ... for a module-specific video.

**Required shape**

````markdown
## Videos
| No. | Name | Module | Link |
| --- | --- | --- | --- |
| 1 | <verified official video> | Foundations | [youtu.be/<id>](https://youtu.be/<id>) |
| 2 | <verified official video> | M04 | [youtu.be/<id>](https://youtu.be/<id>) |

## Mind Map
```markmap
# <course title>
```

## Applied Skills
[<credential title>](<verified credential URL>)

## Contact
````

When an Applied Skills credential exists, the tail order is exact:
**Videos → Mind Map → Applied Skills → Contact**. When no credential exists, omit the entire
Applied Skills section and use **Videos → Mind Map → Contact**. There are no `###` headings inside
`## Videos`, no empty module tables, and no unrelated course sections after Videos.

**Sourcing priority (best first):**
1. The course's **own official video series/playlist** if one exists (search `aka.ms/<COURSE>onYouTube`
   and the Microsoft Learn channel for a per-module episode series) — the single strongest source.
2. Videos **embedded in the course slide deck** (extract via the deck's hyperlink/media relationships
   — see [01-research.md](01-research.md)). These are the ones the course author chose.
3. Additional **official** per-module explainers/demos to fill gaps.

**Hard rules:**
- **Official first-party channels ONLY.** Verify each via YouTube oEmbed (see the tool): confirm
  both `author_name` **and** `author_url` match a verified Microsoft-owned channel identity
  (e.g. *Microsoft*, *Microsoft 365*, *Microsoft Learn*,
  *Microsoft Mechanics*, *Microsoft Developer/365 Developer*, *Microsoft Community Learning*, regional
  *Microsoft APAC/ANZ*). For GitHub-branded courses, GitHub's official channel is also first-party.
  **Reject third-party creators** even when the content looks good, and reject
  anything you cannot confirm the channel of (oEmbed 403 = embedding disabled → verify by hand or drop).
- **Liveness:** oEmbed 404 = unavailable → drop. Re-verify the whole set every delivery.
- **Relevance over completeness.** Keep a video only if it is (a) on-topic for that module, or
  (b) genuinely **foundational/important** context. **Drop off-topic, dated, or redundant clips**
  (e.g. generic app-Copilot demos on an *agents* course) and **do not pad** a module with weak videos.
  Dated product branding in a title (e.g. an old product name) is a signal to look for a newer official
  replacement.
- **No absence placeholders.** If a module has no verified video, it simply has no row. Never add
  text such as "No verified official module-specific video found."
- **No catch-all padding.** Include customer stories or similar content only when it specifically
  demonstrates a course module; label that row with the owning module. Otherwise omit it.

## Mind map

Add a `## Mind Map` after `## Videos` and immediately before `## Applied Skills`; when no Applied
Skills credential exists, place it immediately before `## Contact`. It is a single
```` ```markmap ```` fenced block (HackMD renders it).

**Structure**
- **Root `#`** = the course title.
- **`##` nodes** = `Foundations` + each `Mxx - <module name>` — i.e. **mirror the finalized `## Links`
  taxonomy** so the map, the links, and the modules all agree.
- **`###` / bullet nodes** = the concept spine of each module (below).

**What content each branch must carry** — the map is a *revision aid*, so every module branch should
capture the things a learner is tested/assessed on, not marketing lines:
- **The module's core concepts / the "what"** — the handful of ideas the module teaches (e.g. what an
  agent is, its parts, the benefits).
- **The course's `X vs Y` contrasts** — reuse the same comparisons as the `##### X vs Y` link
  headings, written with **bold `**X**` vs `**Y**`** (e.g. free-tier **vs** licensed, tool-A **vs**
  tool-B, web **vs** work grounding). These are the highest-value revision points.
- **Named items the module enumerates** — e.g. each prebuilt agent/tool/service by name, and the
  specific capabilities or limits the slides call out.
- **Labs / hands-on** — a short `**Labs**: …` note on any module that has exercises.
- **Authoritative links inline** — attach the **same verified URLs** from the ledger as
  `[text](url)` on the concept they explain (not a separate link list).

**Leave out**: per-instance metadata, Skillable/ESI logistics, marketing taglines, and any link not
already verified in the ledger. Don't dump every link — just the spine.

**Shape to aim for** (illustrative — adapt node names to the actual course):

```
## Mxx - <module name>
### <sub-theme>
- Core concept, embedded as [concept](https://learn.microsoft.com/...)
- **<Option A>** vs **<Option B>**: one-line distinction
- Named item 1 / Named item 2 / Named item 3
- **Labs**: <exercise>, <exercise>
```

- Keep it dense-but-scannable; prefer 2–5 bullets per module over exhaustive detail.
- Verify the fence is balanced (one ```` ```markmap ```` open, one ```` ``` ```` close) and that every
  embedded link is in the verified ledger.
