# The research browser

A separate, automated Chrome instance driven through the Playwright MCP tools, on its own
profile (`/home/dai/.local/share/claude-research-browser`), headed, isolated from the
user's daily Firefox. Logins persist in that profile across sessions.

This is the **drive-when-blocked** tool — reach for it only when `WebFetch`/`WebSearch`
can't return the true source: login walls, JS rendering, or a platform's native in-thread
search. For open static pages (docs, blogs, changelogs, GitHub, wikis), fetch instead.

You do **not** see pixels.

## Snapshot to act, `innerText` to read

**Default to `browser_evaluate` returning `document.body.innerText` sliced to a few
thousand chars. Reserve `browser_snapshot` for when you are about to click/type and need
element refs.** A snapshot serialises the page's whole accessibility tree into context —
roughly 10x the tokens of the text — and research is mostly reading, so snapshotting every
thread exhausts the window long before you've triangulated anything. That context is the
budget you triangulate with. Never snapshot a page you only mean to read.

JS-heavy pages must finish rendering before the read is worth taking — `browser_wait_for`
a known bit of text, or read after the interaction settles.

## Known platform quirks (verified 2026-06-30)

The right platforms depend on the question — discover them (see "Finding platforms"
below), don't limit yourself to this table. It only records access/search quirks for
platforms already met, so re-meeting one is cheap:

| Platform                           | Access                                               | Native search                                    |
| ---------------------------------- | ---------------------------------------------------- | ------------------------------------------------ |
| **ArchWiki / Voz Forums / GitHub** | Open, no login. Most reliable.                       | URL or site search box                           |
| **Reddit**                         | Logged in, loads first try                           | `/search/?q=...&type=posts&sort=relevance&t=all` |
| **X**                              | Anonymous → login wall; logged in returns full posts | `/search?q=...&f=live`                           |
| **Facebook groups**                | Login wall anonymous; logged-in readable             | group search                                     |

When you meet a new platform worth keeping, add a row.

## Finding platforms

Use a Google search **only to discover where the conversation lives** — the right
subreddit, forum, or community for the question. Then open that platform and search it
natively. The Google results page is a map to platforms, never a source itself: cite the
posts you land on, not the search blurbs. Note that for Facebook search do not use Facebook
default search rather using google search for Facebook posts

## On-platform AI as a lead-finder

Some platforms host their own AI that will surface posts keyword search misses: **Reddit
Answers** and **X's Grok**. On those platforms **reach for the AI first, then search to
widen** — the AI is the fastest way into the good threads, and its cited posts hand you the
vocabulary and leads to drive the native search harder afterward. Run both, not either;
each surfaces threads the other misses, so the union is the point. Treat the AI as you
treat Google — a **map to posts, never a source**: the synthesis is uncited Tier-D; the
product is the posts it links, which you open and read natively, then triangulate like any
other.

This is a browser interaction, not a URL: click into the feature, `browser_type` the query
(`submit: true`), then **wait out the stream** — the answer types itself in token by token
and the cited links land last, so `browser_wait_for` the completion and read too early at
your peril. Then follow the cited links.

**Do not query Reddit Answers via the `?q=...` URL param** (verified 2026-07-03). Navigating
to `reddit.com/answers/?q=your+question` is ignored — the landing page just shows
Recommended/Recent suggestions, and a shadow-DOM read then silently scrapes *other people's*
suggested question text, which looks like a real answer but isn't. You must `browser_type`
into the `Ask a question` textbox with `submit: true`; a genuine answer lives at
`reddit.com/answers/<uuid>/?q=...` (note the UUID) — if there's no UUID in the URL, you're
reading suggestions, not your answer.

**Reddit Answers renders inside a shadow DOM** (`reddit.com/answers/…`, verified 2026-07-02).
`document.body.innerText` comes back nearly empty (~400 chars) and a normal
`querySelectorAll('a[href*="/comments/"]')` finds **zero** cited links — the answer text and
its "Generated from these posts" links live in a shadow root (Google-styled CSS classes are
the tell). Don't conclude it failed. Read it by walking shadow roots, e.g.
`browser_evaluate`: iterate `document.querySelectorAll('*')`, and for any `el.shadowRoot`
pull `.textContent` (the answer) and `el.shadowRoot.querySelectorAll('a[href]')` filtered to
`/comments/` (the cited posts). Those extracted post URLs are the product — open and read
them natively.
**Hold a conversation, not one shot** — keep asking: rephrase, drill into a sub-question,
chase a name or claim from the last answer. Each round surfaces posts the previous one
missed, and each surfaced post is a new lead to dig from.

