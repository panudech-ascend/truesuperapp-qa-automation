*** Settings ***
Documentation    Connection details and shared keywords for the true Shop app.
...              Every locator here is an accessibility id the app exposes
...              through Semantics(identifier:). Renaming one in the app breaks
...              the suites below, so treat these names as a contract.
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
# The app talks to a live backend over ngrok, so waits are generous on purpose.
${SHORT_WAIT}               10s
${LOAD_WAIT}                30s

# --- Locators: Login ---------------------------------------------------------
${LOGIN_PAGE}               accessibility_id=login_page
${LOGIN_SUBMIT_BUTTON}      accessibility_id=login_submit_button

# --- Locators: Branch select -------------------------------------------------
${BRANCH_SELECT_PAGE}       accessibility_id=branch_select_page
${BRANCH_SELECT_LOADING}    accessibility_id=branch_select_loading
${BRANCH_CONFIRM_BUTTON}    accessibility_id=branch_confirm_button
# Per-branch tiles are branch_tile_<id>; ids come from the backend.
${BRANCH_TILE_PRIMARY}      accessibility_id=branch_tile_rama9


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
