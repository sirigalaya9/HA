/*
* Custom Quote Product Screen controller methods to query and save QuoteLineItem for Mobile
* @author ly.sirigalaya@kliqxe.com
* @since 20.02.2024
* @version 20.02.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 20.02.2024   ly.sirigalaya@kliqxe.com         Initial Version
*/
import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, getFieldValue, notifyRecordUpdateAvailable, deleteRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CURRENCYISOCODE_FIELD from '@salesforce/schema/Quote.CurrencyIsoCode';
import PRICEBOOK_FIELD from '@salesforce/schema/Quote.Pricebook2Id';
import SALESORG_CODE_FIELD from '@salesforce/schema/Quote.Sales_Org_Code__c';
import SAP_QUOTE_NUMBER_FIELD from '@salesforce/schema/Quote.SAP_Quote_Number__c';
import ACC_LANGUAGE_CODE from '@salesforce/schema/Quote.Account.Language__c';
import getItems from '@salesforce/apex/QuoteProductController.getItems';
import getPriceATP from '@salesforce/apex/QuoteProductController.getPriceATP';
import getProducts from '@salesforce/apex/ProductLookupController.getProducts';
import saveItems from '@salesforce/apex/QuoteProductController.saveItems';
import { reduceErrors } from 'c/utils';
import LightningConfirm from 'lightning/confirm';
import { labels } from './labels.js';
import QUOTELINEITEM_OBJECT from '@salesforce/schema/QuoteLineItem';
import PRODUCT2_OBJECT from '@salesforce/schema/Product2';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';


export default class QuoteProductMobile extends LightningElement {

    label = {
        CheckPricingAvailability: labels.CheckPricingAvailability,
        Add: labels.Add,
        Refresh: labels.Refresh,
        Save: labels.Save,
        TotalAmount: labels.TotalAmount,
        No: labels.No,
        Remove: labels.Remove
    };

    _recordId;
    @api
    set recordId(val) {
        console.log('recordId: ' + val);
        this._recordId = val;
        if (val)
            this.getItems();
        else {
            this.items = [];
            this.itemsToDelete = [];
        }
        this.defaultResultsInitialized = false;
    }
    get recordId() {
        return this._recordId;
    }

    currencyIsoCode;
    pricebookId;
    salesOrgCode;
    SAPQuoteNumber;
    languageCode;

    itemsToDelete = [];
    productFields;
    qliObjInfos;
    qliFields;

    disabledCheckPricing;
    isQuoteLocked;

    showSpinner = false;
    @track selectedItem = [];
    @track items = [];
    lineItemEdit = false;
    lineItemAddEdit = false;

    connectedCallback() {
        console.log('connectedCallback');
    }

    get totalAmount() {
        var val = 0;
        if (this.items) {
            this.items.forEach(item => {
                val += item.TotalPrice ? item.TotalPrice : 0;
            });
        }
        return val;
    }

    get numberOfRecords() {
        return this.items != null ? this.items.length : 0;
    }

/*     get isQuoteLocked() {
        return this.SAPQuoteNumber != null  ? true : false;
    } */
    isQuoteLocked;

    get isCheckPricingLocked() {
        return this.disabledCheckPricing || this.isQuoteLocked ? true : false;
    }

    get hasQLIFields() {
        return (this.qliObjInfos && this.qliFields && this.productFields)? true : false;
    }

