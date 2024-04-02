/*
* Quote Trigger Handler
* @author manu.voramontri@kliqxe.com
* @since 14.03.2024
* @version 14.03.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 14.03.2024  manu.voramontri@kliqxe.com         Initial Version
* 30.03.2024  ly.sirigalaya@kliqxe.com         	 relateOpportunityToQuote
* 02.04.2024  ly.sirigalaya@kliqxe.com         	 syncSAPQuoteToOpportunity
*/
public class QuoteTriggerHandler {
    
     public void onBeforeInsert() {
        System.debug('QuoteTriggerHandler onBefore Insert');
         QuoteService.populateLastVersionNumber((List<Quote>) Trigger.New);
         System.debug(Trigger.New);
         QuoteService.relateOpportunityToQuote((List<Quote>) Trigger.New);
         
     }
    
    public void onAfterInsert() {
        System.debug('QuoteTriggerHandler onAfter Insert');
        QuoteService.syncSAPQuoteToOpportunity((List<Quote>) Trigger.New);
        
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