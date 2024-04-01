public class QuoteTriggerHandler {
    
     public void onBeforeInsert() {
        System.debug('QuoteTriggerHandler onBefore Insert');
         QuoteService.populateLastVersionNumber((List<Quote>) Trigger.New);
         System.debug(Trigger.New);
         QuoteService.RelateOpportunityToQuote((List<Quote>) Trigger.New);
         
     }
    
    public void onAfterUpdate() {
        System.debug('QuoteTriggerHandler onAfter Update');
        System.debug('quoteSyncRunning: ' + QuoteService.quoteSyncRunning);
        if (!QuoteService.quoteSyncRunning)
        {
            QuoteService.quoteSyncRunning = true;
            List<Quote> quotes = new List<Quote>();
            for (Quote quote : (List<Quote>)Trigger.New)
            {
                Quote newItem = (Quote)Trigger.newMap.get(quote.Id);
                Quote oldItem = (Quote)Trigger.oldMap.get(quote.Id);
                if (newItem.Project__c != oldItem.Project__c)
                {
                    quotes.add(quote);
                }
            }
            if (!quotes.isEmpty())
            {
                QuoteService.syncQuoteToOpportunityAndRelatedQuotes(quotes);
            }
            QuoteService.quoteSyncRunning = false;
        }        
    }
}