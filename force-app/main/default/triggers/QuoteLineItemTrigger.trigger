trigger QuoteLineItemTrigger on QuoteLineItem (before insert, after insert, before update, after update) {
    Bypass__c bypass = Bypass__c.getInstance();
    if (!bypass.Bypass_Trigger__c && !bypass.Bypass_Trigger_QuoteLineItem__c) {
        QuoteLineItemTriggerHandler handler = new QuoteLineItemTriggerHandler();
        if( trigger.isBefore ) {
            if ( trigger.isInsert) {
                handler.onBeforeInsert();
            }
            else if ( trigger.isUpdate) {
                handler.onBeforeUpdate();
            }
        }
        else if ( trigger.isAfter ) {
            if ( trigger.isUpdate) {
                handler.onAfterUpdate();
            }
            else if ( trigger.isInsert ) {
                handler.onAfterInsert();
            }
        }
    }
    
}