import { LightningElement, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import TASK_OBJECT from '@salesforce/schema/Task';
import createFollowUpTask from '@salesforce/apex/LeadAssignmentFollowUpController.createFollowUpTask';

export default class CreateFollowUpTask extends LightningElement {
    @api recordId;

    taskObjectInfo;
    isLoading = false;
    errorMessage = '';

    @wire(getObjectInfo, { objectApiName: TASK_OBJECT })
    wiredTaskObjectInfo({ error, data }) {
        if (data) {
            this.taskObjectInfo = data;
            this.errorMessage = '';
        } else if (error) {
            this.taskObjectInfo = null;
            this.errorMessage =
                'Unable to verify Task permissions. Please try again or contact your administrator.';
        }
    }

    get canCreateTask() {
        return this.taskObjectInfo && this.taskObjectInfo.createable;
    }

    get hasError() {
        return this.errorMessage && this.errorMessage.length > 0;
    }

    get buttonAriaDescribedBy() {
        return this.hasError ? 'follow-up-error-message' : null;
    }

    async handleCreateTask() {
        this.errorMessage = '';

        if (!this.recordId) {
            this.errorMessage = 'No Lead record was provided.';
            this.focusError();
            return;
        }

        if (!this.canCreateTask) {
            this.errorMessage =
                'You do not have permission to create Tasks. Contact your administrator for access.';
            this.focusError();
            return;
        }

        this.isLoading = true;

        try {
            await createFollowUpTask({ leadIds: [this.recordId] });

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Follow-up Task created.',
                    variant: 'success'
                })
            );

            this.dispatchEvent(new CloseActionScreenEvent());
        } catch (error) {
            let message = 'Unable to create the follow-up Task.';
            if (error && error.body && error.body.message) {
                message = error.body.message;
            }
            this.errorMessage = message;
            this.focusError();
        } finally {
            this.isLoading = false;
        }
    }

    focusError() {
        // Defer focus so the error message is rendered in the DOM first.
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
            const errorEl = this.template.querySelector('[data-id="error-message"]');
            if (errorEl) {
                errorEl.focus();
            }
        }, 0);
    }
}
