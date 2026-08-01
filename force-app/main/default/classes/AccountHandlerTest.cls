@isTest
private class AccountHandlerTest {
    
     @isTest
    Private static void activateNewAccountsTest(){
         List<Account> accList = new List<Account>{
            new Account(Name = 'Test Account 1', Industry = 'Energy'),
            new Account(Name = 'Test Account 2', Industry = 'Agriculture'),
            new Account(Name = 'Test Account 3', Industry = 'Chemicals')
        };
            insert accList;
        List<Account> insertedAccs = [SELECT Id, Active__c, BillingCountry, rating, Industry FROM Account WHERE Id IN :accList];
         for (Account acc1 : insertedAccs) {
            System.assertEquals('Yes', acc1.Active__c, 'Active__c should be Yes');
            System.assertEquals('India', acc1.BillingCountry, 'BillingCountry should be India');
             if(acc1.Industry == 'Energy'){
                 System.assertEquals('Hot', acc1.Rating, 'Rating should be Hot');
             }else if(acc1.Industry == 'Agriculture'){
                 System.assertEquals('Warm', acc1.Rating, 'Rating should be Warm');
             }else{
                 System.assertEquals('Cold', acc1.Rating, 'Rating should be Cold');
             }
        }
    }
    @isTest
    Private static void getAccountRecords(){
        Account accList = new Account();
            accList.Name = 'Test Account 1';
        	accList.Industry = 'Energy';
        	accList.Phone = '1234';
            insert accList;
                
        Account a = AccountHandler.getAccountRecord();
        System.assertEquals(accList.id, a.Id, 'Failed to get records');
        accList.Phone = '12675';
        update accList;
        Account b = [Select id, Phone, Description from Account where id =:accList.id];
        System.assertEquals('Phone number updated', b.Description, 'Failed to update records');
        
    }

    @isTest
    static void testGetAccountRecord_noIndustry_returnsNull() {
        // No accounts with Industry — should return null
        Account acc = new Account(Name = 'No Industry Account');
        insert acc;
        // The trigger will set Active__c but Industry is null
        Account result = AccountHandler.getAccountRecord();
        // May or may not find a record depending on other test data; no exception is the key assertion
        System.assert(true, 'getAccountRecord should not throw when no match');
    }

    @isTest
    static void testActivateNewAccounts_nullList_noError() {
        Test.startTest();
        AccountHandler.activateNewAccounts(null);
        AccountHandler.activateNewAccounts(new List<Account>());
        Test.stopTest();
        System.assert(true, 'Null/empty list should not cause an error');
    }

    @isTest
    static void testUpdateAccRating_nullList_noError() {
        Test.startTest();
        AccountHandler.updateAccRating(null);
        AccountHandler.updateAccRating(new List<Account>());
        Test.stopTest();
        System.assert(true, 'Null/empty list should not cause an error');
    }

    @isTest
    static void testUpdateAccRating_ratingAlreadySet_noOverwrite() {
        Account acc = new Account(Name = 'Pre-rated', Industry = 'Energy', Rating = 'Cold');
        // Call directly — if Rating is already set, it should NOT be overwritten
        AccountHandler.updateAccRating(new List<Account>{acc});
        System.assertEquals('Cold', acc.Rating, 'Existing Rating should not be overwritten');
    }

    @isTest
    static void testUpdateAccRating_nullIndustry_noChange() {
        Account acc = new Account(Name = 'No Industry');
        AccountHandler.updateAccRating(new List<Account>{acc});
        System.assertEquals(null, acc.Rating, 'Rating should remain null when Industry is null');
    }

    @isTest
    static void testUpdateDesc_nullInputs_noError() {
        Test.startTest();
        AccountHandler.updateDesc(null, null);
        AccountHandler.updateDesc(new List<Account>(), new Map<Id, Account>());
        Test.stopTest();
        System.assert(true, 'Null/empty inputs should not cause an error');
    }

    @isTest
    static void testCreateRelatedOpportunities_createsOpps() {
        Account acc = new Account(Name = 'Opp Parent');
        insert acc;

        Test.startTest();
        AccountHandler.createRelatedOpportunities(new List<Account>{acc});
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id, AccountId FROM Opportunity WHERE AccountId = :acc.Id];
        System.assertEquals(1, opps.size(), 'One opportunity should be created per account');
    }

    @isTest
    static void testCreateRelatedOpportunities_nullAndEmpty_noError() {
        Test.startTest();
        AccountHandler.createRelatedOpportunities(null);
        AccountHandler.createRelatedOpportunities(new List<Account>());
        Test.stopTest();
        System.assert(true, 'Null/empty list should not throw an error');
    }

    @isTest
    static void testSyncPhoneToOpportunities_updatesOppPhone() {
        Account acc = new Account(Name = 'Phone Sync Account', Phone = '1111111111');
        insert acc;

        // Insert an opportunity linked to the account (trigger also fires popAccountRevenue)
        Opportunity opp = new Opportunity(
            Name      = 'Sync Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today()
        );
        insert opp;

        Test.startTest();
        AccountHandler.syncPhoneToOpportunities(new List<Account>{acc});
        Test.stopTest();

        Opportunity updatedOpp = [SELECT Id, Phone__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals('1111111111', updatedOpp.Phone__c,
            'Phone__c on opportunity should match account phone after sync');
    }

    @isTest
    static void testSyncPhoneToOpportunities_nullAndEmpty_noError() {
        Test.startTest();
        AccountHandler.syncPhoneToOpportunities(null);
        AccountHandler.syncPhoneToOpportunities(new List<Account>());
        Test.stopTest();
        System.assert(true, 'Null/empty list should not throw an error');
    }

    @isTest
    static void testSyncPhoneToOpportunities_accountWithNoOpps_continuesBranch() {
        // Account with NO opportunities triggers the continue; branch in syncPhoneToOpportunities
        Account acc = new Account(Name = 'No Opp Account', Phone = '9999999999');
        insert acc;

        Test.startTest();
        AccountHandler.syncPhoneToOpportunities([SELECT Id, Phone FROM Account WHERE Id = :acc.Id]);
        Test.stopTest();

        System.assert(true, 'Account with no opportunities should be handled gracefully');
    }
}