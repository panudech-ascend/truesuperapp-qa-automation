*** Settings ***
Documentation    The Stock miniapp, reached from the home shortcut.
...
...              This suite drives web content, not Flutter. Tapping the Stock
...              shortcut loads <miniappBaseUrl>/stock — a Next.js app living in
...              the superapp-mini-app-fe repo — inside a WebView, and the
...              locators here are its `data-testid` attributes.
...
...              Two things must hold or every test fails at setup:
...
...              - the app under test is a **debug** build. MainActivity enables
...                WebView debugging for debuggable builds alone, so a release
...                build has no WEBVIEW context to switch into.
...              - the miniapp is being served. The app points at
...                http://10.0.2.2:3000 (the host's localhost from the
...                emulator), so `npm run dev` has to be running in
...                superapp-mini-app-fe.
Resource         ../resources/app.resource
Test Setup       Open The Stock Miniapp From A Fresh Start
Test Teardown    Close True Shop App
Force Tags       stock    miniapp


*** Test Cases ***
The Stock Miniapp Loads Its Product List
    [Documentation]    TC-W01 — the shortcut opens the web page, the search
    ...    field is usable, and the list arrived with at least one product.
    [Tags]    smoke
    Page Should Contain Element         ${STOCK_WEB_SEARCH}
    Wait Until Page Contains Element    ${STOCK_WEB_ANY_CARD}    ${LOAD_WAIT}

Opening A Product Shows The Branches That Stock It
    [Documentation]    TC-W02 — tapping a product card routes to the branch
    ...    list for that product, and the list is populated.
    Wait Until Page Contains Element    ${STOCK_WEB_ANY_CARD}    ${LOAD_WAIT}
    Click Element                       ${STOCK_WEB_ANY_CARD}

    Wait Until Page Contains Element    ${STOCK_BRANCHES_PAGE}       ${LOAD_WAIT}
    Wait Until Page Contains Element    ${STOCK_BRANCHES_ANY_ROW}    ${LOAD_WAIT}


*** Keywords ***
Open The Stock Miniapp From A Fresh Start
    [Documentation]    Signs in, lands on the home shell, opens the Stock
    ...    shortcut and switches into its WebView.
    Open True Shop App
    Reach The Home Shell
    Open The Stock Miniapp
