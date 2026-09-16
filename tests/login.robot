*** Settings ***
Documentation    Signing in with One Login.
...
...              Runs against a build that answers from bundled mock payloads
...              (`--dart-define=USE_MOCK_API=true`), which return a success and
...              several branches. That build cannot be made to fail a login, so
...              the error dialog is not covered here — see README
...              "Known limitations".
Resource         ../resources/app.resource
Test Setup       Open True Shop App
Test Teardown    Close True Shop App
Force Tags       login


*** Test Cases ***
Signing In Takes The User To Branch Select
    [Documentation]    TC-01 — tapping One Login loads the session and moves on
    ...    to the branch picker.
    [Tags]    smoke
    Wait Until Page Contains Element    ${LOGIN_PAGE}    ${SHORT_WAIT}

    Sign In With One Login

    Wait Until Page Contains Element    ${BRANCH_SELECT_PAGE}    ${LOAD_WAIT}
    Page Should Contain Element         ${BRANCH_CONFIRM_BUTTON}

The Branch List Arrives From The Backend
    [Documentation]    TC-02 — the branches shown come from the login response,
    ...    so at least the primary branch tile is present.
    Sign In With One Login

    Wait Until Page Contains Element    ${BRANCH_SELECT_PAGE}       ${LOAD_WAIT}
    Wait Until Page Contains Element    ${BRANCH_TILE_PRIMARY}      ${SHORT_WAIT}
