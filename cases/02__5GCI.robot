*** Settings ***
Library    OperatingSystem
Library    String
Library    DateTime
#Library    AndroidLibrary
Library    SSHLibrary
Variables    Variables.py
#Library    network.py
Suite Setup    SuiteSetup
Test Setup    TestSetup
Test Template     IperfTest
Default Tags    sanity    IperfTest

*** Variables ***
#${Appserver}    10.1.1.254
#${Appserver}     127.0.0.1
#${Publickserver}    ping.online.net
#${Innerserver}    127.0.0.1
#${ iPerfPort}    5210
#${Logpath}    Log/
#${Logname}

*** Test Cases ***               ${duration}    ${Port}    ${direction}    ${type}    ${bandwidth}
CPE_iperf_dl_udp_10s                  10         5210         'DL'            'UDP'         100M
CPE_iperf_ul_udp_10s                  10         5210         'UL'            'UDP'         100M
CPE_iperf_dl_tcp_10s                  10         5210         'DL'            'TCP'         100M
CPE_iperf_ul_tcp_10s                  10         5210         'UL'            'TCP'         100M
CPE_iperf_dl_udp_1000s                1000       5210         'DL'            'UDP'         100M
CPE_iperf_ul_udp_1000s                1000       5210         'UL'            'UDP'         100M
CPE_iperf_dl_tcp_1000s                1000       5210         'DL'            'TCP'         100M
CPE_iperf_ul_tcp_1000s                1000       5210         'UL'            'TCP'         100M

#CPE_iperf_dl_udp_10s
#    [Documentation]     send downlink udp traffic for 10s
#    [Tags]    sanity
#    iPerfServerSetup    ${Appserver}    ${Appserver_username}    ${Appserver_password}
#    IperfTest    ${TEST NAME}    ${Appserver}    10    ${ iPerfPort}     'DL'    'UDP'
#    Sleep    5
#    [Timeout]    100
#
#
#CPE_iperf_ul_udp_10s
#    [Documentation]     send uplink udp traffic for 10s
#    [Tags]    sanity
#    iPerfServerSetup    ${Appserver}    ${Appserver_username}    ${Appserver_password}
#    IperfTest    ${TEST NAME}    ${Appserver}    10    ${ iPerfPort}     'UL'    'UDP'
#    Sleep    5
#    [Timeout]    100
#
#CPE_iperf_dl_tcp_10s
#    [Documentation]     send downlink udp traffic for 10s
#    [Tags]    sanity
#    iPerfServerSetup    ${Appserver}    ${Appserver_username}    ${Appserver_password}
#    IperfTest    ${TEST NAME}    ${Appserver}    10    ${ iPerfPort}     'DL'    'TCP'
#    Sleep    5
#    [Timeout]    100
#
#
#CPE_iperf_ul_tcp_10s
#    [Documentation]     send uplink udp traffic for 10s
#    [Tags]    sanity
#    iPerfServerSetup    ${Appserver}    ${Appserver_username}    ${Appserver_password}
#    IperfTest    ${TEST NAME}    ${Appserver}    10    ${ iPerfPort}     'UL'    'TCP'
#    Sleep    5
#    [Timeout]    100
#
#CPE_iperf_dl_udp_1000s
#    [Documentation]     send downlink udp traffic for 1000s
#    [Tags]    sanity    long
#    iPerfServerSetup    ${Appserver}    ${Appserver_username}    ${Appserver_password}
#    IperfTest    ${TEST NAME}    ${Appserver}    1000    ${ iPerfPort}     'DL'    'UDP'
#    Sleep    5
#    [Timeout]    1200
#
#
#CPE_iperf_ul_udp_1000s
#    [Documentation]     send uplink udp traffic for 1000s
#    [Tags]    sanity    long
#    iPerfServerSetup    ${Appserver}    ${Appserver_username}    ${Appserver_password}
#    IperfTest    ${TEST NAME}    ${Appserver}    1000    ${ iPerfPort}     'UL'    'UDP'
#    Sleep    5
#    [Timeout]    1200
#
#CPE_iperf_dl_tcp_1000s
#    [Documentation]     send downlink udp traffic for 1000s
#    [Tags]    sanity    long
#    iPerfServerSetup    ${Appserver}    ${Appserver_username}    ${Appserver_password}
#    IperfTest    ${TEST NAME}    ${Appserver}    1000    ${ iPerfPort}     'DL'    'TCP'
#    Sleep    5
#    [Timeout]    1200
#
#
#CPE_iperf_ul_tcp_1000s
#    [Documentation]     send uplink udp traffic for 1000s
#    [Tags]    sanity    long
#    iPerfServerSetup    ${Appserver}    ${Appserver_username}    ${Appserver_password}
#    IperfTest    ${TEST NAME}    ${Appserver}    1000    ${ iPerfPort}     'UL'    'TCP'
#    Sleep    5
#    [Timeout]    1200



*** Keywords ***
IperfTest
    [Documentation]    Perform Iperf Test according to give args
    [Arguments]    ${duration}    ${Port}    ${direction}    ${type}    ${bandwidth}=100M
    iPerfServerSetup    ${APPserver}    ${Appserver_username}    ${Appserver_password}    ${Port}
    StartIperf    ${APPserver}    ${duration}    ${Port}    ${direction}    ${type}    ${bandwidth}

iPerfServerSetup
    [Arguments]    ${ServerAddr}    ${username}    ${password}    ${Port}=5210    ${arg}=${None}
    Open Connection    ${ServerAddr}
    Login    ${username}    ${password}
#    Read Until    [lte@localhost ~]$
    Start Command    kill -s 9 `ps -ef | grep [i]Perf | awk '{print $2}'`
    Start Command    iperf3 -s -1 -i 1 -p ${Port}

StartIperf
    [Documentation]    say something
    [Arguments]    ${server}    ${duration}    ${Port}    ${direction}    ${type}    ${bandwidth}=100M
    Log    ${Logpath}
    ${mode}    Set Variable If    ${type}=='UDP'    -u -b ${bandwidth}
    ${reverse}    Set Variable If    ${direction}=='DL'    -R
    Run And Return Rc And Output    start iperf3 -c ${server} --get-server-output -i 1 -t ${duration} -p ${Port} ${mode} ${reverse} --logfile ${Logpath}\\${TEST NAME}.iPerf.log
    ${Logname}    Set Variable    ${CURDIR}\\${Logpath}\\${TEST NAME}.iPerf.log
    ${output}    Run    type ${Logname}
    ${output}    Run    findstr "error" ${Logname}
    Should Not Contain Any    ${output}    error
    [Timeout]    ${${duration}+${100}}

SSHAppSever
    [Arguments]
    Open Connection    ${Appserver}
    Login    admin    ${RGWHTTPpwd}
    Write    en
    ${output}    Read Until   user#
    Write    shell
    ${output}    Read Until   Password:
    Write    ${RGWSSHpwd}
    ${output}    Read Until   [root@AONT: admin]#
    [Timeout]    100

SuiteSetup
    ${Time}    Get Current Date
    ${Time}    Convert Date    ${Time}      result_format=%Y_%m_%d_%H%M%S
    Set Suite Variable    ${Logpath}    ${Logpath}\\${Time}_${SUITE NAME}
    Create Directory    ${Logpath}

TestSetup
    ${Logname}    Set Variable    ${Logpath}\\${TEST NAME}.iPerf.log


