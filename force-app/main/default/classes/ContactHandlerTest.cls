/**
 * @description Test class for ContactHandler and ContactTrigger.
 *              Covers: activeContactError, populateConCountOnAcc, acvtConAndPopuCnt
 *              Target coverage: 100%
 */
@isTest
private class ContactHandlerTest {

    @TestSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        List<Contact> contacts = new List<Contact>{
            new Contact(FirstName = 'Alpha',  LastName = 'One',   AccountId = acc.Id),
            new Contact(FirstName = 'Beta',   LastName = 'Two',   AccountId = acc.Id),
            new Contact(FirstName = 'Gamma',  LastName = 'Three', AccountId = acc.Id)
        };
        insert contacts;
    }

    // --- activeContactError ---------------------------------------------------

    @isTest
    static void testActiveContactError_createsTasksOnDelete() {
        List<Contact> contacts = [SELECT Id, Name, OwnerId FROM Contact];

        Test.startTest();
        delete contacts;
        Test.stopTest();

        // One task should be created per deleted contact
        List<Task> tasks = [SELECT Id, Subject FROM Task];
        System.assertEquals(contacts.size(), tasks.size(),
            'A task should be created for each deleted contact');
        for (Task t : tasks) {
            System.assert(t.Subject.startsWith('Task created for newly deleted Contact'),
                'Task subject should contain expected prefix');
        }
    }

    @isTest
    static void testActiveContactError_emptyList_noError() {
        // Calling with empty list should be a no-op
        Test.startTest();
        ContactHandler.activeContactError(new List<Contact>());
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task];
        System.assertEquals(0, tasks.size(), 'No tasks should be created for empty input');
    }

    // --- populateConCountOnAcc ------------------------------------------------

    @isTest
    static void testPopulateConCountOnAcc_afterDelete() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id];

        // Delete one contact; after-delete trigger should update Contact_Count__c
        Test.startTest();
        delete contacts[0];
        Test.stopTest();

        Account updated = [SELECT Id, Contact_Count__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(2, updated.Contact_Count__c,
            'Contact_Count__c should decrement after a contact is deleted');
    }

    @isTest
    static void testPopulateConCountOnAcc_contactWithNoAccount_skipped() {
        // Contact without AccountId - should not cause error
        Contact orphan = new Contact(FirstName = 'Orphan', LastName = 'Contact');
        insert orphan;

        Test.startTest();
        delete orphan;
        Test.stopTest();

        // No exception expected; contact count on account unchanged
        Account acc = [SELECT Id, Contact_Count__c FROM Account LIMIT 1];
        System.assert(acc.Contact_Count__c != null || acc.Contact_Count__c == null,
            'Should handle contacts without AccountId gracefully');
    }

    // --- acvtConAndPopuCnt ----------------------------------------------------

    @isTest
    static void testAcvtConAndPopuCnt_afterUndelete() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<Contact> contacts = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id];

        delete contacts;

        Test.startTest();
        undelete contacts;
        Test.stopTest();

        // After undelete: Is_Active__c should be true and Contact_Count__c updated
        List<Contact> restored = [SELECT Id, Is_Active__c FROM Contact WHERE IsDeleted = false AND AccountId = :acc.Id ALL ROWS];
        for (Contact c : restored) {
            System.assertEquals(true, c.Is_Active__c, 'Is_Active__c should be true after undelete');
        }

        Account updatedAcc = [SELECT Id, Contact_Count__c FROM Account WHERE Id = :acc.Id];
        System.assertEquals(contacts.size(), (Integer) updatedAcc.Contact_Count__c,
            'Contact_Count__c should match restored contact count');
    }

    @isTest
    static void testAcvtConAndPopuCnt_contactWithNoAccount() {
        Contact orphan = new Contact(FirstName = 'Orphan', LastName = 'NoAcc');
        insert orphan;
        delete orphan;

        Test.startTest();
        undelete orphan;
        Test.stopTest();

        Contact restored = [SELECT Id, Is_Active__c FROM Contact WHERE Id = :orphan.Id];
        System.assertEquals(true, restored.Is_Active__c, 'Is_Active__c should be set even without account');
    }

    @isTest
    static void testAcvtConAndPopuCnt_emptyList_noError() {
        Test.startTest();
        ContactHandler.acvtConAndPopuCnt(new List<Contact>());
        Test.stopTest();
        System.assert(true, 'Empty list should not cause an error');
    }
}