public with sharing class Sathvika {
   
    public static void getAccountDetails() {
        List<Account> accList = [SELECT Id, Name FROM Account];
        System.debug('Account List: ' + accList);
    }
     public Sathvika() {
        // Constructor logic here
    }
}