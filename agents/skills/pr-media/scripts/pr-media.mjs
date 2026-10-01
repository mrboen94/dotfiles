#!/usr/bin/env node
// Capture, compare and publish pull request screenshots and recordings.
// Workflow: ../SKILL.md. Media lives in <repo>/.pr-media and is never committed to the code branch.
import {execFileSync, spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import fs from 'node:fs';
import {createRequire} from 'node:module';
import os from 'node:os';
import path from 'node:path';
import {pathToFileURL} from 'node:url';
import {parseArgs} from 'node:util';

const VIEWPORTS = {
  mobile: {label: 'Mobile', viewport: {width: 390, height: 844}, deviceScaleFactor: 2, isMobile: true, hasTouch: true},
  tablet: {label: 'Tablet', viewport: {width: 820, height: 1180}, deviceScaleFactor: 1, isMobile: true, hasTouch: true},
  desktop: {label: 'Desktop', viewport: {width: 1440, height: 900}, deviceScaleFactor: 1, isMobile: false, hasTouch: false},
};
const STATES = ['before', 'after', 'bug'];
const MARK_START = '<!-- pr-media:start -->';
const MARK_END = '<!-- pr-media:end -->';

const USAGE = `usage: node pr-media.mjs <command> [options]

  capture  --name SLUG --state before|after|bug --url URL
           [--viewports mobile,tablet,desktop] [--full-page] [--selector CSS] [--wait-for CSS]
           [--steps FILE.mjs] [--storage-state FILE] [--color-scheme light|dark]
           [--title TEXT] [--note TEXT]
  record   --name SLUG --state before|after|bug --url URL --steps FILE.mjs
           [--viewports desktop] [--storage-state FILE] [--title TEXT] [--note TEXT]
  compare  --name SLUG [--title TEXT] [--note TEXT]
           Builds one composite per viewport: before|after side by side, "New" for
           after-only captures, "Not fixed" for bug captures.
  compose  --after FILE [--before FILE] --out FILE [--title TEXT] [--note TEXT]
           Composite for screenshots taken with other tools (MCP, device screenshots).
  publish  --pr NUMBER [--repo OWNER/NAME] [--collapse-after 4] [--update-body]
           [--store attachments|branch] [--branch pr-media]
           Uploads composites and recordings as GitHub attachments (private to the repo,
           nothing committed) and prints the PR body markdown; --update-body replaces the
           section between ${MARK_START} markers in the PR body. --store branch is a
           fallback that commits media to an orphan branch instead.
  list     Show captured media.
  clean    [--name SLUG]  Delete local media.

--steps modules may export these async functions:
  setup({context, page, viewport, state})  before navigation: cookies, init scripts, routes
  ready({page, viewport, state})           after navigation: wait for real content; recordings
                                           start here, so app boot is trimmed from the video
  default({page, viewport, state})         reach the state to capture, or drive the flow
                                           while recording
Media directory: <git root>/.pr-media (override with PR_MEDIA_DIR).`;

function fail(message) {
  console.error(`error: ${message}`);
  process.exit(1);
}

function git(args, options = {}) {
  return execFileSync('git', args, {encoding: 'utf8', stdio: ['pipe', 'pipe', 'pipe'], ...options}).trim();
}

function gitRoot() {
  try {
    return git(['rev-parse', '--show-toplevel']);
  } catch {
    fail('run inside the git repository the pull request belongs to');
  }
}

// Media must never reach the code branch: ignore it locally if the repo does not already.
function mediaDir() {
  const root = gitRoot();
  const dir = process.env.PR_MEDIA_DIR ? path.resolve(process.env.PR_MEDIA_DIR) : path.join(root, '.pr-media');
  fs.mkdirSync(dir, {recursive: true});
  const relative = path.relative(root, dir);
  if (!relative.startsWith('..') && spawnSync('git', ['check-ignore', '-q', path.join(relative, 'probe')], {cwd: root}).status !== 0) {
    const exclude = path.join(path.resolve(root, git(['rev-parse', '--git-common-dir'], {cwd: root})), 'info', 'exclude');
    fs.mkdirSync(path.dirname(exclude), {recursive: true});
    fs.appendFileSync(exclude, `\n/${relative.split(path.sep).join('/')}/\n`);
    console.log(`note: added /${relative}/ to ${exclude}`);
  }
  return dir;
}

function slugDir(name) {
  if (!/^[a-z0-9][a-z0-9-]*$/.test(name ?? '')) fail('--name must be a lowercase-hyphen slug, e.g. profile-card');
  const dir = path.join(mediaDir(), name);
  fs.mkdirSync(dir, {recursive: true});
  return dir;
}

function readMeta(dir) {
  const file = path.join(dir, 'meta.json');
  return fs.existsSync(file) ? JSON.parse(fs.readFileSync(file, 'utf8')) : {};
}

function writeMeta(dir, values) {
  const meta = readMeta(dir);
  meta.created ??= new Date().toISOString();
  for (const [key, value] of Object.entries(values)) if (value !== undefined) meta[key] = value;
  fs.writeFileSync(path.join(dir, 'meta.json'), `${JSON.stringify(meta, null, 2)}\n`);
  return meta;
}

// Reuse an installed Playwright: PLAYWRIGHT_FROM, the current project, or a global install.
async function loadPlaywright() {
  const globalRoot = spawnSync('npm', ['root', '-g'], {encoding: 'utf8'}).stdout?.trim();
  const candidates = [process.env.PLAYWRIGHT_FROM, process.cwd(), gitRoot(), globalRoot && path.dirname(globalRoot)];
  for (const base of candidates.filter(Boolean)) {
    try {
      const resolved = createRequire(path.join(path.resolve(base), 'package.json')).resolve('playwright');
      return (await import(pathToFileURL(resolved).href)).default;
    } catch {
      // try the next location
    }
  }
  fail('Playwright not found. Install it in the project or globally (npm i -g playwright), or set PLAYWRIGHT_FROM to a directory with it installed; then npx playwright install chromium');
}

function parseViewports(value, fallback) {
  const names = (value ?? fallback).split(',').map((name) => name.trim()).filter(Boolean);
  for (const name of names) if (!VIEWPORTS[name]) fail(`unknown viewport '${name}'; use ${Object.keys(VIEWPORTS).join(', ')}`);
  return names;
}

async function loadSteps(stepsFile) {
  if (!stepsFile) return {};
  const module = await import(pathToFileURL(path.resolve(stepsFile)).href);
  if (module.default !== undefined && typeof module.default !== 'function') fail(`${stepsFile}: default export must be a function`);
  return {setup: module.setup, ready: module.ready, run: module.default};
}

function requireState(state) {
  if (!STATES.includes(state)) fail(`--state must be one of ${STATES.join(', ')}`);
}

async function capture(options) {
  requireState(options.state);
  if (!options.url) fail('--url is required');
  const dir = slugDir(options.name);
  writeMeta(dir, {title: options.title, note: options.note});
  const steps = await loadSteps(options.steps);
  const playwright = await loadPlaywright();
  const browser = await playwright.chromium.launch();
  try {
    for (const name of parseViewports(options.viewports, 'mobile,tablet,desktop')) {
      const {label, ...device} = VIEWPORTS[name];
      const context = await browser.newContext({
        ...device,
        ignoreHTTPSErrors: true,
        colorScheme: options['color-scheme'] ?? 'light',
        reducedMotion: 'reduce',
        storageState: options['storage-state'],
      });
      const page = await context.newPage();
      await steps.setup?.({context, page, viewport: name, state: options.state});
      await page.goto(options.url, {waitUntil: 'networkidle'});
      await steps.run?.({page, viewport: name, state: options.state});
      if (options['wait-for']) await page.locator(options['wait-for']).first().waitFor();
      await page.evaluate(() => document.fonts.ready);
      const out = path.join(dir, `${options.state}-${name}.png`);
      const target = options.selector ? page.locator(options.selector).first() : page;
      await target.screenshot({path: out, fullPage: options.selector ? undefined : Boolean(options['full-page']), animations: 'disabled'});
      console.log(`${label.padEnd(8)} ${path.relative(process.cwd(), out)}`);
      await context.close();
    }
  } finally {
    await browser.close();
  }
}

function hasFfmpeg() {
  return spawnSync('ffmpeg', ['-version'], {stdio: 'ignore'}).status === 0;
}

async function record(options) {
  requireState(options.state);
  if (!options.url || !options.steps) fail('--url and --steps are required');
  const dir = slugDir(options.name);
  writeMeta(dir, {title: options.title, note: options.note});
  const steps = await loadSteps(options.steps);
  const playwright = await loadPlaywright();
  const browser = await playwright.chromium.launch();
  const ffmpeg = hasFfmpeg();
  if (!ffmpeg) console.log('note: ffmpeg not found; keeping .webm only (no inline GIF preview)');
  try {
    for (const name of parseViewports(options.viewports, 'desktop')) {
      const {label, ...device} = VIEWPORTS[name];
      const scratch = fs.mkdtempSync(path.join(os.tmpdir(), 'pr-media-'));
      const context = await browser.newContext({
        ...device,
        deviceScaleFactor: 1,
        ignoreHTTPSErrors: true,
        storageState: options['storage-state'],
        recordVideo: {dir: scratch, size: device.viewport},
      });
      const page = await context.newPage();
      const started = Date.now();
      await steps.setup?.({context, page, viewport: name, state: options.state});
      await page.goto(options.url, {waitUntil: 'networkidle'});
      await steps.ready?.({page, viewport: name, state: options.state});
      // Trim app boot from the video: it starts when ready() resolves (or after navigation).
      const trimSeconds = Math.max(0, (Date.now() - started) / 1000 - 0.3).toFixed(2);
      await steps.run?.({page, viewport: name, state: options.state});
      await page.waitForTimeout(800);
      const video = page.video();
      await context.close();
      const base = path.join(dir, `${options.state}-${name}`);
      fs.copyFileSync(await video.path(), `${base}.webm`);
      fs.rmSync(scratch, {recursive: true, force: true});
      if (ffmpeg) {
        run('ffmpeg', ['-y', '-loglevel', 'error', '-ss', trimSeconds, '-i', `${base}.webm`, '-c:v', 'libvpx-vp9', '-b:v', '0', '-crf', '32', `${base}.trimmed.webm`]);
        fs.renameSync(`${base}.trimmed.webm`, `${base}.webm`);
        const width = Math.min(device.viewport.width, 960);
        run('ffmpeg', ['-y', '-loglevel', 'error', '-i', `${base}.webm`, '-movflags', '+faststart', '-pix_fmt', 'yuv420p', '-vf', 'scale=trunc(iw/2)*2:trunc(ih/2)*2', `${base}.mp4`]);
        run('ffmpeg', ['-y', '-loglevel', 'error', '-i', `${base}.webm`, '-vf', `fps=10,scale=${width}:-1:flags=lanczos,split[a][b];[a]palettegen=stats_mode=diff[p];[b][p]paletteuse=dither=bayer`, `${base}.gif`]);
        fs.rmSync(`${base}.webm`);
      }
      console.log(`${label.padEnd(8)} ${path.relative(process.cwd(), base)}.${ffmpeg ? '{mp4,gif}' : 'webm'}`);
    }
  } finally {
    await browser.close();
  }
}

function run(command, args) {
  const result = spawnSync(command, args, {stdio: 'inherit'});
  if (result.status !== 0) fail(`${command} failed`);
}

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>"]/g, (char) => ({'&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;'})[char]);
}

