/**
 * @description Test class for TaskCreation.
 *              Covers: taskForAccount (via direct call and AccountTrigger after update)
 *              Target coverage: 100%
 */
@isTest
private class TaskCreationTest {

    @isTest
    static void testTaskForAccount_inactiveAccount_createsTask() {
        Account acc = new Account(Name = 'Inactive Corp');
        insert acc;

        // Query with OwnerId so the Task insert won't fail with blank owner
        Account queried = [SELECT Id, Name, Active__c, OwnerId FROM Account WHERE Id = :acc.Id];
        queried.Active__c = 'No';

        Test.startTest();
        TaskCreation.taskForAccount(new List<Account>{ queried });
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject FROM Task];
        System.assertEquals(1, tasks.size(), 'Should create a task for inactive account');
        System.assert(tasks[0].Subject.startsWith('Task created for inactive account'),
            'Task subject should reference inactive account');
    }

    @isTest
    static void testTaskForAccount_activeAccount_noTask() {
        Account acc = new Account(Name = 'Active Corp', Active__c = 'Yes');
        insert acc;

        List<Account> testAccs = [SELECT Id, Name, Active__c, OwnerId FROM Account WHERE Id = :acc.Id];

        Test.startTest();
        TaskCreation.taskForAccount(testAccs);
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task];
        System.assertEquals(0, tasks.size(), 'Should NOT create a task for active account');
    }

    @isTest
    static void testTaskForAccount_emptyList_noError() {
        Test.startTest();
        TaskCreation.taskForAccount(new List<Account>());
        Test.stopTest();
        System.assert(true, 'Empty list should not cause an error');
    }

    @isTest
    static void testTaskForAccount_mixedAccounts_onlyInactiveGetTasks() {
        Account acc1 = new Account(Name = 'Active Co',   Active__c = 'Yes');
        Account acc2 = new Account(Name = 'Inactive Co', Active__c = 'No');
        insert new List<Account>{acc1, acc2};

        List<Account> mixed = new List<Account>{
            new Account(Id = acc1.Id, Name = 'Active Co',   Active__c = 'Yes',  OwnerId = UserInfo.getUserId()),
            new Account(Id = acc2.Id, Name = 'Inactive Co', Active__c = 'No',   OwnerId = UserInfo.getUserId())
        };

        Test.startTest();
        TaskCreation.taskForAccount(mixed);
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task];
        System.assertEquals(1, tasks.size(), 'Only the inactive account should get a task');
    }

    @isTest
    static void testAccountTrigger_afterUpdate_inactiveCreatesTask() {
        // Trigger calls TaskCreation.taskForAccount on after update
        Account acc = new Account(Name = 'Trigger Test Account');
        insert acc;

        Test.startTest();
        acc.Active__c = 'No';
        update acc;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :acc.Id];
        System.assertEquals(1, tasks.size(), 'AccountTrigger should create task for inactive account on update');
    }
}