    @wire(getObjectInfo, { objectApiName: QUOTELINEITEM_OBJECT })
    getObjectInfo({ data, error }) {
        if (data) {
            this.qliObjInfos = data;
            this.qliFields = data.fields;
            console.log('qliObjInfos => ', data);
        } else if (error) {
            console.error('qliObjInfos ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }

    @wire(getObjectInfo, { objectApiName: PRODUCT2_OBJECT })
    getProductObjInfos({ data, error }) {
        if (data) {
            this.productFields = data.fields;
            console.log('productFields => ', this.productFields);
        } else if (error) {
            console.error('productObjInfos ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [CURRENCYISOCODE_FIELD, PRICEBOOK_FIELD, SALESORG_CODE_FIELD, SAP_QUOTE_NUMBER_FIELD, ACC_LANGUAGE_CODE] })
    getRecord({ data, error }) {
        console.log('getRecord => ', data, error);
        if (data) {
            this.currencyIsoCode = getFieldValue(data, CURRENCYISOCODE_FIELD);
            this.pricebookId = getFieldValue(data, PRICEBOOK_FIELD);
            this.salesOrgCode = getFieldValue(data, SALESORG_CODE_FIELD);
            this.SAPQuoteNumber =  getFieldValue(data, SAP_QUOTE_NUMBER_FIELD);
            this.languageCode = getFieldValue(data, ACC_LANGUAGE_CODE);
            this.getItems();
            console.log('this.salesOrgCode', this.salesOrgCode);
            console.log('wire getRecord\'s SAPQUOTENUMBER',getFieldValue(data, SAP_QUOTE_NUMBER_FIELD) )
            this.isQuoteLocked = this.SAPQuoteNumber != null  ? true : false;
            console.log('isQuoteLocked in getRecord!', this.isQuoteLocked);
        }
        else if (error) {
            console.error('getRecord ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }

    products;
    @wire(getProducts, { recordId: '$recordId', currencyIsoCode: '$currencyIsoCode', pricebookId: '$pricebookId', salesOrgCode: '$salesOrgCode',languageCode: '$languageCode' })
    wiredProducts({ error, data }) {
        if (data) {
            this.products = data;
            //this.initLookupDefaultResults();
        } else if (error) {
            console.log(error);
        }
    }

    handleDeleteClick(event) {
        this.handleConfirmClick(event.currentTarget.dataset.index);
    }

    async handleConfirmClick(index) {
        let item = this.items.find(i => i.index == index);
        let productName = '"' + item.Product2.Name + '"';
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to delete? ' + productName,
            variant: 'headerless',
            label: 'Delete Opp Item',
        });
        if (result) {
            this.deleteLineItem(item.Id);
        }
    }

    async deleteLineItem(recordId) {
        this.showSpinner = true;
        deleteRecord(recordId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Successfully deleted record",
                        variant: "success",
                    }),
                );
            })
            .catch((error) => {
                this.showSpinner = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error deleting record",
                        message: error.body.message,
                        variant: "error",
                    }),
                );
            }).finally(() => {
                this.showSpinner = false;
                this.getItems();
            });
    }

    addItem() {
        this.selectedItem = {};
        this.selectedItem.index = this.items.length + 1;
        this.selectedItem.errors = [];
        this.selectedItem.selection = null;
        this.selectedItem.Product2 = {};
        this.selectedItem.isadd = true;
        this.lineItemAddEdit = true;
        //this.items.push(item);
        //this.defaultResultsInitialized = false; 
        //this.initLookupDefaultResults();
    }

    getItems() {
        console.log('getItems');
        this.showSpinner = true;
        getItems({ recordId: this.recordId })
            .then(result => {
                console.log('result:');
                console.log(result);
                this.items = JSON.parse(JSON.stringify(result));
                let index = 1;
                this.items.forEach(item => {
                    item.index = index++;
                    item.url = '/' + item.Id;
                    item.errors = [];
                    item.UnitPrice = parseFloat(item.UnitPrice).toFixed(2);
                    item.selection = {
                        id: item.PricebookEntryId,
                        sObjectType: 'Product2',
                        icon: 'standard:product',
                        title: item.Product2.Product_Code_Format__c,
                        subtitle: item.Product2.Description,
                    };
                    item.rejectedClass = item.Rejected__c ? 'rejected' : '';
                    item.disabledRemove = this.isQuoteLocked ? true : false;
                });
            }).catch(error => {
                console.log(error);
            }).finally(() => {
                this.showSpinner = false;
                this.disabledCheckPricing = false;
            });
    }


    handleSearch(event) {
        console.log('handleSearch');
        let index = event.target.dataset.index;
        let searchTerm = event.detail.searchTerm;
        console.log(index + '>' + searchTerm);
        if (searchTerm) {
            searchTerm = '%' + searchTerm + '%';
            getProducts({ recordId: this.recordId, currencyIsoCode: this.currencyIsoCode, pricebookId: this.pricebookId, searchTerm: searchTerm, salesOrgCode: this.salesOrgCode,languageCode: this.languageCode })
                .then(result => {
                    let results = [];
                    result.forEach(item => {
                        let result = {
                            id: item.PricebookEntries[0].Id,
                            sObjectType: 'Product2',
                            icon: 'standard:product',
                            title: item.Product_Code_Format__c,
                            subtitle: item.Description,
                            productCode: item.ProductCode,
                            listPrice: item.PricebookEntries[0].UnitPrice,
                            description : item.Description
                        };
                        results.push(result);
                    });

                    this.template.querySelector('c-lookup[data-index="' + index + '"][data-name="Product2Id"]').setSearchResults(results);
                }).catch(error => {
                    console.log(error);
                }).finally(() => {
                    this.showSpinner = false;
                });
        }
        else {
            //this.initLookupDefaultResults();
        }
    }

