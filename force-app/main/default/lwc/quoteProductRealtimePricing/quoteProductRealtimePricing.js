/*
* Custom Quote Product Screen controller methods to query and save QuoteLineItem
* @author ly.sirigalaya@kliqxe.com
* @since 20.02.2024
* @version 20.02.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 11.04.2024   ly.sirigalaya@kliqxe.com         Initial Version
*/

import { LightningElement, api, track, wire } from 'lwc';
import { getRecord, getFieldValue, notifyRecordUpdateAvailable } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { RefreshEvent } from 'lightning/refresh';
import getItems from '@salesforce/apex/QuoteProductController.getItems';
import getSAPPricing from '@salesforce/apex/QuoteProductController.getSAPPricing';
import getProducts from '@salesforce/apex/ProductLookupController.getProducts';
import saveItems from '@salesforce/apex/QuoteProductController.saveItems';
import { reduceErrors } from 'c/utils';
import CURRENCYISOCODE_FIELD from '@salesforce/schema/Quote.CurrencyIsoCode';
import PRICEBOOK_FIELD from '@salesforce/schema/Quote.Pricebook2Id';
import SALESORG_CODE_FIELD from '@salesforce/schema/Quote.Sales_Org_Code__c';
import SAP_QUOTE_NUMBER_FIELD from '@salesforce/schema/Quote.SAP_Quote_Number__c';
import ACC_LANGUAGE_CODE from '@salesforce/schema/Quote.Account.Language__c';
//import { loadScript } from 'lightning/platformResourceLoader';
//import PARSER from '@salesforce/resourceUrl/PapaParse';
//import productSelection from 'c/productSelection';
import { labels } from './labels.js';
import QUOTELINEITEM_OBJECT from '@salesforce/schema/QuoteLineItem';
import PRODUCT2_OBJECT from '@salesforce/schema/Product2';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
//import hasQuoteCostAndMarginAccess from '@salesforce/customPermission/Quote_Cost_And_Margin_Access';

