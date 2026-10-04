# true Shop — QA automation

Automated UI tests that tap through the app on an emulator and report whether
each flow still works.

**→ [SETUP.md](SETUP.md)** — install, get a build, run. That is the file you work
from. This one is for deciding what can be tested and who to ask.

## Status

| | |
|---|---|
| Covered | Sign in, branch select, Stock — 6 tests |
| Last checked | 6 of 6 pass |
| Build needed | `flutter build apk --debug --flavor dev` — that one only |
| Also needed | The Stock screens running on your machine |
| Sign-in | Answered by the build itself — no server involved |

## What the tests can find

A test can only reach an element that carries a name put there on purpose. So
this is also the list of what can be tested today — and the names are a promise
between teams: rename one and the tests break.

### App screens — ask the app team

| Name | Screen | What it is |
|---|---|---|
| `login_page` | Login | Marks the screen |
| `login_submit_button` | Login | The One Login button |
| `branch_select_page` | Branch select | Marks the screen |
| `branch_select_loading` | Branch select | Spinner while loading |
| `branch_tile_<id>` | Branch select | One branch, e.g. `branch_tile_rama9` |
| `branch_confirm_button` | Branch select | Confirms the choice |
| `nav_tab_home` | Home | The Home tab |
| `miniapp_<name>` | Home | A shortcut tile, e.g. `miniapp_stock` |

### Stock screens — ask the web team

| Name | Screen | What it is |
|---|---|---|
| `stock_page` | Stock | Marks the screen |
| `stock_search_field` | Stock | The search box |
| `stock_product_card_<id>` | Stock | One product; opens its branches |
| `stock_branches_page` | Stock branches | Marks the screen |
| `stock_branch_row_<id>` | Stock branches | One branch |

Testing a screen that has none? Ask the team above, and say which elements you
need to tap or read.

## Known limitations

| | |
|---|---|
| Only one build works | `--debug --flavor dev`. Any other one: the first 4 tests pass and the last 2 always fail |
| Stock needs a dev server | Those screens are not in the APK. Stopped server → last 2 fail |
| A failed login cannot be tested | The build always signs in, so the error dialog never appears |
| Branch tests expect several branches | With `rama9` as the main one. A single-branch build skips the picker and they fail |
| Only Stock is covered | The Sales tab and other miniapps have no names yet |

## Layout

```
SETUP.md     install, get a build, run
apps/        app-debug.apk — the build under test, copy yours in
tests/       one file per flow: login, branch select, Stock
resources/   the names above, and the shared steps
results/     the last run's report
```
