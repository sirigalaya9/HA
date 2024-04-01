public without sharing class OpportunityTriggerHandler {
    
    public void onBeforeInsert() {
        system.debug('OpportunityTrigger onBefore Insert');
        OpportunityService.assignEnterpriseStructure((List<Opportunity>) Trigger.New, null);
    }
    
    public void onBeforeUpdate() {
        system.debug('OpportunityTrigger onBefore Update');
        OpportunityService.assignEnterpriseStructure((List<Opportunity>)Trigger.New, (Map<Id, Opportunity>)Trigger.oldMap);
    }
    
    /*public void onAfterInsert() {
        system.debug('OpportunityTrigger onAfter Insert');
        OpportunityService.copyLeadItemsToOppItems((List<Opportunity>) Trigger.New);
    }*/
    
    public void onAfterUpdate() {
        system.debug('OpportunityLineItemTrigger onAfter Update');
        System.debug('quoteSyncRunning: ' + QuoteService.quoteSyncRunning);
        if (!QuoteService.quoteSyncRunning)
        {
            QuoteService.quoteSyncRunning = true;
            OpportunityService.syncProjectToAllRelatedQuotes((List<Opportunity>)Trigger.New, (Map<Id, Opportunity>)Trigger.oldMap);
            QuoteService.quoteSyncRunning = false;
        }
    }
    
    
}