public with sharing class LeadAssignmentFollowUpController {
    private static final Integer MAX_TASKS = 1000;

    /**
     * Creates a follow-up Task for each provided Lead, relating the Task to the
     * Lead via Task.WhoId. Salesforce requires a Lead (a person/thing) to be in
     * WhoId, not WhatId. Up to 1,000 Leads can be processed in a single call.
     *
     * @param leadIds The Lead record Ids to create follow-up Tasks for.
     * @return The Ids of the Tasks that were created.
     */
    @AuraEnabled
    public static List<Id> createFollowUpTask(List<Id> leadIds) {
        if (leadIds == null || leadIds.isEmpty()) {
            throw new AuraHandledException('Please select at least one Lead to follow up.');
        }
        if (leadIds.size() > MAX_TASKS) {
            throw new AuraHandledException(
                'You can create follow-up tasks for up to ' + MAX_TASKS + ' leads at a time.'
            );
        }

        List<Task> tasksToCreate = new List<Task>();
        for (Id leadId : leadIds) {
            if (leadId == null) {
                continue;
            }
            tasksToCreate.add(
                new Task(
                    WhoId = leadId,
                    WhatId = null,
                    Subject = 'Follow Up',
                    Status = 'Not Started',
                    Priority = 'Normal'
                )
            );
        }

        if (tasksToCreate.isEmpty()) {
            throw new AuraHandledException('No valid Lead records were provided.');
        }

        try {
            insert tasksToCreate;
        } catch (DmlException dmlEx) {
            throw new AuraHandledException(
                'Unable to create follow-up tasks. Please verify you have permission to create Tasks and that all required fields are provided.'
            );
        } catch (Exception ex) {
            throw new AuraHandledException(
                'An unexpected error occurred while creating follow-up tasks. Please try again or contact your administrator.'
            );
        }

        List<Id> taskIds = new List<Id>();
        for (Task t : tasksToCreate) {
            taskIds.add(t.Id);
        }
        return taskIds;
    }
}
