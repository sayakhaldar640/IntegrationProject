public class QuickbooksUtil {

    public String quickBooksQuery() {
        String query = SOQLUtil.buildSOQLQuery('qb_Metadata__mdt', System.Label.QuickbookSandbox);
        return query;
    }

    public static qb_Metadata__mdt quickbooksCred(){
        String query = quickBooksQuery();
        List<qb_Metadata__mdt> qb_CredList = Database.query(query);
        qb_Metadata__mdt qb_Cred = new qb_Metadata__mdt();
        if(qb_CredList != Null && !qb_CredList.isEmpty()){
            qb_Cred = qb_CredList.get(0);
        } else {
            return Null;
        }
        return qb_Cred;
    }

    public PageReference accessToken(){
        
        String query = quickBooksQuery();
        List<qb_Metadata__mdt> qb_CredList = Database.query(query);
        qb_Metadata__mdt qb_Cred = new qb_Metadata__mdt();

        String errorMessage = '';

        if(qb_CredList != Null && !qb_CredList.isEmpty()){
            qb_Cred = qb_CredList.get(0);
        } else {
            return Null;
        }

        String code = ApexPages.currentPage().getParameters().get('code');
        String realmId = ApexPages.currentPage().getParameters().get('realmId');

        // https://deloitteusi-5a-dev-ed--c.develop.vf.force.com/apex/QuickbooksToken
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + qb_Cred.PageName__c;

        // Body: grant_type=authorization_code&
        // code=<the code received>&
        // redirect_uri=<redirect URI>
        String requestBody = 'grant_type=authorization_code&code='+code+'&redirect_uri='+baseUrl;

        // https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer
        String endpoint = qb_Cred.token_url__c;
        String basic = qb_Cred.Client_Id__c + ':' + qb_Cred.Client_Secret__c;
        // Authorization --> Basic base64(ClientId:ClientSecret)
        String encodedString = 'Basic '+ EncodingUtil.base64Encode(Blob.valueOf(basic));

        Http http = new Http();
 
        HttpRequest httpReq = new httpRequest();
        httpReq.setMethod('POST');
        httpReq.setEndpoint(endpoint);
        httpReq.setHeader('Content-Type','application/x-www-form-urlencoded');
        httpReq.setHeader('Accept','application/json');
        httpReq.setHeader('Authorization',encodedString);
        httpReq.setBody(requestBody);

        HttpResponse response = new HttpResponse();

        try{
            response = http.send(httpReq);

            if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                String responseBody = response.getBody();
                QuickbooksToken token = (QuickbooksToken)System.JSON.deserialize(responseBody, QuickbooksToken.class);
                
                Map<String, Object> tokenMap = new Map<String, Object>();
                tokenMap.put('realmId__c', realmId);
                tokenMap.put('expires_in__c',Decimal.ValueOf(token.expires_in));
                tokenMap.put('expires_in_time__c', System.now().addSeconds(token.expires_in));
                tokenMap.put('access_token__c', token.access_token);
                tokenMap.put('refresh_token__c', token.refresh_token);
                tokenMap.put('token_type__c', token.token_type);

                String fullName = 'qb_Metadata.'+System.Label.QuickbookSandbox;

                CreateUpdateMetadataUtils.createUpdateMetadata(fullName, System.Label.QuickbookSandbox, tokenMap);

                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,
                                                            'Successfully Authenticated! You can close the window now.'));
            } else {
                errorMessage = 'Unexpected error while connecting with API. ' + 
                                'Status: ' + response.getStatus() + ' and Status Code: ' + response.getStatusCode();
                System.debug(System.LoggingLevel.DEBUG, 'Exception executed: ' + response.getBody());
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, response.getBody()));
            }
        } catch(System.Exception e){
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                    +' Remote Site Setting and add '+' '+ endPoint +' Endpoint';
            } else {
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
            }
            System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+errorMessage);
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, errorMessage));
        }
        return Null;
    }

    public static Map<String, Object> refreshToken(qb_Metadata__mdt qb_Cred){

        String errorMessage = '';

        String endPoint = qb_Cred.token_url__c;

        String basic = qb_Cred.Client_Id__c + ':' + qb_Cred.Client_Secret__c;
        String encodedString = 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(basic));
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/' + qb_Cred.PageName__c;

        // grant_type=refresh_token&refresh_token=<refresh token>
        String requestBody = 'grant_type=refresh_token&refresh_token='+qb_Cred.refresh_token__c;

        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('POST');
        httpReq.setEndpoint(endPoint);
        httpReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('Authorization',encodedString);
        httpReq.setBody(requestBody);

        HttpResponse response = new HttpResponse();

        Map<String, Object> tokenMap = new Map<String, Object>();

        try{
            response = http.send(httpReq);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                String responseBody = response.getBody();

                QuickbooksToken token = (QuickbooksToken)System.JSON.deserialize(responseBody, QuickbooksToken.class);

                tokenMap.put('expires_in__c',Decimal.valueOf(token.expires_in));
                tokenMap.put('expires_in_time__c', System.now().addSeconds(token.expires_in));
                tokenMap.put('access_token__c', token.access_token);
                tokenMap.put('refresh_token__c', token.refresh_token);

            } else {
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed in Refresh Token '+response.getBody());
            }
        } catch(System.Exception e){
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                    +' Remote Site Setting and add '+' '+ endPoint +' Endpoint';
            }else{
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
            }
            System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed in Refresh Token '+errorMessage);
        }
        return tokenMap;
    }

    public static Boolean checkTokenValidity(qb_Metadata__mdt token){
        Boolean isValid = true;
        if(token.expires_in_time__c < System.now()){
            isValid = false;
        }
        return isValid;
    }

    public static void createCustomer(QuickbooksCustomer customer){

        qb_Metadata__mdt qb_Cred = quickbooksCred();
        if(qb_Cred == Null && String.isBlank(qb_Cred.access_token__c)){
            return;
        }

        String accessToken = qb_Cred.access_token__c;

        Boolean isValid = checkTokenValidity(qb_Cred);

        Map<String, Object> refreshTokenMap = new Map<String, Object>();

        if(!isValid){
            refreshTokenMap = refreshToken(qb_Cred);
            accessToken = (String)refreshTokenMap.get('access_token__c');
        }

        // https://sandbox-quickbooks.api.intuit.com/v3/company/4620816365150899770/customer?minorversion=55
        String endPoint = (qb_Cred.Environment__c == 'Sandbox') ? qb_Cred.Sanbdox_Base_URL__c : qb_Cred.Prod_Base_URL__c;

        String customerUrl = qb_Cred.Create_Customer__c;
        customerUrl = customerUrl.replace('{realmId}',qb_Cred.realmId__c);

        String finalEndpoint = endPoint + customerUrl + qb_Cred.minorversion__c;

        String errorMessage = '';

        // customer information starts
        customer.FullyQualifiedName = 'S Haldar';

        QuickbooksCustomer.PrimaryEmailAddr email = new QuickbooksCustomer.PrimaryEmailAddr();
        email.Address = 'sayakhaldar123@myemail.com';
        customer.PrimaryEmailAddr = email;

        customer.DisplayName = 'S Haldar';
        customer.Notes = 'Created by Sayak from Amit Udmey Integration course';

        QuickbooksCustomer.PrimaryPhone phone = new QuickbooksCustomer.PrimaryPhone();
        phone.FreeFormNumber = '9038272813';
        customer.PrimaryPhone = phone;

        customer.CompanyName = 'Deloitte India (Offices of the US)';
        
        customer.FamilyName = 'Haldar';
        customer.Suffix = 'Sr';
        customer.Title = 'Mr';
        customer.MiddleName = 'Utpal';
        customer.GivenName = 'Babai';

        QuickbooksCustomer.BillAddr billaddr = new QuickbooksCustomer.BillAddr();
        billaddr.CountrySubDivisionCode = 'WB';
        billaddr.City = 'Kolkata';
        billaddr.PostalCode = '700009';
        billaddr.Line1 = 'Acharya Prafulla Chandra Road';
        billaddr.Country = 'India';

        customer.BillAddr = billaddr;
        // customer information ends

        String requestBody = JSON.serialize(customer);

        Http http = new Http();
        HttpRequest httpReq = prepareRequest(finalEndpoint, accessToken, 'POST', requestBody);
        HttpResponse response = new HttpResponse();

        try{
            response = http.send(httpReq);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                String body = response.getBody();
                System.debug(System.LoggingLevel.DEBUG, ' Responsse from Server '+body);
                if(!isValid){
                    String fullName = 'qb_Metadata.' + System.Label.QuickbookSandbox;
                    CreateUpdateMetadataUtils.createUpdateMetadata(fullName, System.Label.QuickbookSandbox, refreshTokenMap);
                }
            } else {
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+response.getBody());
            }
        } catch(System.Exception e){
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                    +' Remote Site Setting and add '+' '+ endPoint +' Endpoint';
            }else{
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
            }
            System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed in Refresh Token '+errorMessage);
        }
    }


    public static void createPayment(Decimal amount, String customer){

        qb_Metadata__mdt qb_Cred = quickbooksCred();

        if(qb_Cred == Null && String.isBlank(qb_Cred.access_token__c)){
            return;
        }

        String accessToken = qb_Cred.access_token__c;

        Boolean isValid = checkTokenValidity(qb_Cred);
        Map<String, Object> refreshTokenMap = new Map<String, Object>();

        if(!isValid){
            refreshTokenMap = refreshToken(qb_Cred);
            accessToken = (String)refreshTokenMap.get('access_token__c');
        }

        String endPoint = qb_Cred.Environment__c == 'Sandbox' ? qb_Cred.Sanbdox_Base_URL__c : qb_Cred.Prod_Base_URL__c;

        String paymentUrl = qb_Cred.Create_Payment__c;
        paymentUrl = paymentUrl.replace('{realmId}',qb_Cred.realmId__c);

        String finalEndpoint = endPoint + paymentUrl + qb_Cred.minorversion__c;

        String errorMessage = '';

        String requestBody = '{'+
            ' "TotalAmt": ' + amount +', '+ 
            ' "CustomerRef": {'+
            '   "value": "' + customer + '"' +
            '}' + 
        '}'    ;

        Http http = new Http();
        HttpRequest httpReq = prepareRequest(finalEndpoint, accessToken, 'POST', requestBody);
        HttpResponse response = new HttpResponse();

        try{
            response = http.send(httpReq);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                String body = response.getBody();
                System.debug(System.LoggingLevel.DEBUG, 'Response from server: '+ body);
                if(!isValid){
                    String fullName = 'qb_Metadata.'+ System.Label.QuickbookSandbox;
                    CreateUpdateMetadataUtils.createUpdateMetadata(fullName, System.Label.QuickbookSandbox, refreshTokenMap);
                }
            } else {
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+response.getBody());
            }
        } catch(System.Exception e){
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                    +' Remote Site Setting and add '+' '+ endPoint +' Endpoint';
            }else{
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
            }
            System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+errorMessage);
        }

    }

    public static void createInvoice(String customer){

        qb_Metadata__mdt qb_Cred = quickbooksCred();

        if(qb_Cred != Null && String.isBlank(qb_Cred.access_token__c)){
            return;
        }
        
        String accessToken = qb_Cred.access_token__c;

        Boolean isValid = checkTokenValidity(qb_Cred);
        Map<String, Object> refreshTokenMap = new Map<String, Object>();

        if(!isValid){
            refreshTokenMap = refreshToken(qb_Cred);
            accessToken = (String)refreshTokenMap.get('access_token__c');
        }

        String endPoint = qb_Cred.Environment__c == 'Sandbox' ? qb_Cred.Sanbdox_Base_URL__c : qb_Cred.Prod_Base_URL__c;

        String invoiceUrl = qb_Cred.Create_Invoice__c;
        invoiceUrl = invoiceUrl.replace('{realmId}',qb_Cred.realmId__c);

        String finalEndpoint = endPoint + invoiceUrl + qb_Cred.minorversion__c;

        String errorMessage = '';

        String requestBody =		'{'+
		'  "Line": ['+
		'    {'+
		'      "DetailType": "SalesItemLineDetail", '+
		'      "Amount": 100.0, '+
		'      "SalesItemLineDetail": {'+
		'        "ItemRef": {'+
		'          "name": "Services", '+
		'          "value": "1"'+
		'        }'+
		'      }'+
		'    }'+
		'  ], '+
		'  "CustomerRef": {'+
		'    "value": "'+ customer + '"'+
		'  }'+
		'}';

        Http http = new Http();
        HttpRequest httpReq = prepareRequest(finalEndpoint, accessToken, 'POST', requestBody);
        HttpResponse response = new HttpResponse();

        try{
            response = http.send(httpReq);
            if(response.getStatusCode() == 200 || response.getStatusCode() == 201){
                String body = response.getBody();
                System.debug(System.LoggingLevel.DEBUG, 'Response from server: '+body);
                if(!isValid){
                    String fullName = 'qb_Metadata.'+System.Label.QuickbookSandbox;
                    CreateUpdateMetadataUtils.createUpdateMetadata(fullName, System.Label.QuickbookSandbox, refreshTokenMap);
                }
            } else{
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+response.getBody());
            }
        } catch(System.Exception e){
            if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                    +' Remote Site Setting and add '+' '+ endPoint +' Endpoint';
            }else{
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
            }
            System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+errorMessage);

        }

    }


    public static HttpRequest prepareRequest(String endPoint, String accessToken, String method, String requestBody){

        HttpRequest httpReq = new HttpRequest();
        
        httpReq.setMethod(method);
        httpReq.setEndpoint(endPoint);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('Authorization', 'Bearer '+accessToken);

        if(!String.isBlank(requestBody)){
            httpReq.setBody(requestBody);
        }

        return httpReq;
    }

}