export default class QuoteProductRealtimePricing extends NavigationMixin(LightningElement) {
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
        if (val) {
            //this.getItems();
        }
        else {
            this.items = [];
            this.itemsToDelete = [];
        }
        this.defaultResultsInitialized = false;
        this.showUploadResult = false;
    }
    get recordId() {
        return this._recordId;
    }
    currencyIsoCode;
    pricebookId;
    quoteType;
    @track items;
    itemsToDelete = [];
    defaultResultsInitialized = false;
    showSpinner = false;
    quoteLineId;
    productFormId;
    showProductForm = false;
    title;
    parserInitialized;
    @track _rows;
    showUploadResult = false;
    qliObjInfos;
    qliFields;
    productFields;
    fields;
    disabledCheckPricing = false;
    salesOrgCode;
    SAPQuoteNumber;

    get numberOfRecords() {
        return this.items != null ? this.items.length : 0;
    }

    get totalLabel() {
        return 'Total Amount: ' + this.totalAmount;
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

    /*get totalCost() {
        var val = 0;
        if (this.items) {
            this.items.forEach(item => {
                val += (item.Cost_Per_Item__c && item.Quantity) ? item.Cost_Per_Item__c * item.Quantity : 0;
            });
        }
        return val;
    }

    get totalMargin() {
        var val = '';
        if (this.totalAmount && this.totalCost) {
            val = ((this.totalAmount - this.totalCost) / this.totalAmount);
        }
        return val;
    }*/

    get isQuoteLocked() {
        return this.SAPQuoteNumber != null ? true : false;
    }

    /*get isCheckPricingLocked() {
        return this.disabledCheckPricing || this.isQuoteLocked ? true : false;
    }*/

    get hasQLIFields() {
        return (this.qliObjInfos && this.qliFields && this.productFields) ? true : false;
    }


    renderedCallback() {
        console.log('renderedCallback');
        if (!this.defaultResultsInitialized)
            this.initLookupDefaultResults();
        /*if (!this.parserInitialized) {
            loadScript(this, PARSER)
                .then(() => {
                    this.parserInitialized = true;
                })
                .catch(error => console.error(error));
        }*/
    }

    connectedCallback() {
        console.log('connectedCallback');
        //loadStyle(this, LWC_Internal_Style); //override standard component style - for modal size
    }

    disconnectedCallback() {
        console.log('disconnectedCallback');
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
            this.SAPQuoteNumber = getFieldValue(data, SAP_QUOTE_NUMBER_FIELD);
            this.languageCode = getFieldValue(data, ACC_LANGUAGE_CODE);
            this.getItems();
            console.log('this.salesOrgCode', this.salesOrgCode);
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
        //console.log(this.brands);
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

                    /*if (item.List_Price__c) {
                        item.ListPrice = item.List_Price__c;
                    }

                    if (!item.Discount__c) {
                        item.Discount__c = item.ListPrice ? parseFloat((1 - (item.UnitPrice / item.ListPrice)) * 100).toFixed(2) : 0;
                    }*/

                    item.rejectedClass = item.Rejected__c ? 'rejected' : '';
                    item.disabledRemove = this.isQuoteLocked ? true : false;
                    //item.marginClass = 'slds-input-' + range + 'Margin';                
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
        item.Product2 = {};
        item.branderrors = [];
        item.brandSelection = null;
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
                            description: item.Description
                            /*cost: item.Cost__c,
                            standardMultiplier: item.PricebookEntries[0].Standard_Multiplier__c,
                            supportedPrice: item.PricebookEntries[0].Supported_Price1__c,
                            discountPercentage: item.PricebookEntries[0].Discount_Percentage__c,
                            approvalMarginBase: item.Approval_Margin_Base__c*/
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
        let item = this.items.find(i => i.index == index);
        const selection = event.target.getSelection();
        console.log('selection', selection);
        if (value) {
            //item.Product2Id = value;    
            //item.Product2 = this.products.find(i => i.Id == value);                     
            item.selection = selection[0];
            item.PricebookEntryId = value;
            item.ListPrice = selection[0].listPrice;
            item.UnitPrice = selection[0].listPrice;
            //item.Cost_Per_Item__c = selection[0].cost;
            //item.Standard_Multiplier__c = selection[0].standardMultiplier;
            //item.Supported_Price__c = selection[0].supportedPrice;     
            item.Description = selection[0].description;
            item.Product2.ProductCode = selection[0].productCode;
            //item.Multiplier__c = selection[0].standardMultiplier;
            //item.Discount_Percentage__c = selection[0].discountPercentage;
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
            this.disabledCheckPricing = true;
        }


        console.log('current ' + item[field] + ' New ' + value);
        item[field] = value;
        if (item.UnitPrice && field === 'UnitPrice') {
            item.Discount__c = item.ListPrice ? parseFloat((1 - (item.UnitPrice / item.ListPrice)) * 100).toFixed(2) : 0;
        }

        if (item.Discount__c && field === 'Discount__c') {
            //item.UnitPrice = parseFloat(item.List_Price__c - (item.List_Price__c * item.Discount__c/100)).toFixed(2);
            item.UnitPrice = item.ListPrice ? parseFloat(item.ListPrice * (1 - item.Discount__c / 100)).toFixed(2) : 0;
        }
        if (value && (field === 'Quantity' || field === 'UnitPrice' || field === 'Discount__c')) {
            item.TotalPrice = item.Quantity * item.UnitPrice;
            //console.log(item.TotalPrice);
            /*item.Margin_Percentage__c = ((item.TotalPrice - (item.Cost_Per_Item__c * item.Quantity)) / item.TotalPrice) * 100;
            //console.log(item.Margin_Percentage__c);
            item.Margin_Percentage__c = parseFloat(item.Margin_Percentage__c).toFixed(2);
            //console.log(item.Margin_Percentage__c);
            item.Difference__c = item.Supported_Price__c - item.UnitPrice;            
            let range;
            if (item.Margin_Percentage__c < item.selection.approvalMarginBase)
            {
                range = 'low';                
            }           
            item.marginClass = 'slds-input-' + range + 'Margin'; */
        }

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
                this.dispatchEvent(new RefreshEvent());
                this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
                notifyRecordUpdateAvailable([{ recordId: this.recordId }]);
            });
    }

    handleCheckPrice() {
        this.showSpinner = true;
        let title, message, variant;
        let items = JSON.parse(JSON.stringify(this.items));
        items.forEach(item => {
            //item.UnitPrice = parseInt(item.UnitPrice);
            //item.Discount__c = parseFloat(item.Discount__c);
            delete item.selection;
            delete item.errors;
            delete item.productResults;
            if (!item.QuoteId) {
                item.QuoteId = this.recordId;
            }
        });


        getSAPPricing({ recordId: this.recordId, quoteItems: items })
            .then(results => {
                console.log('getSAPPricing ', results);
                if (results) {

                    this.items.forEach(item => {
                        let itemNo = '000' + item.index + '00';
                        item.itemNo = itemNo;
                        console.log('Item ' + item.index, itemNo);

                        //ET_EINT_OUT
                        results.ET_EINT_OUT.forEach(eint => {
                            if (eint.COM_DATE && item.itemNo == eint.ORDPOSNO ) {
                                let devliverlyDate = eint.COM_DATE;
                                console.log('devliverlyDate', devliverlyDate);
                                item.Delivery_Date__c = devliverlyDate;
                            }
                        })

                        //ET_KOMV_OUT
                        results.ET_KOMV_OUT.forEach(komv => {
                            //console.log(komv);
                            if (item.itemNo == komv.ORDPOSNO) {
                                switch (komv.STUNR) {
                                    case '090':
                                        let basePrice = parseFloat(komv.KBETR) / 100;
                                        console.log('basePrice', basePrice);
                                        item.Base_Price__c = basePrice;
                                        break;
                                    case '800':
                                        let stdPrice = parseFloat(komv.KBETR) / 100;
                                        console.log('stdPrice', stdPrice);
                                        item.Std_Price__c = stdPrice;
                                        break;
                                    case '805':
                                        let unitPrice = parseFloat(komv.KBETR) / 100;
                                        let totalPrice = parseFloat(komv.KWERT);
                                        console.log('unitPrice', unitPrice);
                                        console.log('totalPrice', totalPrice);
                                        item.UnitPrice = unitPrice;
                                        item.TotalPrice = totalPrice;
                                        item.is_SAP_Price__c = true;
                                        break;
                                    case '985':
                                        let grossProfit = parseFloat(komv.KAWRT);
                                        item.Gross_Profit__c = grossProfit;
                                        console.log('grossProfit', grossProfit);
                                        break;
                                }
                            }

                        })

                        console.log(item);
                    })

                }
                else {
                    alert('No response');
                }




                //console.log(results);

                /*if (results && results.isSuccess) {
                    this.items.forEach(item => {

                        results.data.forEach(result => {
                            if (item.Product2.ProductCode == result.productCode) {
                                item.List_Price__c = parseFloat(result.unitPrice).toFixed(2);
                                //item.ListPrice = item.List_Price__c;
                                item.UnitPrice = parseFloat(result.unitPrice).toFixed(2);
                                item.Delivery_Date__c = result.deliveryDate;
                                item.is_SAP_Price__c = true;

                                //item.Discount__c = item.ListPrice ? parseFloat((1 - (item.UnitPrice / item.ListPrice)) * 100).toFixed(2) : 0;
                                item.TotalPrice = item.Quantity * item.UnitPrice;
                            }

                        })

                    });
                    this.saveItems(false);
                    console.log('getPriceATP ', this.items);;

                    title = 'SAP Pricing & ATP';
                    message = 'successfully get Pricing & Delivery Date';
                    variant = 'success';
                } else if (results.errorMessage) {
                    title = 'SAP Pricing & ATP';
                    message = results.errorMessage;
                    variant = 'error';
                }*/

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

    openProductForm(event) {
        console.log('openProductForm');
        let index = event.target.dataset.index;
        let item = this.items.find(i => i.index == index);
        this.quoteLineId = item.Id;
        this.productFormId = item.Product_Form_Id__c;
        this.showProductForm = true;
    }

    closeProductForm(event) {
        console.log('closeProductForm');
        this.showProductForm = false;
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
                                            description: item.Description
                                            /*cost: item.Cost__c,
                                            standardMultiplier: item.PricebookEntries[0].Standard_Multiplier__c,
                                            supportedPrice: item.PricebookEntries[0].Supported_Price1__c,
                                            discountPercentage: item.PricebookEntries[0].Discount_Percentage__c,
                                            approvalMarginBase: item.Approval_Margin_Base__c*/
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
                                            itemObj.List_Price__c = itemObj.selection.listPrice;   
                                            itemObj.Cost_Per_Item__c = itemObj.selection.cost;
                                            itemObj.Standard_Multiplier__c = itemObj.selection.standardMultiplier;
                                            itemObj.Supported_Price__c = itemObj.selection.supportedPrice;     
                                            itemObj.Description = itemObj.selection.subtitle;       
                                            itemObj.UnitPrice = itemObj.selection.supportedPrice;
                                            itemObj.Multiplier__c = itemObj.selection.standardMultiplier;
                                            itemObj.Discount_Percentage__c = itemObj.selection.discountPercentage;                                         
                                            itemObj.TotalPrice = itemObj.Quantity * itemObj.UnitPrice;                                        
                                            itemObj.Margin_Percentage__c = ((itemObj.TotalPrice - (itemObj.Cost_Per_Item__c * itemObj.Quantity)) / itemObj.TotalPrice) * 100;                                        
                                            itemObj.Margin_Percentage__c = parseFloat(itemObj.Margin_Percentage__c).toFixed(2);                                        
                                            itemObj.Difference__c = item.Supported_Price__c - itemObj.UnitPrice;            
                                            let range;
                                            if (itemObj.Margin_Percentage__c < itemObj.selection.approvalMarginBase) 
                                            {
                                                range = 'low' ;
                                            }                                                    
                                            itemObj.marginClass = 'slds-input-' + range + 'Margin';                                                                                                      
                                            
                                            //-- Replace a blank line which has no product selected
                                            let blankItemIndex = this.items.findIndex(i => !i.selection);
                                            console.log('blankItemIndex', blankItemIndex);
                                            if (blankItemIndex > -1)
                                            {                                            
                                                this.items.splice(blankItemIndex, 1, itemObj);
                                            }
                                            else
                                            {
                                                this.items.push(itemObj);
                                            }
                                            //--                                                                          
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
}