import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Navigate extends NavigationMixin(LightningElement) {

    @api objectApiName;
    @api recordId;
    @api actionName;
    @api showChoice;
    @api choiceLabel1;
    @api choiceLabel2;
    @api recordId2;

    navigate() 
    {
        console.log('navigate');
        /*
        let defaultValuesObj = {};
        defaultValuesObj[this.parentFieldAPIName] = this.recordId;
        const defaultValues = encodeDefaultFieldValues(defaultValuesObj);
        */

        if (this.actionName == 'edit')
        {
            this[NavigationMixin.Navigate]({
                type: 'standard__objectPage',
                attributes: {
                    objectApiName: this.objectApiName,
                    actionName: this.actionName,
                    recordId: this.recordId
                }
            }); 
        }            
        else if (this.actionName == 'view')
        {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {                    
                    actionName: this.actionName,
                    recordId: this.recordId
                }
            }); 
        }
    }

    renderedCallback()
    {
        if (this.objectApiName && this.recordId && this.actionName)
        {
            console.log('renderedCallback', this.objectApiName, this.recordId);
        }
    }

    connectedCallback() 
    {
        if (this.objectApiName && this.recordId && this.actionName && !this.showChoice)
        {
            console.log('connectedCallback', this.objectApiName, this.recordId);
            this.navigate();
        }
    }

    handleChoice(event)
    {
        console.log('handleChoice', event.target.value);
        if (event.target.value === 'choice1')
        {            
            this.navigate();
        }
        else
        {
            this.recordId = this.recordId2;
            this.navigate();
        }
    }
}