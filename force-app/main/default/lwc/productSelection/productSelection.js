/*
* 
*
*
*
*
*/

import { track, api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { MessageContext, publish } from 'lightning/messageService';
//import RefreshWizard from '@salesforce/messageChannel/RefreshWizard__c';
import getProducts from '@salesforce/apex/ProductWizardController.getProducts';
import searchProducts from '@salesforce/apex/ProductWizardController.searchProducts';
/*import saveAllProducts from '@salesforce/apex/ProductWizardController.saveAllProducts';
import getOpportunityProductsByRoom from '@salesforce/apex/ProductWizardController.getOpportunityProductsByRoom';
import deleteProducts from '@salesforce/apex/ProductWizardController.deleteProducts';
import replaceProducts from '@salesforce/apex/ProductWizardController.replaceProducts';
import reorderRoomModal from 'c/reorderRoomModal';
import productSalesPriceMismatchModal from 'c/productSalesPriceMismatchModal';
import detectSalesPriceMismatch from '@salesforce/apex/ProductWizardController.detectSalesPriceMismatch';
import getProductData from '@salesforce/apex/ProductWizardController.getProductData';*/
import ProductFilter from './productFilter';
import { reduceErrors } from 'c/utils';

export default class ProductSelection extends LightningModal {
    
    @api recordId;
    @api room;
    @api activeTabValue;
    @api tabName;
    
    @track selectedList = [];
    
    @wire(MessageContext)
    messageContext;

    sticky = false;
    timeout = 3000;

    columns = [
        { label: 'Name', fieldName: 'link', type: 'url', sortable: 'true', initialWidth: 250, typeAttributes: { label: { fieldName: 'Name' }, target: '_blank' } },
        //{ label: 'Name', fieldName: 'Name' },
        { label: 'Product Code', fieldName: 'ProductCode'},
        //{ label: 'Description', fieldName: 'Description'},
        //{ label: 'Material Group', fieldName: 'MaterialGroup'},
        //{ label: 'Material Number', fieldName: 'MaterialNumber'},
        { label: 'Product Hierarchy', fieldName: 'ProductHierarchy'},
        //{ label: 'List Price', fieldName: 'ListPrice'},
        
    ];

    init = false;
    editTabName = 'Edit Products (0)';
    filerTabClass = 'slds-col slds-size_9-of-12';
    showFilter = true;
    modalName;
    products;
    showAddFooter = true;
    showSpinner = false;
    showSearchSpinner = false;
    currencyIsoCode;
    listToUpdate = [];
    childList = [];

    //search filter fields
    ph1val;
    ph2val;
    ph3val;
    codeInput;
    priceInput = 0;
    productFilter = new ProductFilter();
    productFilterData = {
        filterOptions: {},
        selectedFilterValues: {},
        showOtherFilters: false,
        selectedFilters: [],
        visibility: {}
    };

    /*@wire(getProductData, {})
    wiredCategoryBrandCombinations({ error, data }) {
        if (data) {
            this.updateProductFilterField('productData', data);
        } else if (error) {
            console.log(error);
        }
    }*/

    updateProductFilterField(fieldName, value){
        this.productFilter[fieldName] = value;
        this.productFilterData = this.productFilter.data;
    }

    async handleFilterOnChange(event){
        let name = event.target.dataset.filterName;
        let value = event.detail.value;

        this.showSearchSpinner = true;

        try{
            this.productFilter.selectFilter(name, value);
            this.productFilterData = this.productFilter.data;
        }catch(error){
            console.log(error);
        }

        this.showSearchSpinner = false;
    }

    get showOtherFilters(){
        return this.productFilterData.selectedFilterValues.category__c || this.productFilterData.selectedFilterValues.brand__c;
    }
        

    //use to set the sequence
    position = 0;

    // Selected rows
    @track selectedRows = {};
    showSelected = false;

    renderedCallback(){
        console.log('renderedCallback');
        if(!this.init) {

            this.showSearchSpinner = true;
            this.showSpinner = true;
            this.modalName = 'Product Wizard (' + this.tabName + ')'; 

            getProducts({ recordId: this.recordId }).then(response => {

                this.products = response;
                this.products = response.map((d) => ({ ...d, link: '/lightning/r/Product2/' + d.Product2Id + '/view' }));

                if(!this.currencyIsoCode) {

                    this.currencyIsoCode = response[0].CurrencyIsoCode;
                }
            })
            .catch(error => {

                console.error ('Error:' + reduceErrors(error));
            })
            .finally(() => {
                this.showSpinner = false;
                this.showSearchSpinner = false;
                /*getOpportunityProductsByRoom({roomId : this.room.id}).then(response => {

                    let elementWithRelationship = [];

                    response.forEach(element => {
                        
                        if(!element.RelationshipType) {

                            element.requiredCount = 0;
                            element.recommendedCount = 0;
                            element.upsellCount = 0;
                            element.sparesCount = 0;
                            this.selectedList.push(element);
                        }
                        else {

                            elementWithRelationship.push(element);
                        }
                    });

                    elementWithRelationship.forEach(element => {

                        let index = this.selectedList.findIndex(item => item.UniqueId == element.ParentId);
                        let x = this.selectedList[index];

                        switch(element.RelationshipType) {

                            case 'Products Must be used with':

                                x.requiredCount++;
                                break;

                            case 'Compatible / Recommended Products':

                                x.recommendedCount++;
                                break;

                            case 'Upsell Product/s':
                                
                                x.upsellCount++;
                                break;
                            
                            case 'Spares, Compatible Product Spares':
                                x.sparesCount++;
                                break;

                            default:
                                
                        }
                    });

                    //set current position
                    this.position = this.selectedList.length;
                    
                })
                .catch(error => {

                    console.error ('Error:' + reduceErrors(error));
                })
                .finally(() => {
        
                    this.setEditTabName(this.selectedList.length);
                    this.showSearchSpinner = false;
                    this.showSpinner = false;
                });*/
            });
    
            this.init = true;
        }
    } 

    handleRowSelection(event){
        let currentSelectedRows = event.detail.selectedRows;
        let currentSelectedRowIds = new Set(currentSelectedRows.map(row => row.Product2Id));
        let newSelectedRows = {...this.selectedRows};

        // Add selected row
        for(let selectedRow of currentSelectedRows){
            newSelectedRows[selectedRow.Product2Id] = selectedRow;
        }

        // Create unselected row ids
        let unselectedRowIds = new Set();

        for(let product of this.datatableData){
            if(!currentSelectedRowIds.has(product.Product2Id)){
                unselectedRowIds.add(product.Product2Id);
            }
        }
        
        // Deselect row
        for(let rowId of Object.keys(this.selectedRows)){
            if(unselectedRowIds.has(rowId)){
                delete newSelectedRows[rowId];
            }
        }

        this.selectedRows = newSelectedRows;
    }

    get showSelectedStyle(){
        if(Object.keys(this.selectedRows).length > 0 || this.showSelected){
            return "color: blue;cursor: pointer; user-select: none;";
        }else{
            return "color: grey;cursor: pointer; user-select: none;";
        }
    }

    get showSelectedLabel(){
        return this.showSelected?
                "Back to All Products"
                :`Show Selected (${Object.keys(this.selectedRows).length})`
    }

    handleShowSelectedClick(){
        this.showSelected = !this.showSelected;
    }

    get datatableData(){
        if(this.showSelected){
            return Object.values(this.selectedRows);
        }else{
            return this.products;
        }
    }

    get selectedRowIds(){
        return Object.keys(this.selectedRows);
    }
    
    handleAddProducts() {

        let count = 0;

        var selectedRecords =  Object.values(this.selectedRows); 
        this.selectedRows = {};

        selectedRecords.forEach(element => {
            // Check if product already exist
            // If exist, skip
            let isExist = this.selectedList.find(item => item.Product2Id === element.Product2Id);
            if(isExist){
                return;
            }

            count++;
            let payload = {};
            
            /*let uniqueId = Date.now() + Math.floor(Math.random() * 100000);
            let uniqueId2 = Date.now() + Math.floor(Math.random() * 100000);
            let uniqueIdStr = uniqueId.toString() + uniqueId2.toString();

            payload.UniqueId = uniqueIdStr;*/
    
            payload.OpportunityId = this.recordId.substring(0,3) == '006' ? this.recordId : undefined;
            payload.QuoteId = this.recordId.substring(0,3) == '0Q0' ? this.recordId : undefined;
            payload.OpportunityLineItemId = '';
            payload.QuoteLineItemId = '';
            payload.PricebookEntryId = element.PricebookEntryId;
            payload.ProductCode = element.ProductCode;
            payload.ProductName = element.ProductName;
            payload.Name = element.Name;
            payload.Product2Id = element.Product2Id;
            payload.Quantity = null;
            payload.SalesPriceDiscount = 0;
            payload.UnitPrice = element.UnitPrice;
            payload.ListPrice = element.ListPrice;
            payload.TotalPrice = element.TotalPrice;
            payload.Description = element.Description;
            payload.CurrencyIsoCode = element.CurrencyIsoCode;
            /*payload.RoomId = this.room.id;
            payload.ImageUrl = element.ImageUrl;
            payload.RelationshipType = element.RelationshipType;
            payload.RelationshipId = element.RelationshipId;
            payload.Checked = element.Checked;
            payload.ParentId = element.ParentId;
            payload.requiredCount = 0;
            payload.recommendedCount = 0;
            payload.upsellCount = 0;
            payload.sparesCount = 0;
            payload.Sequence = this.position + 1;
            payload.CurrentCost = element.CurrentCost;*/

            // Calculate margin
            /*if(element.Margin){
                payload.Margin = element.Margin;
            }else {
                if(element.UnitPrice && element.CurrentCost && element.UnitPrice !== 0){
                    payload.Margin = (((element.UnitPrice - element.UnitPrice)/element.UnitPrice) * 100).toFixed(2);
                }
            }*/

            // Calculate discount
            if(element.SalesPriceDiscount){
                payload.SalesPriceDiscount = element.SalesPriceDiscount;
            }else {
                if(element.UnitPrice && element.ListPrice && element.ListPrice !== 0){
                    payload.SalesPriceDiscount = (((element.ListPrice - element.UnitPrice)/element.ListPrice) * 100).toFixed(2);
                }
            }

            this.position += 1;

            this.selectedList.push(payload);
            console.log(this.selectedList);
            /*this.dispatchEvent(
                new CustomEvent("addproduct", {
                    detail: this.selectedList
                })
            );*/
            this.close(this.selectedList);
        });

        switch(count) {

            case 1:
                this.showToast('success', '1 product has been added.');
                break;

            default:
                this.showToast('success', count + ' products have been added.');

        }

        this.setEditTabName(this.selectedList.length);
    }

    handleAddAndEditProducts() {

        let count = 0;

        var selectedRecords =  Object.values(this.selectedRows); 
        this.selectedRows = {};  
        
        selectedRecords.forEach(element => {
            // Check if product already exist
            // If exist, skip
            let isExist = this.selectedList.find(item => item.Product2Id === element.Product2Id);
            if(isExist){
                return;
            }

            count++;
            let payload = {};

            /*let uniqueId = Date.now() + Math.floor(Math.random() * 100000);
            let uniqueId2 = Date.now() + Math.floor(Math.random() * 100000);
            let uniqueIdStr = uniqueId.toString() + uniqueId2.toString();*/

            //payload.UniqueId = uniqueIdStr;
            payload.OpportunityId = this.room.opportunityId;
            payload.QuoteId = this.room.quoteId;
            payload.OpportunityLineItemId = '';
            payload.QuoteLineItemId = '';
            payload.PricebookEntryId = element.PricebookEntryId;
            payload.ProductCode = element.ProductCode;
            payload.ProductName = element.ProductName;
            payload.Name = element.Name;
            payload.Product2Id = element.Product2Id;
            payload.Quantity = null;
            payload.PreviousQuantity = null;
            payload.Discount = 0;
            payload.UnitPrice = element.UnitPrice;
            payload.ListPrice = element.ListPrice;
            payload.TotalPrice = element.TotalPrice;
            payload.Description = element.Description;
            payload.CurrencyIsoCode = element.CurrencyIsoCode;
            /*payload.RoomId = this.room.id;
            payload.ImageUrl = element.ImageUrl;
            payload.RelationshipType = element.RelationshipType;
            payload.RelationshipId = element.RelationshipId;
            payload.Checked = element.Checked;
            payload.ParentId = element.ParentId;
            payload.requiredCount = 0;
            payload.recommendedCount = 0;
            payload.upsellCount = 0;
            payload.sparesCount = 0;
            payload.Sequence = this.position + 1;
            payload.CurrentCost = element.CurrentCost;*/

            // Calculate margin
            /*if(element.Margin){
                payload.Margin = element.Margin;
            }else {
                if(element.UnitPrice && element.CurrentCost && element.UnitPrice !== 0){
                    payload.Margin = (((element.UnitPrice - element.CurrentCost)/element.UnitPrice) * 100).toFixed(2);
                }
            }*/

            // Calculate discount
            if(element.SalesPriceDiscount){
                payload.SalesPriceDiscount = element.SalesPriceDiscount;
            }else {
                if(element.UnitPrice && element.ListPrice && element.ListPrice !== 0){
                    payload.SalesPriceDiscount = (((element.ListPrice - element.UnitPrice)/element.ListPrice) * 100).toFixed(2);
                }
            }

            this.position += 1;

            this.selectedList.push(payload);
        });

        switch(count) {

            case 1:
                this.showToast('success', '1 product has been added.');
                break;
            default:
                this.showToast('success', count + ' products have been added.');

        }

        this.setEditTabName(this.selectedList.length);
        this.activeTabValue = 'edit';
    }

    setEditTabName(x) {

        this.editTabName = 'Edit Products (' + x + ')';
    }

    handleCodeInputChange(event) {

        this.codeInput =  event.detail.value;
    }

    handleSearch() {
        this.showSearchSpinner = true;
        let filters = this.productFilterData.selectedFilterValues;

        if(this.codeInput) {
            filters.ProductCode = this.codeInput;
        }

        console.log("filters: ", filters);

        searchProducts({ 
            filters: filters,
            currencyIsoCode: this.currencyIsoCode,
            price: this.priceInput
        }).then(response => {

            this.products = response;
            this.products = this.products.map((d) => ({ ...d, link: '/lightning/r/Product2/' + d.Product2Id + '/view' }));
        })
        .catch(error => {

            console.log ('Error:' +error.body.message);
        })
        .finally(() => {

            this.showSearchSpinner = false;
        });
    }

    async handleSaveAll() {

        this.showSpinner = true;

        try{
            let salesPriceMismatchCheckResult = await this.checkSalesPriceMismatch();

            if(salesPriceMismatchCheckResult.status === 'cancelled'){
                this.showSpinner = false;
                return;
            }else if(salesPriceMismatchCheckResult.status === 'success'){
                if(salesPriceMismatchCheckResult.data){
                    let userSelections = salesPriceMismatchCheckResult.data;
                    for(let el of Object.values(userSelections)){
                        let productId = el.productData.productId;

                        for(let product of this.listToUpdate){
                            if(product.Product2Id === productId){
                                product.UnitPrice = el.value;
                            }
                        }
                    }
                }
            }

            // Filter
            let productsToDelete = [];
            let productsToUpdate = [];

            for(let el of this.listToUpdate){
                if(el.ToDelete){
                    productsToDelete.push(el);
                }else{
                    productsToUpdate.push(el);
                }
            }
            
            // Delete
            await deleteProducts({payloads: productsToDelete, room: this.room});

            // Save
            let saveResult = await saveAllProducts({ payloads: productsToUpdate, room: this.room });
            
            saveResult.forEach(element => {

                switch(element.RelationshipType) {

                    case 'Products Must be used with':

                        break;

                    case 'Compatible / Recommended Products':
 
                        break;

                    case 'Upsell Product/s':
                        
                        break;

                    default:

                        let index = this.selectedList.findIndex(item => item.UniqueId === element.UniqueId);
                        
                        if(this.selectedList[index]) {

                            this.selectedList[index] = element;
                        }
                        break;
                        
                }
            });

            this.showToast('success', this.selectedList.length + ' product(s) saved successfully.');
        }catch(error){
            this.showToast('error', this.product.productCode + ' - ' + this.product.description + ' not saved.');
        }

        this.showSpinner = false;
        this.listToUpdate = [];
    }

    async checkSalesPriceMismatch(){
        let salesPriceMismatch = await detectSalesPriceMismatch({
            payloads: this.listToUpdate, 
            recordId: this.recordId
        });

        if(salesPriceMismatch.length > 0){
            const result = await productSalesPriceMismatchModal.open({
                size: 'small',
                description: 'Accessible description of modal\'s purpose',
                productOptions: salesPriceMismatch,
                message: 'The following products have a sales price mismatch. Please select a sales price for each product.'
            });

            return result;
        }

        return {
            status: 'success'
        }
    }

    async handleSaveAllAndClose() {
        this.showSpinner = true;
        try{
            let salesPriceMismatchCheckResult = await this.checkSalesPriceMismatch();

            if(salesPriceMismatchCheckResult.status === 'cancelled'){
                this.showSpinner = false;
                return;
            }else if(salesPriceMismatchCheckResult.status === 'success'){
                if(salesPriceMismatchCheckResult.data){
                    let userSelections = salesPriceMismatchCheckResult.data;
                    for(let el of Object.values(userSelections)){
                        let productId = el.productData.productId;

                        for(let product of this.listToUpdate){
                            if(product.Product2Id === productId){
                                product.UnitPrice = el.value;
                            }
                        }
                    }
                }
            }

            // Filter
            let productsToDelete = [];
            let productsToUpdate = [];

            for(let el of this.listToUpdate){
                if(el.ToDelete){
                    productsToDelete.push(el);
                }else{
                    productsToUpdate.push(el);
                }
            }
            
            // Delete
            await deleteProducts({payloads: productsToDelete, room: this.room});

            // Save
            let saveResult = await saveAllProducts({ payloads: productsToUpdate, room: this.room });
            
            this.showToast('success', this.selectedList.length + ' product(s) saved successfully.');
            publish(this.messageContext, RefreshWizard, { update: true });
            this.close('some response here');
        }catch(error){
            this.showToast('error', 'Error:' + reduceErrors(error));
        }

        this.showSpinner = false;
    }

    async handleReorderProducts() {

        const result = await reorderRoomModal.open({

            size: 'small',
            description: 'Accessible description of modal\'s purpose',
            rooms: this.selectedList,
            isProduct: true,
            label: 'Reorder Products X'
        });

        let x = JSON.parse(JSON.stringify(result));
        this.selectedList = [];
        this.selectedList = this.selectedList.concat(x);
    }

    async handleCheckProductAvailability(){
        let productRows = this.template.querySelectorAll('c-product-row');
        let promises = [];
        this.showSpinner = true;

        for(let productRow of productRows){
            promises.push(productRow.checkStockAvailability());
        }

        Promise.all(promises).then(result => console.log("Product Selection: done product availability checking"))
        .catch(error => {
            let errorMessage = reduceErrors(error);

            this.showToast('error', 'Product availability checking failed: ' + errorMessage);
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }

    async handleCheckPricing(){
        let productRows = this.template.querySelectorAll('c-product-row');
        let promises = [];
        this.showSpinner = true;

        for(let productRow of productRows){
            promises.push(productRow.checkPricing());
        }

        Promise.all(promises).then(result => console.log("Product Selection: done price checking"))
        .catch(error => {
            let errorMessage = reduceErrors(error);

            this.showToast('error', 'Price checking failed: ' + errorMessage);
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }

    handleAddTab() {

        this.showAddFooter = true;
        this.activeTabValue = 'add';
    }

    handleEditTab() {

        this.showAddFooter = false;
        this.activeTabValue = 'edit';
    }

    handleToggleFilter() {

        this.showFilter = (this.showFilter) ? false : true;
        this.filerTabClass = (this.showFilter) ? 'slds-col slds-size_9-of-12' : 'slds-col slds-size_12-of-12';
    }

    removeItemByUniqueId(list, uniqueId) {
        let index = list.findIndex(item => item.UniqueId == uniqueId);

        if(list[index]) {
            list.splice(index, 1);
        };
    }

    handleRowDeleteEvent(event) {
        let productRowsToDelete = event.detail.detail;

        for(let productRow of productRowsToDelete){
            let index = this.listToUpdate.findIndex(item => item.UniqueId ===  productRow.UniqueId);

            if(this.listToUpdate[index]) {
                this.listToUpdate[index] = productRow;
            }
            else {
                this.listToUpdate.push(productRow);
            }
        }
    }

    handleChildDeleteEvent(event) {

        let index = this.listToUpdate.findIndex(item => item.UniqueId === event.detail.UniqueId);

        if(this.listToUpdate[index]) {
            this.listToUpdate[index] = event.detail;
        }
        else {
            this.listToUpdate.push(event.detail);
        }
    }

    handleProductUpdate(event) {

        let index = this.listToUpdate.findIndex(item => item.UniqueId == event.detail.UniqueId);

        if(this.listToUpdate[index]) {
            
            this.listToUpdate[index] = event.detail;
        }
        else {

            this.listToUpdate.push(event.detail);
        }
    }

    handleProductClone(event) {

        let uniqueId = Date.now() + Math.floor(Math.random() * 100000);
        let uniqueId2 = Date.now() + Math.floor(Math.random() * 100000);
        let uniqueIdStr = uniqueId.toString() + uniqueId2.toString();

        let clonedProduct = event.detail;
        clonedProduct.OpportunityLineItemId = null;
        clonedProduct.QuoteLineItemId = null;
        clonedProduct.RoomItemId = null;
        clonedProduct.UniqueId = uniqueIdStr;
        clonedProduct.PreviousQuantity = 0;
        clonedProduct.Sequence = this.position + 1;
        this.position += 1;

        this.selectedList.push(clonedProduct);
        this.listToUpdate.push(clonedProduct);
    }

    handleProductReplacement(event) {

        this.showSpinner = true;
        let replacement = event.detail.replacement;

        let current = event.detail.current;
        current.ToDelete = true;

        replacement.Checked = current.Checked;
        replacement.Sequence = current.Sequence;
        replacement.Quantity = current.Quantity;
        replacement.requiredCount = 0;
        replacement.recommendedCount = 0;
        replacement.upsellCount = 0;
        replacement.ParentId = null;
        replacement.RelationshipId = null;
        replacement.RelationshipType = null;

        replaceProducts({ current: current, replacement: replacement, room: this.room }).then(result => {

            let currentIndex = this.selectedList.findIndex(item => item.UniqueId === current.UniqueId);
            this.selectedList[currentIndex] = result[0];
        })
        .catch(error => {

            this.showToast('error', 'product replacement failed.');
            console.log(error);
        })
        .finally(() => {

             this.showSpinner = false;
        });
    }
    
    handlePriceChange(event) {

        this.priceInput = event.detail.value;
    }

    showToast(variant, msg) {
        this.template
        .querySelector("c-custom-toast-notification")
        .showToast(variant, msg);
    }

    numberWithCommas(x) {
        if(x){
            return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        }
        
        return x;
    }

    get showResetFilters(){
        return this.codeInput != null || this.productFilterData.selectedFilters.length > 0 || this.priceInput > 0
        || this.ph1val != null || this.ph2val != null || this.ph3val != null;
    }

    async handleResetFilters(){
        this.codeInput = null;
        this.priceInput = 0;

        this.ph1val = null;
        this.ph2val = null;
        this.ph3val = null;
        
        // Reset filters
        this.productFilter.reset();
        this.productFilterData = this.productFilter.data;

        // Refresh product results
        this.showSearchSpinner = true;

        try{
            this.products = await getProducts({ recordId: this.recordId });
            this.products = this.products.map((d) => ({ ...d, link: '/lightning/r/Product2/' + d.Product2Id + '/view' }));
        }catch(error){
            console.log("error: ", error);
        }
        
        this.showSearchSpinner = false;
    }

    handleClose() {
        this.close('some response here');
    }
}