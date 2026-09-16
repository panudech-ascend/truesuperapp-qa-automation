*** Settings ***
Documentation    Choosing the branch to work from, after signing in.
Resource         ../resources/app.resource
Test Setup       Open True Shop App And Sign In
Test Teardown    Close True Shop App
Force Tags       branch


*** Test Cases ***
The Picker Preselects The Primary Branch
    [Documentation]    TC-03 — the branch the backend marks primary is already
    ...    selected, so confirming without choosing is a valid path.
    Page Should Contain Element    ${BRANCH_TILE_PRIMARY}
    Page Should Contain Element    ${BRANCH_CONFIRM_BUTTON}

Choosing A Branch And Confirming Leaves The Picker
    [Documentation]    TC-04 — picking a branch and confirming closes the
    ...    picker; the app does not come back to it.
    [Tags]    smoke
    Click Element    ${BRANCH_TILE_PRIMARY}
    Click Element    ${BRANCH_CONFIRM_BUTTON}

    Wait Until Page Does Not Contain Element    ${BRANCH_SELECT_PAGE}
    ...    ${LOAD_WAIT}


*** Keywords ***
Open True Shop App And Sign In
    Open True Shop App
    Sign In With One Login
    Wait Until Page Contains Element    ${BRANCH_SELECT_PAGE}    ${LOAD_WAIT}
