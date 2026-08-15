public with sharing class PolicyRenewalBatch implements Database.Batchable<Policy__c> {

    public Iterable<Policy__c> start(Database.BatchableContext bc) {
        return [
            SELECT Id, Customer__c, Policy_Start_Date__c, Policy_End_Date__c
            FROM Policy__c
            WHERE Policy_End_Date__c >= :Date.today()
            AND Policy_End_Date__c <= :Date.today().addDays(30)
        ];
    }

    public void execute(Database.BatchableContext bc, List<Policy__c> scope) {
        Set<Id> policyIds = new Set<Id>();
        Set<Id> customerIds = new Set<Id>();

        for (Policy__c p : scope) {
            if (p.Customer__c != null) {
                policyIds.add(p.Id);
                customerIds.add(p.Customer__c);
            }
        }
        if (policyIds.isEmpty()) return;

        Map<Id, Contact> customers = new Map<Id, Contact>([
            SELECT Id, OwnerId
            FROM Contact
            WHERE Id IN :customerIds
        ]);

        Set<Id> alreadyHasTask = new Set<Id>();
        for (Task t : [
            SELECT WhatId
            FROM Task
            WHERE WhatId IN :policyIds
            AND Subject = 'Policy Renewal Follow-up'
            AND Status != 'Completed'
            AND Status != 'Deferred'
        ]) {
            alreadyHasTask.add(t.WhatId);
        }

        List<Task> tasksToInsert = new List<Task>();

        for (Policy__c p : scope) {
            if (alreadyHasTask.contains(p.Id)) continue;
            if (p.Customer__c == null || p.Policy_End_Date__c == null) continue;

            Contact c = customers.get(p.Customer__c);
            if (c == null || c.OwnerId == null) continue;

            Date dueDate = p.Policy_End_Date__c.addDays(-7);
            if (dueDate < Date.today()) dueDate = Date.today();

            tasksToInsert.add(new Task(
                Subject = 'Policy Renewal Follow-up',
                Status = 'Not Started',
                OwnerId = c.OwnerId,
                WhoId = c.Id,
                WhatId = p.Id,
                ActivityDate = dueDate
            ));
        }

        if (!tasksToInsert.isEmpty()) {
            Database.insert(tasksToInsert, false);
        }
    }

    public void finish(Database.BatchableContext bc) {}
}