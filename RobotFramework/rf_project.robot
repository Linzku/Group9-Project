*** Settings ***
Library    String
Library    Collections
Library    OperatingSystem
Library    DatabaseLibrary
Library    DateTime
Library    validationcode.py

*** Variables ***
${PATH}    C:/Users/OMISTAJA/KOULU/RPA/
@{ListToDB}
${InvoiceNumber}    empty

# Tietokantaa liittyvät apumuuttujat
${dbname}    invoicedb
${dbuser}    robotuser
${dbpass}    password
${dbhost}    localhost
${dbport}    3306

*** Keywords ***
Make Connection
    [Arguments]    ${dbtoconnect}
    Connect To Database    pymysql    ${dbtoconnect}    ${dbuser}    ${dbpass}    ${dbhost}    ${dbport}

*** Keywords ***
Add row data to list
    [Arguments]    ${items}
    @{AddInvoiceRowData}=    Create List
    Append To List    ${AddInvoiceRowData}    ${InvoiceNumber}
    Append To List    ${AddInvoiceRowData}    ${items}[8]
    Append To List    ${AddInvoiceRowData}    ${items}[0]
    Append To List    ${AddInvoiceRowData}    ${items}[1]
    Append To List    ${AddInvoiceRowData}    ${items}[2]
    Append To List    ${AddInvoiceRowData}    ${items}[3]
    Append To List    ${AddInvoiceRowData}    ${items}[4]
    Append To List    ${AddInvoiceRowData}    ${items}[5]
    Append To List    ${AddInvoiceRowData}    ${items}[6]

    Append To List    ${ListToDB}    ${AddInvoiceRowData}

*** Keywords ***
Add invoice header to DB
    [Arguments]    ${items}    ${rows}
    Make Connection    ${dbname}
    # TODO: laskun päivä- ja summatiedot + status ja kommentit
    # Asetetaan dateformat
    ${invoiceDate}=    Convert Date    ${items}[3]    date_format=%d.%m.%Y    result_format=%Y-%m-%d
    ${dueDate}=    Convert Date    ${items}[4]    date_format=%d.%m.%Y    result_format=%Y-%m-%d

    # Invoice status muuttuja
    ${InvoiceStatus}=    Set Variable    0
    ${InvoiceComment}=    Set Variable    All ok


    # validoi referencenumber
    ${refStatus}=    Is Reference Number Correct    ${items}[2]

    IF    not ${refStatus}
        ${InvoiceStatus}=    Set Variable    1
        ${InvoiceComment}=    Set Variable    Reference number error
    END

    # validoi IBAN
    ${ibanStatus}=    Check IBAN    ${items}[6]

    IF    not ${ibanStatus}
        ${InvoiceStatus}=    Set Variable    2
        ${InvoiceComment}=    Set Variable    IBAN number error
    END

      # validoi amount
    ${sumStatus}=    Check Amounts from Invoice    ${items}[9]    ${rows}

    IF    not ${sumStatus}
        ${InvoiceStatus}=    Set Variable    3
        ${InvoiceComment}=    Set Variable    Amount difference
    END

     #Validate iban number
    ${ibanstatus}=    Validate Iban    ${items}[6]
    IF   ${ibanstatus}
        ${InvoiceStatus}=    Set Variable    2
        ${ImnvoiceComment}=    Set Variable    IBAN number error
    END

    ${insertStmt}=    Set Variable    insert into invoiceheader (invoicenumber, companyname, companycode, referencenumber, invoicedate, duedate, bankaccountnumber, amountexclvat, vat, totalamount, invoicestatus_id, comments) values ('${items}[0]', '${items}[1]', '${items}[5]', '${items}[2]', '${invoiceDate}', '${dueDate}', '${items}[6]', '${items}[7]', '${items}[8]', '${items}[9]', '${InvoiceStatus}', '${InvoiceComment}');
    Execute Sql String    ${insertStmt}

*** Keywords ***
Add invoice row to DB
    [Arguments]    ${items}
    Make Connection    ${dbname}

    ${insertStmt}=    Set Variable    insert into invoicerow (invoicenumber, rownumber, description, quantity, unit, unitprice, vatpercent, vat, total) values ('${items}[0]', '${items}[1]', '${items}[2]', '${items}[3]', '${items}[4]', '${items}[5]', '${items}[6]', '${items}[7]', '${items}[8]');
    Execute Sql String    ${insertStmt}


*** Keywords ***
Check IBAN
    [Arguments]    ${iban}
    ${iban}=    Remove String    ${iban}    ${SPACE}
    ${status}=    Set Variable    ${False}
    ${length}=    Get Length    ${iban}

    IF    ${length} == 18
        ${status}=    Set Variable    ${True}
    END    
    [Return]    ${status}

