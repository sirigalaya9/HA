import { LightningElement, wire } from 'lwc';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import IDEA_OBJECT from "@salesforce/schema/Idea__c";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class Request extends NavigationMixin (LightningElement) {

    showSpinner;

    @wire(getObjectInfo, { objectApiName: IDEA_OBJECT })
    objectInfo;
  

    handleLoad()
    {
        this.showSpinner = false;
    }

    handleCancel()
    {
        //this.currentStep--;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if(field.name === "Category__c") {
                    field.reset();
                }
            });
        }        
    }

    handleSubmit(event)
    {
        console.log('handleSubmit');
        this.showSpinner = true;
    }

    handleError(event)
    {
        console.log('handleError');
        this.showSpinner = false;
    }    

    handleSuccess(event)
    {
        this.showSpinner = false;
        console.log('handleSuccess', JSON.parse(JSON.stringify(event.detail)));
        const evt = new ShowToastEvent({
            title: 'Idea created',
            //message: 'Request Number: ' + event.detail.fields.Name,
            variant: 'success',
        });
        this.dispatchEvent(evt);  
        this.navigate(event.detail.id);        
        this.handleClose();
    }

    handleClose()
    {
        this.handleCancel();
        this.dispatchEvent(new CustomEvent('close'));        
    }

    navigate(id) 
    {               
        console.log('navigate', id);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: id,                
                actionName: 'view'
            }
        }, true);
    }
}