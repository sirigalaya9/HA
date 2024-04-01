/*
* Opp Item Conversion screen to convert a generic (New) product levels
* @author manu.voramontri@kliqxe.com
* @since 06.03.2024
* @version 06.03.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 06.03.2024   manu.voramontri@kliqxe.com         Initial Version
*/
import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getObjectInfo, getPicklistValuesByRecordType } from "lightning/uiObjectInfoApi";
import { reduceErrors, generateGUID } from 'c/utils';
import PRODUCT_OBJECT from "@salesforce/schema/Product2";
//import getProductInfo from '@salesforce/apex/OpportunityProductConvertController.getProductInfo';
import getProductHierarchy from '@salesforce/apex/OpportunityProductConvertController.getProductHierarchy';
import convertOppItem from '@salesforce/apex/OpportunityProductConvertController.convertOppItem';
import getProducts from '@salesforce/apex/ProductLookupController.getProducts';
import LWC_Internal_Style from '@salesforce/resourceUrl/LWC_Internal_Style';
import { loadStyle } from 'lightning/platformResourceLoader';

import LBL_OpportunityLineItem_SelectGenericProduct from '@salesforce/label/c.LBL_OpportunityLineItem_SelectGenericProduct';
import BTN_OpportunityLineItem_Save from '@salesforce/label/c.BTN_OpportunityLineItem_Save';
import BTN_OpportunityLineItem_Cancel from '@salesforce/label/c.BTN_OpportunityLineItem_Cancel';

export default class OpportunityProductConvert extends LightningElement {

    label = {
        title: LBL_OpportunityLineItem_SelectGenericProduct,
        product: 'Product',
        searchProducts: 'Search Products...',
        cancel: BTN_OpportunityLineItem_Cancel,
        save: BTN_OpportunityLineItem_Save,
        successTitle: 'Success',
        successMessage: 'Selected item successfully',
        errorTitle: 'Error Selecting Item'
    };

    @api recordId;
    @api currencyIsoCode;
    @api pricebookId;
    @api salesOrgCode;
    @api languageCode;

    _item;
    @api
    set item(val) 
    {        
        if (val)
        {
            this._item = JSON.parse(JSON.stringify(val));
            console.log('item', this._item);            
            this.getProductHierarchy();
            //this.getProductInfo(val.Product2.Id);
        }
    }
    get item() 
    {
        return this._item;
    } 

    searchTerm;
    products;
    selectedProduct;    
    errors = [];
    showSpinner = false;    

    @api objectApiName;
    @api objectRecordTypeId;
    @api controllerFieldApiName = 'PCM_Hierarchy_1__c';
    @api controllerFieldLabel = 'PCM Hierarchy 1';

    @api dependentFieldApiName = 'PCM_Hierarchy_3__c';
    @api dependentFieldLabel = 'PCM Hierarchy 3';

    @api dependentFieldApiName2 = 'PCM_Hierarchy_3__c';
    @api dependentFieldLabel2 = 'PCM Hierarchy 3';    
     
    @track controllerValue;
    @track dependentValue;
    @track dependentValue2;
 
    controllingPicklist=[];
    dependentPicklist;
    dependentPicklist2;
    @track finalDependentVal=[];
    @track finalDependentVal2=[];
    @track selectedControlling="--None--";
    @track selectedControlling2;
    @track selectedControlling3;
  
    showpicklist = false;
    dependentDisabled=true;
    dependentDisabled2=true;
    showdependent = false;  
    showdependent2 = false;  

    productHierarchy = [];

