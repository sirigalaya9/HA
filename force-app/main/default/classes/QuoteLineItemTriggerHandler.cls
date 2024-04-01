public class QuoteLineItemTriggerHandler {
    
    public void onBeforeInsert() {
        system.debug('QuoteLineItemTriggerHandler onBefore Insert');
        QuoteLineItemService.populateProductDetails((List<QuoteLineItem>) Trigger.New);
        for (QuoteLineItem qli : (List<QuoteLineItem>) Trigger.new) { if (qli.Rejected__c) { qli.UnitPrice = 0; } }
        QuoteLineItemService.populatePricebookID((List<QuoteLineItem>) Trigger.New);
    }
    
    public void onBeforeUpdate() {
        system.debug('QuoteLineItemTriggerHandler onBefore Update');
        for (QuoteLineItem qli : (List<QuoteLineItem>) Trigger.new) { if (qli.Rejected__c) { qli.UnitPrice = 0; } }
    }
    
    public void onAfterInsert() {
        system.debug('QuoteLineItemTriggerHandler onAfter Insert');
        //QuoteLineItemService.syncQuoteItemsToOpportunityItems((List<QuoteLineItem>) Trigger.New);
    }
    
    public void onAfterUpdate() {
        system.debug('QuoteLineItemTriggerHandler onAfter Update');
        List<QuoteLineItem> qlis = new List<QuoteLineItem>();
        for (QuoteLineItem qli : (List<QuoteLineItem>)Trigger.New)
        {
            QuoteLineItem newItem = (QuoteLineItem)Trigger.newMap.get(qli.Id);
            QuoteLineItem oldItem = (QuoteLineItem)Trigger.oldMap.get(qli.Id);
            if (
                (newItem.is_SAP_Price__c != oldItem.is_SAP_Price__c) &&
                (newItem.Quantity == oldItem.Quantity) &&
                (newItem.UnitPrice == oldItem.UnitPrice)
            )
            {
                qlis.add(qli);
            }
        }
        if (!qlis.isEmpty())
        {
            QuoteLineItemService.syncQuoteItemsToOpportunityItems(qlis);
        }        
    }

    

}