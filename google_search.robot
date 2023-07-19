*** Settings ***
Library  SeleniumLibrary

*** Variables ***
${BROWSER}       chrome
${SEARCH_URL}    https://www.google.com
${QUERY}         test

*** Test Cases ***
User Can Perform Google Search
    Open Search Page
    Input Query    ${QUERY}
    Submit Query
    [Teardown]    Close Browser

*** Keywords ***
Open Search Page
    Open Browser    ${SEARCH_URL}    ${BROWSER}
    Maximize Browser Window

Input Query
    [Arguments]    ${query}
    Input Text    name=q    ${query}

Submit Query
    Press Key    name=q    \\13
    Sleep    2s
