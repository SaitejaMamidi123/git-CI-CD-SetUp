/**
 * @description Test class for CalculateTotalRevenueSchedule.
 *              Covers: execute (Schedulable interface)
 *              Target coverage: 100%
 */
@isTest
private class CalculateTotalRevenueScheduleTest {

    @isTest
    static void testScheduleExecutes() {
        String cronExp = '0 0 0 1 1 ? 2099';

        Test.startTest();
        String jobId = System.schedule(
            'Test CalculateTotalRevenueSchedule',
            cronExp,
            new CalculateTotalRevenueSchedule()
        );
        Test.stopTest();

        System.assertNotEquals(null, jobId, 'Scheduled job ID should not be null');
    }
}