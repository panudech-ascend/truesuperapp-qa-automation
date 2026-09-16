# true Shop — QA automation

UI automation for the **true Shop** Flutter app (`com.amaze.apptrue`), driven
from outside the app with Appium and written in Robot Framework.

This is a proof of concept. It covers two flows — signing in, and choosing a
branch — to prove the app can be driven by an out-of-process tool at all. The
framework choice is not final: see [Choosing a different framework](#choosing-a-different-framework).

## Status

| | |
|---|---|
| Flows covered | Sign in, branch select (4 test cases) |
| Verified on a device | **Not yet** — see [What is unproven](#what-is-unproven) |
| App under test | debug build, `com.amaze.apptrue` |
| Backend | live, over ngrok |

## Requirements

Setting up for the first time? Follow **[SETUP.md](SETUP.md)** — it goes from an
empty Mac to a passing run, one step at a time.

The short version, for a machine that is already set up:

```bash
brew install appium
appium driver install uiautomator2
brew install pipx && pipx ensurepath        # then open a new terminal
pipx install robotframework
pipx inject robotframework robotframework-appiumlibrary
```

> Install through Homebrew and pipx, not `pip3 install` — a Homebrew Mac
> refuses the latter with `externally-managed-environment` (PEP 668).

## Running the tests

**1. Get the app.** The APK is ~177 MB and is not committed, so build it:

```bash
./scripts/fetch_apk.sh          # builds, copies to apps/, installs on the device
```

By default it looks for the app repo at `../truesuperapp`; override with
`APP_REPO=/path/to/truesuperapp ./scripts/fetch_apk.sh`.

**2. Start Appium** in its own terminal, and leave it running:

```bash
appium
```

**3. Run:**

```bash
robot --outputdir results tests/                 # everything
robot --outputdir results --include smoke tests/ # the two core cases
robot --outputdir results tests/login.robot      # one suite
```

Open `results/report.html` for the result and `results/log.html` to see each
step, including a screenshot wherever a test failed.

## How the app is located

The app is Flutter, which draws its own widgets — Appium sees one canvas, not a
tree of buttons, so nothing is findable by default. The app therefore publishes
an **accessibility id** on each element the tests need, via
`Semantics(identifier:)` in the Flutter code. Those ids are the contract between
the two repos; renaming one in the app breaks the suites here.

| Accessibility id | Screen | What it is |
|---|---|---|
| `login_page` | Login | Marks the screen |
| `login_submit_button` | Login | The One Login button |
| `branch_select_page` | Branch select | Marks the screen |
| `branch_select_loading` | Branch select | Spinner while loading |
| `branch_tile_<id>` | Branch select | One branch, e.g. `branch_tile_rama9` |
| `branch_confirm_button` | Branch select | Confirms the choice |

All of them live in [`resources/app.resource`](resources/app.resource) as
variables — use those, don't hard-code the strings.

**Need an id that isn't there?** Ask the app team to add it. Do not work around
it with a coordinate tap or an XPath over the raw tree: both break on the next
layout change.

## What is unproven

**No test in this repo has been run against a device yet.** The suites are
written against the ids the app publishes and the responses the backend
currently returns, but nobody has watched them pass. Expect the first run to
need adjustment — most likely the waits, which are guesses about how slow the
live backend is.

Before trusting a result, confirm with Appium Inspector that the ids in the
table above actually appear on the device. If they do not, the problem is in the
app, not in these tests.

## Known limitations

**A failed login cannot be tested.** The backend answers every login with
success, so the error dialog is unreachable from here. Testing it needs either a
backend that can be told to fail, or a build pointed at a mock server
(`--dart-define=API_BASE_URL=...`).

**The branch list comes from the backend.** The tests assume several branches
and a primary branch of `rama9`. If the backend ever returns a single branch,
the app confirms it automatically and never shows the picker — every branch test
would then fail without the app being broken.

**Miniapps need a debug build and a context switch.** Most of the app's content
(the Sales and Stock tabs, and ~35 miniapps) is web content inside a WebView.
Appium sees it only after switching context:

```robotframework
Switch To Context    WEBVIEW_com.amaze.apptrue
```

That context exists only in a **debug** build — `MainActivity` enables WebView
debugging for debuggable builds alone. A release build cannot reach inside a
miniapp at all. Nothing here exercises that yet.

## Choosing a different framework

Appium and Robot Framework were picked to get this proof of concept moving, not
because the app requires them. The app publishes standard OS accessibility ids,
which means **Maestro**, Espresso/XCUITest, and most commercial tools can drive
it just as well, using the same ids in the table above.

Two alternatives worth weighing before committing:

- **Maestro** — YAML, no server to run, far less to install. The same flows fit
  in a few lines. Also reaches inside WebViews.
- **Patrol** — Dart, runs through Flutter's own tooling, so no APK needs to be
  built and handed over. It finds widgets by Flutter `Key`, which the app
  already has ~32 of, so it would not need the accessibility ids at all.

Whichever is chosen, the work already done in the app carries over: the
accessibility ids serve every out-of-process tool, and the Flutter keys serve
the Dart-based ones.

## Layout

```
SETUP.md     first-time setup, step by step
apps/        the APK under test (gitignored — build it with scripts/fetch_apk.sh)
resources/   connection settings, locators, shared keywords
tests/       one .robot suite per flow
results/     run output (gitignored)
scripts/     helpers
```
