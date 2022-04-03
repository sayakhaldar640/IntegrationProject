// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

// List<Account> accList = [SELECT Id FROM Account WHERE isDeleted = :true ALL ROWS];
// System.debug('Deleted Account: '+ accList[0]);
// undelete accList[0];

// Id recordId = '0015j00000c2J3DAAU';
// OpenCageGeocoderUtil.forwardGeoCoding(recordId);

Id recordId = '0015j00000c2J3DAAU';
OpenCageGeocoderUtil.reverseGeoCoding(recordId);


// Account acc = [SELECT Id, Name, Location__Latitude__s, Location__Longitude__s, ShippingState, ShippingCity, ShippingPostalCode, ShippingStreet, ShippingCountry 
//                       FROM Account WHERE Id = '0015j00000c2J3DAAU'];

// String location = String.valueOf(acc.Location__Latitude__s)+', '+String.valueOf(acc.Location__Longitude__s);
// String encLocation = EncodingUtil.urlEncode(location, 'UTF-8');

// System.debug('Location: '+location);
// System.debug('Encoded Location: '+ encLocation);