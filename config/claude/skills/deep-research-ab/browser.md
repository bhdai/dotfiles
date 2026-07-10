# The research browser

The browser is driven through the **agent-browser** skill — a Rust CLI (`agent-browser
<cmd>`) that talks to Chrome over CDP and returns compact, token-cheap text. **That skill
is the source of truth for the command vocabulary** (`open`, `read`, `snapshot`, `click`,
`type`, `eval`, `cookies`, `network`, …). When you need a command you don't know, invoke
the `agent-browser` skill or run `agent-browser skills get core --full` — don't guess flags.
This file adds only what _research_ needs on top: the persistent logged-in profile, the
read discipline, the bot-wall workaround, and the per-platform quirks.

This is the **drive-when-blocked** tool — reach for it only when `WebFetch`/`WebSearch`
can't return the true source: login walls, JS rendering, or a platform's native in-thread
search. For open static pages (docs, blogs, changelogs, GitHub, wikis), fetch instead.

You do **not** see pixels.

## The persistent research profile

Every command carries the same dedicated Chrome profile so logins persist across sessions
with no save/load dance:

```
--profile ~/.local/share/agent-browser-research
```

e.g. `agent-browser --profile ~/.local/share/agent-browser-research open <url>`. This
profile persists cookies, localStorage, and IndexedDB across restarts automatically — a
crash or a forgotten `close` never costs you a login. Treat `--profile
~/.local/share/agent-browser-research` as a fixed prefix on **every** `agent-browser`
command in a research run; a command without it launches a blank browser and looks logged
out.

**Logins are one-time per site, done by the user manually** in a headed window — never ask
for their credentials. To stage a login, open headed and hand off:

```
agent-browser --profile ~/.local/share/agent-browser-research open --headed https://old.reddit.com/login/
```

Then the user signs in; the auth cookie lands in the profile and future headless runs are
logged in.

## Getting past bot walls: the Referer trick

A cold, referrer-less navigation to some platforms trips their WAF — **Reddit** serves a
"blocked by network security" page on direct navigation but lets you through when you
arrive with a Google referrer. Set it once per session before navigating:

```
agent-browser --profile ~/.local/share/agent-browser-research set headers '{"Referer":"https://www.google.com/","Accept-Language":"en-US,en;q=0.9"}'
```

After a navigation, confirm you weren't blocked:
`agent-browser ... eval "/network security|blocked/i.test(document.body.innerText)"` → must
be `false`. If a platform greets a direct hit with a block page, try the referrer before
concluding it's down.

## Read cheap, snapshot only to act

**Default to `agent-browser read` (or `eval "document.body.innerText.slice(0,3000)"`) to
consume a page. Reserve `agent-browser snapshot` for when you are about to click/type and
need `@eN` refs.** `read` returns agent-readable text from the rendered, authed DOM;
`snapshot` serialises the whole accessibility tree — far more tokens — and research is
mostly reading, so snapshotting every thread exhausts the window before you've triangulated
anything. That context is the budget you triangulate with. Never snapshot a page you only
mean to read.

JS-heavy pages must finish rendering before the read is worth taking —
`agent-browser wait --text "<known bit>"` (or `wait --load networkidle`), or read after the
interaction settles.

## Check login by cookies, not `document.cookie`

Auth cookies (`reddit_session`, `token_v2`, …) are **httpOnly** — invisible to
`eval "document.cookie"`, which will falsely read as logged-out. Verify a session two
reliable ways:

- the CDP cookie store, which sees httpOnly:
  `agent-browser --profile … cookies | grep -E "reddit_session|token_v2"`
- the page's own logged-in marker: on old.reddit the header username
  (`#header-bottom-right .user`); a "Log in or sign up" prompt there means logged out.

## Known platform quirks (verified 2026-07-06 on agent-browser)

The right platforms depend on the question — discover them ("Finding platforms" below),
don't limit yourself to this table. It records only access/search quirks for platforms
already met, so re-meeting one is cheap:

| Platform                           | Access                                                                                     | Native search                                    |
| ---------------------------------- | ------------------------------------------------------------------------------------------ | ------------------------------------------------ |
| **ArchWiki / Voz Forums / GitHub** | Open, no login. Most reliable.                                                              | URL or site search box                           |
| **Reddit**                         | `www` often blocked in VN + WAF-blocks cold nav → use **old.reddit** + **Google Referer**  | `/search/?q=...&type=posts&sort=relevance&t=all` |
| **X**                              | Anonymous → login wall; logged in returns full posts                                       | `/search?q=...&f=live`                            |
| **Facebook groups**                | Login wall anonymous; logged-in readable                                                   | group search                                     |

When you meet a new platform worth keeping, add a row.

## Finding platforms

Use a Google search **only to discover where the conversation lives** — the right
subreddit, forum, or community for the question. Then open that platform and search it
natively. The Google results page is a map to platforms, never a source itself: cite the
posts you land on, not the search blurbs. For Facebook, don't use Facebook's own search —
find Facebook posts via a Google search instead.

## On-platform AI as a lead-finder

Some platforms host their own AI that surfaces posts keyword search misses: **Reddit
Answers** and **X's Grok**. On those platforms **reach for the AI first, then search to
widen** — the AI is the fastest way into the good threads, and its cited posts hand you the
vocabulary and leads to drive the native search harder afterward. Run both, not either;
each surfaces threads the other misses. Treat the AI as you treat Google — a **map to
posts, never a source**: the synthesis is uncited Tier-D; the product is the posts it
links, which you open and read natively, then triangulate like any other.

