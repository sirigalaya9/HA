import { LightningElement, api, track, wire } from 'lwc';
import { gql, graphql, refreshGraphQL } from "lightning/uiGraphQLApi";
import { getRecord, getFieldValue, notifyRecordUpdateAvailable, deleteRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import getShipTo from '@salesforce/apex/QuoteCreationController.getShipTo';
import getIncoterm from '@salesforce/apex/QuoteCreationController.getIncoterm';
import sendQuoteToSAP from '@salesforce/apex/QuoteCreationController.sendQuoteToSAP';
import getReasons from '@salesforce/apex/QuoteCreationController.getReasons';

import SALES_ORGANIZATION from '@salesforce/schema/Quote.Opportunity.Sales_Organization__c';
import SALES_OFFICE from '@salesforce/schema/Quote.Sales_Office__c';
import DIVISION from '@salesforce/schema/Quote.Division__c';
import DISTRIBUTION_CHANNEL from '@salesforce/schema/Quote.Distribution_Channel__c';
import PO_NUMBER from '@salesforce/schema/Quote.Customer_PO_Number__c';
import Z_DISCOUNT from '@salesforce/schema/Quote.Header_Discount__c';
import INCOTERMS_2 from '@salesforce/schema/Quote.Incoterms_2__c';
import INCOTERMS_1 from '@salesforce/schema/Quote.Incoterms_1__c';
import SOLD_TO from '@salesforce/schema/Quote.AccountId';
import SHIP_TO from '@salesforce/schema/Quote.Ship_To__c';
import SAP_ACCOUNT_NUMBER from '@salesforce/schema/Quote.SAP_Account_Number__c';
import QUOTE_REASON from '@salesforce/schema/Quote.Quote_Reason__c';
import DOCUMENT_TYPE from '@salesforce/schema/Quote.Document_Type__c';
import NAME from '@salesforce/schema/Quote.Name';
import REQUESTED_DELIVERY_DATE from '@salesforce/schema/Quote.Requested_Delivery_Date__c';
import GROSS_PROFIT from '@salesforce/schema/Quote.Gross_Profit__c';
import CURRENCYISOCODE from '@salesforce/schema/Quote.CurrencyIsoCode';

import BILLING_STREET from '@salesforce/schema/Quote.BillingStreet';
import BILLING_CITY from '@salesforce/schema/Quote.BillingCity';
import BILLING_STATE from '@salesforce/schema/Quote.BillingState';
import BILLING_COUNTRY from '@salesforce/schema/Quote.BillingCountry';
import BILLING_POSTAL_CODE from '@salesforce/schema/Quote.BillingPostalCode';

import LightningModal from 'lightning/modal';
import dataTableModal from 'c/dataTableModal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import { reduceErrors } from 'c/utils';
export default class SAPQuoteCreation extends LightningModal {
  @api
  recordId;

  @track
  quote;

  poNumber;
  zDiscount;
  incoterms2;
  incoterms;
  reqDeliveryDate;
  quoteReason;
  documentType = 'ZQS';
  grossProfit;
  currencyIsoCode;
  sapQuoteNumber;

  @track
  isLoaded = false;
  showSpinner = false;

  shipTo;

  get shipToName() {
    return !this.shipTo ? '' : `${this.shipTo.Name} (${this.shipTo.overcast__SAP_BP_Number__c})`;
  }

  get incotermsId() {
    if (this.incoterms) {
      if (this.incoterms.BEZEI) {
        return `${this.incoterms.BEZEI} (${this.incoterms.INCO1})`;
      }
      else {
        return `${this.incoterms.INCO1}`;
      }
    }
    else return '';
  }

  get quoteReasonId() {
    return !this.quoteReason ? '' : `${this.quoteReason.BEZEI} (${this.quoteReason.AUGRU})`;
  }

  get grossProfitHeader() {
    return this.grossProfit;
  }

  get salesOrgName() {
    return !this.salesOrg ? '' : this.salesOrg.displayValue;
    //return !this.salesOrg ? '' : `${this.salesOrg.displayValue} (${this.salesOrg.value})`;
  }

  @wire(getRecord, {
    recordId: '$recordId', fields: [NAME, CURRENCYISOCODE, SALES_ORGANIZATION, SALES_OFFICE, DIVISION, DISTRIBUTION_CHANNEL, PO_NUMBER, Z_DISCOUNT, INCOTERMS_2, SAP_ACCOUNT_NUMBER, DOCUMENT_TYPE,
      INCOTERMS_1, SOLD_TO, SHIP_TO, BILLING_STREET, BILLING_CITY, BILLING_STATE, BILLING_COUNTRY, BILLING_POSTAL_CODE, QUOTE_REASON, REQUESTED_DELIVERY_DATE, GROSS_PROFIT]
  })
  getWiredRecord({ data, error }) {
    console.log('getWiredRecord');
    if (data) {
      console.log('DP record', data);
      this.quote = data;
      this.poNumber = getFieldValue(this.quote, NAME)
      this.zDiscount = getFieldValue(this.quote, Z_DISCOUNT)
      this.incoterms2 = getFieldValue(this.quote, INCOTERMS_2)
      this.quoteReason = getFieldValue(this.quote, QUOTE_REASON)
      this.reqDeliveryDate = getFieldValue(this.quote, REQUESTED_DELIVERY_DATE)
      this.salesOrg = data.fields.Opportunity.value.fields.Sales_Organization__c;

      if (!this.salesOrg) {
        alert('No Sales Org');
      }
      else {
        this.isLoaded = true;
      }
    }
    if (error) {
      console.log(error);
    }
  }

  connectedCallback() {
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
    try {
      switch (field) {
        case 'Customer_PO_Number__c':
          this.poNumber = value;
          break;
        case 'Header_Discount__c':
          this.zDiscount = parseFloat(value);
          break;
        case 'Incoterms_2__c':
          this.incoterms2 = value;
          break;
        case 'Requested_Delivery_Date__c':
          this.reqDeliveryDate = value;
          break;
      }
    }
    catch (ex) {
      console.log(ex)
    }
  }

  async getIncoterms(event) {
    event.preventDefault();
    this.showSpinner = true;
    try {
      let incotermsList = await getIncoterm({ languageCode: 'E' });
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
      if (result == undefined || result == 'canceled') return;
      this.incoterms = result.selectedRow;

    }
    catch (ex) {
      console.log(ex);
    }
  }

  async getReason(event) {
    event.preventDefault();
    this.showSpinner = true;
    try {
      let reasonList = await getReasons({ languageCode: 'E' });
      console.log('reasonList', reasonList);
      const result = await dataTableModal.open({
        // `label` is not included here in this example.
        // it is set on lightning-modal-header instead
        size: 'small',
        label: 'Select Quote Reason',
        recordList: reasonList,
        columns: [
          { label: "Quote Reason", fieldName: "AUGRU", type: "text", sortable: "false" },
          { label: "Description", fieldName: "BEZEI", type: "text", sortable: "false" },
        ]
      });
      this.showSpinner = false;
      // if modal closed with X button, promise returns result = 'undefined'
      // if modal closed with OK button, promise returns result = 'okay'
      console.log(result);
      if (result == undefined || result == 'canceled') return;
      this.quoteReason = result.selectedRow;

    }
    catch (ex) {
      console.log(ex);
    }
  }

  async getShipTo(event) {
    event.preventDefault();
    this.showSpinner = true;
    try {
      let accounts = await getShipTo({ accSAPNumber: this.quote.fields.SAP_Account_Number__c.value });
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
      if (result == undefined || result == 'canceled') return;
      this.shipTo = result.selectedRow;

    }
    catch (ex) {
      console.log(ex);
    }
  }

  handleReturnData(event) {
    //this.showSpinner = true;
    const _returnData = event.detail;
    console.log('Simulate ReturnData', _returnData);
    if (_returnData && _returnData.E_HEADER) {
      this.grossProfit = _returnData.E_HEADER.CONTRIBUTION_MARGIN_ABS;
      this.incoterms = {};
      this.incoterms.INCO1 = _returnData.E_HEADER.INCO1;
      this.incoterms2 = _returnData.E_HEADER.INCO2;

    }


    console.log('grossProfit', this.grossProfit);
  }

  handleCreateQuote() {
    console.log('handleCreateQuote');
    this.template.querySelector('c-quote-products').handleCreateQuote();
  }

  async createQuote(event) {

    const _items = event.detail;
    console.log('items', _items);
    const passer = this.template.querySelector('c-event-passer');

    let isValid = [...this.template.querySelectorAll("lightning-input-field")].reduce((validSoFar, field) => {
      return (validSoFar && field.reportValidity());
    }, true);

    if (!this.quoteReason || !this.quoteReason.AUGRU) {
      isValid = false;
      const event = new ShowToastEvent({ title: 'Quote Reason is required', variant: 'error', message: 'Please populate Quote Reason before Send to SAP' });
      passer.passEvent(event);
    }
    else if (!this.incoterms || !this.incoterms.INCO1) {
      isValid = false;
      const event = new ShowToastEvent({ title: 'Incoterms is required', variant: 'error', message: 'Please populate Incoterms before Send to SAP' });
      passer.passEvent(event);
    }
    else if (!this.shipTo) {
      isValid = false;
      const event = new ShowToastEvent({ title: 'Ship To is required', variant: 'error', message: 'Please populate Ship To before Send to SAP' });
      passer.passEvent(event);
    }

    if (!isValid) {
      return;
    }

    try {
      this.showSpinner = true;
      const input = {
        salesOrg: getFieldValue(this.quote, SALES_ORGANIZATION),
        salesOffice: getFieldValue(this.quote, SALES_OFFICE),
        division: getFieldValue(this.quote, DIVISION),
        disChannel: getFieldValue(this.quote, DISTRIBUTION_CHANNEL),
        soldTo: getFieldValue(this.quote, SAP_ACCOUNT_NUMBER),
        quoteRef: getFieldValue(this.quote, NAME),
        currencyIsoCode: getFieldValue(this.quote, CURRENCYISOCODE),

        headerdiscount: this.zDiscount,
        incoterm1: this.incoterms.INCO1,
        incoterm2: this.incoterms2,
        shipTo: this.shipTo?.overcast__SAP_BP_Number__c,
        reason: this.quoteReason.AUGRU,
        reqDeliveryDate: this.reqDeliveryDate,
        docType: this.documentType

      }
      let items = _items.map(item => {
        return {
          Id: item.Id,
          Base_Price__c: item.Base_Price__c,
          Delivery_Date__c: item.Delivery_Date__c,
          Description: item.Description,
          Gross_Profit__c: item.Gross_Profit__c,
          ListPrice: item.ListPrice,
          PricebookEntryId: item.PricebookEntryId,
          Product2Id: item.Product2Id,
          Product2: item.Product2,
          QuoteId: item.QuoteId,
          Std_Price__c: item.Std_Price__c,
          Rejected__c: item.Rejected__c,
          TotalPrice: item.TotalPrice,
          UnitPrice: item.UnitPrice,
          is_SAP_Price__c: item.is_SAP_Price__c,
          Manual_Price__c: item.Manual_Price__c,
          Discount__c: item.Discount__c,
          Quantity: item.Quantity,
          SAP_UOM__c: item.SAP_UOM__c
        }
      });
      console.log('items', items, input);
      let results = await sendQuoteToSAP({ header: input, quoteItems: items, quoteId: this.recordId });
      console.log(results);
      if (results) {
        this.sapQuoteNumber = null;
        if (results.E_HEADER.ORDNO) {
          this.sapQuoteNumber = results.E_HEADER.ORDNO;
          const event = new ShowToastEvent({
            title: "Success",
            message: 'Quotation ' + this.sapQuoteNumber + ' is created in SAP successfully',
            variant: "success"
          });
          passer.passEvent(event);

        }

        let returnMessage = '';
        results.ET_MSG_OUT.forEach(msgOut => {
          if (msgOut.MESSAGE) {
            returnMessage += msgOut.MESSAGE + '=> \n';
          }
        })
        console.log('returnMessage', returnMessage);

        const fields = {};
        fields['Id'] = this.recordId;
        fields['SAP_Quote_Number__c'] = this.sapQuoteNumber ? this.sapQuoteNumber : null;
        fields['Return_Logs__c'] = returnMessage;
        const recordInput = { fields };
        console.log(recordInput);
        updateRecord(recordInput)
          .then(updateRecord => {
            //console.log(updateRecord);
            //title = 'Successfully updated SAP Quote Number';
            //variant = 'success';
          })
          .catch(error => {
            title = 'Error updated record';
            message = reduceErrors(error);
            variant = 'error';
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
          }).finally(() => {
            this.showSpinner = false;
          });

        this.handleShowMessage(returnMessage);


        // this.close('success');

      }
      else {
        const event = new ShowToastEvent({
          title: 'Error',
          variant: 'error',
          message: 'No response'
        });
        passer.passEvent(event);
      }
    }
    catch (ex) {
      console.log(ex);
    }
    finally {
      this.showSpinner = false
    }
  }

  async handleShowMessage(returnMessage) {
    const result = await LightningConfirm.open({
      message: returnMessage,
      variant: 'header',
      label: 'Status',
    });
    /*if (result && sapQuoteNumber) {
      this.showSpinner = true;
      const fields = {};
      fields['Id'] = this.recordId;
      fields['SAP_Quote_Number__c'] = sapQuoteNumber;
      fields['Return_Logs__c'] = returnMessage;
      const recordInput = { fields };
      console.log(recordInput);
      updateRecord(recordInput)
        .then(updateRecord => {
          console.log(updateRecord);
          title = 'Successfully updated SAP Quote Number';
          variant = 'success';
        })
        .catch(error => {
          title = 'Error updated record';
          message = reduceErrors(error);
          variant = 'error';
        }).finally(() => {
          this.showSpinner = false;
          this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        });
    }*/
  }

}