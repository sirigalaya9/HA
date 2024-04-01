trigger OpportunityTrigger on Opportunity (before insert, after insert, before update, after update) {
    Bypass__c bypass = Bypass__c.getInstance();
    if (!bypass.Bypass_Trigger__c && !bypass.Bypass_Trigger_Opportunity__c) {    
        OpportunityTriggerHandler handler = new OpportunityTriggerHandler();
        
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
        }
    }
}