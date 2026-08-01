/**
 * @description Test class for SchedulableApex.
 *              Covers: execute — deletes Closed Lost opportunities when scheduled.
 *              Target coverage: 100%
 */
@isTest
private class SchedulableApexTest {

    @isTest
    static void testScheduleExecutes_deletesClosedLostOpps() {
        // Insert a Closed Lost opportunity that the scheduler should delete
        Opportunity closedLost = new Opportunity(
            Name      = 'Lost Deal',
            StageName = 'Closed Lost',
            CloseDate = System.today()
        );
        insert closedLost;

        // Insert a Closed Won opportunity that should NOT be deleted
        Opportunity closedWon = new Opportunity(
            Name      = 'Won Deal',
            StageName = 'Closed Won',
            CloseDate = System.today()
        );
        insert closedWon;

        String cronExp = '0 0 0 1 1 ? 2099';

        Test.startTest();
        String jobId = System.schedule(
            'Test SchedulableApex',
            cronExp,
            new SchedulableApex()
        );
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');

        // After Test.stopTest the execute method runs synchronously
        List<Opportunity> remaining = [SELECT Id, StageName FROM Opportunity];
        for (Opportunity opp : remaining) {
            System.assertNotEquals('Closed Lost', opp.StageName,
                'Closed Lost opportunities should have been deleted');
        }
    }

    @isTest
    static void testScheduleExecutes_noOppsToDelete() {
        // No Closed Lost opps — execute should run without error
        String cronExp = '0 0 0 1 1 ? 2099';

        Test.startTest();
        String jobId = System.schedule(
            'Test SchedulableApex NoOpps',
            cronExp,
            new SchedulableApex()
        );
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Scheduled job should execute without error');
    }
}