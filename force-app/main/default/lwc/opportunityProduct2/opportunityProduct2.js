/*
* Custom Opportunity Product Screen controller methods to query and save OpportunityLineItem
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
import { getRecord, getFieldValue, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getItems from '@salesforce/apex/OppProductController.getItems';
import getProducts from '@salesforce/apex/ProductLookupController.getProducts';
import getPriceATP from '@salesforce/apex/OppProductController.getPriceATP';
import saveItems from '@salesforce/apex/OppProductController.saveItems';
import { reduceErrors } from 'c/utils';
import CURRENCYISOCODE_FIELD from '@salesforce/schema/Opportunity.CurrencyIsoCode';
import SALESORG_CODE_FIELD from '@salesforce/schema/Opportunity.User_Sales_Organization__r.Code__c';
import PRICEBOOK_FIELD from '@salesforce/schema/Opportunity.Pricebook2Id';
import { loadScript } from 'lightning/platformResourceLoader';
import PARSER from '@salesforce/resourceUrl/PapaParse';
import productSelection from 'c/productSelection';

export default class OppProduct extends NavigationMixin(LightningElement) {
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
    @track items;
    itemsToDelete = [];
    defaultResultsInitialized = false;
    showSpinner = false;
    title;
    showProductSelectionForm = false;
    disabledCheckPricing = false;

    showGenericProductSelectionForm = false;
    selectedItem = {};

    parserInitialized;
    @track _rows;
    showUploadResult = false;

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

    renderedCallback() {
        console.log('renderedCallback');
        if (!this.defaultResultsInitialized)
            this.initLookupDefaultResults();
        if (!this.parserInitialized) {
            loadScript(this, PARSER)
                .then(() => {
                    this.parserInitialized = true;
                })
                .catch(error => console.error(error));
        }
    }

    connectedCallback() {
        console.log('connectedCallback');
    }

    @wire(getRecord, { recordId: '$recordId', fields: [CURRENCYISOCODE_FIELD, PRICEBOOK_FIELD, SALESORG_CODE_FIELD] })
    getRecord({ data, error }) {
        console.log('getRecord => ', data, error);
        if (data) {
            this.currencyIsoCode = getFieldValue(data, CURRENCYISOCODE_FIELD);
            this.pricebookId = getFieldValue(data, PRICEBOOK_FIELD);
            this.salesOrgCode = getFieldValue(data, SALESORG_CODE_FIELD);

            console.log('this.salesOrgCode', this.salesOrgCode);
        }
        else if (error) {
            console.error('getRecord ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }

    products;
    @wire(getProducts, { recordId: '$recordId', currencyIsoCode: '$currencyIsoCode', pricebookId: '$pricebookId', salesOrgCode: '$salesOrgCode' })
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
                            oha: product.OHA_Classification__c,
                            generic: product.Generic__c
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

                    if (!item.Product2.Generic__c) {
                        item.disabledOHA = true;
                    }
                });
            }).catch(error => {
                console.log(error);
            }).finally(() => {
                this.showSpinner = false;
                this.disabledCheckPricing = false;
            });
    }

    addItem() {
        let item = {};
        item.index = this.items.length + 1;
        item.errors = [];
        item.selection = null;
        //item.locked = false;
        item.Product2 = {};
        this.items.push(item);
        this.defaultResultsInitialized = false;
        this.initLookupDefaultResults();
        this.disabledCheckPricing = true;

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
        this.disabledCheckPricing = true;
    }

    handleSearch(event) {
        console.log('handleSearch');
        let index = event.target.dataset.index;
        let searchTerm = event.detail.searchTerm;
        console.log(index + '>' + searchTerm);
        if (searchTerm) {
            searchTerm = '%' + searchTerm + '%';
            getProducts({ recordId: this.recordId, currencyIsoCode: this.currencyIsoCode, pricebookId: this.pricebookId, searchTerm: searchTerm, salesOrgCode: this.salesOrgCode })
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
                            oha: item.OHA_Classification__c,
                            generic: item.Generic__c
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

        /*
        let results = [];
        this.template.querySelector('c-lookup[data-index="' + index + '"][data-name="Product2Id"]').setSearchResults(results); 
        let item = this.items.find(i => i.index == index);
        console.log(item);
        results = item.productResults.filter(i => i.title.toLowerCase().includes(searchTerm));
        console.log(results);
        this.template.querySelector('c-lookup[data-index="' + index + '"][data-name="Product2Id"]').setSearchResults(results);   
        */
    }

    handleSelectionChange(event) {
        console.log('handleSelectionChange');
        let index = event.target.dataset.index;
        let value = event.detail[0];
        console.log(index);
        console.log(value);
        let item = this.items.find(i => i.index == index);
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
            item.OHA__c = selection[0].oha ? 'Yes' : 'No'
            item.disabledOHA = !selection[0].generic
            item.PCM_Product__c = selection[0].generic;
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
            item.PCM_Product__c = false;
        }
        this.initLookupDefaultResults();
    }

    handleItemChange(event) {
        console.log('handleItemChange');
        let index = event.target.dataset.index;
        let field = event.target.dataset.field;
        let value = Array.isArray(event.detail.value) ? event.detail.value[0] : event.detail.value;
        console.log('Row ' + index + ' : ' + field + ' = ' + value);
        let item = this.items.find(i => i.index == index);
        if (item[field] != value && (field === 'Quantity' || field === 'UnitPrice' || field === 'Discount__c')) {
            item.is_SAP_Price__c = false;
        }

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

    handlePriceLocked(event) {
        let index = event.target.dataset.index;
        let item = this.items.find(i => i.index == index);
        if (item.is_Price_Locked__c) item.is_Price_Locked__c = false;
        else item.is_Price_Locked__c = true;

        console.log('handlePriceLocked ', this.items);

    }

    cancelForm() {
        //this.getItems();                
        console.log('cancelForm');
        this._rows = null;
        let recordId = this.recordId;
        this.dispatchEvent(new CustomEvent('close'));
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
    }

    handleSaveAndCloseItems() {
        this.saveItems(true);
    }

    handleSaveItems() {
        this.saveItems(false);
    }

    refresh() {
        this.getItems();
        this._rows = undefined;
        this.itemsToDelete = [];
    }

    handleCheckPrice() {
        this.showSpinner = true;
        let title, message, variant;
        let items = JSON.parse(JSON.stringify(this.items));
        items.forEach(item => {
            delete item.selection;
            delete item.errors;
            delete item.productResults;
            if (!item.OpportunityId) {
                item.OpportunityId = this.recordId;
            }

        });


        getPriceATP({ recordId: this.recordId, oppItems: items })
            .then(results => {
                console.log('handleCheckPrice ', results);
                //console.log(results);

                if (results && results.isSuccess) {
                    this.items.forEach(item => {
                        if (!item.is_Price_Locked__c && !item.PCM_Product__c) {
                            results.data.forEach(result => {
                                if (item.Product2.ProductCode == result.productCode) {
                                    //item.List_Price__c = (result.unitPrice).toFixed(2);
                                    //item.ListPrice = item.List_Price__c;
                                    item.ListPrice = parseFloat(result.unitPrice).toFixed(2);
                                    item.UnitPrice = parseFloat(result.unitPrice).toFixed(2);
                                    //item.Delivery_Date__c = result.deliveryDate;
                                    item.is_SAP_Price__c = true;

                                    item.Discount__c = item.ListPrice ? parseFloat((1 - (item.UnitPrice / item.ListPrice)) * 100).toFixed(2) : 0;
                                    item.TotalPrice = item.Quantity * item.UnitPrice;
                                }

                            });
                        }

                    });

                    console.log('getPriceATP ', this.items);

                    title = 'SAP Pricing';
                    message = 'successfully get Pricing from SAP';
                    variant = 'success';
                } else if (results.errorMessage) {
                    title = 'SAP Pricing & ATP';
                    message = results.errorMessage;
                    variant = 'error';
                }

                /*this.items.forEach(item => {
                    item.pricechecked = true;
                });*/

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

    saveItems(close) {
        console.log('saveItems');
        console.log(this.items);
        let title, message, variant;
        let items = JSON.parse(JSON.stringify(this.items));

        const isValid = [...this.template.querySelectorAll('lightning-input'),].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        console.log('isValid', isValid);

        if (!isValid) {
            return;
        }

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
                this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
                notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
            });
    }

    get columns() {
        const columns = [
            { label: 'Product Code', fieldName: 'ProductCode', hideDefaultActions: true },
            //{ label: 'Sales Organisation', fieldName: 'Sales_Organisation__c', hideDefaultActions: true },            
            { label: 'Quantity', fieldName: 'Quantity', hideDefaultActions: true },
            { label: 'Unit Price', fieldName: 'UnitPrice', hideDefaultActions: true },
            { label: 'Result', fieldName: 'Result', hideDefaultActions: true }
        ];
        return columns;
    }

    get rows() {
        if (this._rows) {
            return this._rows.map((row, index) => {
                row.key = index;
                return row;
            })
        }
        return [];
    }

    handleFileInputChange(event) {
        if (event.target.files.length > 0) {
            const file = event.target.files[0];
            this.showSpinner = true;
            Papa.parse(file, {
                quoteChar: '"',
                header: 'true',
                complete: (results) => {
                    console.log('meta', results.meta);
                    let hasProductCode = false;
                    if (results.meta.fields) {
                        results.meta.fields.forEach(field => {
                            if (field == 'ProductCode') {
                                hasProductCode = true;
                            }
                        });
                    }
                    if (hasProductCode) {
                        if (results.data && results.data.length <= 1000) {
                            this._rows = results.data;
                            let productCodes = results.data.map((item) => item.ProductCode);
                            console.log('productCodes', productCodes);
                            //this.filters.ProductCode = productCodes.toString();
                            getProducts({ currencyIsoCode: this.currencyIsoCode, pricebookId: this.pricebookId, productCodes: productCodes.toString() })
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
                                            //supportedPrice: item.PricebookEntries[0].Supported_Price1__c
                                        };
                                        //results.push(result); 

                                        let row = this._rows.find(i => i.ProductCode === item.ProductCode);
                                        /*let itemSelected = this.items.find(i => item.Id === i.Product2Id); //If previously selected just update
                                        if (itemSelected && itemSelected.Product2 && itemSelected.Product2.Sales_Organisation__c
                                            && itemSelected.Product2.Sales_Organisation__c === row.Sales_Organisation__c)
                                        {                                        
                                            itemSelected.Quantity = row.Quantity;
                                            row.Result = 'Matched';
                                        }
                                        else if (item.Sales_Organisation__c === row.Sales_Organisation__c)
                                        {                     
                                            row.Result = 'Matched';
                                            let itemObj = {};
                                            itemObj.index = this.items.length + 1;
                                            itemObj.errors = [];
                                            itemObj.selection = result;       
                                            itemObj.Quantity = row.Quantity;     
                                            itemObj.PricebookEntryId = result.id;         
                                            itemObj.ListPrice = itemObj.selection.listPrice;    
                                            itemObj.Description = itemObj.selection.subtitle;
                                            itemObj.UnitPrice = itemObj.selection.supportedPrice;
                                            this.items.push(itemObj);                                           
                                        }*/
                                        if (row) // For Workshop Demo
                                        {
                                            //row.Result = 'Not found';
                                            row.Result = 'Matched';
                                            let itemObj = {};
                                            itemObj.index = this.items.length + 1;
                                            itemObj.errors = [];
                                            itemObj.selection = result;
                                            itemObj.Quantity = row.Quantity;
                                            itemObj.PricebookEntryId = result.id;
                                            itemObj.ListPrice = itemObj.selection.listPrice;
                                            //itemObj.Description = itemObj.selection.subtitle;
                                            itemObj.UnitPrice = row.UnitPrice;
                                            itemObj.Product2 = {};
                                            itemObj.Product2.ProductCode = row.ProductCode;
                                            itemObj.TotalPrice = itemObj.UnitPrice * itemObj.Quantity;
                                            itemObj.Discount__c = itemObj.ListPrice ? parseFloat((1 - (itemObj.UnitPrice / itemObj.ListPrice)) * 100).toFixed(2) : 0;
                                            this.items.push(itemObj);
                                        }
                                    });

                                    //this.template.querySelector('c-lookup[data-index="' + itemObj.index + '"][data-name="Product2Id"]').setSearchResults(results); 
                                }).catch(error => {
                                    console.log(error);
                                }).finally(() => {
                                    this.showSpinner = false;
                                });
                        }
                        else {
                            this.dispatchEvent(new ShowToastEvent({ title: 'File Upload Error', message: 'Reduce the number of rows to 1,000 or below', variant: 'error' }));
                            this.showSpinner = false;
                        }
                    }
                    else {
                        this.dispatchEvent(new ShowToastEvent({ title: 'File Upload Error', message: 'No ProductCode column found', variant: 'error' }));
                        this.showSpinner = false;
                    }
                },
                error: (error) => {
                    console.error(error);
                    this.showSpinner = false;
                    this.dispatchEvent(new ShowToastEvent({ title: 'File Upload Error', message: error, variant: 'error' }));
                }
            })
        }
    }

    get hasFileRows() {
        return (this._rows && this._rows.length > 0) ? true : false;
    }

    cancel() {
        this._rows = undefined;
    }

    handleShowUploadResult() {
        this.showUploadResult = true;
    }

    handleCloseUploadResult() {
        this.showUploadResult = false;
    }

    handleShowProductSelectionForm() {
        console.log('handleShowProductSelectionForm');
        this.showProductSelectionForm = true;
        //this.disableTable = true;

    }
    handleHideProductSelectionForm() {
        console.log('handleHideProductSelectionForm');
        this.showProductSelectionForm = false;
        //this.disableTable = false;
    }

    handleAddProductSelection(event) {
        console.log('handleAddProductSelection', event.detail);
    }

    async handleAddProducts() {

        const result = await productSelection.open({

            size: 'large',
            description: 'Accessible description of modal\'s purpose',
            recordId: this.recordId,
            tabName: this.tabName,
            //room: this.room,
            activeTabValue: 'add'
        });

        console.log(result);

        result.forEach(product => {
            console.log(product);

            let selection = {
                id: product.PricebookEntryId,
                sObjectType: 'Product2',
                icon: 'standard:product',
                title: product.Name,
                subtitle: product.ProductCode,
                productCode: product.ProductCode,
                listPrice: product.ListPrice
                //supportedPrice: item.PricebookEntries[0].Supported_Price1__c
            };

            let item = {};
            item.index = this.items.length + 1;
            item.errors = [];
            item.selection = selection;
            item.Product2 = {};
            item.Product2.ProductCode = product.ProductCode;
            item.OpportunityId = product.OpportunityId;
            item.Product2Id = product.Product2Id;
            item.PricebookEntryId = product.PricebookEntryId;
            item.ListPrice = product.ListPrice;
            item.UnitPrice = product.ListPrice;
            item.CurrencyIsoCode = product.CurrencyIsoCode;
            item.Description = product.Description;
            this.items.push(item);

        });

        //this.handleRefresh();
    }

    handleShowGenericProductSelectionForm(event)
    {
        let id = event.currentTarget.dataset.id;             
        console.log('handleShowGenericProductSelectionForm', id); 
        this.showGenericProductSelectionForm = true;
        let item = this.items.find(i => i.Id === id);  
        if (item)
        {
            this.selectedItem = JSON.parse(JSON.stringify(item));
        }
        else
        {
            this.selectedItem.OpportunityId = this.recordId;
        }        
        event.preventDefault();        
    }

    handleCloseGenericProductSelectionForm(event)
    {
        console.log('handleCloseOppItemConvertForm');
        this.showGenericProductSelectionForm = false;  
        this.selectedItem = {};  
        this.getItems();          
    }    
}