    handleSelectionChange(event) {
        console.log('handleSelectionChange');
        let index = event.target.dataset.index;
        let value = event.detail[0];
        console.log(index);
        console.log(value);
        let item = this.selectedItem;
        const selection = event.target.getSelection();
        console.log('selection', selection);
        if (value) {
            item.selection = selection[0];
            item.PricebookEntryId = value;
            item.ListPrice = selection[0].listPrice;
            item.UnitPrice = selection[0].listPrice;     
            item.Description = selection[0].description;       
            item.Product2.ProductCode = selection[0].productCode;
            item.Product2Id = selection[0].productId;
            console.log(item);
        }
        else {
            //item.Product2Id = null;
            item.selection = null;
            item.PricebookEntryId = null;
            item.ListPrice = null;
            item.UnitPrice = null;
            item.Cost_Per_Item__c = null;
            item.Standard_Multiplier__c = null;
            item.Supported_Price__c = null;
            item.Description = null;
            item.UnitPrice = null;
            item.Multiplier__c = null;
            item.Quantity = null;
            item.TotalPrice = null;
            item.Margin_Percentage__c = null;
            item.Discount__c = null;
            item.Product2 = {};
        }
        //this.initLookupDefaultResults();     
    }


    handleTileClick(event) {
        this.lineItemAddEdit = true;
        let index = event.currentTarget.dataset.index;
        this.selectedItem = this.items[index - 1];
        console.log(this.selectedItem);
    }

    handleItemChange(event) {
        console.log('handleItemChange');
        let index = event.target.dataset.index;
        let field = event.target.dataset.field;
        let value = Array.isArray(event.detail.value) ? event.detail.value[0] : event.detail.value;
        console.log('Row ' + index + ' : ' + field + ' = ' + value);
        let item = this.selectedItem;
        item[field] = value;
        console.log(item);
        if (item.UnitPrice && field === 'UnitPrice') {
            item.Discount__c = item.ListPrice ? parseFloat((1 - (item.UnitPrice / item.ListPrice)) * 100).toFixed(2) : 0;
        }

        if (item.Discount__c && field === 'Discount__c') {
            //item.UnitPrice = parseFloat(item.List_Price__c - (item.List_Price__c * item.Discount__c/100)).toFixed(2);
            item.UnitPrice = item.ListPrice ? parseFloat(item.ListPrice * (1 - item.Discount__c / 100)).toFixed(2) : 0;
        }

        if (value && (field === 'Quantity' || field === 'UnitPrice' || field === 'Discount__c')) {
            item.TotalPrice = item.UnitPrice * item.Quantity;
        }
    }

    handleCancelEditItems() {
        this.lineItemAddEdit = false;
        // don't have to set this.selectedItem = {}, because next tile click or addition of new item would set the value for it.
    }

    handleSaveItems(event) {
        let isAdd = event.currentTarget.dataset.add;
        this.saveItems(isAdd);
    }