function dataUri(file) {
  return `data:image/png;base64,${fs.readFileSync(file).toString('base64')}`;
}

// One consistent frame: title bar, equal-width panels aligned to the top, dark label bar below.
function compositeHtml({title, note, panels}) {
  const columns = panels.map(() => '1fr').join(' ');
  return `<!doctype html><html><head><style>
    * { box-sizing: border-box; margin: 0; }
    body { background: #fff; font: 16px/1.4 system-ui, -apple-system, "Segoe UI", Roboto, sans-serif; color: #1f1f1f; }
    #frame { display: inline-block; border: 2px solid #1f1f1f; border-radius: 6px; overflow: hidden; background: #fff; }
    header { padding: 14px 20px; border-bottom: 2px solid #1f1f1f; }
    header h1 { font-size: 20px; font-weight: 600; }
    header p { font-size: 14px; color: #555; margin-top: 2px; }
    .panels, .labels { display: grid; grid-template-columns: ${columns}; }
    .panel { padding: 24px; display: flex; justify-content: center; align-items: flex-start; background: #f4f4f5; }
    .panel + .panel, .label + .label { border-left: 2px solid #1f1f1f; }
    .panel img { display: block; max-width: none; box-shadow: 0 1px 4px rgba(0,0,0,.18); background: #fff; }
    .labels { background: #1f1f1f; color: #fff; }
    .label { padding: 12px; text-align: center; font-size: 18px; font-weight: 600; letter-spacing: .02em; }
    .label.bug { background: #b42318; }
  </style></head><body><div id="frame">
    <header><h1>${escapeHtml(title)}</h1>${note ? `<p>${escapeHtml(note)}</p>` : ''}</header>
    <div class="panels">${panels.map((panel) => `<div class="panel"><img src="${dataUri(panel.file)}" style="width:${panel.width}px"></div>`).join('')}</div>
    <div class="labels">${panels.map((panel) => `<div class="label ${panel.bug ? 'bug' : ''}">${escapeHtml(panel.label)}</div>`).join('')}</div>
  </div></body></html>`;
}

