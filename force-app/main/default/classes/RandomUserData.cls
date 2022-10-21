public class RandomUserData{
    @AuraEnabled public Results[] resultWrappers;
    
    public class Results {
        @AuraEnabled public String gender;
        @AuraEnabled public Name name;
        @AuraEnabled public String email;
        @AuraEnabled public Picture picture;

    }
    public class Name {
        @AuraEnabled public String first;
        @AuraEnabled public String last;	
    }

    public class Picture {
        @AuraEnabled public String large;		
    }
}