*** Keywords ***
Check Amounts from Invoice
    [Arguments]    ${totalSumFromHeader}    ${invoiceRows}
    ${status}=    Set Variable    ${False}
    ${totalAmountFromRows}=    Evaluate    0

    FOR    ${element}    IN    @{invoiceRows}
        #Log    ${element}
        ${totalAmountFromRows}=    Evaluate    ${totalAmountFromRows}+${element}[8]
    END
    
    ${diff}=    Convert To Number    0.01
    ${totalSumFromHeader}=    Convert To Number    ${totalSumFromHeader}
    ${totalAmountFromRows}=    Convert To Number    ${totalAmountFromRows}

    ${status}=    Is Equal    ${totalSumFromHeader}    ${totalAmountFromRows}    ${diff}

    [Return]    ${status}

*** Test Cases ***
Read CSV file to list
    #Make Connection    ${dbname}
    ${outputHeader}=    Get File    ${PATH}InvoiceHeaderData.csv
    ${outputRows}=    Get File    ${PATH}InvoiceRowData.csv
    Log    ${outputHeader}
    Log    ${outputRows}
    
    # otetaan jokainen rivi käsittelyyn yksittäisenä elementtinä
    @{headers}=    Split String    ${outputHeader}    \n
    @{rows}=    Split String    ${outputRows}    \n

    
    # poistetaan ensimmäinen (otsikko) rivi ja viimeinen (tyhjä) rivi
    ${length}=    Get Length    ${headers}
    ${length}=    Evaluate    ${length}-1
    ${index}=    Convert To Integer    0

    Remove From List    ${headers}    ${length}
    Remove From List    ${headers}    ${index}

    ${length}=    Get Length    ${rows}
    ${length}=    Evaluate    ${length}-1

    Remove From List    ${rows}    ${length}
    Remove From List    ${rows}    ${index}

    Set Global Variable    ${headers}
    Set Global Variable    ${rows}

*** Test Cases ***
Loop all invoice rows
    # käydään läpi kaikki laskurivit
    FOR    ${element}    IN    @{rows}
        Log    ${element}

        # jaetaan rivin data omiksi elementeiksi
        @{items}=    Split String    ${element}    ;

        # haetaan käsiteltävän rivin laskunumero
        ${rowInvoiceNumber}=    Set Variable    ${items}[7]

        Log    ${rowInvoiceNumber}
        Log    ${InvoiceNumber}

        # tutkitaan vaihtuuko käsiteltävä laskunumero
        IF    '${rowInvoiceNumber}' == '${InvoiceNumber}'
            Log    Lisäätään laskulle rivejä

            # Lisää käsiteltävän laskun tiedot listaan
            Add row data to list    ${items}

        ELSE
            Log    Pitää tutkia onko tietokanta listassa jo rivejä
            ${length}=    Get Length    ${ListToDB}

            IF    ${length} == ${0}
                Log    ensimmäisen laskun tapaus
                # päivitä laskunumero
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}

                # Lisää käsiteltävän laskun tiedot listaan
                Add row data to list    ${items}
            ELSE
                Log    Lasku vaihtuu, pitää käsitellä myös otsikko data

                # Etsi laskun otsikkorivi
                FOR    ${headerElement}    IN    @{headers}
                    @{headerItems}=    Split String    ${headerElement}    ;
                    IF    '${headerItems}[0]' == '${InvoiceNumber}'
                        Log    lasku löytyi
                        # Validointi

                        # Syötä laskun otsikkorivi tietokantaan
                        Add invoice header to DB    ${headerItems}    ${ListToDB}

                        # Syötä laskun rivit tietokantaan
                        FOR    ${rowElement}    IN    @{ListToDB}
                            Add invoice row to DB    ${rowElement}
                            
                        END  
                    END
                    
                END

                

                # Syötä laskun otsikkorivi tietokantaan

                # Syötä laskun rivit tietokantaan

                # Valmista prosessi seuraavaan laskuun
                @{ListToDB}    Create List
                Set Global Variable    ${ListToDB}
                ${InvoiceNumber}=    Set Variable    ${rowInvoiceNumber}
                Set Global Variable    ${InvoiceNumber}
                # Lisää käsiteltävän laskun tiedot listaan
                Add row data to list    ${items}
            END
        END
    END

    # viimeisen laskun tapaus
    ${length}=    Get Length    ${ListToDB}
    IF    ${length} > ${0}
        Log    viimeisen laskun otsikkokäsittely

          # Etsi laskun otsikkorivi
                FOR    ${headerElement}    IN    @{headers}
                    @{headerItems}=    Split String    ${headerElement}    ;
                    IF    '${headerItems}[0]' == '${InvoiceNumber}'
                        Log    lasku löytyi
                        # Validointi

                        # Syötä laskun otsikkorivi tietokantaan
                        Add invoice header to DB    ${headerItems}    ${ListToDB}

                        # Syötä laskun rivit tietokantaan
                        FOR    ${rowElement}    IN    @{ListToDB}
                            Add invoice row to DB    ${rowElement}
                            
                        END  
                    END
                    
                END
    END