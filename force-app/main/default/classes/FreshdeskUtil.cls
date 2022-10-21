public with sharing class FreshdeskUtil {
    public static final String TICKET_ENDPOINT = 'https://persistentsystems.freshdesk.com/api/v2/tickets';
    public static final String CONTACT_ENDPOINT = 'https://persistentsystems.freshdesk.com/api/v2/contacts';

    public static void createContact(String name, String email, String phone, String mobile){

        String errorMessage = '';
        String endpoint = CONTACT_ENDPOINT;

        String creds = System.Label.FreshDeskApi; // base64Encode(username:password)

        String requestBody = '{"name" : "'+name+'",'+
                              '"email" : "'+email+'",'+
                              '"phone" : "'+phone+'",'+
                              '"mobile" : "'+mobile+'" }';
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setBody(requestBody);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(creds)));

        HttpResponse response = new HttpResponse();

        try{
            response = http.send(request);
            if(response.getStatusCode() == 201){
                String responseBody = response.getBody();
                System.debug(System.LoggingLevel.DEBUG, 'Response from server: '+responseBody);
            } else {
                errorMessage = 'Unexpected error while communicating with FreshDesk API. '+
                               'Status '+ response.getStatus() + ' and Status Code ' + response.getStatusCode();
                System.debug(System.LoggingLevel.DEBUG, 'Error Message: '+ errorMessage);
            }

        } catch(System.Exception ex){
            if(String.valueOf(ex.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorized endpoint: An Administrator must go to Setup -> Security Control ->'+
                               ' Remote Site Settings and add '+ ' '+ endpoint + ' Endpoint';
            } else {
                errorMessage = 'Unexpected error while communicating with FreshDesk API. '+
                               'Status '+ response.getStatus() + ' and Status Code ' + response.getStatusCode();
            }
            System.debug(System.LoggingLevel.FINEST, 'Error Message: '+ errorMessage);
        }

    }

    public static void createTicket(String description, String subject, String email, Integer priority, Integer status, Integer source){

        String errorMessage = '';
        String endpoint = TICKET_ENDPOINT;
        String creds = System.Label.FreshDeskApi; // base64Encode(username:password)


        String requestBody = '{"description": "'+description+'",'+
                        '"subject": "'+subject+'",'+ 
                        '"email": "'+email+'",'+ 
                        '"priority":'+priority+','+
                        '"status":'+ status+','+
                        '"source" :'+source+'}';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(creds)));
        request.setBody(requestBody);
        HttpResponse response = new HttpResponse();

        try{
            response = Http.send(request);
            if(response.getStatusCode() == 201){
                String responseBody = response.getBody();
                System.debug(System.LoggingLevel.DEBUG, 'Response from server: '+ responseBody);
            } else {
                errorMessage = 'Unexpected error while communicating with FreshDesk API.'+
                                'Status: '+response.getStatus() + ' and Status Code: '+ response.getStatusCode();
                System.debug(System.LoggingLevel.DEBUG, 'Error Message: '+ errorMessage);
            }
        } catch(System.Exception ex){
            if(String.valueOf(ex.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorized endpoint: An Administrator must go to Setup -> Security Control ->'+
                               ' Remote Site Settings and add '+ ' '+ endpoint + ' Endpoint';
            } else {
                errorMessage = 'Unexpected error while communicating with FreshDesk API: '+
                                'Status: '+ response.getStatus() + ' and Status Code: '+ response.getStatusCode();
            }
            System.debug(System.LoggingLevel.DEBUG, 'Error Message: '+errorMessage);
        }

    }

    public static void listAllTickets(){

        String errorMessage = '';
        String endPoint     = TICKET_ENDPOINT;
        String cred = System.Label.FreshDeskApi; // base64Encode(username:password)
        
        Http http = new Http();
        httpRequest httpReq = new httpRequest();
        httpReq.setMethod('GET');
        httpReq.setEndpoint(endPoint);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(cred)));
        HttpResponse response = new HttpResponse();
        
        try{
             response = http.send(httpReq);
            if( response.getStatusCode() == 200 ){
                String body = response.getBody();
                System.debug(System.LoggingLevel.DEBUG, ' Responsse from Server '+body);
                List<FreshdeskTicket> tickets = (List<FreshdeskTicket>)System.JSON.deserialize(body, List<FreshdeskTicket>.class);
                for(FreshdeskTicket ticket : tickets){
                    // upsert Fr_Ticket__c record here
                }
                System.debug(System.LoggingLevel.DEBUG, ' Responsse from Server '+tickets);
            }else{
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+errorMessage);
            }
        }catch(System.Exception e){
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

    public static void listCustomerTickets(String email){

        String errorMessage = '';
		String endPoint = TICKET_ENDPOINT+'?email='+EncodingUtil.urlEncode(email, 'UTF-8');
        String cred = System.Label.FreshDeskApi;
        
        Http http = new Http();
        httpRequest httpReq = new httpRequest();
        httpReq.setMethod('GET');
        httpReq.setEndpoint(endPoint);
        httpReq.setHeader('Content-Type', 'application/json');
        httpReq.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(Blob.valueOf(cred)));
        HttpResponse response = new HttpResponse();
        
        try{
             response = http.send(httpReq);
            if( response.getStatusCode() == 200 ){
                String body = response.getBody();
                System.debug(System.LoggingLevel.DEBUG, ' Responsse from Server '+body);
                List<FreshdeskTicket> tickets = (List<FreshdeskTicket>)System.JSON.deserialize(body, List<FreshdeskTicket>.class);
                for(FreshdeskTicket ticket : tickets){
                    // upsert Fr_Ticket__c record here
                }
            }else{
                errorMessage = 'Unexpected Error while communicating with API. '
                    +'Status '+response.getStatus()+' and Status Code '+response.getStatuscode();
                System.debug(System.LoggingLevel.DEBUG, 'Exeception Executed '+errorMessage);
            }
        }catch(System.Exception e){
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

}