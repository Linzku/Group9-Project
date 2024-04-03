*** Settings ***
Library    DatabaseLibrary

*** Variables ***
${dbname}    invoicedb
${dbuser}    robotuser
${dbpass}    password
${dbhost}    localhost
${dbport}    3306

*** Keywords ***
Make Connection
    [Arguments]    ${dbtoconnect}
    Connect To Database    pymysql    ${dbtoconnect}    ${dbuser}    ${dbpass}    ${dbhost}    ${dbport}

*** Tasks ***
Select data from Database
    Make Connection    ${dbname}
    @{statusList}=    Query    select * from invoicestatus;

    FOR    ${element}    IN    @{statusList}
        Log    ${element}[0]
        Log    ${element}[1]
        
    END