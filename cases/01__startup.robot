*** Settings ***
Library    OperatingSystem
Library    String
#Library    AndroidLibrary
Library    SSHLibrary
Library    SeleniumLibrary
Variables    Variables.py

*** Variables ***
#${qcVersion}    D010001B28T0101E0009
#${RGWIPaddr}    192.168.1.254
#${RGWVer}    3TG00118ABAB09
#${RGWHTTPpwd}    Nq+L5st7o
#${RGWSSHpwd}    m7p9LxpVFusQ

*** Test Cases ***
CheckRoute
    [Tags]    sanity
    ${output}    Run    ipconfig|findstr IP|findstr 192.168.1
    ${output}    Run    route ADD 10.1.1.254 MASK 255.255.255.255 192.168.1.254
    Sleep    10

ping_app_server
    [Documentation]     ping app server
    ${output}    Run    ping ${Appserver}
    [Timeout]    100


CPE_check_QC
    [Tags]    sanity
    check_QCstartup
    check_QCversion
    check_QCIP

CPE_check_RGW
    [Tags]    sanity
    Log    ${RGWIPaddr}
    check_RGWversion


*** Keywords ***
adb_shell
    [Arguments]    ${cmd}
    ${output}    Run    adb shell ${cmd}
    [Return]    ${output}

Wait_For_Device
    [Arguments]    ${cmd}
    Run Keyword If    Run    adb devices
    [Return]    ${output}

check_QCstartup
    [Arguments]
    ${Wait For Device}    Run    adb devices
    Should Contain X Times    ${Wait For Device}    device    2

check_QCversion
    [Arguments]
    ${Version}    adb_shell    cat /vendor/etc/qcVersion.txt
    Should Contain    ${Version}    ${qcVersion}

check_QCIP
    [Arguments]
#    ${adaptor}    adb_shell    "ifconfig|grep rmnet_data|cut -d \" \" -f 1"
#    ${ipadd}    adb_shell    "ifconfig rmnet_data|grep inet addr|cut -d \":\" -f 2|cut -d \" \" -f 1"
    ${adaptor}    adb_shell    "ifconfig|grep rmnet_data"
    Should Contain    ${adaptor}    rmnet_data
    ${adaptor}    Get Substring      ${adaptor}    0    11
    ${ipadd}    adb_shell    "ifconfig ${adaptor}"
    Should Contain    ${ipadd}    inet addr
    ${output}    adb shell    "adb shell ping -c 5 10.1.1.254"
    Should Not Contain Any    ${output}    error

check_RGWversion
    [Arguments]
#HTTP slow than SSH
#    checkRGWversionHTTP
    checkRGWversionSSH

checkRGWversionHTTP
    [Arguments]
    OpenWEBGUI
    Page Should Contain    ${RGWVer}
    Close Browser
    [Teardown]    Close Browser

OpenWEBGUI
    Open Browser    https://${RGWIPaddr}    chrome
    Sleep    3
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

checkRGWversionSSH
    [Arguments]
    SSHrootRGW
    Write    cat /usr/etc/buildinfo
    ${stdout}    Read
    Should Contain    ${stdout}    ${RGWVer}
    [Teardown]    Close All Connections

SSHrootRGW
    [Arguments]
    Open Connection    ${RGWIPaddr}
    Login    admin    ${RGWHTTPpwd}
    Write    en
    ${output}    Read Until   user#
    Write    shell
    ${output}    Read Until   Password:
    Write    ${RGWSSHpwd}
    ${output}    Read Until   [root@AONT: admin]#
    [Timeout]    100