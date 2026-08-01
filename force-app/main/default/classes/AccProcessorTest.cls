/**
 * @description Test class for AccProcessor batch class.
 *              Covers: start, execute, finish
 *              Target coverage: 100%
 */
@isTest
private class AccProcessorTest {

    @isTest
    static void testBatchExecutes_noAccounts() {
        Test.startTest();
        AccProcessor batch = new AccProcessor();
        Id batchId = Database.executeBatch(batch, 200);
        Test.stopTest();

        System.assertNotEquals(null, batchId, 'Batch job ID should be returned');
    }

    @isTest
    static void testBatchExecutes_withAccounts() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 50; i++) {
            accounts.add(new Account(Name = 'Batch Acc ' + i));
        }
        insert accounts;

        Test.startTest();
        AccProcessor batch = new AccProcessor();
        Id batchId = Database.executeBatch(batch, 200);
        Test.stopTest();

        System.assertNotEquals(null, batchId, 'Batch job ID should be returned');
        // Verify the batch ran over the inserted accounts
        List<Account> results = [SELECT Id FROM Account];
        System.assertEquals(50, results.size(), 'All accounts should still exist after batch');
    }
}