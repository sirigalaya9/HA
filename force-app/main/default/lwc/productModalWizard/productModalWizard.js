// The code that is deployed currently to the prembotwo 12:42Am thursday 23 march malaysian time.

import { LightningElement, wire, api, track } from "lwc";
import getProducts from "@salesforce/apex/ProductController.getProducts";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
//import getIds from "@salesforce/apex/ProductController.getIds";
import getSearchResult from "@salesforce/apex/ProductController.getSearchResult";
// Source: https://www.salesforcebolt.com/2021/08/increase-size-width-of-lightning-web.html
//import modalcss from "@salesforce/resourceUrl/pswcustomcssbyPrem";
import { loadStyle } from "lightning/platformResourceLoader";
import getOpportunityLineItems from "@salesforce/apex/ProductController.getOpportunityLineItems";
import saveItems from '@salesforce/apex/ProductController.saveItems';
import saveOLI from "@salesforce/apex/ProductController.saveOLI";
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import PRICEBOOK_FIELD from '@salesforce/schema/Opportunity.Pricebook2Id';
import CURRENCYISOCODE_FIELD from '@salesforce/schema/Opportunity.CurrencyIsoCode';
import { CloseActionScreenEvent } from 'lightning/actions';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrors } from 'c/utils';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LWC_Internal_Style from '@salesforce/resourceUrl/LWC_Internal_Style';




export default class ProductWizard extends NavigationMixin(LightningElement) {

    connectedCallback() {
        console.log("connectedCallback");
        //loadStyle(this, modalcss);
        loadStyle(this, LWC_Internal_Style);
    }

    disconnectedCallback() {
        //loadStyle(this, modalcssreset);
    }
    renderedCallback() {
        //loadStyle(this, modalcss);
    }
    // Columns to display for the datatable.
    cols = [
        //{ label: "Product Name", fieldName: "Name", type: "text", sortable: "true", initialWidth: 230},
        { label: 'Product Code', fieldName: 'link', type: 'url', sortable: 'true', initialWidth: 160, typeAttributes: { label: { fieldName: 'ProductCode' }, target: '_blank' } },
        { label: "Description", fieldName: "Description", type: "text", sortable: "true", initialWidth: 350 },
        { label: "Product Range", fieldName: "Product_Range__c", type: "text", sortable: "true", initialWidth: 130 },
        { label: "Product Size", fieldName: "Product_Size__c", type: "text", sortable: "true", initialWidth: 130 },
        { label: "Product Type", fieldName: "Product_Type__c", type: "text", sortable: "true", initialWidth: 150 },
        { label: 'View', type: 'button-icon', size: "xx-small", initialWidth: 100 ,
            typeAttributes: {
                iconName: 'action:preview',
                title: 'View Product Details',
                alternativeText: 'View',
                variant: "bare"
            }
        }

    ];

    // Variable Declarations
    userRecordTypeId;
    @api recordId;
    @api accountId;
    @api country;
    @api channel;

    stage1 = true;
    stage2 = false;
    @track productRangeFilter = null;
    searchValue = null;
    haveSelectedProduct = false;
    pricebookId;
    currencyIsoCode;
    showSpinner = false;

    @track items = [];
    numberOfProductSelected = 0;
    numberOfResults = 0;
    @track numberOfCurrentProductsInOLI;

    @track data;
    @track error;
    @track initialRecords;
    @track selectedRows = [];

    @track showSelectedProducts;

    @track dataAfterNeedFilter;
    @track dataAfterFamilyFilter;
    @track dataAfterClassFilter;
    @track dataAfterLineFilter;
    @track dataAfterTypeFilter;

    @track sortBy;
    @track sortDirection;


    @track modalContainer = false;
    @track contactRow = {};
    viewRecordId;
    @track OLIProducts = [];
    @track productsToShowOnSecondPage;

    currentStep = 1;

    modalBody = true;
    modalBody2 = false;
    productRangeMap = new Map();

