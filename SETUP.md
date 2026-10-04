# Setup

```
Part 1  Install        once per machine     ~30 min
Part 2  Get a build    once per build       1 command
Part 3  Run            every test session   3 terminals
```

Everything installs through Homebrew. Do not use `pip3 install` — it fails on a
Homebrew Mac.

---

## Part 1 — Install (once)

Run these in order. Each row says what proves it worked.

| # | Run | You should see |
|---|---|---|
| 1 | `brew --version` | `Homebrew 4.x.x` — if not, install from <https://brew.sh> |
| 2 | `brew install appium` | then `appium --version` → `3.x.x` |
| 3 | `appium driver install uiautomator2` | `successfully installed` |
| 4 | `brew install pipx && pipx ensurepath` | — **then open a new terminal** |
| 5 | `pipx install robotframework` | — |
| 6 | `pipx inject robotframework robotframework-appiumlibrary` | then `robot --version` → `Robot Framework 7.x` |

You also need an **Android emulator you can open and leave running**. Any recent
Pixel is fine. Set it up however you normally do.

---

## Part 2 — Get a build (once per build)

Ask whoever builds the app for the APK this command produces — that one build,
nothing else:

```bash
flutter build apk --debug --flavor dev
```

They will hand you `app-dev-debug.apk`. Copy it in, renamed:

```bash
cp ~/Downloads/app-dev-debug.apk apps/app-debug.apk
```

That is all. The tests install it on the next run.

Any other build fails: the tests look for `com.amaze.apptrue.dev`, which only
`--flavor dev` produces, and only `--debug` lets them read the Stock screens.

---

## Part 3 — Run (every session)

Open your Android emulator and leave it on its home screen. Then three terminals,
left running:

### Terminal 1 — Appium

```bash
appium --allow-insecure=uiautomator2:chromedriver_autodownload
```

→ `Appium REST http interface listener started on http://0.0.0.0:4723`

Use that whole line every time. Plain `appium` looks fine, then the last 2 tests
fail.

### Terminal 2 — the Stock screens

From the `superapp-mini-app-fe` folder:

```bash
npm run dev
```

→ `Local: http://localhost:3000`

### Terminal 3 — the tests

```bash
robot --outputdir results tests/
```

→ `6 tests, 6 passed, 0 failed`

The first run is slow; it installs the app.

| To run | Command |
|---|---|
| Everything | `robot --outputdir results tests/` |
| 3 core cases | `robot --outputdir results --include smoke tests/` |
| The 2 Stock tests | `robot --outputdir results --include miniapp tests/` |
| One file | `robot --outputdir results tests/login.robot` |

### Read the result

```bash
open results/report.html
```

| File | Shows |
|---|---|
| `report.html` | Pass or fail, at a glance |
| `log.html` | Every step, with a screenshot where it failed |

---

## When something goes wrong

| What you see | Fix |
|---|---|
| `command not found: robot` | Open a new terminal; else redo Part 1 steps 4-6 |
| `command not found: appium` | Redo Part 1 step 2 |
| `Could not connect to http://127.0.0.1:4723` | Terminal 1 is not running |
| `Neither ANDROID_HOME nor ANDROID_SDK_ROOT ... exported` | Set `ANDROID_HOME` to your Android SDK path, then restart Appium in a **new** terminal |
| `An unknown server-side error... device` | Emulator is off — start it, check with `adb devices` |
| `Application is not installed` | No APK in `apps/` — see Part 2 |
| `No Chromedriver found that can automate Chrome ...` | Terminal 1 was started without the `--allow-insecure` part |
| `No WEBVIEW context yet: ['NATIVE_APP']` | Wrong build — ask for `flutter build apk --debug --flavor dev` |
| Only the last 2 tests fail | Terminal 2 is not running |
| Nothing happens on the emulator at all | Your emulator may have a different name. Run `adb devices` and put that name in `${DEVICE_NAME}` in `resources/app.resource` |
| Fails waiting for `branch_select_page` | See **sign-in** below |
| Everything fails at once | Emulator or Appium, not the app — recheck Part 3 |

### Sign-in

The build signs in by itself, no server involved, so this should not fail. If it
does, tap the login button on the emulator by hand:

| Result | Means |
|---|---|
| Fails by hand too | Real bug — report it with the screenshot |
| Works by hand | The test is at fault — report it to the app team |

An error dialog with `Ref. T-COR-00401` means the build was made to fail its
sign-in. Ask for one that signs in.

---

## A test failed — what now

1. `open results/log.html`, find the red step
2. Look at its screenshot — that is the screen when it gave up
3. Try the same thing by hand on the emulator

| By hand | Means |
|---|---|
| Fails too | Real bug. Report it with the screenshot and the steps |
| Works | The test is at fault. Report it; do not patch around it |

## A screen with no test

Tests can only find elements that carry a name put there on purpose. The names
that exist today, and which team to ask for a new one, are in
[README.md](README.md#what-the-tests-can-find).