async function renderComposite(browser, {title, note, panels, out}) {
  // Show screenshots at CSS size so both sides share one scale regardless of device pixel ratio.
  const sized = await Promise.all(panels.map(async (panel) => ({...panel, width: await cssWidth(browser, panel.file, panel.scale ?? 1)})));
  const page = await browser.newPage({viewport: {width: 800, height: 600}, deviceScaleFactor: Math.max(...panels.map((panel) => panel.scale ?? 1))});
  await page.setContent(compositeHtml({title, note, panels: sized}));
  await page.locator('img').evaluateAll((images) => Promise.all(images.map((image) => image.decode())));
  await page.locator('#frame').screenshot({path: out});
  await page.close();
  console.log(path.relative(process.cwd(), out));
}

async function cssWidth(browser, file, scale) {
  const page = await browser.newPage();
  const width = await page.evaluate(async (src) => {
    const image = new Image();
    image.src = src;
    await image.decode();
    return image.naturalWidth;
  }, dataUri(file));
  await page.close();
  return Math.round(width / scale);
}

async function compare(options) {
  const dir = slugDir(options.name);
  const meta = writeMeta(dir, {title: options.title, note: options.note});
  const title = meta.title ?? options.name;
  const playwright = await loadPlaywright();
  const browser = await playwright.chromium.launch();
  let made = 0;
  try {
    for (const [name, {label, deviceScaleFactor}] of Object.entries(VIEWPORTS)) {
      const file = (state) => path.join(dir, `${state}-${name}.png`);
      const exists = (state) => fs.existsSync(file(state));
      const heading = `${title} · ${label} ${VIEWPORTS[name].viewport.width}px`;
      const scale = deviceScaleFactor;
      let panels;
      if (exists('bug')) {
        panels = [{file: file('bug'), label: 'Not fixed', bug: true, scale}];
      } else if (exists('before') && exists('after')) {
        panels = [{file: file('before'), label: 'Before', scale}, {file: file('after'), label: 'After', scale}];
      } else if (exists('after')) {
        panels = [{file: file('after'), label: 'New', scale}];
      } else if (exists('before')) {
        console.log(`warning: ${name} has a before capture but no after capture; skipped`);
        continue;
      } else {
        continue;
      }
      await renderComposite(browser, {title: heading, note: meta.note, panels, out: path.join(dir, `composite-${name}.png`)});
      made += 1;
    }
  } finally {
    await browser.close();
  }
  if (made === 0) fail(`no captures found in ${dir}`);
}

