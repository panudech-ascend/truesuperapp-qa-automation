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
${APP_PACKAGE}              com.amaze.apptrue
${APP_ACTIVITY}             com.amaze.apptrue.MainActivity

# Install from source on the first run; afterwards the installed app is reused.
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


*** Keywords ***
Open True Shop App
    [Documentation]    Starts a clean session. noReset=false so each test begins
    ...    signed out — the app clears any stored session on start anyway.
    Open Application    ${APPIUM_URL}
    ...    platformName=${PLATFORM_NAME}
    ...    automationName=${AUTOMATION_NAME}
    ...    deviceName=${DEVICE_NAME}
    ...    appPackage=${APP_PACKAGE}
    ...    appActivity=${APP_ACTIVITY}
    ...    autoGrantPermissions=${TRUE}
    ...    newCommandTimeout=120

Close True Shop App
    Close Application

Sign In With One Login
    [Documentation]    Taps the One Login button and waits for the request to
    ...    finish. Does not assert where it lands — callers decide that.
    Wait Until Page Contains Element    ${LOGIN_SUBMIT_BUTTON}    ${SHORT_WAIT}
    Click Element                       ${LOGIN_SUBMIT_BUTTON}
