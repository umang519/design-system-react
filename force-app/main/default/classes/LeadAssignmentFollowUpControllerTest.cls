@isTest
private class LeadAssignmentFollowUpControllerTest {

    @TestSetup
    static void setupData() {
        List<Lead> leads = new List<Lead>();
        for (Integer i = 0; i < 1000; i++) {
            leads.add(
                new Lead(
                    LastName = 'TestLead ' + i,
                    Company = 'Test Company',
                    Status = 'Open - Not Contacted'
                )
            );
        }
        insert leads;
    }

    @isTest
    static void testCreateFollowUpTask_SingleLead() {
        Lead testLead = [SELECT Id FROM Lead LIMIT 1];
        List<Id> leadIds = new List<Id>{ testLead.Id };

        Test.startTest();
        List<Id> taskIds = LeadAssignmentFollowUpController.createFollowUpTask(leadIds);
        Test.stopTest();

        System.assertEquals(1, taskIds.size(), 'Expected one Task Id to be returned.');

        List<Task> tasks = [SELECT Id, WhoId, WhatId FROM Task WHERE Id IN :taskIds];
        System.assertEquals(1, tasks.size(), 'Expected one Task to be created.');
        System.assertEquals(testLead.Id, tasks[0].WhoId, 'Task.WhoId should be set to the Lead Id.');
        System.assertEquals(null, tasks[0].WhatId, 'Task.WhatId should be null.');
    }

    @isTest
    static void testCreateFollowUpTask_Bulk210() {
        List<Lead> leads = [SELECT Id FROM Lead LIMIT 210];
        System.assertEquals(210, leads.size(), 'Expected 210 Leads for the bulk test.');

        List<Id> leadIds = new List<Id>();
        for (Lead l : leads) {
            leadIds.add(l.Id);
        }
        Set<Id> leadIdSet = new Set<Id>(leadIds);

        Test.startTest();
        List<Id> taskIds = LeadAssignmentFollowUpController.createFollowUpTask(leadIds);
        Test.stopTest();

        System.assertEquals(210, taskIds.size(), 'Expected 210 Task Ids to be returned.');

        List<Task> tasks = [SELECT Id, WhoId, WhatId FROM Task WHERE WhoId IN :leadIds];
        System.assertEquals(210, tasks.size(), 'Expected 210 Tasks to be created.');
        for (Task t : tasks) {
            System.assert(leadIdSet.contains(t.WhoId), 'Task.WhoId should match one of the provided Lead Ids.');
            System.assertEquals(null, t.WhatId, 'Task.WhatId should be null for every Task.');
        }
    }

    @isTest
    static void testCreateFollowUpTask_Bulk1000() {
        List<Lead> leads = [SELECT Id FROM Lead LIMIT 1000];
        System.assertEquals(1000, leads.size(), 'Expected 1000 Leads for the bulk test.');

        List<Id> leadIds = new List<Id>();
        for (Lead l : leads) {
            leadIds.add(l.Id);
        }
        Set<Id> leadIdSet = new Set<Id>(leadIds);

        Test.startTest();
        List<Id> taskIds = LeadAssignmentFollowUpController.createFollowUpTask(leadIds);
        Test.stopTest();

        System.assertEquals(1000, taskIds.size(), 'Expected 1000 Task Ids to be returned.');

        List<Task> tasks = [SELECT Id, WhoId, WhatId FROM Task WHERE WhoId IN :leadIds];
        System.assertEquals(1000, tasks.size(), 'Expected 1000 Tasks to be created.');
        for (Task t : tasks) {
            System.assert(leadIdSet.contains(t.WhoId), 'Task.WhoId should match one of the provided Lead Ids.');
            System.assertEquals(null, t.WhatId, 'Task.WhatId should be null for every Task.');
        }
    }

    @isTest
    static void testCreateFollowUpTask_EmptyListThrowsException() {
        Boolean exceptionThrown = false;
        try {
            LeadAssignmentFollowUpController.createFollowUpTask(new List<Id>());
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected an AuraHandledException when an empty list is provided.');
    }

    @isTest
    static void testCreateFollowUpTask_NullListThrowsException() {
        Boolean exceptionThrown = false;
        try {
            LeadAssignmentFollowUpController.createFollowUpTask(null);
        } catch (AuraHandledException ex) {
            exceptionThrown = true;
        }
        System.assert(exceptionThrown, 'Expected an AuraHandledException when a null list is provided.');
    }
}
