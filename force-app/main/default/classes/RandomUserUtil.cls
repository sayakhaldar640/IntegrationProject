public with sharing class RandomUserUtil {
    
    @AuraEnabled
    public static RandomUserData getUserData(){
        String endpoint = 'https://randomuser.me/api/';
        
        Http http = new Http();
        
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        
        HttpResponse response = http.send(request);
        
        try{
            String responseBody = response.getBody();
            RandomUserData randomData = (RandomUserData) System.JSON.deserialize(responseBody, RandomUserData.class);
            System.debug('Response BODY: '+responseBody);
            return randomData;
        } catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }  
    }
}