    getProductHierarchy()
    {
        console.log('getProductHierarchy');
        this.showSpinner = true;
        getProductHierarchy()
        .then(result => {
            console.log('getProductHierarchy result', result); 
            this.productHierarchy = result;
            
            let optionsValue = {}
            optionsValue["label"] = "--None--";
            optionsValue["value"] = "";
            this.controllingPicklist.push(optionsValue);            
            this.productHierarchy.forEach(optionData => {
                this.controllingPicklist.push({label : optionData.label, value : optionData.value});
            });     
            if (this.item && this.item.Product2)
            {
                //this.getProductInfo(this.item.Product2.Id); 
                this.selectedControlling = this.item.Product2[this.controllerFieldApiName];            
                this.populateDependentValue(this.selectedControlling);
                if (this.item.Product2[this.dependentFieldApiName])
                {
                    this.selectedControlling2 = this.item.Product2[this.dependentFieldApiName]; 
                    this.populateDependentValue2(this.selectedControlling2); 
                }                 
            } 
            /*
            else
            {
                this.showSpinner = false;
            } 
            */          
            this.showpicklist = true;        
        }).catch(error => {
            console.log(error);
        }).finally(() => {
            this.showSpinner = false;            
        });
    }

    /*
    getProductInfo(productId)
    {
        console.log('getProductInfo', productId);
        this.showSpinner = true;
        getProductInfo({ productId  })
        .then(result => {
            console.log('getProductInfo result', result);       
            this.selectedControlling = result[this.controllerFieldApiName];            
            this.populateDependentValue(this.selectedControlling);
            if (result[this.dependentFieldApiName])
            {
                this.selectedControlling2 = result[this.dependentFieldApiName]; 
                this.populateDependentValue2(this.selectedControlling2); 
            }                   
        }).catch(error => {
            console.log(error);
        }).finally(() => {
            this.showSpinner = false;            
        });
    }
    */
    
    @wire(getObjectInfo, { objectApiName: PRODUCT_OBJECT })
    productInfo({ data, error }) {
        if (data) 
        {
            console.log('productInfo', data);
            this.controllerFieldLabel = data.fields[this.controllerFieldApiName].label;
            this.dependentFieldLabel = data.fields[this.dependentFieldApiName].label;
            this.dependentFieldLabel2 = data.fields[this.dependentFieldApiName2].label;
            this.label.product = data.label;
            this.label.searchProducts = 'Search ' + data.labelPlural + '...';
        }
    }    
 
    fetchDependentValue(event)
    {
        const selectedVal = event.target.value;
        this.populateDependentValue(selectedVal);        
    }

    populateDependentValue(selectedVal)
    {
        console.log('populateDependentValue', selectedVal);
        this.dependentDisabled = true;
        this.dependentDisabled2 = true;
        this.finalDependentVal=[];
        this.finalDependentVal2=[];
        this.showdependent = false;
        
        this.controllerValue = selectedVal;
        this.finalDependentVal.push({label : "--None--", value : ""});
        this.dependentValue = null;

        this.productHierarchy.forEach(optionData => {
            if (selectedVal === optionData.value)
            {
                optionData.dependentOptions.forEach(option =>  {                    
                    this.dependentDisabled = false;
                    this.showdependent = true;                    
                    this.finalDependentVal.push({label : option.label, value : option.value});
                });
            }            
        }); 
        /*
        //this.getProducts(null, true);
        */
        if (this.template.querySelector('c-lookup[data-name="Product2Id"]'))
        {
            this.template.querySelector('c-lookup[data-name="Product2Id"]').setSearchResults([]); 
            this.template.querySelector('c-lookup[data-name="Product2Id"]').setDefaultResults([]); 
        }
    }    
 
    handleDependentPicklist(event)
    {        
        const selectedVal = event.target.value;
        console.log('handleDependentPicklist', selectedVal);
        this.populateDependentValue2(selectedVal);
    }
    populateDependentValue2(selectedVal)
    {
        this.dependentValue = selectedVal;
        
        if (this.template.querySelector('c-lookup[data-name="Product2Id"]'))
        {
            this.template.querySelector('c-lookup[data-name="Product2Id"]').setSearchResults([]); 
            this.template.querySelector('c-lookup[data-name="Product2Id"]').setDefaultResults([]); 
        }
        this.getProducts(null, true);
    }

    handleLookupFocus()
    {
        console.log('handleLookupFocus', this.searchTerm);
    }

