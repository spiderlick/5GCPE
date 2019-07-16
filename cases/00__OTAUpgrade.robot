*** Settings ***
Library           ../libs/WponSsh.py
Library           ../libs/Ncclient.py
Library           ../libs/PacketGen.py
Resource          comm.robot
Suite Setup       Pre Test
Suite Teardown    Run Keyword If Any Tests Failed    Post Test
Test Setup        None
Test Teardown     Run Keyword If Test Failed    Post Test
Variables    Variables.py

*** Variables ***
${RGWIPaddr}    192.168.1.254

*** Test Cases ***
UpgradeRGW    ${RGWVer}

*** Keywords ***

check_RGWversion
    [Arguments]
    checkRGWversionHTTP
    checkRGWversionSSH

checkRGWversionHTTP
    [Arguments]
    OpenWEBGUI
    Page Should Contain    ${RGWVer}
    Close Browser
    [Teardown]    Close Browser

OpenWEBGUI
    Open Browser    https://${RGWIPaddr}    chrome
    Sleep    5
#    ${elem}    Get WebElement    TANGRAM__PSP_4__footerULoginBtn
#    Click Link    ${elem}
    Click Button    Login
    Input TEXT    username    admin
    Input Password    password    ${RGWHTTPpwd}
    Click Button    Login
    Sleep     3
    Page Should Contain    Device Information
    Sleep     3
    [Timeout]    100

UpgradeRGW
    Click Element    "Maintenance"
    Click Element    "Firmware Upgrade"
    Loadfile    ${RGWVer}
    Click Button    buttonX
    Click Button    Upgrade
    Wait Until Element Contains    output    Upgrade ok, rebooting
    Sleep    60

checkRGWversionSSH
    [Arguments]
    SSHrootRGW
    Write    cat /usr/etc/buildinfo
    ${stdout}    Read
    Should Contain    ${stdout}    ${Version}
    Close All Connections

SSHrootRGW
    [Arguments]
    Open Connection    ${RGWIPaddr}
    Login    admin    ${RGWHTTPpwd}
    RootRGW

RootRGW
    [Arguments]
    Write    en
    Write    shell
    Write    ${RGWSSHpwd}




"""Checking upgrade partition...
Everything is OK.
kernel size:28442644
Upgrade ok, rebooting..."""