async function compose(options) {
  if (!options.after || !options.out) fail('--after and --out are required');
  const playwright = await loadPlaywright();
  const browser = await playwright.chromium.launch();
  try {
    const panels = options.before
      ? [{file: options.before, label: 'Before'}, {file: options.after, label: 'After'}]
      : [{file: options.after, label: 'New'}];
    await renderComposite(browser, {title: options.title ?? path.basename(options.out, '.png'), note: options.note, panels, out: path.resolve(options.out)});
  } finally {
    await browser.close();
  }
}

function collectMedia() {
  const root = mediaDir();
  // PR body order follows capture order: plan the scenes in the order reviewers should read them.
  const created = (slug) => Date.parse(readMeta(path.join(root, slug)).created ?? '') || fs.statSync(path.join(root, slug)).birthtimeMs;
  const slugs = fs.readdirSync(root, {withFileTypes: true}).filter((entry) => entry.isDirectory()).map((entry) => entry.name);
  slugs.sort((a, b) => created(a) - created(b));
  return slugs.map((slug) => {
    const dir = path.join(root, slug);
    const files = fs.readdirSync(dir).sort();
    const composites = Object.keys(VIEWPORTS).map((name) => `composite-${name}.png`).filter((file) => files.includes(file));
    const videos = files.filter((file) => /^(before|after|bug)-[a-z]+\.(gif|mp4|webm)$/.test(file));
    return {slug, dir, meta: readMeta(dir), composites, videos, raw: files.filter((file) => /^(before|after|bug)-[a-z]+\.png$/.test(file))};
  });
}