    handleSearch(event)
    {                
        let searchTerm = event.detail.searchTerm;
        this.searchTerm = searchTerm;
        console.log('handleSearch', searchTerm);        
        this.getProducts(searchTerm, false);
    }
    
    getProducts(searchTerm, setDefaultResults) 
    {
        console.log('getProducts', searchTerm, setDefaultResults, this.recordId, this.currencyIsoCode, this.pricebookId, this.salesOrgCode, this.controllerValue, this.dependentValue);
        searchTerm = searchTerm ? '%' + searchTerm + '%' : '%';        
        getProducts({ recordId: this.recordId, currencyIsoCode: this.currencyIsoCode, pricebookId: this.pricebookId, searchTerm: searchTerm, salesOrgCode: this.salesOrgCode, hierarchy1: this.controllerValue, hierarchy3: this.dependentValue, languageCode: this.languageCode })
        .then(result => {
            console.log('getProducts', result);
            let results = [];
            result.forEach(item => {
                let result = {
                    id: item.Id,
                    sObjectType: 'Product2',
                    icon: 'standard:product',
                    title: item.Product_Code_Format__c,
                    subtitle: item.Description,
                    productCode: item.ProductCode,
                    listPrice: item.PricebookEntries[0].UnitPrice,
                    oha: item.OHA_Classification__c,
                    generic: item.PCM_Product__c
                };
                results.push(result);
            });
            if (setDefaultResults)
            {
                this.template.querySelector('c-lookup[data-name="Product2Id"]').setDefaultResults(results);                
            }
            else
            {
                this.template.querySelector('c-lookup[data-name="Product2Id"]').setSearchResults(results);
            }
        }).catch(error => {
            console.log(error);
        }).finally(() => {
            this.showSpinner = false;
        });
    }

    handleSelectionChange(event) {
        
        let value = event.detail[0];
        console.log('handleSelectionChange', value);      
        const selection = event.target.getSelection();
        console.log('selection', selection);
        if (value) {
            this.selectedProduct = value;
        }
        else {
            this.selectedProduct = null;
        }
    }    

    close()
    {
        console.log('close');         
        this.dispatchEvent(new CustomEvent('closeform'));
    }

    connectedCallback()
    {
        console.log('connectedCallback'); 
        loadStyle(this, LWC_Internal_Style); //override standard component style - for modal overflow        
    }    

    async handleSave() {
        this.showSpinner = true;
        try {           
            console.log('handleSave', this.item.Id, this.controllerValue, this.dependentValue, this.selectedProduct); 
            let quantity = this.item.Quantity;
            let unitPrice = this.item.UnitPrice;
            let oha = this.item.OHA__c;
            let productId;
            if (this.selectedProduct)
            {
                productId = this.selectedProduct;
            }
            else
            {
                let item = this.productHierarchy.find(i => i.value === this.controllerValue);  
                if (item)
                {
                    productId = item.productId;
                    if (this.dependentValue)
                    {
                        let childItem = item.dependentOptions.find(i => i.value === this.dependentValue);  
                        if (childItem)
                        {
                            productId = childItem.productId;
                        }
                    }                
                }
            }
            console.log('productId', productId);
            //await convertOppItem({oppItemId: this.item.Id, level1: this.controllerValue, level2: this.dependentValue, level3: this.dependentValue2});
            await convertOppItem({oppId: this.item.OpportunityId, oppItemId: this.item.Id, productId: productId, quantity, unitPrice, oha});
            const evt = new ShowToastEvent({
                title: this.label.successTitle,
                message: this.label.successMessage,
                variant: "success"
            });
            this.dispatchEvent(evt);
            console.log('close');            
            this.dispatchEvent(new CustomEvent('closeform'));
        }
        catch (error) {
            console.log(error);
            let title = this.label.errorTitle;
            let message = reduceErrors(error);
            let variant = 'error';              
            const evt = new ShowToastEvent({ title, message, variant });
            this.dispatchEvent(evt);         
        } finally {
            console.log('Finally Block');
            this.showSpinner = false;

        }
    }
}