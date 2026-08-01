/**
 * @description Test class for Demo.
 *              Covers: oppCreateForAcc — creates opportunities for accounts named 'Saiteja12345'
 *              Target coverage: 100%
 */
@isTest
private class DemoTest {

    @isTest
    static void testOppCreateForAcc_matchingAccount_createsOpportunity() {
        Account acc = new Account(Name = 'Saiteja12345');
        insert acc;

        Test.startTest();
        Demo.oppCreateForAcc();
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id, Name, AccountId FROM Opportunity WHERE AccountId = :acc.Id];
        System.assertEquals(1, opps.size(), 'One opportunity should be created for the matching account');
        System.assertEquals('Saiteja12345', opps[0].Name, 'Opportunity name should match account name');
    }

    @isTest
    static void testOppCreateForAcc_noMatchingAccount_noOpportunityCreated() {
        // Insert an account with a different name
        insert new Account(Name = 'Other Company XYZ');

        Test.startTest();
        Demo.oppCreateForAcc();
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        System.assertEquals(0, opps.size(), 'No opportunities should be created when no matching account exists');
    }

    @isTest
    static void testOppCreateForAcc_multipleMatchingAccounts_createsOppForEach() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Saiteja12345'),
            new Account(Name = 'Saiteja12345')
        };
        insert accounts;

        Test.startTest();
        Demo.oppCreateForAcc();
        Test.stopTest();

        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        System.assertEquals(2, opps.size(), 'One opportunity per matching account should be created');
    }
}