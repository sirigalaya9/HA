public class OpportunityLineItemTriggerHandler {
    
    public static Boolean runOnce = false;

    public void onBeforeInsert() {
        system.debug('OpportunityLineItemTrigger onBefore Insert');
        OpportunityLineItemService.populateProductDetails((List<OpportunityLineItem>) Trigger.New);
    }
    
    public void onBeforeUpdate() {
        system.debug('OpportunityLineItemTrigger onBefore Update');
        if (!QuoteLineItemService.isRunning)
        {            
            OpportunityLineItemService.syncQuoteLineItems((Map<Id, OpportunityLineItem>)Trigger.newMap, (Map<Id, OpportunityLineItem>)Trigger.oldMap);
            OpportunityLineItemService.updateItemDetails((List<OpportunityLineItem>) Trigger.New, (Map<Id, OpportunityLineItem>)Trigger.oldMap);
        }
    }

    public void onAfterInsert() {
        system.debug('OpportunityLineItemTrigger onAfter Insert');
        if (runOnce == false)
        {
            runOnce = true;
            OpportunityLineItemService.syncQuoteLineItems((Map<Id, OpportunityLineItem>)Trigger.newMap, null);
        }
    }
    
    public void onAfterUpdate() {
        system.debug('OpportunityLineItemTrigger onAfter Update');
    }     

}