/**
 * @description Test class for UpdateAccountBatch.
 *              Covers: start, execute (updates Active__c to Yes), finish
 *              Target coverage: 100%
 */
@isTest
private class UpdateAccountBatchTest {

    @isTest
    static void testBatch_updatesInactiveAccounts() {
        // Insert accounts - AccountTrigger sets Active__c = 'Yes' on before insert
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 10; i++) {
            accounts.add(new Account(Name = 'Batch Account ' + i));
        }
        insert accounts;

        // Before-update trigger only calls updateDesc (phone change check), not activateNewAccounts.
        // So updating Active__c to 'No' here is not overridden by the trigger.
        for (Account acc : accounts) {
            acc.Active__c = 'No';
        }
        update accounts;

        Test.startTest();
        UpdateAccountBatch batch = new UpdateAccountBatch();
        Id batchId = Database.executeBatch(batch, 200);
        Test.stopTest();

        System.assertNotEquals(null, batchId, 'Batch job ID should not be null');

        List<Account> updated = [SELECT Id, Active__c FROM Account WHERE Name LIKE 'Batch Account%'];
        for (Account acc : updated) {
            System.assertEquals('Yes', acc.Active__c,
                'Active__c should be updated to Yes by the batch');
        }
    }

    @isTest
    static void testBatch_noInactiveAccounts_finishesCleanly() {
        // Insert an active account — should not match the batch query and batch runs cleanly
        insert new Account(Name = 'Already Active', Active__c = 'Yes');

        Test.startTest();
        UpdateAccountBatch batch = new UpdateAccountBatch();
        Id batchId = Database.executeBatch(batch, 200);
        Test.stopTest();

        System.assertNotEquals(null, batchId, 'Batch job should complete without error');
    }
}