function list() {
  for (const item of collectMedia()) {
    console.log(`${item.slug}${item.meta.title ? ` — ${item.meta.title}` : ''}`);
    console.log(`  captures:   ${item.raw.join(', ') || '-'}`);
    console.log(`  composites: ${item.composites.join(', ') || '- (run compare)'}`);
    console.log(`  recordings: ${item.videos.join(', ') || '-'}`);
  }
}

function clean(options) {
  const root = mediaDir();
  const target = options.name ? path.join(root, options.name) : root;
  if (path.relative(root, target).startsWith('..')) fail('refusing to delete outside the media directory');
  fs.rmSync(target, {recursive: true, force: true});
  console.log(`removed ${path.relative(process.cwd(), target) || '.'}`);
}

function repoSlug(explicit) {
  if (explicit) return explicit;
  const result = spawnSync('gh', ['repo', 'view', '--json', 'nameWithOwner', '-q', '.nameWithOwner'], {encoding: 'utf8'});
  if (result.status !== 0) fail('could not detect the GitHub repository; pass --repo OWNER/NAME');
  return result.stdout.trim();
}

const MIME = {'.png': 'image/png', '.gif': 'image/gif', '.mp4': 'video/mp4', '.webm': 'video/webm'};

// Upload like drag-and-drop in the PR editor: github.com/user-attachments URLs follow the
// repository's access rules and nothing is committed. The endpoint is undocumented; if it
// stops working, use --store branch. Uploads are cached by content, so republishing only
// sends changed files.
async function uploadAttachments({repo, files}) {
  const token = execFileSync('gh', ['auth', 'token'], {encoding: 'utf8'}).trim();
  const repositoryId = execFileSync('gh', ['api', `repos/${repo}`, '--jq', '.id'], {encoding: 'utf8'}).trim();
  const urls = {};
  for (const file of files) {
    const cacheFile = path.join(path.dirname(file.local), 'uploads.json');
    const cache = fs.existsSync(cacheFile) ? JSON.parse(fs.readFileSync(cacheFile, 'utf8')) : {};
    const key = `${repositoryId}:${file.remote}`;
    if (!cache[key]) {
      const query = new URLSearchParams({name: path.basename(file.remote), content_type: MIME[path.extname(file.local)], repository_id: repositoryId});
      const response = await fetch(`https://uploads.github.com/user-attachments/assets?${query}`, {
        method: 'POST',
        headers: {Authorization: `Bearer ${token}`, Accept: 'application/json', 'Content-Type': MIME[path.extname(file.local)]},
        body: fs.readFileSync(file.local),
      });
      if (!response.ok) fail(`upload of ${file.local} failed (HTTP ${response.status}); retry with --store branch`);
      cache[key] = (await response.json()).url;
      fs.writeFileSync(cacheFile, `${JSON.stringify(cache, null, 2)}\n`);
    }
    urls[file.local] = cache[key];
  }
  return urls;
}

