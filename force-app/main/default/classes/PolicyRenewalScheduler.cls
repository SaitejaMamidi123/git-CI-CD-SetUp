global with sharing class PolicyRenewalScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new PolicyRenewalBatch(), 200);
    }
}