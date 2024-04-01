/*
* Validate required fields and regex format before sanding to SAP
* @author ly.sirigalaya@kliqxe.com
* @since 20.02.2024
* @version 20.02.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 20.02.2024   ly.sirigalaya@kliqxe.com         Initial Version
*/

import { LightningElement, api, track, wire } from 'lwc';
import { getRecord,getFieldValue } from 'lightning/uiRecordApi';
import getFields from '@salesforce/apex/DataCompletenessController.getFields';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import BILLINGCOUNTRYCODE_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import { reduceErrors } from 'c/utils';
//import { parsePhoneNumberFromString } from 'libphonenumber-js';

export default class DataCompleteness extends LightningElement {

    @api recordId;
    @track fieldSet;
    showSpinner = false;

    validationMessages = {
        taxNumber: {
            invalid: 'Invalid Tax number.',
            valid: 'Valid Tax number.'
        },
        phone: {
            invalid: 'Invalid Phone Number.',
            valid: 'Valid Phone Number.'
        },
    };


    @wire(getRecord, {
        recordId: "$recordId",
        fields: ["Id"]
    })
    wiredGetRecord({ data, error }) {
        console.log('getRecord => ', data, error);
        if (data) {
            //this.countryCode = getFieldValue(data, BILLINGCOUNTRYCODE_FIELD);
            this.getFields();
        }
        else if (error) 
        {
            console.error('getRecord ERROR => ', JSON.stringify(error)); // handle error properly
        }
        
    }

    connectedCallback() {
        //this.getFields();
    }

    get hasFields() {
        return this.fieldSet && (this.fieldSet.requiredFields.length || this.fieldSet.optionalFields.length) ? true : false;
    }

    get hasNoFields() {
        return this.fieldSet && (this.fieldSet.requiredFields.length === 0 && this.fieldSet.optionalFields.length === 0) ? true : false;
    }

    getFields() {
        this.showSpinner = true;
        getFields({ recordId: this.recordId })
            .then(result => {
                console.log(result);
                this.fieldSet = result;
                let requiredFieldsIndex = 1;
                let optionalFieldsIndex = 1;
                this.fieldSet.requiredFields.forEach(i => {
                    i.index = requiredFieldsIndex++
                    if (i.regex && i.value) {
                        i.description = i.name == 'Tax_Number__c'  ? this.validateTaxNumber(i.regex, i.value) : i.description;
                        i.description = i.name == 'Phone' ? this.validatePhone(i.regex, i.value): i.description;
                    }

                    /*if(i.name == 'Email__c' ){
                        i.description = i.value ? this.validateEmail(i.value) : i.description;
                    }*/

                    
                });
                this.fieldSet.optionalFields.forEach(i => {
                    i.index = optionalFieldsIndex++
                    if (i.regex && i.value) {
                        i.description = i.name == 'Tax_Number__c'  ? this.validateTaxNumber(i.regex, i.value) : i.description;
                        i.description = i.name == 'Phone' ? this.validatePhone(i.regex, i.value): i.description;
                    }
                });
            }).catch(error => this.handleError(error)) 
            .finally(() => { this.showSpinner = false; });
    }

    validateEmail(email) {
        const regex = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

        if (regex.test(email)) {
            return 'Valid Email.'
        } else {
            return 'Invalid Email.';
        }
    }

    validateTaxNumber(regexStr, value) {
        return new RegExp(regexStr).test(value) ?
            this.validationMessages.taxNumber.valid :
            this.validationMessages.taxNumber.invalid;
    }

    validatePhone(regexStr, value) {
        // Consider a robust library like 'libphonenumber-js' here as well
        return new RegExp(regexStr).test(value) ?
            this.validationMessages.phone.valid :
            this.validationMessages.phone.invalid;
    }

    handleError(error) {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Error',
            message: reduceErrors(error),
            variant: 'error'
        }));
    }

        /* AU Phone
        +61(02)89876544
+61 2 8986 6544
02 8986 6544
+61289876544
0414 570776
0414570776
0414 570 776
04 1457 0776
+61 414 570776
+61 (04)14 570776
+61 (04)14-570-776
0416 227 040
*/

        /*
            const parsedNumber = parsePhoneNumberFromString(phoneNumber, 'US'); // Replace with your target country code

        if (!parsedNumber.isValid()) {
            this.validationMessage = 'Invalid phone number format.';
        } else {
            this.validationMessage = 'Phone number is valid.';
        }
      */
    
}