// Fallback: commit media to an orphan branch with plumbing commands: the working tree, index
// and current branch are never touched. Links use the commit SHA so they never go stale.
function uploadToBranch({repo, branch, pr, files}) {
  // PR_MEDIA_REMOTE exists for offline tests; normal use pushes to the PR's own repository.
  const remoteUrl = process.env.PR_MEDIA_REMOTE ?? `https://github.com/${repo}.git`;
  const fetched = spawnSync('git', ['fetch', '--quiet', remoteUrl, `refs/heads/${branch}`], {encoding: 'utf8'});
  const parent = fetched.status === 0 ? git(['rev-parse', 'FETCH_HEAD']) : null;
  const index = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'pr-media-index-')), 'index');
  const env = {...process.env, GIT_INDEX_FILE: index};
  try {
    if (parent) git(['read-tree', parent], {env});
    else git(['read-tree', '--empty'], {env});
    for (const file of files) {
      const blob = git(['hash-object', '-w', file.local]);
      git(['update-index', '--add', '--cacheinfo', `100644,${blob},pr-${pr}/${file.remote}`], {env});
    }
    const tree = git(['write-tree'], {env});
    let commit = parent;
    if (!parent || git(['rev-parse', `${parent}^{tree}`]) !== tree) {
      commit = git(['commit-tree', tree, ...(parent ? ['-p', parent] : []), '-m', `Media for #${pr}`]);
      const push = spawnSync('git', ['push', '--quiet', remoteUrl, `${commit}:refs/heads/${branch}`], {stdio: 'inherit'});
      if (push.status !== 0) fail(`push to ${branch} failed`);
    }
    return Object.fromEntries(files.map((file) => [file.local, `https://github.com/${repo}/blob/${commit}/pr-${pr}/${file.remote}?raw=true`]));
  } finally {
    fs.rmSync(path.dirname(index), {recursive: true, force: true});
  }
}

function digest(file) {
  return createHash('sha256').update(fs.readFileSync(file)).digest('hex').slice(0, 8);
}

function mediaMarkdown({items, collapseAfter}) {
  const total = items.reduce((count, item) => count + item.composites.length + item.videos.length, 0);
  const collapse = total > collapseAfter;
  const blocks = items.map((item) => {
    const title = item.meta.title ?? item.slug;
    const lines = [];
    if (item.meta.note) lines.push(`_${item.meta.note}_`, '');
    for (const composite of item.composites) {
      const viewport = VIEWPORTS[composite.replace(/^composite-|\.png$/g, '')].label;
      lines.push(`![${title} – ${viewport}](${item.urls[composite]})`, '');
    }
    const videoCells = (state) => {
      const files = item.videos.filter((file) => file.startsWith(`${state}-`));
      const preview = files.find((file) => file.endsWith('.gif'));
      const video = files.find((file) => !file.endsWith('.gif'));
      return [preview ? `<img src="${item.urls[preview]}" width="100%">` : '', video ? `[${state} video](${item.urls[video]})` : '']
        .filter(Boolean)
        .join('<br>');
    };
    if (item.videos.length) {
      const states = STATES.filter((state) => item.videos.some((file) => file.startsWith(`${state}-`)));
      const headers = states.map((state) => ({before: 'Before', after: 'After', bug: 'Not fixed'})[state]);
      lines.push(`| ${headers.join(' | ')} |`, `| ${states.map(() => '---').join(' | ')} |`, `| ${states.map(videoCells).join(' | ')} |`, '');
    }
    if (!collapse) return [`#### ${title}`, '', ...lines].join('\n');
    const viewports = item.composites.map((file) => VIEWPORTS[file.replace(/^composite-|\.png$/g, '')].label.toLowerCase());
    const parts = [];
    const kind = item.raw.some((file) => file.startsWith('bug-')) ? 'not fixed, shown' : item.raw.some((file) => file.startsWith('before-')) ? 'before/after' : 'new';
    if (viewports.length) parts.push(`${kind} at ${viewports.join(', ')}`);
    if (item.videos.length) parts.push(item.videos.some((file) => file.startsWith('before-')) ? 'before/after recordings' : 'screen recording');
    return [`<details>`, `<summary><b>${escapeHtml(title)}</b> — ${parts.join(' + ')}</summary>`, '', ...lines, `</details>`].join('\n');
  });
  return [MARK_START, '### Screenshots and recordings', '', blocks.join('\n\n'), MARK_END].join('\n');
}

