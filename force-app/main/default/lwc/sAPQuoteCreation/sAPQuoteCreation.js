import { LightningElement, api, track, wire } from 'lwc';
import { gql, graphql, refreshGraphQL } from "lightning/uiGraphQLApi";
import { getRecord, updateRecord, getFieldValue } from 'lightning/uiRecordApi';
import getShipTo from '@salesforce/apex/QuoteCreationController.getShipTo';
import getIncoterm from '@salesforce/apex/QuoteCreationController.getIncoterm';
import sendQuoteToSAP from '@salesforce/apex/QuoteCreationController.sendQuoteToSAP';

import SALES_ORGANIZATION from '@salesforce/schema/Quote.Sales_Organization__c';
import SALES_OFFICE from '@salesforce/schema/Quote.Sales_Office__c';
import DIVISION from '@salesforce/schema/Quote.Division__c';
import DISTRIBUTION_CHANNEL from '@salesforce/schema/Quote.Distribution_Channel__c';
import PO_NUMBER from '@salesforce/schema/Quote.Customer_PO_Number__c';
import Z_DISCOUNT from '@salesforce/schema/Quote.zDiscount__c';
import INCOTERMS_2 from '@salesforce/schema/Quote.Incoterms_2__c';
import INCOTERMS_1 from '@salesforce/schema/Quote.Incoterms_1__c';
import SOLD_TO from '@salesforce/schema/Quote.AccountId';
import SHIP_TO from '@salesforce/schema/Quote.Ship_To__c';
import SAP_ACCOUNT_NUMBER from '@salesforce/schema/Quote.SAP_Account_Number__c';

import BILLING_STREET from '@salesforce/schema/Quote.BillingStreet';
import BILLING_CITY from '@salesforce/schema/Quote.BillingCity';
import BILLING_STATE from '@salesforce/schema/Quote.BillingState';
import BILLING_COUNTRY from '@salesforce/schema/Quote.BillingCountry';
import BILLING_POSTAL_CODE from '@salesforce/schema/Quote.BillingPostalCode';