This is a browser interaction, not a URL: click into the feature, `type` the query and
submit, then **wait out the stream** — the answer types itself in token by token and the
cited links land last, so `agent-browser wait --text "<completion cue>"` and read too early
at your peril. Then follow the cited links.

**Do not query Reddit Answers via the `?q=...` URL param.** Navigating to
`reddit.com/answers/?q=your+question` is ignored — the landing page shows
Recommended/Recent suggestions, and a read then silently scrapes *other people's* suggested
question text, which looks like a real answer but isn't. You must `type` into the `Ask a
question` textbox and submit; a genuine answer lives at `reddit.com/answers/<uuid>/?q=...`
(note the UUID) — no UUID in the URL means you're reading suggestions, not your answer.

**Reddit Answers renders inside a shadow DOM.** `document.body.innerText` and `read` come
back nearly empty, and a normal `querySelectorAll('a[href*="/comments/"]')` finds **zero**
cited links — the answer text and its "Generated from these posts" links live in a shadow
root. Don't conclude it failed; read it by walking shadow roots via `eval`:

```
agent-browser --profile ~/.local/share/agent-browser-research eval "(() => { let out=[]; document.querySelectorAll('*').forEach(el => { if (el.shadowRoot) { out.push(el.shadowRoot.textContent); el.shadowRoot.querySelectorAll('a[href*=\"/comments/\"]').forEach(a => out.push(a.href)); } }); return out.join('\n').slice(0, 4000); })()"
```

Those extracted post URLs are the product — open and read them natively.

**Hold a conversation, not one shot** — keep asking: rephrase, drill into a sub-question,
chase a name or claim from the last answer. Each round surfaces posts the previous one
missed.

**With Grok, pin the corpus and license an empty answer.** Asked plainly, Grok answers like
web-grounded ChatGPT — it quietly falls back to blogs/GitHub and pads a confident essay
that only *looks* X-sourced (watch the "N posts, M web pages" footer: a high web count means
it found little on X). Two phrases fix this: (1) *"Search ONLY X posts — no web pages,
blogs, or GitHub"* forces the corpus you want; (2) *"if there are few or no good posts, say
so plainly rather than filling in from general knowledge"* converts padding into an honest
null. A forced-empty Grok answer is itself the signal to go look on Reddit or the docs
instead. Route by corpus: reach for Grok when the answer plausibly lives on X (breaking
releases, real-time sentiment, AI/tech-figure discourse).

## Navigating threads

`agent-browser open` jumps to any URL (the fast path); `agent-browser snapshot` then
`click @eN` presses links/buttons (next-page, "load more", sort, timeline scrubber);
`agent-browser press PageDown`/`End` or `eval "window.scrollTo(...)"` move within a page.

When the URL path fails — you can't guess a site's search query params, or a typed-in URL
doesn't load the results — **stop guessing and drive the page like a human**: snapshot,
click the search box, `type` the query and submit (`agent-browser press Enter`), and follow
the on-page links. Same for any config picker, filter, or dropdown: interact with the real
control rather than reverse-engineering its URL.

**On Reddit or X the search box is never your first move** — the instant you land, query
the platform's AI (Reddit Answers, Grok — above); come to the search box only afterward, to
widen with the vocabulary its cited posts gave you.

**On an open forum (Voz, GitHub, public Discourse), page by URL with `WebFetch`** — no
login and stable page/post URLs, so fetching `…/page-N` reads a page far cheaper than a
snapshot. But **one fetch returns only that page — a thread's first page is not the thread,
and the threads Google surfaced are not the whole discussion.** The on-topic material sits
on later pages and in threads Google never indexed. So before you synthesize:

- **Run the forum's _own_ search**, not just Google's links: `/search/` across the whole
  site surfaces posts Google misses. Drive the search box (type + submit) when the URL
  params won't guess.
- **Go past page 1** of any load-bearing thread — fetch `…/page-2`, `…/page-3`, or jump to
  the on-topic post via in-thread search.

Drive the browser only for what fetch can't do: in-thread search on skinned sites and
dynamic controls. Two engines cover most threads; **for both, don't read a long thread
linearly** — search the thread, jump to each hit, read its neighbourhood.

**Discourse** (PyTorch, Hugging Face, many OSS communities) — no real "pages": one
infinite-scroll stream where every post has a _number_.

- Jump in with `/t/<slug>/<topic-id>/<post-number>`; it loads ~20 posts around that point.
- Search `/search?q=...` with operators: `topic:<id> <keyword>` (search _inside_ one giant
  thread — the power move), `order:likes` (best answers), `@user`, `category:...`,
  `in:first`, `"exact phrase"`.

**XenForo** (Voz and many enthusiast forums) — real paginated pages.

- Pages: `…/page-<N>`. Route prefix varies — `/threads/` by default, **Voz uses `/t/`**
  (threads `/t/<slug>.<id>/`, forums `/f/<slug>.<id>/`).
- Jump to a post with `…/post-<post-id>` (also `/posts/<post-id>/`).
- No `topic:` operator. Global search is `/search/`. In-thread search may be renamed or
  hidden on skinned sites (Voz) — verify per site.

## Rules

- **Logins are one-time per site, done by the user manually** in the headed window. Never
  ask for their credentials.
- **Company WiFi blocks X** at the network level — the user must switch to phone hotspot
  for that source. Reddit and GitHub work on company WiFi.
- **Reddit `www` is intermittently ISP-blocked in VN** — prefer `old.reddit.com`, and note
  Reddit Answers (new-Reddit only) may be unreachable while `www` is blocked.
- When a command or flag is unknown, load the **agent-browser** skill or run
  `agent-browser skills get core --full` — never invent flags.