**With Grok, pin the corpus and license an empty answer** (verified 2026-07-02). Asked
plainly, Grok answers like web-grounded ChatGPT — it quietly falls back to blogs/GitHub and
pads a confident essay that only *looks* X-sourced (watch the "N posts, M web pages"
footer: a high web count means it found little on X). Two phrases fix this: (1) *"Search
ONLY X posts — no web pages, blogs, or GitHub"* forces the corpus you actually want; (2)
*"if there are few or no good posts, say so plainly rather than filling in from general
knowledge"* converts padding into an honest null. The payoff often isn't better posts — for
a niche/technical topic the real conversation may live on Reddit, not X — it's a **fast,
trustworthy "not here"** instead of a citation-shaped hallucination. So route by corpus:
reach for Grok when the answer plausibly lives on X (breaking releases, real-time sentiment,
AI/tech-figure discourse); a forced-empty Grok answer is itself the signal to go look on
Reddit or the docs instead.

## Navigating threads

Both URL and clicks work: `browser_navigate` jumps to any URL (the fast path),
`browser_click` presses links/buttons from the snapshot (next-page, "load more", sort,
timeline scrubber), and `browser_press_key` (PageDown/End) or
`browser_evaluate(window.scrollTo)` move within a page.

When the URL path fails — you can't guess a site's search query parameters, or a typed-in
URL doesn't load the results — **stop guessing and drive the page like a human**: click the
search box, `browser_type` the query (with `submit: true` to press Enter), and follow the
on-page links. The same goes for any config picker, filter, or dropdown: interact with the
real control rather than reverse-engineering its URL.

**On Reddit or X the search box is never your first move** — the instant you land, query the
platform's AI (Reddit Answers, Grok — see "On-platform AI" above); come to the search box
only afterward, to widen with the vocabulary its cited posts gave you.

**On an open forum (Voz, GitHub, public Discourse), page by URL with `WebFetch`** — no
login and stable page/post URLs, so fetching `…/page-N` or `…/post-<id>` reads a page far
cheaper than a snapshot. But **one fetch returns only that page — a thread's first page is
not the thread, and the threads Google surfaced are not the whole discussion.** The
on-topic material — the warranty gripe six months later, the one-line mention buried in an
unrelated thread — sits on later pages and in threads Google never indexed. So before you
synthesize:

- **Run the forum's _own_ search**, not just Google's links: `/search/` for the store or
  topic across the whole site surfaces posts and comments Google misses. Drive the search
  box (type + `submit: true`) when the URL params won't guess.
- **Go past page 1** of any load-bearing thread — fetch `…/page-2`, `…/page-3`, or jump to
  the on-topic post via in-thread search; don't read linearly, but don't stop at the top
  either.

Drive the browser only for what fetch can't do: in-thread search on skinned sites and
dynamic controls (the moves below).

Two forum engines cover most threads; the moves below transfer across every site on the
same engine. **The rule for both: don't read a long thread linearly** — it blows time and
working memory, and most posts are noise. Search the thread, jump to each hit, read its
neighbourhood. A short thread you can just read top to bottom.

**Discourse** (PyTorch, Hugging Face, many OSS communities) — no real "pages": one
infinite-scroll stream where every post has a _number_.

- Jump in with `/t/<slug>/<topic-id>/<post-number>`; it loads ~20 posts around that point.
- Search `/search?q=...` with operators: `topic:<id> <keyword>` (search _inside_ one
  giant thread — the power move), `order:likes` (best answers, not newest), `@user`,
  `category:...`, `in:first`, `"exact phrase"`.

**XenForo** (Voz and many enthusiast forums) — real paginated pages. _(Voz scheme verified
firsthand 2026-06-30.)_

- Pages: `…/page-<N>`. Route prefix varies — `/threads/` by default, **Voz uses `/t/`**
  (threads `/t/<slug>.<id>/`, forums `/f/<slug>.<id>/`).
- Jump to a post with `…/post-<post-id>` — resolves to the right page + `#post-<id>` anchor
  (also `/posts/<post-id>/`).
- No `topic:` operator. Global search is `/search/`. XenForo _normally_ offers in-thread
  search via the thread-tools menu, but skinned sites (Voz) may rename or hide it — verify
  per site rather than assume.

## Rules

- **Logins are one-time per site, done by the user manually** in the visible window. Never
  ask for their credentials.
- **Company WiFi blocks X** at the network level — the user must switch to phone hotspot
  for that source. Reddit and GitHub work on company WiFi.
- First `browser_navigate` of a session may fail with "Target page… closed" — retry once;
  the browser launches on the second call.

The MCP install command and full troubleshooting history are in the user's
`research/NOTES.md` — the single source of truth for setup; don't duplicate it here.