async function publish(options) {
  const pr = options.pr;
  if (!/^\d+$/.test(pr ?? '')) fail('--pr NUMBER is required');
  const repo = repoSlug(options.repo);
  const store = options.store ?? 'attachments';
  if (!['attachments', 'branch'].includes(store)) fail('--store must be attachments or branch');
  const items = collectMedia().filter((item) => item.composites.length || item.videos.length);
  if (!items.length) fail('nothing to publish; run capture/record and compare first');
  const files = [];
  for (const item of items) {
    for (const file of [...item.composites, ...item.videos]) {
      const local = path.join(item.dir, file);
      files.push({local, remote: `${item.slug}/${path.basename(file, path.extname(file))}-${digest(local)}${path.extname(file)}`});
    }
  }
  const urls = store === 'branch' ? uploadToBranch({repo, branch: options.branch ?? 'pr-media', pr, files}) : await uploadAttachments({repo, files});
  for (const item of items) {
    item.urls = Object.fromEntries([...item.composites, ...item.videos].map((file) => [file, urls[path.join(item.dir, file)]]));
  }
  const markdown = mediaMarkdown({items, collapseAfter: Number(options['collapse-after'] ?? 4)});
  if (options['update-body']) {
    const current = execFileSync('gh', ['pr', 'view', pr, '--repo', repo, '--json', 'body', '-q', '.body'], {encoding: 'utf8'});
    const pattern = new RegExp(`${MARK_START}[\\s\\S]*?${MARK_END}`);
    const body = pattern.test(current) ? current.replace(pattern, () => markdown) : `${current.trimEnd()}\n\n${markdown}\n`;
    execFileSync('gh', ['pr', 'edit', pr, '--repo', repo, '--body-file', '-'], {input: body, stdio: ['pipe', 'inherit', 'inherit']});
    console.log(`updated media section in ${repo}#${pr}`);
  } else {
    console.log(markdown);
  }
}

const [command, ...rest] = process.argv.slice(2);
const {values: options} = parseArgs({
  args: rest,
  allowPositionals: false,
  options: {
    name: {type: 'string'},
    state: {type: 'string'},
    url: {type: 'string'},
    viewports: {type: 'string'},
    'full-page': {type: 'boolean'},
    selector: {type: 'string'},
    'wait-for': {type: 'string'},
    steps: {type: 'string'},
    'storage-state': {type: 'string'},
    'color-scheme': {type: 'string'},
    title: {type: 'string'},
    note: {type: 'string'},
    before: {type: 'string'},
    after: {type: 'string'},
    out: {type: 'string'},
    pr: {type: 'string'},
    repo: {type: 'string'},
    store: {type: 'string'},
    branch: {type: 'string'},
    'collapse-after': {type: 'string'},
    'update-body': {type: 'boolean'},
  },
});

const commands = {capture, record, compare, compose, publish, list, clean};
if (!commands[command]) {
  console.log(USAGE);
  process.exit(command && command !== 'help' && command !== '--help' ? 1 : 0);
}
await commands[command](options);
