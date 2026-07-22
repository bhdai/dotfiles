---
name: deep-research
description: Research a question from the best live evidence — official docs, source, or practitioner communities — read directly and triangulated, fetched where possible and driven in a browser when not. Type /deep-research with a question.
---

# Deep Research

Answer a question from the best available evidence, read at its **source** and checked
before you believe it — not from a search engine's summary, a listicle, or your own
priors. The discipline is three moves: **go where the answer lives**, **read the source
directly**, then **triangulate**.

Where the answer lives depends on the question. A factual or how-does-it-work question is
answered in the docs, the changelog, the source code. A "what actually happens in
production" question is answered by practitioners on the platforms where they gripe. The
failure mode is reaching for one fixed home — always docs, or always Reddit — regardless
of what was asked. Match the source to the question.

The product is a short, fully-cited finding that answers the user's _actual_ question. A
pile of confident-sounding tabs is the failure mode; a claim that survives lateral
checking is the product.

Match the tool to the source. **Fetch open static pages** — `WebFetch` and `WebSearch`
read docs, changelogs, blogs, GitHub, and wikis directly and cheaply, with no browser
setup; this is the default for anything that loads without a login. **Drive
login-walled or JS-heavy platforms straight away** — Reddit, X, and Facebook groups gate
their content, so go directly to the browser; don't waste a fetch probe on a platform you
already know needs a login (see browser.md's quirk table). For an *unknown* platform,
fetch is a fair first try — but treat a truncated, empty, or blocked fetch as a failed
read and escalate, never triangulate on a degraded page.

**`WebSearch` is US-only.** It powers *discovery* — finding where the answer lives — not
reading, and from Vietnam it's unavailable or US-skewed, missing local sources (Voz,
Tinhte, VN Facebook groups, pricing in đồng). When it's absent or the question is
VN-local, do discovery by driving the browser to Google instead (browser.md, "Finding
platforms"). `WebFetch` of a known URL is unaffected — geography doesn't block fetching a
specific page, so read VN pages directly as normal.

**Fetch-first is a tool choice, never a source choice.** Do not let what fetches easily —
blogs and docs — crowd out the practitioner and social sources the question's **shape**
demands. When the shape points to Reddit, X, or a forum, those are the answer's home:
`WebFetch` returns a login stub or a stripped page, not the posts, so a pile of fetchable
blogs is a substitution, not the research. **The moment your source list names a
login-walled or JS-heavy platform (Reddit, X, Facebook, native forum search), read
[browser.md](browser.md) and drive** — don't quietly settle for what fetch could reach.

The browser mechanics (profiles, logins, per-platform quirks, extraction) also live in
browser.md — read it up front when your plan names a browser platform (step 1), or whenever
a platform later misbehaves.

## Go where the answer lives

Classify the question's **shape** before you search — it decides which sources you open
first. State the shape you picked in one line so the choice is visible.

| Shape                     | Looks like                                     | Go first to                                                                     |
| ------------------------- | ---------------------------------------------- | ------------------------------------------------------------------------------- |
| **Factual / mechanism**   | "how does X work", "what does this API do"     | Official docs, source code, changelog (A) → forums for gotchas                  |
| **Usage / best-practice** | "right way to do X", "how should I structure…" | Official docs + canonical examples (A) → practitioner threads for caveats (B)   |
| **Opinion / experience**  | "is X worth it", "what breaks in prod"         | Practitioner communities (B) → social for sentiment (C)                         |
| **Comparison / decision** | "X vs Y", "which should I pick"                | Docs of _both_ for capability (A) + practitioner threads for real tradeoffs (B) |
| **Current state / news**  | "what changed in v…", "latest on…"             | Changelog/releases, GitHub, X (A/C)                                             |

Most real questions are a blend — lead with the dominant shape, then fill gaps from the
others. The shape sets your _starting_ tier; the ladder below sets what you'll _accept_.

## The source ladder

Rank every source by credibility; never rest a load-bearing claim on the bottom two rungs.
The ladder is about trust, the router above about where to start — a source can be the
right place to look and still need corroboration.

| Tier                     | What                                                                                                                                                                 | Use for                                                                                                                                             |
| ------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------- |
| **A — Primary**          | Official docs, API references, source code, changelog/release notes, the original author's post, upstream bug report, maintainer commit, distro wiki (e.g. ArchWiki) | The ground truth. Start here for factual/usage questions; **trace** every claim down to here.                                                       |
| **B — Practitioner**     | Subreddits, vendor/enthusiast forums, GitHub issues, mailing lists, first-party engineering blogs                                                                    | Lived experience and authored guidance. The main ground for opinion/experience — but a first-party blog spins, so corroborate it against docs/code. |
| **C — Social/ephemeral** | X, YouTube comments, Discord                                                                                                                                         | Sentiment and leads. Noisy and ToS-gray — corroborate before citing.                                                                                |
| **D — Commentary/SEO**   | Review sites, listicles, reseller/ad posts, AI-generated content                                                                                                     | **Not sources.** Spec/factual verification only — never opinion.                                                                                    |

## The loop

### 1. Frame the question and pick its shape

Write the user's real question in one sentence, name its **shape** from the router, then
list the specific sources you'll open first. Picking the shape and sources up front is
what stops the run from drifting into whatever a search engine surfaces — or into Reddit
by reflex when the answer lives in the docs.

**If any named source needs the browser** — Reddit, X, Facebook, a native forum search, or
anything login-walled or JS-heavy — **read [browser.md](browser.md) now, before the first
fetch.** Needing the browser is a fact you already know from the plan, so load its mechanics
up front rather than discovering the block midway and interrupting the research to read them
then.

**Done when:** a one-line question, its named shape, and a named source list all exist —
and if any named source needs the browser, browser.md has been read.

### 2. Read the source directly

Open each source and use _its own search_ — the docs site's search and the actual code
for factual/usage questions; for experience questions, the forum's search box or GitHub
issue search, and **on Reddit or X the platform's AI first — Reddit Answers, Grok — then
`reddit.com/search` / X live search** to widen (see browser.md). The instant you land on an
AI-equipped platform, the AI is your first action, never the search box. You are reading the
doc, the code, or the thread itself, not a search engine's summary of it.

**Never guess canonical doc URLs.** Reverse-engineering paths — `.ipynb` sources,
`raw.githubusercontent`, `/api/…` reference routes — burns fetches on 404s, redirects, and
rate-limits. Use the site's own search to get the real URL; when a fetch returns a
redirect, an empty body, or a 4xx/429, that's the signal to search for the right page, not
to guess the next path.

A Google search is allowed for **one job: discovering _where_ the answer lives** — the
right doc page, repo, subreddit, or forum to then open and read natively. Never cite the
Google results page or its blurbs, and never lean on review sites except to verify a hard
fact (a spec, a date). The sources you reach are an open set; don't limit yourself to ones
you already know.

**Make the forum legwork visible.** Google finding threads is not the forum's own search,
and a thread's first page is not the thread. So before synthesizing, on a practitioner
forum you must _state, with URLs_:

- on a platform with its own AI (Reddit Answers, X's Grok), the **AI query you ran first**
  and the posts it pointed you to — reach for the AI before the search box, then let its
  leads sharpen the search; run both, not either, since each surfaces threads the other
  misses (see browser.md);
- the **native search you ran** and how many hits you triaged from it, not just the
  threads Google surfaced. XenForo search URLs (Voz) rarely guess — **drive the search box
  like a human** (click it, `browser_type` the query, `submit: true`) rather than skipping
  the search when the URL won't work;
- for each **load-bearing thread**, the **pages you actually read** (`page-1`, `page-3`, or
  "single page") — a thread you only opened at the top is not yet read.

An unstated search or an unpaged multi-page thread is unfinished work, not a judgement call
— show the artifact or keep digging (mechanics in browser.md).

**Done when:** you are reading the actual source — doc, code, or thread — across at least
three independent sources for a question of real weight; on any AI-equipped platform you
ran both its AI and its native search; and the forum-legwork artifact above exists.

### 3. Read laterally and trace to the original

Keep the claim in one tab and open _other_ tabs to check it — fact-checkers read across
sources, not down a single page. **Trace** quotes, numbers, and screenshots back to the
earliest credible origin. Discard Tier-D noise on sight: reseller listings, ad posts, and
AI-generated comments are not owner experience even when they sit in a real thread.

**Done when:** every load-bearing claim has been checked _outside_ the page it came from,
and each quote/number is traced to its source.

### 4. Triangulate — the gate

**No load-bearing _opinion_ or contested claim rests on fewer than two independent
sources.** A fact stated by an authoritative primary — an official doc, the source code,
the changelog — can stand on that one source, but verify it against the actual code or
release notes when it's load-bearing. Everything else is either triangulated or explicitly
flagged as single-source / contested — never quietly asserted. When sources disagree,
surface the disagreement; the lone dissent is often the most useful thing you found.

**Done when:** every load-bearing claim is backed by ≥2 independent sources, anchored to
an authoritative primary, or visibly flagged.

### 5. Synthesize a cited finding

Write the answer to the user's _actual_ question, organised by what they asked about.
Every claim carries an inline link to its source. State contradictions honestly. End with
a direct answer — the recommendation, the verdict, the number — not a hedge.

**Done when:** the finding addresses the original question head-on and every claim is
cited.

## Apply SIFT throughout

Run the four **SIFT** moves on any source before you trust it — **S**top, **I**nvestigate
the source, **F**ind better coverage, **T**race to the original. Re-Stop whenever a source
gives you an emotional tug; that reaction is what bad sources are built to trigger. Full
detail in the playbook referenced above.
