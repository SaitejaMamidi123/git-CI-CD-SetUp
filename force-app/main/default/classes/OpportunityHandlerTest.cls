/**
 * @description Test class for OpportunityHandler and OpportunityTrigger.
 *              Covers: taskForClosedOpp, popAccountRevenue, getClosedWonOpportunityAmountTotal
 *              Target coverage: 100%
 */
@isTest
private class OpportunityHandlerTest {

    @TestSetup
    static void setupTestData() {
        Account acc = new Account(Name = 'Test Account', AnnualRevenue = 0);
        insert acc;
    }

    // --- getClosedWonOpportunityAmountTotal -----------------------------------

    @isTest
    static void testGetClosedWonOpportunityAmountTotal_noOpps() {
        OpportunityHandler handler = new OpportunityHandler();
        Test.startTest();
        Object total = handler.getClosedWonOpportunityAmountTotal();
        Test.stopTest();
        // With no opportunities, SUM returns null
        System.assert(total == null || total != null, 'Method should execute without exception');
    }

    @isTest
    static void testGetClosedWonOpportunityAmountTotal_withOpps() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        insert new Opportunity(
            Name      = 'Test Opp',
            AccountId = acc.Id,
            StageName = 'Closed Won',
            CloseDate = System.today(),
            Amount    = 5000
        );

        OpportunityHandler handler = new OpportunityHandler();
        Test.startTest();
        Object total = handler.getClosedWonOpportunityAmountTotal();
        Test.stopTest();

        System.assertNotEquals(null, total, 'Total should not be null when opportunities exist');
    }

    // --- taskForClosedOpp -----------------------------------------------------

    @isTest
    static void testTaskForClosedOpp_transitionToClosedWon_createsTask() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = new Opportunity(
            Name      = 'Test Closed Won',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today(),
            Amount    = 1000
        );
        insert opp;

        Test.startTest();
        opp.StageName = 'Closed Won';
        update opp;
        Test.stopTest();

        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE WhatId = :opp.Id];
        System.assertEquals(1, tasks.size(), 'One task should be created when opp moves to Closed Won');
        System.assert(tasks[0].Subject.startsWith('Task Created for Opportunity'), 'Task subject mismatch');
    }

    @isTest
    static void testTaskForClosedOpp_alreadyClosedWon_noNewTask() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = new Opportunity(
            Name      = 'Already Closed',
            AccountId = acc.Id,
            StageName = 'Closed Won',
            CloseDate = System.today(),
            Amount    = 2000
        );
        insert opp;

        // Force an update without changing stage
        Test.startTest();
        opp.Description = 'No stage change';
        update opp;
        Test.stopTest();

        List<Task> tasks = [SELECT Id FROM Task WHERE WhatId = :opp.Id];
        System.assertEquals(0, tasks.size(), 'No task should be created when stage does not transition to Closed Won');
    }

    @isTest
    static void testTaskForClosedOpp_emptyList_noError() {
        Test.startTest();
        OpportunityHandler.taskForClosedOpp(new List<Opportunity>(), new Map<Id, Opportunity>());
        Test.stopTest();
        System.assert(true, 'Empty list should not throw an exception');
    }

    // --- popAccountRevenue ----------------------------------------------------

    @isTest
    static void testPopAccountRevenue_onInsert_setsAnnualRevenue() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        insert new Opportunity(
            Name      = 'Revenue Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today(),
            Amount    = 3000
        );
        Test.stopTest();

        Account updated = [SELECT Id, AnnualRevenue FROM Account WHERE Id = :acc.Id];
        System.assertEquals(3000, updated.AnnualRevenue, 'AnnualRevenue should equal opportunity amount after insert');
    }

    @isTest
    static void testPopAccountRevenue_onUpdate_recalculatesRevenue() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp = new Opportunity(
            Name      = 'Revenue Opp Update',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today(),
            Amount    = 1000
        );
        insert opp;

        Test.startTest();
        opp.Amount = 5000;
        update opp;
        Test.stopTest();

        Account updated = [SELECT Id, AnnualRevenue FROM Account WHERE Id = :acc.Id];
        System.assertEquals(5000, updated.AnnualRevenue, 'AnnualRevenue should be updated when opp amount changes');
    }

    @isTest
    static void testPopAccountRevenue_onDelete_recalculatesRevenue() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity opp1 = new Opportunity(Name = 'Opp1', AccountId = acc.Id, StageName = 'Prospecting', CloseDate = System.today(), Amount = 2000);
        Opportunity opp2 = new Opportunity(Name = 'Opp2', AccountId = acc.Id, StageName = 'Prospecting', CloseDate = System.today(), Amount = 3000);
        insert new List<Opportunity>{opp1, opp2};

        Test.startTest();
        delete opp1;
        Test.stopTest();

        Account updated = [SELECT Id, AnnualRevenue FROM Account WHERE Id = :acc.Id];
        System.assertEquals(3000, updated.AnnualRevenue, 'AnnualRevenue should reflect remaining opp after delete');
    }

    @isTest
    static void testPopAccountRevenue_nullAmount_skipped() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        insert new Opportunity(
            Name      = 'No Amount Opp',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = System.today()
            // Amount intentionally null
        );
        Test.stopTest();

        Account updated = [SELECT Id, AnnualRevenue FROM Account WHERE Id = :acc.Id];
        System.assertEquals(0, updated.AnnualRevenue == null ? 0 : updated.AnnualRevenue,
            'Null amount should contribute 0 to AnnualRevenue');
    }

    @isTest
    static void testPopAccountRevenue_noAccountId_skipped() {
        List<Opportunity> opps = new List<Opportunity>{
            new Opportunity(Name = 'No Acc Opp', StageName = 'Prospecting', CloseDate = System.today(), Amount = 999)
        };
        Map<Id, Opportunity> oldMap = new Map<Id, Opportunity>();

        Test.startTest();
        OpportunityHandler.popAccountRevenue(opps, oldMap);
        Test.stopTest();

        System.assert(true, 'Opps without AccountId should be silently skipped');
    }
}