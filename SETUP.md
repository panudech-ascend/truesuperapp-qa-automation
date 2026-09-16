# Setup — from nothing to a passing test run

Written for someone setting this up on a Mac for the first time. Follow the
steps in order. Each one says what you should see when it worked, so you can
tell before moving on.

Everything installs through **Homebrew**. Do not use `pip3 install` directly —
on a Homebrew Mac it fails with `externally-managed-environment`.

---

## Before you start

You need a Mac with Homebrew. Check:

```bash
brew --version
```

**Expected:** a version number, e.g. `Homebrew 4.x.x`.

**If it says `command not found`:** install Homebrew from
<https://brew.sh>, then open a **new** terminal and try again.

---

## Step 1 — Install Appium

Appium is the program that taps the phone for you.

```bash
brew install appium
```

Check it:

```bash
appium --version
```

**Expected:** a version number, e.g. `3.7.0`.

---

## Step 2 — Install the Android driver

Appium needs a driver to speak to Android.

```bash
appium driver install uiautomator2
```

**Expected:** ends with `Driver uiautomator2@x.x.x successfully installed`.

Check it:

```bash
appium driver list --installed
```

**Expected:** a line mentioning `uiautomator2`.

---

## Step 3 — Install Robot Framework

Robot Framework is the language the tests are written in.

```bash
brew install pipx
pipx ensurepath
```

Now **close the terminal and open a new one** — `pipx ensurepath` changes your
PATH, and only a new terminal picks it up.

In the new terminal:

```bash
pipx install robotframework
pipx inject robotframework robotframework-appiumlibrary
```

> Why not `brew install robot-framework`? Because the tests also need
> **AppiumLibrary**, which is not in Homebrew. `pipx` installs Robot Framework
> and then adds AppiumLibrary into the same isolated environment, so both end up
> on your PATH together.

Check it:

```bash
robot --version
```

**Expected:** something like `Robot Framework 7.x.x (Python 3.x.x on darwin)`.

**If it still says `command not found`:** you are in the old terminal. Open a
new one.

---

## Step 4 — Install the Android tools

You need `adb` (talks to the phone) and an emulator to run the app on.

```bash
brew install --cask android-platform-tools
```

Check it:

```bash
adb version
```

**Expected:** `Android Debug Bridge version 1.0.xx`.

For the emulator, install **Android Studio** from
<https://developer.android.com/studio>, open it once, and create a virtual
device through **Device Manager** (any recent Pixel is fine).

> If Android Studio is already installed, you already have `adb` — skip the brew
> command above.

### Tell Appium where the SDK is

Appium refuses to start a session without this, with
`Neither ANDROID_HOME nor ANDROID_SDK_ROOT environment variable was exported`.
Having `adb` on your PATH is not enough — the variable has to be set too.

```bash
echo '
# Android SDK — Appium needs this to find adb and the emulator
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"' >> ~/.zshrc
```

Then **open a new terminal** and check:

```bash
echo $ANDROID_HOME
```

**Expected:** `/Users/<you>/Library/Android/sdk`.

**If it prints nothing:** you are still in the old terminal, or the SDK is
somewhere else. Find it with `ls ~/Library/Android/sdk`; if that path does not
exist, open Android Studio → Settings → Languages & Frameworks → Android SDK and
use the path shown there.

---

## Step 5 — Start the emulator

Start your virtual device from Android Studio's Device Manager, wait until the
home screen is up, then check the computer can see it:

```bash
adb devices
```

**Expected:**

```
List of devices attached
emulator-5554	device
```

**If it says `unauthorized`:** look at the emulator screen and accept the
debugging prompt.

**If the list is empty:** the emulator has not finished booting. Wait and try
again.

Note the name (`emulator-5554`) — you need it in step 7.

---

## Step 6 — Install the app

The app is not in this repo (it is a 177 MB file). Build it from the app repo:

```bash
cd /path/to/truesuperapp-qa-automation
./scripts/fetch_apk.sh
```

**Expected:** ends with `Success` from `adb install`.

This needs the app source checked out next to this repo. If it sits elsewhere:

```bash
APP_REPO=/path/to/truesuperapp ./scripts/fetch_apk.sh
```

**If you were handed an `app-debug.apk` file instead of the source**, put it in
the `apps/` folder and install it yourself:

```bash
adb install -r apps/app-debug.apk
```

Check the app is on the device:

```bash
adb shell pm list packages | grep amaze
```

**Expected:** `package:com.amaze.apptrue`.

---

## Step 7 — Point the tests at your device

Open `resources/app.resource` and find this line near the top:

```robotframework
${DEVICE_NAME}              emulator-5554
```

If `adb devices` in step 5 showed a different name, change it to match.

---

## Step 8 — Start Appium

Appium runs as a server that stays open while you test.

```bash
appium
```

**Expected:** `Appium REST http interface listener started on http://0.0.0.0:4723`.

**Leave this terminal alone.** It will keep printing as tests run. Closing it
stops the tests from working.

---

## Step 9 — Run the tests

Open a **second terminal** (the first one is busy running Appium):

```bash
cd /path/to/truesuperapp-qa-automation
robot --outputdir results tests/
```

**Expected:** the emulator wakes up, the app opens, it signs in and picks a
branch by itself, and the terminal finishes with something like:

```
4 tests, 4 passed, 0 failed
```

---

## Step 10 — Read the result

```bash
open results/report.html
```

- **report.html** — pass or fail, at a glance.
- **log.html** — every step, with a screenshot wherever a test failed.

---

## When something goes wrong

| What you see | What it means | What to do |
|---|---|---|
| `command not found: robot` | Step 3 not finished, or you are in the terminal from before `pipx ensurepath` | Open a new terminal; if it persists, redo step 3 |
| `command not found: appium` | Step 1 not finished | Redo step 1 |
| `Could not connect to http://127.0.0.1:4723` | Appium is not running | Do step 8 in its own terminal |
| `Neither ANDROID_HOME nor ANDROID_SDK_ROOT ... was exported` | Appium cannot find the Android SDK | Set `ANDROID_HOME` (step 4), then restart Appium from a **new** terminal |
| `An unknown server-side error... device` | The emulator is off or not visible | Redo step 5 |
| `Application is not installed` | The app is not on the device | Redo step 6 |
| Tests fail waiting for `branch_select_page` | Sign-in never finished — usually the backend | See "About the backend" below |
| All tests fail immediately | Usually Appium or the device, not the app | Work through steps 5, 6, 8 again |

### About the backend

The app talks to a live backend over an ngrok URL. If that server is down or its
URL has changed, sign-in fails and **every test fails even though nothing is
wrong with the app**. Before reporting a bug, open the app on the emulator by
hand and tap the login button — if it fails there too, the problem is the
backend.

---

## What to do about a failure

1. Open `results/log.html` and find the red step.
2. Look at the screenshot on that step — it shows the screen when it gave up.
3. Reproduce it by hand on the emulator.
   - **Fails by hand too** → a real bug. Report it with the screenshot and the
     steps.
   - **Works by hand** → the test is at fault, usually waiting for something
     that is now named differently, or not waiting long enough. Report it to the
     app team; do not patch around it by tapping coordinates.

---

## What to ask the app team for

The tests find things on screen by **accessibility id** — names the app
publishes on purpose. Six exist today, listed in
[README.md](README.md#how-the-app-is-located).

To test a screen that has none, ask the app team to add them. Tell them which
screen and which elements you need to tap or read. Do not work around a missing
id with a coordinate tap or an XPath — both break the next time the layout
changes.
