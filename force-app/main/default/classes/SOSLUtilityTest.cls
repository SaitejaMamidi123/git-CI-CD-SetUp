/**
 * @description Test class for SOSLUtility.
 *              Covers: getRecordsMatchingName
 *              Target coverage: 100%
 *
 *              Note: SOSL searches in Apex tests return only records that
 *              are explicitly registered via Test.setFixedSearchResults().
 */
@isTest
private class SOSLUtilityTest {

    @TestSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'test Account SOSL');
        insert acc;

        Contact con = new Contact(FirstName = 'test', LastName = 'Contact SOSL', AccountId = acc.Id);
        insert con;

        Lead lead = new Lead(FirstName = 'test', LastName = 'Lead SOSL', Company = 'SOSL Corp', LeadSource = 'Web');
        insert lead;

        Opportunity opp = new Opportunity(Name = 'test Opp SOSL', StageName = 'Prospecting', CloseDate = System.today());
        insert opp;
    }

    @isTest
    static void testGetRecordsMatchingName_returnsResults() {
        Contact con = [SELECT Id FROM Contact LIMIT 1];
        Lead    lad = [SELECT Id FROM Lead    LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        // Register the records for SOSL so test assertions are deterministic
        Test.setFixedSearchResults(new List<Id>{con.Id, lad.Id, acc.Id, opp.Id});

        SOSLUtility util = new SOSLUtility();

        Test.startTest();
        List<List<sObject>> results = util.getRecordsMatchingName('test');
        Test.stopTest();

        System.assertNotEquals(null, results, 'SOSL result should not be null');
        System.assert(results.size() > 0, 'Should return at least one sObject list');
    }

    @isTest
    static void testGetRecordsMatchingName_noFixedResults() {
        // Without fixed results the search returns empty lists — should not throw
        SOSLUtility util = new SOSLUtility();

        Test.startTest();
        List<List<sObject>> results = util.getRecordsMatchingName('test');
        Test.stopTest();

        System.assertNotEquals(null, results, 'Result should not be null even when empty');
    }
}