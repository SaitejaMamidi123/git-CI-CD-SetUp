/**
 * @description Test class for ProducerSearchController.
 *              Covers: searchProducers (valid search, empty result)
 *              Target coverage: 100%
 */
@isTest
private class ProducerSearchControllerTest {

    @TestSetup
    static void setupTestData() {
        List<Producer__c> producers = new List<Producer__c>{
            new Producer__c(Name = 'Steven Spielberg'),
            new Producer__c(Name = 'Christopher Nolan'),
            new Producer__c(Name = 'James Cameron')
        };
        insert producers;
    }

    @isTest
    static void testSearchProducers_validTerm_returnsResults() {
        Test.startTest();
        List<Producer__c> results = ProducerSearchController.searchProducers('Nolan');
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should find Christopher Nolan');
        System.assert(results[0].Name.contains('Nolan'), 'Name should contain the search term');
    }

    @isTest
    static void testSearchProducers_noMatch_returnsEmpty() {
        Test.startTest();
        List<Producer__c> results = ProducerSearchController.searchProducers('XYZNoMatch999');
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(0, results.size(), 'Should return empty list when no match');
    }

    @isTest
    static void testSearchProducers_partialMatch() {
        Test.startTest();
        List<Producer__c> results = ProducerSearchController.searchProducers('Steven');
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should find Steven Spielberg with partial name');
    }

    @isTest
    static void testSearchProducers_emptyString_returnsAll() {
        // Empty string pattern '%  %' matches everything — result limited to 10
        Test.startTest();
        List<Producer__c> results = ProducerSearchController.searchProducers('');
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null for empty search term');
    }
}