    closeForm() {
        let recordId = this.recordId;
        this.dispatchEvent(new CustomEvent('close'));
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                actionName: 'view'
            }
        });
        eval("$A.get('e.force:refreshView').fire();");
        //window.location.reload();
        //this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleClose()
    {
        console.log('handleClose');
        this.show = false;
        this.dispatchEvent(new CustomEvent('closeform'));          
    }

    @wire(getRecord, { recordId: '$recordId', fields: [PRICEBOOK_FIELD, CURRENCYISOCODE_FIELD] })
    getRecord({ data, error }) {
        console.log('getRecord => ', data, error);
        if (data) {
            this.currencyIsoCode = getFieldValue(data, CURRENCYISOCODE_FIELD);
            this.pricebookId = getFieldValue(data, PRICEBOOK_FIELD);
            console.log("currencyIsoCode", this.currencyIsoCode);
            console.log("pricebookId", this.pricebookId);
            this.getTheProducts();
            this.getOppLineItems();
            
        }
        else if (error) {
            console.error('getRecord ERROR => ', JSON.stringify(error)); // handle error properly
        }
    }

    getOppLineItems() {
        getOpportunityLineItems({
            oliRecordId: this.recordId
        }).then(results => {
            this.OLIProducts = JSON.parse(JSON.stringify(results));
            console.log("this is the OLIProducts", this.OLIProducts);
            this.numberOfCurrentProductsInOLI = results.length;

        }).catch(error => {
            console.log("this is the erro from getOppLineItems Apex method", error);
        })
    }

    getTheProducts() {
        this.showSpinner = true;
        console.log("getTheProducts is caleld");
        this.data = [];
        getProducts({
            pricebookId: this.pricebookId,
            CurrencyCode: this.currencyIsoCode
        }).then(results => {
            console.log("this is the results from getProducts Apex Method", results);
            //console.log("this is the results in JSObject", JSON.stringify(results));
            //this.data = JSON.parse(JSON.stringify(results));
            //console.log("this is the results in JSObject", this.data);
            let index = 0;

            if (results.length > 0) {
                this.numberOfResults = results.length;
                this.data = results.map((d) => ({ ...d, link: '/lightning/r/Product2/' + d.Id + '/view' }));
            

                this.data.forEach(item => {
                    item.index = index++;
                    item.Quantity = 1;
                    item.Discount = 0;
                    item.PBEID = item.PricebookEntries[0].Id
                    item.UPrice = item.PricebookEntries[0].UnitPrice;
                });

            }

            this.initialRecords = this.data;
            console.log("this is the initialRecords", this.initialRecords)
            this.showSpinner = false;
        }).catch(error => {
            console.log("this is the erro from getProducts Apex method", error);
        })
    }

    handleSearch(event) {

        const searchKey = event.target.value.toLowerCase();
        console.log('the general search key is ', searchKey);
        // Write a if else statement, if pn, pf and pc is null, then use normal search key (the code below), else search using the filters.
        if (searchKey) {
            this.searchKey = searchKey;
            this.data = this.initialRecords;
            if (this.data) {
                let searchRecords = [];
                for (let record of this.data) {
                    let valuesArray = Object.values(record);
                    for (let val of valuesArray) {
                        console.log("val is " + val);
                        let strVal = String(val);
                        if (strVal) {
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
                
                this.data = searchRecords;
                this.numberOfResults = searchRecords.length;
            }
        } else {
            this.data = this.initialRecords;
            this.numberOfResults = this.data.length;
            this.searchKey = null;
        }
        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
    }


    searchFilters() {
        this.showSpinner = true;
        let formFields = Array.from(this.template.querySelectorAll('lightning-input-field'));
        console.log(formFields);
        if (formFields.length > 0) {
            let product = {};
            formFields.forEach(field => {
                console.log(field.fieldName + ' : ' + field.value);
                product[field.fieldName] = field.value;
            });

            console.log(product);

            getSearchResult({
                product: product,
                pricebookId: this.pricebookId,
                currencyCode: this.currencyIsoCode,
                searchTerm: this.searchKey
            })
                .then(results => {
                    if (results && results.length > 0) {
                        console.log(results);
                        this.data = [];
                        let index = 0;
                        this.numberOfResults = results.length;
                        this.data = results.map((d) => ({ ...d, link: '/lightning/r/Product2/' + d.Id + '/view' }));
        
                        this.data.forEach(item => {
                            item.index = index++;
                            item.Quantity = 1;
                            item.Discount = 0;
                            item.PBEID = item.PricebookEntries[0].Id
                            item.UPrice = item.PricebookEntries[0].UnitPrice;
                        });

                        this.initialRecords = this.data;

                    }
                    else {
                        this.numberOfResults = 0;
                        this.data = [];
                    }
                    this.showSpinner = false;
                })
                .catch(error => {
                    console.log('Error in query: ' + JSON.stringify(error));
                    this.showSpinner = false;
                });
        }
    }

    pnChange(event) {
        this.pnFieldValue = event.target.value;
        if (this.pnFieldValue !== null) {
            const datainJsobj = JSON.parse(JSON.stringify(this.data));
            console.log('this is the data we get', datainJsobj);
            var latestData = datainJsobj.filter(obj => {
                return obj.Product_Range__c == this.pnFieldValue;
            });
            this.data = latestData;
            this.dataAfterNeedFilter = latestData;
        }

        if (typeof this.pnFieldValue === 'string' && this.pnFieldValue.length === 0) {
            this.data = this.initialRecords;
        }
        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
    }


    handleShowSelected() {
        this.showSelectedProducts = this.template.querySelector('[data-id="datatable"]').getSelectedRows();
        this.stage1 = false;
        this.stage2 = true;
    }

    handleRowSelection(event) {
        this.productsToShowOnSecondPage = event.detail.selectedRows;
        console.log('this is the productsToShowOnSecondPage', this.productsToShowOnSecondPage);
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selectedRows);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();
        this.data.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });
        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });
            // Add any new items to the selectedRows list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }
        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });
        this.selectedRows = [...selectedItemsSet];
        console.log("selectedRows==> " + JSON.stringify(this.selectedRows));
        this.numberOfProductSelected = this.selectedRows.length;
        if (this.numberOfProductSelected > 0) {
            this.haveSelectedProduct = true;
        } else {
            this.haveSelectedProduct = false;
        }
    }

    /*     handleNext() {
            this.stage1 = false;
            this.stage2 = true;
        } */

    handlePrevious() {
        this.stage1 = true;
        this.stage2 = false;
    }

    // Source: https://www.apexhours.com/lightning-datatable-sorting-in-lightning-web-components/
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    // Source: https://www.apexhours.com/lightning-datatable-sorting-in-lightning-web-components/
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.data));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.data = parseData;
    }

    handleRowAction(event) {
        const dataRow = event.detail.row;
        this.viewRecordId = dataRow.Id;
        console.log('This is the viewRecordId: ' + this.viewRecordId);
        this.contactRow = dataRow;
        this.modalContainer = true;
    }

    closeModalAction() {
        this.modalContainer = false;
    }

    handlePreviousForStep(event) {
        this.currentStep = this.currentStep - 1;
        if (this.currentStep == 2) {
            this.page1 = true;
        }
    }
    handleNextForStep(event) {
        this.currentStep = this.currentStep + 1;
        this.page1 = false;
    }

    handleNext() {
        this.currentStep = this.currentStep + 1;
        this.modalBody = false;
        this.modalBody2 = true;

        this.items = [];

        let index = 1;
        this.OLIProducts.forEach(oli => {
            let item = {};
            item.index = index++;
            item.errors = [];
            item.Id = oli.Id;
        });
    }

    handlePreviousTwo() {
        this.currentStep = this.currentStep - 1;
        this.modalBody2 = false;
        this.modalBody = true;

    }

    handleResetFilter(event) {
        //this.data = this.initialRecords;
        this.searchValue = null;

        let inputFields = Array.from(this.template.querySelectorAll('lightning-input-field'));
        inputFields.forEach(field => {
            field.value = null;
        });

        let inputs = Array.from(this.template.querySelectorAll('lightning-input'));
        inputs.forEach(field => {
            field.value = null;
        });

        this.getTheProducts();

    }

    removeItem(event) {
        let idToDelete = event.target.dataset.index;
        console.log("this is the idtodelete", idToDelete);
        deleteRecord(idToDelete).then(() => {
            console.log("success callingDeleteProducts")
            return refreshApex(this.OLIProducts);
        }).catch(error => {
            console.log(error);
        });
        console.log("This is the ID I pass to delete", idToDelete);
    }

    inputChanged(event) {
        let item = this.productsToShowOnSecondPage.find(item => item.Id === event.target.dataset.id);
        console.log("this is the item", item);
        item[event.target.dataset.field] = event.detail.value;
        item.TotPrice = item.UPrice * item.Quantity;
        console.log("this it the item after the event target value", item);
    }

    createOLItem(event) {
        let item = this.productsToShowOnSecondPage.find(item => item.Id === event.target.dataset.id);
        console.log("this is the recordID", this.recordId);
        console.log("This is item for createOLIItem Id", item.Id);
        console.log("This is item for createOLIItem qty", item.Quantity);
        console.log("This is item for createOLIItem UPrice", item.UPrice);
        console.log("This is item for createOLIItem PBEID", item.PBEID);

        saveOLI({ OpId: this.recordId, ProdId: item.Id, qty: item.Quantity, sprice: item.UPrice, PriceBId: item.PBEID }).then(results => {
            console.log("this is the result of CreateOLIItem", results);
        }).catch(error => {
            console.log("this is the error from CreateOLIItem", error);
        })
    }

    /*handleAddSelectedProducts() {
        let title, message, variant;
        if (this.productsToShowOnSecondPage.length > 0) {
            //console.log("This is the products with checkbox checked, ", productsToAdd);
            this.productsToShowOnSecondPage.forEach(product => {
                console.log("This is the Product Index", product.index)
                this.showSpinner = true;
                saveOLI({ OpId: this.recordId, ProdId: product.Id, qty: product.Quantity, sprice: product.UPrice, PriceBId: product.PBEID, Discounts: product.Discount })
                    .then(result => {
                        console.log("added product", result);
                        //this.temporaryStorage.push(product)
                        //let index = this.productsToShowOnSecondPage.findIndex(item => item.Id == product.Id);
                        //this.productsToShowOnSecondPage.splice(index,1);
                        console.log("This is the new set of products to show on the second page", this.productsToShowOnSecondPage)
                        this.showSpinner = false;
                        title = 'Successfully saved record';
                        variant = 'success';
                        this.closeForm();
                    }).catch(error => {
                        let errorMsg = reduceErrors(error);
                        if (errorMsg && errorMsg.includes(', ')) {
                            errorMsg = errorMsg.split(', ')[1];
                        }
                        console.log(error);
                        title = 'Error saving record';
                        message = errorMsg;
                        variant = 'error';
                    }).finally(() => {
                        this.showSpinner = false;
                        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
                        //window.location.reload();
                    });
            })
        } else {
            alert("Please select some products!")
        }
    }*/

    handleAddSelectedProducts2() {
        let title, message, variant;
        if (this.productsToShowOnSecondPage.length > 0) {
            this.showSpinner = true;
            //console.log("This is the products with checkbox checked, ", productsToAdd);
            let oppItems = [];
            let OppItemWraps = [];
            this.productsToShowOnSecondPage.forEach(product => {
                console.log("Product", product);
                console.log("accountId", this.accountId);
                let OppItemWrap = {};
                let oppItem = {};
                oppItem.OpportunityId = this.recordId;
                oppItem.Product2Id = product.Id;
                oppItem.Quantity = product.Quantity;
                oppItem.PricebookEntryId = product.PBEID;
                oppItem.UnitPrice = product.UPrice;
                oppItems.push(oppItem);

                OppItemWrap.oppLineItem = oppItem;
                OppItemWrap.productRange = product.Product_Range__c;
                OppItemWraps.push(OppItemWrap);
            })

            saveItems({ OppItemWraps: OppItemWraps, accountId: this.accountId, country: this.country, channel: this.channel})
                    .then(result => {
                        console.log("added product", result);
                        this.showSpinner = false;
                        title = 'Successfully created Product(s)';
                        variant = 'success';
                        this.closeForm();
                    }).catch(error => {
                        let errorMsg = reduceErrors(error);
                        if (errorMsg && errorMsg.includes(', ')) {
                            errorMsg = errorMsg.split(', ')[1];
                        }
                        console.log(error);
                        title = 'Error saving Products';
                        message = errorMsg;
                        variant = 'error';
                    }).finally(() => {
                        this.showSpinner = false;
                        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
                        //window.location.reload();
                    });
        } else {
            alert("Please select some products!")
        }
    }
}

// to add
// Currency, total price for all products