@RestResource(urlMapping='/v1/Account/*')
global with sharing class AccountManager {
    @httpGet
    global static AccountWrapper accountInformation(){
        
        RestRequest request = RestContext.request;
        //String requestURI = request.requestURI;
        String accountId = request.requestURI.substringAfterLast('/');
        List<Account> accountList = [SELECT Id, Name, Rating, Industry, Description, Phone, Fax 
        FROM Account 
        WHERE Id = :accountId];
        
        List<Contact> contactList = [SELECT Id, Name, FirstName, LastName, Email, Phone
        FROM Contact
        WHERE AccountId = :accountId];
        
        List<Case> caseList = [SELECT Id, CaseNumber, Subject, Description, Status, Owner.Name
        FROM Case
        WHERE AccountId = :accountId];
        
        AccountWrapper wrapper = new AccountWrapper();
        
        if(!accountList.isEmpty()){
            wrapper.accountRecord = accountList.get(0);
            wrapper.contactList = contactList;
            wrapper.caseList = caseList;
        }
        
        return wrapper;
        
    }
    
    @httpPost
    global static AccountInformation accountInsertion(AccountInformation information){
        
        Account accountRecord = information.accountRecord;
        insert accountRecord;
        
        Contact contactRecord = information.contactRecord;
        contactRecord.AccountId = accountRecord.Id;
        insert contactRecord;

        return information;
        
    }
    
    @httpDelete
    global static String deleteAccount(){
        RestRequest request = RestContext.request; 
        String accountId = request.requestURI.substringAfterLast('/');
        List<Account> accountRecordToDelete = [SELECT Id FROM Account WHERE Id = :accountId];
        
        if(accountRecordToDelete != Null && accountRecordToDelete.size() > 0){
            try{
                delete accountRecordToDelete;
                return '{"message": "Account Record Deleted"}';
            } catch(System.Exception ex){
                String message = ex.getMessage();
                return '{"message": "'+message+'"}';
            }
        }
        else{
            return '{"message" : "Account Record Not Found"}';
        }
        
    }

    @httpPatch
    global static ResponseWrapper updateAccount(String description, String rating){
        // get the account id from URI
        RestRequest request = RestContext.request;
        String accountId = request.requestURI.substringAfterLast('/');

        ResponseWrapper wrapper = new ResponseWrapper();

        List<Account> accountList = [SELECT Id, Description, Rating FROM Account WHERE Id = :accountId];
        if(accountList.size() > 0){
            accountList[0].Description = description;
            accountList[0].Rating = rating;

            update accountList;

            wrapper.accountRecord = accountList[0];
            wrapper.message = 'Account Record Updated.';
        } else {
            wrapper.message = 'Account Record Not Found.';
        }

        return wrapper;
    }

    @httpPut
    global static Account upsertRecord(String description, String rating){
        RestRequest request = RestContext.request;
        String accountId = request.requestURI.substringAfterLast('/');
        Account accRec;

        if(accountId == 'Account' || accountId == null || String.isBlank(accountId)){
            accRec = new Account(Name = 'Created from Put' ,Description = description, Rating = rating);
        } else {
            List<Account> accList = [SELECT Id, Name, Description, Rating FROM Account WHERE Id = :accountId];
            accList[0].Name = 'Updated from Put';
            accList[0].Description = description;
            accList[0].Rating = rating;
            accRec = accList[0];
        }

        upsert accRec;
        return accRec;
    }

    global Class AccountInformation{
        global Account accountRecord { get; set; }
        global Contact contactRecord { get; set; }

    }
    
    global Class AccountWrapper{
        global Account accountRecord;
        global List<Contact> contactList;
        global List<Case> caseList;
    } 

    global Class ResponseWrapper{
        global Account accountRecord;
        global String message;
    }
}
