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
* 20.03.2024   prem@kliqxe.com                  Added functionality to buttons and general behaviours for HAFELE team to demo in ANZ.
*/

import { LightningElement, wire, track, api } from 'lwc';
import { getRecord, getFieldValue, notifyRecordUpdateAvailable, deleteRecord, createRecord, updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import CURRENCYISOCODE_FIELD from '@salesforce/schema/Opportunity.CurrencyIsoCode';
import PRICEBOOK_FIELD from '@salesforce/schema/Opportunity.Pricebook2Id';
import SALESORG_CODE_FIELD from '@salesforce/schema/Opportunity.User_Sales_Organization__r.Code__c';
import getItems from '@salesforce/apex/OppProductController.getItems';
import getProducts from '@salesforce/apex/ProductLookupController.getProducts';
import { reduceErrors } from 'c/utils';
import LightningConfirm from 'lightning/confirm';
import formFactor from '@salesforce/client/formFactor';
import getPriceATP from '@salesforce/apex/OppProductController.getPriceATP';
import saveItems from '@salesforce/apex/OppProductController.saveItems';



import SYNC_QUOTE_ID from '@salesforce/schema/Opportunity.SyncedQuoteId';
import ACC_LANGUAGE_CODE from '@salesforce/schema/Opportunity.Account.Language__c';

function timeoutPromise(ms) {
    return new Promise((resolve, reject) => {
        setTimeout(() => reject(new Error('Timeout exceeded')), ms);
    });
}

const SWIPE_THRESHOLD = 70; // Minimum swipe distance
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
    pricebookId;
    @track items = [];
    itemsToDelete = [];
    showSpinner = false;
    @track selectedItem = [];
    newItem = {};
    lineItemEdit = false;
    lineItemAddEdit = false;
    @track isDesktop = formFactor === 'Large';
    @track isMobile = formFactor === 'Small';
    salesOrgCode;
    syncedQuoteId;
    languageCode;


    connectedCallback() {
        //this.fetchData();
        console.log('connectedCallback');

    }



    startX;
    endX;
    @track swipeDirection;
    @track isDeleteIconVisible = false; // Track icon visibility
    renderedCallback(){
        const swipeDiv = this.refs.swipe;
        // Add event listeners for swipes
        swipeDiv.addEventListener('touchstart', this.handleTouchStart.bind(this));
        swipeDiv.addEventListener('touchmove', this.handleTouchMove.bind(this));
        swipeDiv.addEventListener('touchend', this.handleTouchEnd.bind(this));
    }

    animateIconSlideIn() {
        const deleteIcon = this.refs.delete;
        deleteIcon.style.opacity = 1; // Set opacity to show
        deleteIcon.style.transform = 'translateX(0)'; // Reset transform for animation

        // Animation using vanilla JS
        let animationFrame;
        let startTime = null;
        const animationDuration = 200; // Adjust animation duration (ms)

        const animate = (timestamp) => {
            if (!startTime) {
                startTime = timestamp;
            }

            const elapsed = timestamp - startTime;
            const ease = elapsed / animationDuration; // Ease function (linear in this case)
            const translateX = -100 * ease; // Adjust translation for slide-in effect (replace with your desired animation)

            deleteIcon.style.transform = `translateX(${translateX}%)`;

            if (ease < 1) {
                animationFrame = window.requestAnimationFrame(animate);
            } else {
                window.cancelAnimationFrame(animationFrame);
            }
        };

        animationFrame = window.requestAnimationFrame(animate);
    }


    handleTouchStart(event) {
        this.startX = event.changedTouches[0].screenX;
        this.startY = event.changedTouches[0].screenY;
        this.isDeleteIconVisible = false; // Hide icon on touch start
    }

    handleTouchMove(event) {
        this.endX = event.changedTouches[0].screenX;
        // Consider adding logic to track vertical movement for future enhancements
    }

    handleTouchEnd() {
        const swipeDistanceX = this.endX - this.startX;
        const swipeDistanceY = Math.abs(this.endY - this.startY); // Calculate Y movement

        if (Math.abs(swipeDistanceX) > SWIPE_THRESHOLD) { // Check X movement and Y tolerance
            this.swipeDirection = swipeDistanceX > 0 ? 'right' : 'left';
            if (this.swipeDirection === 'left') {
                this.isDeleteIconVisible = true;
                //this.animateIconSlideIn();
            }
            this.showToast();
        } else {
            // Handle tap scenario (optional)
            console.log('Tap detected'); // Example tap logging
        }
    }

    showToast() {
        const event = new ShowToastEvent({
            title: 'Swipe Detected',
            message: `You swiped ${this.swipeDirection}`,
            variant: 'info'
        });
        this.dispatchEvent(event);
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

    get isOppLocked() {
        return this.syncedQuoteId != null ? true : false;
    }


    get numberOfRecords() {
        return this.items != null ? this.items.length : 0;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [CURRENCYISOCODE_FIELD, PRICEBOOK_FIELD, SALESORG_CODE_FIELD, SYNC_QUOTE_ID, ACC_LANGUAGE_CODE] })
    getRecord({ data, error }) {
        console.log('getRecord => ', data, error);
        if (data) {
            this.currencyIsoCode = getFieldValue(data, CURRENCYISOCODE_FIELD);
            this.pricebookId = getFieldValue(data, PRICEBOOK_FIELD);
            this.salesOrgCode = getFieldValue(data, SALESORG_CODE_FIELD);
            this.syncedQuoteId = getFieldValue(data, SYNC_QUOTE_ID);
            this.languageCode = getFieldValue(data, ACC_LANGUAGE_CODE);

        }
        else if (error) {
            console.error('getRecord ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }

    products;
    @wire(getProducts, { recordId: '$recordId', currencyIsoCode: '$currencyIsoCode', pricebookId: '$pricebookId', salesOrgCode: '$salesOrgCode', languageCode: '$languageCode' })
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
                            title: product.Product_Code_Format__c,
                            subtitle: product.Description,
                            productCode: product.ProductCode,
                            listPrice: product.PricebookEntries[0].UnitPrice,
                            oha: product.OHA_Classification__c,
                            generic: product.PCM_Product__c,
                            description: product.Description
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
        this.selectedItem.isAdd = true;
        this.selectedItem.OpportunityId = this.recordId;
        this.selectedItem.OHA_editablity = true; //means disabled=true in html, cannot edit Sales Price and OHA.
        this.lineItemAddEdit = true;
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

    async getItems() {
        console.log('getItems');
        this.showSpinner = true;
        await getItems({ oppId: this.recordId })
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
                        title: item.Product2.Product_Code_Format__c,
                        subtitle: item.Product2.Description
                    };
                    item.OHA_editablity = !item.PCM_Product__c; //used in "disabled" property in html. If it is not a PCM product, then should not be able to change the OHA. If, this.OHA_editability = true, then disabled, else can edit.
                    item.disabledRemove = this.isOppLocked ? true : false;
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
            getProducts({ recordId: this.recordId, currencyIsoCode: this.currencyIsoCode, pricebookId: this.pricebookId, searchTerm: searchTerm, salesOrgCode: this.salesOrgCode, languageCode: this.languageCode })
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
                            oha: item.OHA_Classification__c,
                            generic: item.PCM_Product__c,
                            description: item.Description
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
            // this.initLookupDefaultResults();
        }
    }

    handleSelectionChange(event) {
        console.log('handleSelectionChange');
        let index = event.target.dataset.index;
        let value = event.detail[0]; // value will be undefined, if it is cleared (empty)
        console.log(index);
        console.log(value);
        let item = this.selectedItem;
        const selection = event.target.getSelection();
        console.log('selection', JSON.stringify(selection, null, 2));
        if (value) {
            //item.Product2Id = value;    
            //item.Product2 = this.products.find(i => i.Id == value);                     
            item.selection = selection;
            item.PricebookEntryId = value;
            item.ListPrice = selection[0].listPrice;
            item.UnitPrice = selection[0].listPrice;
            item.Description = selection[0].subtitle;
            item.Product2.ProductCode = selection[0].productCode;
            item.PCM_Product__c = selection[0].generic; //generic property from the lookup component is such that generic = PCM_Product__c
            item.OHA_editablity = !selection[0].generic; //generic property from the lookup component is such that generic = PCM_Product__c
            item.OHA__c = "No";
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
            item.OHA__c = null;
            item.OHA_editablity = true; //cannot edit
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
            item.UnitPrice = item.ListPrice ? parseFloat(item.ListPrice * (1 - item.Discount__c / 100)).toFixed(2) : 0;
        }

        if (value && (field === 'Quantity' || field === 'UnitPrice' || field === 'Discount__c')) {
            item.TotalPrice = item.UnitPrice * item.Quantity;
        }
    }

    async handleCancelEditItems(e) {
        await this.getItems();
        this.selectedItem = {};
        this.lineItemAddEdit = false;
        console.log('These are the items after cancel', JSON.stringify(this.items, null, 2));
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
    }

    saveItemsTwo() {
        console.log('saveItems');
        console.log(this.items);
        let title, message, variant;
        let items = JSON.parse(JSON.stringify(this.items));
        this.showSpinner = true;
        items.forEach(item => {
            item.UnitPrice = parseFloat(item.UnitPrice);
            item.Discount__c = parseFloat(item.Discount__c);

            delete item.selection;
            delete item.errors;
            delete item.productResults;
            delete item.TotalPrice;
            delete item.Product2;
            if (!item.OpportunityId) {
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
                this.getItems();
            }).catch(error => {
                console.log(error);
                title = 'Error saving record';
                message = reduceErrors(error);
                variant = 'error';
            }).finally(() => {
                this.showSpinner = false;
                this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
                notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
            });
    }


    @track filter = {
        criteria: [
            { fieldPath: 'IsActive', operator: 'eq', value: true },
        ],
    };
    @track searchValue = '';
    @track selectedProductId = null;

    showPCM = false;
    async handlePCMClick() {
        this.showPCM = true;
        if (this.selectedItem.isAdd) {
            this.selectedItem.PCM_Product__c = true;
        }
    }

    handleXClose() {
        if (this.selectedItem.isAdd) {
            this.selectedItem.PCM_Product__c = false;
        }
        this.showPCM = false;
    }

    async handleCloseForm() {
        this.getItems();
        notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
        this.showPCM = false;
        this.lineItemAddEdit = false;
    }

    async handleCheckPricing() {
        let title, message, variant;
        try {
            this.showSpinner = true;
            let items = JSON.parse(JSON.stringify(this.items));
            items.forEach(item => {
                delete item.selection;
                delete item.errors;
                delete item.productResults;
                if (!item.OpportunityId) {
                    item.OpportunityId = this.recordId;
                }
            });

            const results = await Promise.race([
                getPriceATP({ recordId: this.recordId, oppItems: items }),
                timeoutPromise(20000) // 20 seconds timeout
            ]);

            console.log('handleCheckPrice ', results);
            if (results && results.isSuccess) {
                this.items.forEach(item => {
                    if (!item.is_Price_Locked__c && !item.PCM_Product__c) {
                        results.data.forEach(result => {
                            if (item.Product2.ProductCode == result.productCode) {
                                item.UnitPrice = parseFloat(result.unitPrice).toFixed(2);
                                item.is_SAP_Price__c = true;
                                item.TotalPrice = item.Quantity * item.UnitPrice;
                            }
                        });
                    }
                });
                this.saveItemsTwo(false);
                console.log('getPriceATP ', this.items);
                title = 'SAP Pricing';
                message = 'successfully get Pricing from SAP';
                variant = 'success';
            } else if (results.errorMessage) {
                title = 'SAP Pricing & ATP';
                message = results.errorMessage;
                variant = 'error';
            } else {
                title= 'SAP Pricing Checked';
                message= 'No eligibile product met the condition for pricing check.';
                variant = 'warning'
            }
            this.showSpinner = false;

        } catch (error) {
            if (error.message === 'Timeout exceeded') {
                title = 'SAP Timeout! Please try again later.';
                message = 'Timeout exceeded';
                variant = 'error';
                console.error('SAP callout timed out after 20 seconds');
            } else {
                console.error(error);
                title = 'Error callout Pricing';
                message = reduceErrors(error);
                variant = 'error';
            }
        } finally {
            this.showSpinner = false;
            this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
        }
    }

    handleBack() {
        this.selectedItem = {};
        this.lineItemAddEdit = false;
    }

}