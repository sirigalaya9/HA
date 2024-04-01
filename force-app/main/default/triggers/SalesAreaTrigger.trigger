trigger SalesAreaTrigger on Sales_Area__c (before insert, before update, after insert, after update, before delete) {
    Bypass__c bypass = Bypass__c.getInstance();
    if (!bypass.Bypass_Trigger__c && !bypass.Bypass_Trigger_SalesArea__c ) {
        new SalesAreaTriggerHandler().run();  
    }
}