import { LightningElement, api, wire, track } from 'lwc';
import LightningModal from 'lightning/modal';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrors } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createOrUpdateProjectTeam from '@salesforce/apex/ProjectTeamController.createOrUpdateProjectTeam';
//import cloneRoom from '@salesforce/apex/RoomSelectorController.cloneRoom';

export default class AddProjectTeam extends LightningModal {

    @api parentRecordId;
    @api UserContext;

    @track projectTeams = [];
    itemsToDelete = [];
    showSpinner = false;

    get title() {
        return 'Add Project Team Members';
    }

    connectedCallback() {
        console.log('Add Project Team Members connectedCallback');
        this.addItem();
    }


    addItem() {
        let item = {};
        item.index = this.projectTeams.length + 1;
        item.errors = [];
        item.Project__c = this.parentRecordId;
        this.projectTeams.push(item);
    }

    removeItem(event) {
        console.log('removeItem');
        let index = event.target.dataset.index;
        console.log(index);
        index--;
        let item = this.projectTeams.splice(index, 1);
        if (item && item[0] && item[0].Id)
            this.itemsToDelete.push({ Id: item[0].Id });
        index = 1;
        this.projectTeams.forEach(item => {
            item.index = index++;
        });
    }

    handleItemChange(event) {
        console.log('handleItemChange');
        let field = event.target.dataset.field;
        let index = event.target.dataset.index;
        let value = event.target.value;

        console.log(index);
        console.log(field);
        console.log(value);

        let item = this.projectTeams.find(item => item.index == index);
        item[field] = value;

        console.log(this.projectTeams);
    }


    handleSave(event) {
        this.showSpinner = true;
        // If all fields aren't validated, throw error message
    if (!this.validateFields()) {
        /*let variant = 'error', title = 'Required Field', message = 'Review all error messages below to correct your data.';
        sforce.one.ShowToastEvent({title, message, variant});*/
        this.showSpinner = false;
    }
    // Otherwise submit save
    else {

        this.projectTeams.forEach(item => {
            let field = 'Project_Access__c';
            let projectAccessVal = this.template.querySelector('lightning-input-field[data-index="' + item.index + '"][data-field="' + field + '"]');
            item.Project_Access__c = projectAccessVal.value;
        });

        createOrUpdateProjectTeam({ projectTeams: this.projectTeams })
        .then(result => {    
            console.log('result:');
            console.log(result);            
            //title = 'Successfully saved record';            
            //variant = 'success';
            //this.cancelForm();
        }).catch(error => {
            let errorMsg = reduceErrors(error);
            if (errorMsg && errorMsg.includes(', '))
            {
                errorMsg = errorMsg.split(', ')[1];
            }
            console.log(error);
        }).finally(() => {
            this.showSpinner = false;
            //this.dispatchEvent(new ShowToastEvent({title, message, variant}));
            //this.itemsToDelete = [];
            //this.getItems();
        });
    }
    }

    validateFields() {
        return [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return (validSoFar && field.reportValidity());
        }, true);
    }


    cancel() {
        if (this.UserContext && (this.UserContext == 'Theme4t' || this.UserContext == 'Theme4d')) {
            console.log('VF in S1 or LEX');

            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    "recordId": this.parentRecordId,
                    "objectApiName": "Project__c",
                    "actionName": "view"
                },
            });

        }
    }


}