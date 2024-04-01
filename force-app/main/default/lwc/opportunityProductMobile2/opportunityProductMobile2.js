/*
* Custom Opportunity Product Screen controller methods to query and save OpportunityLineItem for Mobile
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
import { NavigationMixin } from 'lightning/navigation';
import CURRENCYISOCODE_FIELD from '@salesforce/schema/Opportunity.CurrencyIsoCode';
import PRICEBOOK_FIELD from '@salesforce/schema/Opportunity.Pricebook2Id';
import getItems from '@salesforce/apex/OppProductController.getItems';
import getProducts from '@salesforce/apex/ProductLookupController.getProducts';
import { reduceErrors } from 'c/utils';
import LightningConfirm from 'lightning/confirm';
import formFactor from '@salesforce/client/formFactor';

export default class OpportunityLineItems extends NavigationMixin(LightningElement) {
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
    pricebook2Id;
    @track items = [];
    itemsToDelete = [];
    showSpinner = false;
    @track selectedItem = [];
    newItem = {};
    lineItemEdit = false;
    lineItemAddEdit = false;
    @track isDesktop = formFactor === 'Large';
    @track isMobile = formFactor === 'Small';

    connectedCallback() {
        //this.fetchData();
        console.log('connectedCallback');
    }

    get title() {
        return 'Opportunity Product (' + this.numberOfRecords + ')';
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

    @wire(getRecord, { recordId: '$recordId', fields: [CURRENCYISOCODE_FIELD, PRICEBOOK_FIELD] })
    getRecord({ data, error }) {
        console.log('getRecord => ', data, error);
        if (data) {
            this.currencyIsoCode = getFieldValue(data, CURRENCYISOCODE_FIELD);
            this.pricebookId = getFieldValue(data, PRICEBOOK_FIELD);
        }
        else if (error) {
            console.error('getRecord ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }

    products;
    @wire(getProducts, { currencyIsoCode: '$currencyIsoCode', pricebookId: '$pricebookId' })
    wiredProducts({ error, data }) {
        if (data) {
            this.products = data;
            this.initLookupDefaultResults();
        } else if (error) {
            console.log(error);
        }
    }

    initLookupDefaultResults() {
        console.log('initLookupDefaultResults');
        console.log(this.items);
        console.log(this.products);
        if (this.items && this.products
            && this.template.querySelectorAll('c-lookup[data-name="Product2Id"]').length == this.items.length) {
            this.defaultResultsInitialized = true;
            this.items.forEach(item => {
                this.template.querySelector('c-lookup[data-index="' + item.index + '"][data-name="Product2Id"]').setDefaultResults([]);

                let productResults = [];

                this.products.forEach(product => {
                    {
                        let productResult = {
                            id: product.PricebookEntries[0].Id,
                            sObjectType: 'Product2',
                            icon: 'standard:product',
                            title: product.Name,
                            subtitle: product.ProductCode,
                            productCode: product.ProductCode,
                            listPrice: product.PricebookEntries[0].UnitPrice,
                        };
                        productResults.push(productResult);
                    }
                });
                this.template.querySelector('c-lookup[data-index="' + item.index + '"][data-name="Product2Id"]').setDefaultResults(productResults);
                this.template.querySelector('c-lookup[data-index="' + item.index + '"][data-name="Product2Id"]').setSearchResults(productResults);
                item.productResults = productResults;
            });
        }
    }


    message;
    handleSwipe(event) {
        // define the minimum distance to trigger the action
        const minDistance = 80;
        const container = this.template.querySelector('.swipe-container');
        const output = this.template.querySelector('.output');
        // get the distance the user swiped
        console.log('scrollLeft : ' + container.scrollLeft)
        console.log('clientWidth : ' + container.clientWidth)
        const swipeDistance = container.scrollLeft - container.clientWidth;
        console.log(swipeDistance)
        console.log(event.currentTarget.dataset.index)
        /* if (swipeDistance < minDistance * -1) {
           this.message = 'Delete Item : '+event.currentTarget.dataset.index;
         } else if (swipeDistance > minDistance) {
           this.message = 'Edit : '+event.currentTarget.dataset.index;
           //this.handleTileClick(event.currentTarget.dataset.index);
         } */

        if (swipeDistance > minDistance) {
            this.message = 'Delete Item : ' + event.currentTarget.dataset.index;
            this.handleConfirmClick(event.currentTarget.dataset.index);
        }
        else {
            this.message = `did not swipe ${minDistance}px`;
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
            // setting theme would have no effect
        });
        //Confirm has been closed
        //result is true if OK was clicked
        //and false if cancel was clicked

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

    removeItem(event) {
        console.log('removeItem');
        let index = event.target.dataset.index;
        console.log(index);
        index--;
        let item = this.items.splice(index, 1);
        if (item && item[0] && item[0].Id)
            this.itemsToDelete.push({ Id: item[0].Id });
        index = 1;
        this.items.forEach(item => {
            item.index = index++;
        });
        this.initLookupDefaultResults();
    }

    getItems() {
        console.log('getItems');
        this.showSpinner = true;
        getItems({ oppId: this.recordId })
            .then(result => {
                console.log('result:');
                console.log(result);
                this.items = JSON.parse(JSON.stringify(result));
                let index = 1;
                this.items.forEach(item => {
                    item.index = index++;
                    item.url = '/' + item.Id;
                    item.errors = [];
                    item.selection = {
                        id: item.PricebookEntryId,
                        sObjectType: 'Product2',
                        icon: 'standard:product',
                        title: item.Product_Name__c,
                        subtitle: item.Product2.ProductCode
                    };
                    if (!item.Discount__c) {
                        item.Discount__c = item.ListPrice ? parseFloat((1 - (item.UnitPrice / item.ListPrice)) * 100).toFixed(2) : 0;
                    }
                });
            }).catch(error => {
                console.log(error);
            }).finally(() => {
                this.showSpinner = false;
            });
    }


    handleSearch(event) {
        console.log('handleSearch');
        let index = event.target.dataset.index;
        let searchTerm = event.detail.searchTerm;
        console.log(index + '>' + searchTerm);
        if (searchTerm) {
            searchTerm = '%' + searchTerm + '%';
            getProducts({ currencyIsoCode: this.currencyIsoCode, pricebookId: this.pricebookId, searchTerm: searchTerm })
                .then(result => {
                    let results = [];
                    result.forEach(item => {
                        let result = {
                            id: item.PricebookEntries[0].Id,
                            sObjectType: 'Product2',
                            icon: 'standard:product',
                            title: item.Name,
                            subtitle: item.ProductCode,
                            productCode: item.ProductCode,
                            listPrice: item.PricebookEntries[0].UnitPrice,
                            supportedPrice: item.PricebookEntries[0].Supported_Price1__c
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
            this.initLookupDefaultResults();
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
            //item.Product2Id = value;    
            //item.Product2 = this.products.find(i => i.Id == value);                     
            item.selection = selection;
            item.PricebookEntryId = value;
            item.ListPrice = selection[0].listPrice;
            item.UnitPrice = selection[0].listPrice;
            //item.Description = selection[0].subtitle;
            item.Product2.ProductCode = selection[0].productCode;
            //item.UnitPrice = selection[0].supportedPrice;    

            console.log(item);
        }
        else {
            //item.Product2Id = null;
            item.selection = null;
            item.PricebookEntryId = null;
            item.ListPrice = null;
            item.Description = null;
            item.UnitPrice = null;
            item.Product2 = {};
            item.Discount__c = null;
        }
        //this.initLookupDefaultResults();     
    }


    handleTileClick(event) {
        //const recordId = event.target.dataset.recordId;
        this.lineItemAddEdit = true;
        let index = event.currentTarget.dataset.index;

        this.selectedItem = this.items[index - 1];
        console.log(this.selectedItem);
        //this.navigateToEditRecord(recordId);
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

        /*const isValid = [...this.template.querySelectorAll('lightning-input-field'),].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        console.log('isValid', isValid);*/

        if (!this.selectedItem.PricebookEntryId) {
            return;
        }

        this.showSpinner = true;
        const fields = {};

        fields['Quantity'] = this.selectedItem.Quantity;
        fields['UnitPrice'] = this.selectedItem.UnitPrice;
        fields['Description'] = this.selectedItem.Description;
        const recordInput = { fields };

        if (Boolean(isAdd) === true) {
            fields['OpportunityId'] = this.recordId;
            fields['PricebookEntryId'] = this.selectedItem.PricebookEntryId;
            fields['Product2Id'] = this.selectedItem.Product2Id;
            fields['CurrencyIsoCode'] = this.currencyIsoCode;
            recordInput.apiName = 'OpportunityLineItem';
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

        /*const isValid = [...this.template.querySelectorAll('lightning-input'),].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);        

        console.log('isValid', isValid);

        if (!isValid){
            return;
        }
        
        //this.showSpinner = true;
        items.forEach(item => {
            item.UnitPrice = parseFloat(item.UnitPrice);
            item.Discount__c = parseFloat(item.Discount__c);

            delete item.selection;
            delete item.errors;
            delete item.productResults;
            delete item.TotalPrice;
            delete item.Product2;
            if (!item.OpportunityId)
            {
                item.OpportunityId = this.recordId;
            }
        });
        saveItems({ items: items, itemsToDelete: this.itemsToDelete })
        .then(result => {    
            console.log('result:');
            console.log(result);
            this.itemsToDelete = [];
            title = 'Successfully saved record';            
            variant = 'success';
            if (close)
                this.cancelForm();
            else
                this.getItems();
        }).catch(error => {
            console.log(error);
            title = 'Error saving record';
            message = reduceErrors(error);
            variant = 'error';
        }).finally(() => {
            this.showSpinner = false;
            this.dispatchEvent(new ShowToastEvent({title, message, variant}));
            //notifyRecordUpdateAvailable([{recordId: this.recordId}]);
            this.lineItemEdit = false;
            this.selectedItem = [];
        });*/
    }



    navigateToEditRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'OpportunityLineItem',
                actionName: 'edit'
            }
        }).then(() => {
            // Optionally show a success toast
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!',
                    message: 'Opening line item for edit.',
                    variant: 'success'
                })
            );
        }).catch((error) => {
            // Handle navigation error
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Error opening record: ' + error.message,
                    variant: 'error'
                })
            );
        });
    }

    matchingInfo = {
        primaryField: { fieldPath: 'Name' },
        additionalFields: [{ fieldPath: 'ProductCode' }],
    };

    @track filter = {
        criteria: [
            { fieldPath: 'IsActive', operator: 'eq', value: true },
        ],
    };
    @track searchValue = '';
    @track selectedProductId = null;

    displayInfo = {
        primaryField: 'Name',
        additionalFields: ['ProductCode'],
    };

    handleSearchValueChange(event) {
        console.log('event.detail:', event.detail);
        console.log('handleSearchValueChange : ' + event.detail.value);
        this.searchValue = 'door';
        this.filter = updateFilterWithSearchValue(this.searchValue, this.filter);
    }

    updateFilterWithSearchValue(searchValue, filter) {
        filter.criteria = [
            ...filter.criteria, // Preserve existing active product filter
            {
                fieldPath: 'Name',
                operator: 'likeInsensitive', // Case-insensitive match
                value: '%' + searchValue + '%',
            },
            {
                fieldPath: 'ProductCode',
                operator: 'likeInsensitive',
                value: '%' + searchValue + '%',
            },
        ];
        return filter;
    }

    handleRecordSelection(event) {
        this.selectedProductId = event.detail.recordId;
        console.log('this.selectedProductId : ' + this.selectedProductId)
    }
}