// labels.js
import { LightningElement } from 'lwc'; 
import CheckPricingAvailability from '@salesforce/label/c.BTN_QuoteLineItem_CheckPricingATP';
import Add from '@salesforce/label/c.BTN_QuoteLineItem_Add';  
import Refresh from '@salesforce/label/c.BTN_QuoteLineItem_Refresh';  
import Save from '@salesforce/label/c.BTN_QuoteLineItem_Save';
import TotalAmount from '@salesforce/label/c.LBL_QuoteLineItem_TotalAmount';
import No from '@salesforce/label/c.LBL_QuoteLineItem_No'; 
import Remove from '@salesforce/label/c.LBL_QuoteLineItem_Remove'; 
// ... import more labels as needed

export const labels = {
    CheckPricingAvailability, // Key matches the API name of the custom label
    Add,
    Refresh,
    Save,
    TotalAmount,
    No,
    Remove
}