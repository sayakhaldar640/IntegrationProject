// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

List<Account> accList = [SELECT Id FROM Account WHERE isDeleted = :true ALL ROWS];
System.debug('Deleted Account: '+ accList[0]);
undelete accList[0];