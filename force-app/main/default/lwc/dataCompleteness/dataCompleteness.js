import { LightningElement, api, track, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getFields from '@salesforce/apex/DataCompletenessController.getFields';

export default class DataCompleteness extends LightningElement {

    @api recordId;
    @track fieldSet;    
    showSpinner = false;

    @wire(getRecord, {
        recordId: "$recordId",
        fields: ["Id"]
    })
    wiredGetRecord({data, error}){
        if (data)
        {
            this.getFields();
        }        
    }

    connectedCallback()
    {
        //this.getFields();
    }

    get hasFields()
    {
        return this.fieldSet && (this.fieldSet.requiredFields.length || this.fieldSet.optionalFields.length) ? true : false;
    }

    get hasNoFields()
    {
        return this.fieldSet && (this.fieldSet.requiredFields.length === 0 && this.fieldSet.optionalFields.length === 0) ? true : false;
    }    

    getFields()
    {
        this.showSpinner = true;
        getFields({recordId: this.recordId})
        .then(result => {
            console.log(result);
            this.fieldSet = result;            
            let requiredFieldsIndex = 1;
            let optionalFieldsIndex = 1;
            this.fieldSet.requiredFields.forEach(i => {
                i.index = requiredFieldsIndex++
            });
            this.fieldSet.optionalFields.forEach(i => {
                i.index = optionalFieldsIndex++
            });
            this.showSpinner = false;            
        }).catch(error => {
            console.log(error);                
        }).finally(() => {
            this.showSpinner = false;                
        });
    }
}