trigger LeadTrigger on Lead (after update) {
    Bypass__c bypass = Bypass__c.getInstance();
    if (!bypass.Bypass_Trigger__c) {
        LeadTriggerHandler handler = new LeadTriggerHandler();
        
        /*if( trigger.isBefore ) {
            if ( trigger.isInsert) {
                handler.onBeforeInsert();
            }
            else if ( trigger.isUpdate) {
                handler.onBeforeUpdate();
            }
        }*/
        if ( trigger.isAfter ) {
            if ( trigger.isUpdate) {
                handler.onAfterUpdate();
            }
            /*else if ( trigger.isInsert ) {
                handler.onAfterInsert();
            }*/
        }
    }
}