import LightningModal from 'lightning/modal';
import dataTableModal from 'c/dataTableModal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class SAPQuoteCreation extends LightningModal {
  @api
  recordId;

  @track
  quote;

  poNumber;
  zDiscount;
  incoterms2

  @track
  isLoaded = false;
  showSpinner = false;
  
  shipTo;

  get shipToName() {
    return !this.shipTo ? '' : `${this.shipTo.Name} (${this.shipTo.overcast__SAP_BP_Number__c})`;
  }

  incoterms;

  get incotermsId() {
    return !this.incoterms ? '' : `${this.incoterms.INCO1}`;
  }

  @wire(getRecord, { recordId: '$recordId', fields: [SALES_ORGANIZATION, SALES_OFFICE, DIVISION, DISTRIBUTION_CHANNEL, PO_NUMBER, Z_DISCOUNT, INCOTERMS_2, SAP_ACCOUNT_NUMBER,
                                                    INCOTERMS_1, SOLD_TO, SHIP_TO, BILLING_STREET, BILLING_CITY, BILLING_STATE, BILLING_COUNTRY, BILLING_POSTAL_CODE] })
    getWiredRecord({ data, error }) {
        console.log('getWiredRecord');
        if (data) {
            console.log('DP record', data);
            this.quote = data;
            this.poNumber = getFieldValue(this.quote, PO_NUMBER)
            this.zDiscount = getFieldValue(this.quote, Z_DISCOUNT)
            this.incoterms2 = getFieldValue(this.quote, INCOTERMS_2)
            this.isLoaded = true;
        }
        if (error) {
            console.log(error);
        }
  }

  connectedCallback(){
  //   // document.addEventListener("DOMContentLoaded", function() {
  //   //   var button = document.querySelector('.shipTo');
  
  //   //   button.addEventListener('click', function() {
  //   //       // Your onclick event logic goes here
  //   //       alert('Button clicked!');
  //   //   });
  // });
  
  }

  handleInputChange(event) {
    let field = event.target.dataset.field;
    let value = event.target.value;
    console.log(field, value);
    try{
      switch(field) {      
        case 'Customer_PO_Number__c':          
            this.poNumber = value;          
            break;
        case 'zDiscount__c':          
            this.zDiscount = value;          
            break;
        case 'Incoterms_2__c':          
            this.incoterms2 = value;          
            break;
      }
    }
    catch(ex) {
      console.log(ex)
    }
  }

  async getIncoterms(event) {
    event.preventDefault();
    this.showSpinner = true;
    try{
      let incotermsList = await getIncoterm({languageCode:'E'});
      console.log('incotermsList', incotermsList);
          const result = await dataTableModal.open({
            // `label` is not included here in this example.
            // it is set on lightning-modal-header instead
            size: 'small',
            label: 'Select Incoterms',
            recordList: incotermsList,
            columns: [
              { label: "Incoterms", fieldName: "INCO1", type: "text", sortable: "false" },
              { label: "Description", fieldName: "BEZEI", type: "text", sortable: "false" },              
            ]            
        });
        this.showSpinner = false;
      // if modal closed with X button, promise returns result = 'undefined'
      // if modal closed with OK button, promise returns result = 'okay'
      console.log(result);  
      if ( result == undefined || result == 'canceled' ) return;    
      this.incoterms = result.selectedRow;

      }
    catch(ex) {
      console.log(ex);
    }
  }

  async getShipTo(event) {
    event.preventDefault();
    this.showSpinner = true;
    try{
      let accounts = await getShipTo({accSAPNumber:this.quote.fields.SAP_Account_Number__c.value});
      console.log('accounts', accounts);
          const result = await dataTableModal.open({
            // `label` is not included here in this example.
            // it is set on lightning-modal-header instead
            size: 'medium',
            label: 'Ship To Party',
            recordList: accounts,
            columns: [
              { label: "Partner Number", fieldName: "overcast__SAP_BP_Number__c", type: "text", initialWidth: 167, sortable: "false" },
              { label: "Partner Name", fieldName: "Name", type: "text", initialWidth: 167, sortable: "false" },
              { label: "Street", fieldName: "BillingStreet", type: "text", initialWidth: 167, sortable: "false" },
              { label: "City", fieldName: "BillingCity", type: "text", initialWidth: 167, sortable: "false" },
              { label: "State", fieldName: "BillingState", type: "text", initialWidth: 167, sortable: "false" },
              { label: "Postal Code", fieldName: "BillingPostalCode", type: "text", initialWidth: 167, sortable: "false" },
              { label: "Country", fieldName: "BillingCountry", type: "text", initialWidth: 167, sortable: "false" },
            ]            
        });
        this.showSpinner = false;
      // if modal closed with X button, promise returns result = 'undefined'
      // if modal closed with OK button, promise returns result = 'okay'
      console.log(result);  
      if ( result == undefined || result == 'canceled' ) return;    
      this.shipTo = result.selectedRow;

      }
    catch(ex) {
      console.log(ex);
    }
  }

  async handleCreateQuote() {
    this.showSpinner = true;
    try{
      const passer = this.template.querySelector('c-event-passer');    
      const input = {
        salesOrg: getFieldValue(this.quote, SALES_ORGANIZATION),
        salesOffice: getFieldValue(this.quote, SALES_OFFICE),
        division: getFieldValue(this.quote, DIVISION),
        disChannel: getFieldValue(this.quote, DISTRIBUTION_CHANNEL),
        discount: this.zDiscount,
        poNumber: this.poNumber,
        incoterm1: this.incotermsId,
        incoterms2: this.incoterms2,
        soldTo: getFieldValue(this.quote, SAP_ACCOUNT_NUMBER),
        shipTo: this.shipTo?.overcast__SAP_BP_Number__c
      }
      let result = await  sendQuoteToSAP({header:input, quoteId: this.recordId});      
      console.log(result);
      if( result.isSuccess === true ) {
        const event = new ShowToastEvent({
          title: "Success",
          message: `Quote ${result.quoteSAPId} is created in SAP successfully`,
          variant: "success"
        });
        passer.passEvent(event);
        // this.close('success');
        
      }
      else {
        const event = new ShowToastEvent({        
          title: 'Error',
          variant: 'error',
          message: result.errorMessages
        });
        passer.passEvent(event);
      }
    }
    catch(ex) {
      console.log(ex);
    }
    finally{
      this.showSpinner = false
    }
  }

}