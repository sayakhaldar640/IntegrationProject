/*
Class demonstrates the SOAP service from Salesforce

1. Body of the Request

XML Request Structure:
<?xml version="1.1" encoding="UTF-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sayak="http://soap.sforce.com/schemas/class/WelcomeSOAP">
    <soapenv:Header>
        <sayak:SessionHeader>       
           <sayak:sessionId>00D5j00000B8uvH!ARMAQC5aCWYBekGTepGrk0nV3LosHQ00nmtYdng3CcdSwlwZTzTJCj05Q940uDuBGH0tAUf00jukIgxoJskqb5Ibo.iJ6lqg</sayak:sessionId>
        </sayak:SessionHeader>
    </soapenv:Header>
    <soapenv:Body>
        <sayak:fullName>
            <sayak:firstName>Sayak</sayak:firstName>
            <sayak:lastName>Haldar</sayak:lastName>
        </sayak:fullName>
    </soapenv:Body>
</soapenv:Envelope>

2. URL for request
URL: /services/Soap/class/WelcomeSOAP



3. Create the header

Header:
Content-Type: text/xml; charset=UTF-8
Accept: text/xml
SOAPAction: ''

4. Generate Session ID

Session ID Generation:
    a.Create a VF Page
    b.Paste this code:

    <apex:page >
        {!$Api.Session_Id}
    </apex:page>
    
    c.Preview the VF Page.

5. Hit the API from Workbench or Postman

*/


global class WelcomeSOAP {
    webservice static String fullName(String firstName, String lastName){
        String greetMessage = 'Welcome '+firstName+' '+lastName;
        return greetMessage;
    }

    webservice static AccountWrapper createAccount(AccountWrapper wrapper){
        Account acc = new Account();
        acc.Name = wrapper.Name;
        acc.Rating = wrapper.Rating;
        acc.Industry = wrapper.Industry;
        acc.Phone = wrapper.Phone;
        acc.AccountNumber = wrapper.AccountNumber;
        insert acc;

        Contact con = wrapper.conRecord;
        con.AccountId = acc.Id;
        insert con;
        return wrapper;
    }

    global class AccountWrapper{
        webservice String Name;
        webservice String Rating;
        webservice String Industry;
        webservice String Phone;
        webservice String AccountNumber;
        webservice Contact conRecord;
    }
}