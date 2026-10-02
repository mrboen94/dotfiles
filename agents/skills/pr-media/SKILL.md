---
name: pr-media
description: 'Use when a change affects UI or UX and needs visual evidence in a pull request: capture before/after screenshots at mobile, tablet and desktop sizes, record flows, combine each change into one labelled side-by-side image, and upload the media privately to the PR body without committing it. Also use when review changes alter a captured view and the PR media must be refreshed.'
---

# PR Media

Visual evidence for pull requests with [scripts/pr-media.mjs](scripts/pr-media.mjs) (`node <skill-dir>/scripts/pr-media.mjs help`). If the repository has its own PR or media rules, follow those; this skill fills in where it has none.

Requirements: Node 18+, Playwright (in the project, globally, or via `PLAYWRIGHT_FROM`) with Chromium installed (`npx playwright install chromium`), `gh` logged in for publishing, and optionally `ffmpeg` for MP4/GIF recordings. Run the script from inside the repository the PR belongs to.

## Rules

- **Before you change anything**, capture the current state of every view you will touch at mobile (390px), tablet (820px) and desktop (1440px). If the code is already changed, capture the base branch from a separate `git worktree` on another port; never revert work to capture.
- **One image per change per screen size**: before on the left, after on the right, same scale, labelled. Show the change in use on its page, not only the isolated component; one overview image covering several components is fine.
- **New views** have no before: capture every state at every size as "New" frames, in use.
- **Bugs found but not fixed** get a "Not fixed" screenshot with a one-line description, and are listed under "Known issues" in the PR body.
- **Flows, animations and timing**: add before and after recordings as separate files, shown side by side in the PR body. Do not merge videos.
- **Media is never committed.** It lives in the git-ignored `.pr-media/` folder (the script adds it to `.git/info/exclude` if needed) and is uploaded as GitHub attachments, which only people with access to the repository can view. Do not use gists; anyone with the link can open them.
- **Keep it current**: when later commits change a captured view, recapture, compare and publish again.
- Use a Mermaid diagram in the PR body when a flow is easier to read as a picture.

## Procedure

1. **Plan** every page, state and flow the change touches, in the order reviewers should read them, and pick a slug for each (`profile-card`). Capture in that order: the PR body follows it.
2. **Write a steps module** when the page needs sign-in or interaction. It can export three async functions:
   - `setup({context, page})` runs before navigation: auth cookies, init scripts, routes.
   - `ready({page})` waits for real content rather than a loading spinner. Recordings are trimmed to start here.
   - a default function reaches the state to capture (open a dialog, fill a form), or drives the flow while recording.

   Wait on content and test IDs, not fixed timeouts. Prefer mock or seeded local data over real accounts, and never capture personal data or secrets.
3. **Before**: `capture --name <slug> --state before --url <url> --steps steps.mjs --title "…"`. When a user flow changes or still images can't show the change, also run `record --name <slug> --state before --url <url> --steps flow.mjs` with the same slug and URL.
4. **Implement and verify** the change.
5. **After**: capture the same slugs, sizes and states with `--state after`, and repeat recordings with the same steps. New views use `--state after` only. Unfixed bugs use `--state bug --note "what is wrong, how to reproduce"`.
6. **Combine**: run `compare --name <slug> [--note "…"]` for each slug. Open every composite and check that it shows the right state, that before and after show the same place, that nothing is cut off, and that it contains no personal data. Measure suspected bugs before reporting them.
7. **Publish** once the PR exists (a draft is fine): `publish --pr <number> --update-body` uploads the composites and recordings and replaces the section between the `<!-- pr-media:start -->` and `<!-- pr-media:end -->` markers. If there's a lot of media, each change goes in a `<details>` section whose summary says what it contains. Republishing only uploads changed files. Without `--update-body`, it prints the markdown for you to place yourself.

Other options: `--viewports mobile,desktop`, `--selector CSS` (a single element), `--storage-state FILE`, `--color-scheme dark`. To combine screenshots taken with other tools, use `compose --before a.png --after b.png --out file.png`.

## Caveats

- The attachment upload uses GitHub's undocumented `uploads.github.com/user-attachments/assets` endpoint with the `gh` token. If it fails, publish with `--store branch`, which commits media to an orphan `pr-media` branch instead, and tell the user.
- `--full-page` only extends captures when the document itself scrolls. Apps that scroll inside a container need the relevant part scrolled into view instead.
- Mock APIs can return data a real backend wouldn't. If a recording shows something surprising, check whether the mock or the code causes it before you publish or report it.

## Report

List the captured views and sizes, published composites and recordings, and "Not fixed" issues, plus anything you could not capture and why. Never describe screenshots you did not take.
