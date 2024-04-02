public class SyncQuoteQueueable implements Queueable {
    
    public Map<Id, Id> quoteMap ; 
    public SyncQuoteQueueable(Map<Id, Id> quoteMap){
        this.quoteMap = quoteMap ;  
    }
    public void execute(QueueableContext context) {
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        system.debug('SyncQuoteQueueable=> '+quoteMap);
        for(Id currentQuote : quoteMap.keyset())
        {
            Opportunity opp = new Opportunity();
            opp.Id = quoteMap.get(currentQuote);
            opp.SyncedQuoteId = currentQuote;
            oppMap.put(opp.Id, opp);
            system.debug('oppMap=> '+oppMap);
        }
        update oppMap.values();
    }

}