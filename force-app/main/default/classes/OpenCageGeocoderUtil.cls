global with sharing class OpenCageGeocoderUtil {
    
    @future(callout=true)
    public static void forwardGeoCoding(Id recordId){
        
        String endpoint = System.Label.OpenCageEndpoint;
        String apiKey = System.Label.OpenCageKey;
        String errorMessage = '';

        Account acc = [SELECT Id, Name, Location__Latitude__s, Location__Longitude__s, ShippingState, ShippingCity, ShippingPostalCode, ShippingStreet, ShippingCountry 
                      FROM Account WHERE Id = :recordId];

        String address = acc.ShippingStreet + ',' + 
                        acc.ShippingCity + ',' + 
                        acc.ShippingState + ',' + 
                        acc.ShippingPostalCode + ',' +
                        acc.ShippingCountry;

        String encAddress = EncodingUtil.urlEncode(address, 'UTF-8');


        String finalEndpoint = endpoint + 'q='+ encAddress + '&key=' + apiKey + '&pretty=1&limit=1';

        //https://api.opencagedata.com/geocode/v1/json?
        //q=Rua+Cafel%C3%A2ndia%2C+Carapicu%C3%ADba%2C+Brasil&key=92f0caea2d334a5c95aff693c2385144&pretty=1

        Http http = new Http();

        HttpRequest httpReq = new HttpRequest();
        httpReq.setMethod('GET');
        httpReq.setEndpoint(finalEndpoint);
        httpReq.setHeader('Content-Type', 'application/json');
        
        HttpResponse response = new HttpResponse();

        try{
            
            response = http.send(httpReq);

            if(response.getStatusCode() == 200){
                String body = response.getBody();
                //System.debug(System.LoggingLevel.DEBUG, 'Body: '+body);
                OpenCageResponse opencagedata = (OpenCageResponse)System.JSON.deserialize(body, OpenCageResponse.class);
                List<OpenCageResponse.cls_results> results = opencagedata.results;
                if(results != Null && results.size() > 0){
                    OpenCageResponse.cls_results result = results.get(0);
                    //System.debug(System.LoggingLevel.DEBUG, 'Result: '+result);
                    acc.Location__Latitude__s = result.geometry.lat;
                    acc.Location__Longitude__s = result.geometry.lng;
                    update acc;
                }

            } else {
                errorMessage = 'Unexpected error while communicating with OpenCage GeoCoder API. '+
                                'Status '+ response.getStatus() + ' and Status Code ' + response.getStatusCode();
                System.debug(System.LoggingLevel.DEBUG, 'Exception Executed '+errorMessage);
            }

        } catch(System.Exception ex){
            
            if(String.valueOf(ex.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorized endpoint: An Administrator must go to Setup -> Security Control ->'+
                                ' Remote Site Settings and add '+ ' '+ endpoint + ' Endpoint';
            } else {
                errorMessage = 'Unexpected error while communicating with OpenCage GeoCoder API. '+
                                'Status '+ response.getStatus() + ' and Status Code ' + response.getStatusCode();
            }
            System.debug(System.LoggingLevel.DEBUG, 'Exception Executed '+errorMessage);
        
        }

    }

    @future(callout=true)
    public static void reverseGeoCoding(Id recordId){
        
        String endpoint = System.Label.OpenCageEndpoint;
        String key = System.Label.OpenCageKey;
        String errorMessage = '';

        Account acc = [SELECT Id, Name, Location__Latitude__s, Location__Longitude__s, ShippingState, ShippingCity, ShippingPostalCode, ShippingStreet, ShippingCountry 
                      FROM Account WHERE Id = :recordId];

        String location = String.valueOf(acc.Location__Latitude__s)+', '+String.valueOf(acc.Location__Longitude__s);
        String encLocation = EncodingUtil.urlEncode(location, 'UTF-8');

        String finalEndpoint = endpoint + 'q=' + encLocation + '&key=' + key + '&pretty=1';

        //https://api.opencagedata.com/geocode/v1/json?
        //q=-22.6792%2C+14.5272&key=92f0caea2d334a5c95aff693c2385144&pretty=1

        // 38.9573233, -95.2497421

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(finalEndpoint);
        request.setHeader('Content-Type', 'application/json');

        HttpResponse response = new HttpResponse();

        try{
            response = http.send(request);

            if(response.getStatusCode() == 200){
                String body = response.getBody();
                OpenCageResponse opencageData = (OpenCageResponse)System.JSON.deserialize(body, OpenCageResponse.class);
                List<OpenCageResponse.cls_results> results = opencageData.results;
                if(results != Null && results.size() > 0){
                    OpenCageResponse.cls_results result = results.get(0);
                    
                    acc.ShippingStreet = result.components.road;
                    acc.ShippingCity = result.components.city;
                    acc.ShippingState = result.components.state;
                    acc.ShippingPostalCode = result.components.postcode;
                    acc.ShippingCountry = result.components.country;

                    update acc;
                }

            } else {
                errorMessage = 'Unexpected error while communicating with OpenCage GeoCoder API. '+
                                'Status: '+ response.getStatus() + ' and Status Code: ' + response.getStatusCode();
                System.debug(System.LoggingLevel.DEBUG, 'Error Message: '+ errorMessage);
            }

        } catch(System.Exception ex){
            if(String.valueOf(ex.getMessage()).startsWith('Unauthorized endpoint')){
                errorMessage = 'Unauthorized endpoint: An Administrator must go to Setup -> Security Control ->'+
                               ' Remote Site Settings and add '+ ' '+ endpoint + ' Endpoint';
            } else {
                errorMessage = 'Unexpected error while communicating with OpenCage GeoCoder API. '+
                               'Status '+ response.getStatus() + ' and Status Code ' + response.getStatusCode();
            }
            System.debug(System.LoggingLevel.FINEST, 'Error Message: '+ errorMessage);
        }

    }
}