    saveItems(isAdd) {
        console.log('saveItems');
        console.log(this.selectedItem);
        let title, message, variant;

        if (!this.selectedItem.PricebookEntryId) {
            let variant = 'error', title = 'Required Product', message = 'Please enter Product';
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        }

        if (!this.selectedItem.PricebookEntryId) {
            return;
        }

        this.showSpinner = true;
        const fields = {};

        fields['Quantity'] = this.selectedItem.Quantity;
        fields['UnitPrice'] = this.selectedItem.UnitPrice;
        fields['Description'] = this.selectedItem.Description;
        fields['Discount__c'] = this.selectedItem.Discount__c;
        fields['is_SAP_Price__c'] = false;
        const recordInput = { fields };

        if (Boolean(isAdd) === true) {
            fields['QuoteId'] = this.recordId;
            fields['PricebookEntryId'] = this.selectedItem.PricebookEntryId;
            fields['Product2Id'] = this.selectedItem.Product2Id;
            //fields['CurrencyIsoCode'] = this.currencyIsoCode;
            recordInput.apiName = 'QuoteLineItem';
            console.log(recordInput);
            createRecord(recordInput)
                .then(createdRecord => {
                    console.log(createdRecord);
                    title = 'Successfully created record';
                    variant = 'success';
                })
                .catch(error => {
                    title = 'Error created record';
                    message = reduceErrors(error);
                    variant = 'error';
                    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
                    this.showSpinner = false;
                }).finally(() => {
                    this.showSpinner = false;
                    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
                    this.getItems();
                    this.lineItemAddEdit = false;
                    this.selectedItem = [];
                });
        }
        else {
            recordInput.fields['Id'] = this.selectedItem.Id;
            recordInput.fields['UnitPrice'] = 0;
            console.log(recordInput);
            updateRecord(recordInput)
                .then(updateRecord => {
                    console.log(updateRecord);
                    title = 'Successfully updated record';
                    variant = 'success';
                })
                .catch(error => {
                    title = 'Error updated record';
                    message = reduceErrors(error);
                    variant = 'error';
                    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
                    this.showSpinner = false;
                }).finally(() => {
                    this.showSpinner = false;
                    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
                    this.getItems();
                    this.lineItemAddEdit = false;
                    this.selectedItem = [];
                });
        }
    }


    saveItemsTwo(){ //will be merged with saveItems above, but for now temporarily using another method
        let title, message, variant;
        let items = JSON.parse(JSON.stringify(this.items));
        this.showSpinner = true;
        items.forEach(item => {
            item.UnitPrice = parseFloat(item.UnitPrice);
            item.Discount__c = parseFloat(item.Discount__c);
            item.List_Price__c = parseFloat(item.List_Price__c);
            delete item.selection;
            delete item.errors;
            delete item.productResults;
            delete item.TotalPrice;
            delete item.Product2;
            if (!item.QuoteId) {
                item.QuoteId = this.recordId;
            }
        });
        console.log('before save items apex');
        saveItems({ items: items, itemsToDelete: this.itemsToDelete })
            .then(result => {
                console.log('then of saveitems apex');
                console.log('result:');
                console.log(result);
                this.itemsToDelete = [];
                title = 'Successfully saved record';
                variant = 'success';
                this.getItems();
            }).catch(error => {
                console.log('catch of saveitems apex');
                console.log(error);
                title = 'Error saving record';
                message = reduceErrors(error);
                variant = 'error';
            }).finally(() => {
                console.log('finally of saveitems apex');
                this.showSpinner = false;
                //this.dispatchEvent(new RefreshEvent());
                this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
                notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
            });
    }

    handleCheckPrice() {
        this.showSpinner = true;
        let title, message, variant;
        let items = JSON.parse(JSON.stringify(this.items));
        items.forEach(item => {
            delete item.selection;
            delete item.errors;
            delete item.productResults;
            if (!item.QuoteId) {
                item.QuoteId = this.recordId;
            }
        });
        getPriceATP({ recordId: this.recordId, quoteItems: items })
            .then(results => {
                console.log('handleCheckPrice ', results);
                if (results && results.isSuccess) {
                    this.items.forEach(item => {

                        results.data.forEach(result => {
                            if (item.Product2.ProductCode == result.productCode) {
                                item.List_Price__c = parseFloat(result.unitPrice).toFixed(2);
                                item.UnitPrice = parseFloat(result.unitPrice).toFixed(2);
                                item.Delivery_Date__c = result.deliveryDate;
                                item.is_SAP_Price__c = true;
                                item.TotalPrice = item.Quantity * item.UnitPrice;
                            }
                        });
                    });
                    this.saveItemsTwo();

                    console.log('getPriceATP ', this.items);
                    title = 'SAP Pricing & ATP';
                    message = 'successfully get Pricing & Delivery Date';
                    variant = 'success';
                } else if (results.errorMessage) {
                    title = 'SAP Pricing & ATP';
                    message = results.errorMessage;
                    variant = 'error';
                }
            }).catch(error => {
                console.log(error);
                title = 'Error callout Pricing';
                message = reduceErrors(error);
                variant = 'error';
            }).finally(() => {
                this.showSpinner = false;
                this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
            });
    }

    handleBack(){
        this.lineItemAddEdit = false;
    }
}