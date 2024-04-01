trigger QuoteTrigger on Quote (before insert, after update) {
    Bypass__c bypass = Bypass__c.getInstance();
    if (!bypass.Bypass_Trigger__c && !bypass.Bypass_Trigger_Quote__c) {    
            QuoteTriggerHandler handler = new QuoteTriggerHandler();
            if ( trigger.isAfter ) {
                if ( trigger.isUpdate) {
                    handler.onAfterUpdate();
                }
                /*else if ( trigger.isInsert ) {
                    handler.onAfterInsert();
                }*/
            }
            if( trigger.isBefore ) {
                if ( trigger.isInsert) {
                    system.debug('QuoteTrigger onBeforeInsert');
                    handler.onBeforeInsert();
                }
            }
        
    }
}