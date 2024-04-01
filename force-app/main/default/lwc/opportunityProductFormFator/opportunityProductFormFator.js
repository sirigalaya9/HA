/*
* Configure a component to display on a Lightning record page (Dektop,Tablet,Mobile)
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
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class OpportunityProductFormFator extends LightningElement {
    @track isDesktop = FORM_FACTOR === 'Large';
    @track isTablet = FORM_FACTOR === 'Medium';
    @track isMobile = FORM_FACTOR === 'Small';
    @api recordId;

    




}