*** Settings ***
Documentation    Connection details and shared keywords for the true Shop app.
...
...              Locators match on `resource-id`, which is where Flutter puts a
...              `Semantics(identifier:)` on Android — NOT on `content-desc`,
...              so Appium's `accessibility_id=` strategy does not find them.
...              Plain `id=` does not match either: UiAutomator2 expects a
...              package-prefixed id there, and Flutter writes the bare name.
...              XPath on `@resource-id` is what works.
...
...              These names are a contract with the app. Renaming one in the
...              Flutter code breaks the suites here.
Library          AppiumLibrary


*** Variables ***
# --- Appium connection -------------------------------------------------------
${APPIUM_URL}               http://127.0.0.1:4723
${PLATFORM_NAME}            Android
${AUTOMATION_NAME}          UiAutomator2
# Leave empty to let Appium pick the only attached device.
${DEVICE_NAME}              emulator-5554
${APP_PACKAGE}              com.amaze.apptrue.dev
${APP_ACTIVITY}             com.amaze.apptrue.MainActivity

# Drop a new APK here and the next run installs it. Must be a debug build, or
# the miniapp suites have no WEBVIEW context.
${APP_PATH}                 ${EXECDIR}${/}apps${/}app-debug.apk

# --- Timeouts ----------------------------------------------------------------
# SHORT_WAIT is for what should already be on screen; LOAD_WAIT covers a request
# going out and coming back. Generous because a test that fails only when the
# machine is busy is worse than one that takes a few seconds longer.
${SHORT_WAIT}               10s
${LOAD_WAIT}                30s

# --- Locators: Login ---------------------------------------------------------
${LOGIN_PAGE}               xpath=//*[@resource-id='login_page']
${LOGIN_SUBMIT_BUTTON}      xpath=//*[@resource-id='login_submit_button']

# --- Locators: Branch select -------------------------------------------------
${BRANCH_SELECT_PAGE}       xpath=//*[@resource-id='branch_select_page']
${BRANCH_SELECT_LOADING}    xpath=//*[@resource-id='branch_select_loading']
${BRANCH_CONFIRM_BUTTON}    xpath=//*[@resource-id='branch_confirm_button']
# Per-branch tiles are branch_tile_<id>; ids come from the backend.
${BRANCH_TILE_PRIMARY}      xpath=//*[@resource-id='branch_tile_rama9']

# --- Locators: Home ----------------------------------------------------------
${NAV_TAB_HOME}             xpath=//*[@resource-id='nav_tab_home']
# Shortcut tiles are miniapp_<route>; the route comes from the /home response.
${MINIAPP_STOCK_TILE}       xpath=//*[@resource-id='miniapp_stock']

# --- Locators: Stock miniapp (web, inside the WebView) -----------------------
# These live in the superapp-mini-app-fe repo, not in the Flutter app, and are
# CSS rather than XPath because the WebView context is queried as a browser.
# Renaming a data-testid there breaks this suite.
${STOCK_WEB_PAGE}           css=[data-testid="stock_page"]
${STOCK_WEB_SEARCH}         css=[data-testid="stock_search_field"]
# One card per product; the suffix is the productId the API returned.
${STOCK_WEB_ANY_CARD}       css=[data-testid^="stock_product_card_"]
${STOCK_BRANCHES_PAGE}      css=[data-testid="stock_branches_page"]
${STOCK_BRANCHES_ANY_ROW}   css=[data-testid^="stock_branch_row_"]


*** Keywords ***
Open True Shop App
    [Documentation]    Starts a clean session. noReset=false so each test begins
    ...    signed out — the app clears any stored session on start anyway.
    Open Application    ${APPIUM_URL}
    ...    platformName=${PLATFORM_NAME}
    ...    automationName=${AUTOMATION_NAME}
    ...    deviceName=${DEVICE_NAME}
    ...    app=${APP_PATH}
    ...    appPackage=${APP_PACKAGE}
    ...    appActivity=${APP_ACTIVITY}
    ...    autoGrantPermissions=${TRUE}
    ...    newCommandTimeout=120
    # Fetches the chromedriver matching the device's WebView, needed by the
    # miniapp suites.
    ...    chromedriverAutodownload=${TRUE}

Close True Shop App
    Close Application

Sign In With One Login
    [Documentation]    Taps the One Login button and waits for the request to
    ...    finish. Does not assert where it lands — callers decide that.
    Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON}    ${SHORT_WAIT}
    Click Element                       ${LOGIN_SUBMIT_BUTTON}

Reach The Home Shell
    [Documentation]    Signs in and confirms the preselected branch, which is
    ...    what the app needs before any tab or miniapp is reachable.
    Wait Until Page Contains Element    ${LOGIN_PAGE}             ${SHORT_WAIT}
    Sign In With One Login
    Wait Until Page Contains Element    ${BRANCH_SELECT_PAGE}     ${LOAD_WAIT}
    Wait Until Page Contains Element    ${BRANCH_CONFIRM_BUTTON}  ${SHORT_WAIT}
    Click Element                       ${BRANCH_CONFIRM_BUTTON}
    Wait Until Page Contains Element    ${NAV_TAB_HOME}           ${LOAD_WAIT}

Open The Stock Miniapp
    [Documentation]    Taps the Stock shortcut, which loads
    ...    <miniappBaseUrl>/stock in a WebView, then switches into that WebView
    ...    so the web locators resolve. Leaves the context switched.
    Wait Until Page Contains Element    ${MINIAPP_STOCK_TILE}    ${LOAD_WAIT}
    Click Element                       ${MINIAPP_STOCK_TILE}
    Switch Into The Miniapp WebView

Switch Into The Miniapp WebView
    [Documentation]    Waits for the WebView to register a context, then switches
    ...    into it once. The wait covers the WebView still attaching; the switch
    ...    itself is not retried, so a missing chromedriver or a release build
    ...    fails straight away instead of after the full timeout.
    ${webview_context}=    Wait Until Keyword Succeeds    ${LOAD_WAIT}    1s
    ...    Get The Miniapp Webview Context
    Switch To Context                   ${webview_context}
    Wait Until Page Contains Element    ${STOCK_WEB_PAGE}    ${LOAD_WAIT}

Get The Miniapp Webview Context
    [Documentation]    Returns the first WEBVIEW context Appium reports. Named
    ...    after the package, so it is looked up rather than hard-coded.
    ${all_contexts}=    Get Contexts
    ${webview_contexts}=    Evaluate    [c for c in $all_contexts if 'WEBVIEW' in c]
    Should Not Be Empty    ${webview_contexts}    No WEBVIEW context yet: ${all_contexts}
    RETURN    ${webview_contexts}[0]

Leave The Miniapp WebView
    [Documentation]    Returns to the Flutter side so native locators work.
    Switch To Context    NATIVE_APP
