@isTest
private class AccountManager_Test {
    @TestSetup
    static void createData(){
        Account acc = new Account(Name='Integration Test', Industry='Health', Description='Test Method for Apex Rest');
        insert acc;
        Contact con = new Contact(AccountId=acc.Id, LastName='Test', FirstName='Test', Phone='0990909909');
        insert con;   
        Case cs = new Case(AccountId=acc.Id, Status='New',Origin='Web');
        insert cs; 
    }

    @isTest
    private static void test_accountInformation(){
        RestRequest request = new RestRequest();
        List<Account> accRecord = [SELECT Id FROM Account LIMIT 1];
        request.requestURI = '/services/apexrest/v1/Account/'+accRecord[0].Id;
        request.httpMethod = 'GET';

        RestContext.request = request;

        Test.startTest();
        AccountManager.AccountWrapper wrapper = AccountManager.accountInformation();
        System.assertNotEquals(null, wrapper,'Check wrapper is null');
        Test.stopTest();
    }

    @isTest
    private static void test_accountInsertion(){

        RestRequest request = new RestRequest();
        request.requestURI = 'services/apexrest/v1/Account';
        request.httpMethod = 'POST';

        RestContext.request = request;

        Account acc = new Account(Name='Test');
        Contact con = new Contact(LastName='Haldar', FirstName='Sayak', Email='sayakhaldar640@gmail.com');

        AccountManager.AccountInformation information = new AccountManager.AccountInformation();
        
        information.accountRecord = acc;
        information.contactRecord = con;

        Test.startTest();
        AccountManager.accountInsertion(information);
        Test.stopTest();
    }

    @isTest
    private static void test_deleteAccount(){
        RestRequest request = new RestRequest();
        
        Account acc = new Account(Name='Integration Test1', Industry='Health', Description='Test Method for Apex Rest');
        insert acc;

        request.requestURI = 'services/apexrest/v1/Account/'+acc.Id;
        request.httpMethod = 'DELETE';
        RestContext.request = request;

        Test.startTest();
        String message = AccountManager.deleteAccount();
        System.assertEquals('{"message": "Account Record Deleted"}', message);
        Test.stopTest();

    }

    @isTest
    private static void test_deleteAccount_withException(){
        RestRequest request = new RestRequest();
        
        List<Account> accList = [SELECT Id FROM Account LIMIT 1]; 

        request.requestURI = 'services/apexrest/v1/Account/'+accList[0].Id;
        request.httpMethod = 'DELETE';
        RestContext.request = request;

        Test.startTest();
        String message = AccountManager.deleteAccount();
        System.assertNotEquals('{"message": "Account Record Deleted"}', message);
        Test.stopTest();

    }

    @isTest
    private static void test_deleteAccount_invalidId(){
        RestRequest request = new RestRequest();
        
        //List<Account> accList = [SELECT Id FROM Account LIMIT 1]; 

        request.requestURI = 'services/apexrest/v1/Account/'+'anything123';
        request.httpMethod = 'DELETE';
        RestContext.request = request;

        Test.startTest();
        String message = AccountManager.deleteAccount();
        System.assertEquals('{"message" : "Account Record Not Found"}', message);
        Test.stopTest();

    }

    @isTest
    private static void test_updateAccount_withValidData(){
        RestRequest request = new RestRequest();
        List<Account> accList = [SELECT Id, Description, Rating FROM Account];
        request.requestURI = 'services/apexrest/v1/Account/'+accList[0].Id;
        request.httpMethod = 'PATCH';
        RestContext.request = request;

        Test.startTest();

        AccountManager.ResponseWrapper wrapper = new AccountManager.ResponseWrapper();
        wrapper = AccountManager.updateAccount('Updated from test class method', 'warm');
        System.assertEquals('Account Record Updated.', wrapper.message);
        Test.stopTest();

    }

    @isTest
    private static void test_updateAccount_withInvalidData(){
        RestRequest request = new RestRequest();
        //List<Account> accList = [SELECT Id, Description, Rating FROM Account];
        request.requestURI = 'services/apexrest/v1/Account'+'anything123';
        request.httpMethod = 'PATCH';
        RestContext.request = request;

        Test.startTest();
        AccountManager.ResponseWrapper wrapper = new AccountManager.ResponseWrapper();
        wrapper = AccountManager.updateAccount('Updated from test class method', 'warm');
        System.assertEquals('Account Record Not Found.', wrapper.message);
        Test.stopTest();

    }

    @isTest 
    private static void test_upsertRecord_update(){
        RestRequest request = new RestRequest();
        List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        request.requestURI = 'services/apexrest/v1/Account/'+accList[0].Id;
        request.httpMethod = 'PUT';
        RestContext.request = request;

        Test.startTest();
        Account acc = AccountManager.upsertRecord('Update in upsert from Test Method', 'warm');
        System.assertEquals('Updated from Put', acc.Name);
        Test.stopTest();
    }

    @isTest 
    private static void test_upsertRecord_create(){
        RestRequest request = new RestRequest();
        //List<Account> accList = [SELECT Id FROM Account LIMIT 1];
        request.requestURI = 'services/apexrest/v1/Account';
        request.httpMethod = 'PUT';
        RestContext.request = request;

        Test.startTest();
        Account acc = AccountManager.upsertRecord('Create in upsert from Test Method', 'warm');
        System.assertEquals('Created from Put', acc.Name);
        Test.stopTest();
    }
    
    
}