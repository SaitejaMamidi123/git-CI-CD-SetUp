/**
 * @description Test class for LeadTrigger.
 *              Covers: before insert validation (null LeadSource → addError)
 *                       before update validation (null LeadSource → addError)
 *              Target coverage: 100%
 */
@isTest
private class LeadTriggerTest {

    @isTest
    static void testLeadInsert_withLeadSource_succeeds() {
        Lead lead = new Lead(
            FirstName  = 'John',
            LastName   = 'Doe',
            Company    = 'Test Corp',
            LeadSource = 'Web'
        );

        Test.startTest();
        insert lead;
        Test.stopTest();

        Lead inserted = [SELECT Id, LeadSource FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('Web', inserted.LeadSource, 'Lead with LeadSource should be inserted successfully');
    }

    @isTest
    static void testLeadInsert_withoutLeadSource_throwsError() {
        Lead lead = new Lead(
            FirstName = 'Jane',
            LastName  = 'Smith',
            Company   = 'No Source Corp'
            // LeadSource intentionally omitted
        );

        Test.startTest();
        try {
            insert lead;
            System.assert(false, 'Insert should have failed due to missing LeadSource');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Pls populate the Lead Source Field'),
                'Error message should mention LeadSource requirement. Actual: ' + e.getMessage()
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testLeadUpdate_withLeadSource_succeeds() {
        Lead lead = new Lead(
            FirstName  = 'Alice',
            LastName   = 'Wonderland',
            Company    = 'Dream Corp',
            LeadSource = 'Phone'
        );
        insert lead;

        Test.startTest();
        lead.LeadSource = 'Web';
        update lead;
        Test.stopTest();

        Lead updated = [SELECT Id, LeadSource FROM Lead WHERE Id = :lead.Id];
        System.assertEquals('Web', updated.LeadSource, 'Lead should update with valid LeadSource');
    }

    @isTest
    static void testLeadUpdate_clearingLeadSource_throwsError() {
        Lead lead = new Lead(
            FirstName  = 'Bob',
            LastName   = 'Builder',
            Company    = 'Build Corp',
            LeadSource = 'Web'
        );
        insert lead;

        Test.startTest();
        try {
            lead.LeadSource = null;
            update lead;
            System.assert(false, 'Update should have failed due to null LeadSource');
        } catch (DmlException e) {
            System.assert(
                e.getMessage().contains('Pls populate the Lead Source Field'),
                'Error message should mention LeadSource requirement on update'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testLeadInsert_bulkWithMixedLeadSource() {
        List<Lead> leads = new List<Lead>{
            new Lead(FirstName = 'Good1', LastName = 'Lead', Company = 'Corp1', LeadSource = 'Web'),
            new Lead(FirstName = 'Good2', LastName = 'Lead', Company = 'Corp2', LeadSource = 'Email')
        };

        Test.startTest();
        insert leads;
        Test.stopTest();

        System.assertEquals(2, [SELECT Id FROM Lead].size(), 'Both valid leads should be inserted');
    }
}