// labels.js
import { LightningElement } from 'lwc'; 
import CheckPricing from '@salesforce/label/c.BTN_OpportunityLineItem_CheckPricing';
import Add from '@salesforce/label/c.BTN_OpportunityLineItem_Add';  
import Refresh from '@salesforce/label/c.BTN_OpportunityLineItem_Refresh';  
import Save from '@salesforce/label/c.BTN_OpportunityLineItem_Save';
import TotalAmount from '@salesforce/label/c.LBL_OpportunityLineItem_TotalAmount';
import No from '@salesforce/label/c.LBL_OpportunityLineItem_No'; 
import Remove from '@salesforce/label/c.LBL_OpportunityLineItem_Remove';
import SelectGenericProduct from '@salesforce/label/c.LBL_OpportunityLineItem_SelectGenericProduct';

export const labels = {
    CheckPricing, // Key matches the API name of the custom label
    Add,
    Refresh,
    Save,
    TotalAmount,
    No,
    Remove,
    SelectGenericProduct
}