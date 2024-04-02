/*
* Quote Service
* @author manu.voramontri@kliqxe.com
* @since 14.03.2024
* @version 14.03.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 14.03.2024  manu.voramontri@kliqxe.com         Initial Version
* 25.03.2024  ly.sirigalaya@kliqxe.com           relateOpportunityToQuote
* 01.04.2024  ly.sirigalaya@kliqxe.com           syncSAPQuoteToOpportunity
*/

public without sharing class QuoteService 
{

    public static Boolean quoteSyncRunning = false;
    
    // Before Quote created in SF, Create Opp and link
    public static void relateOpportunityToQuote(List<Quote> quotes) {
        try
        {
            system.debug('relateOpportunityToQuote : '+quotes);
            List<Opportunity> oppsToCreate = new List<Opportunity>();
            Set<Id> successOppIds = new Set<Id>();
            Map<String, Account> accountMap = new Map<String, Account>();
            Map<String, Boolean> exitingSAPQuoteMap = new Map<String, Boolean>();
            Set<String> sAPAccountNumbers = new set<String>();
            Set<String> sAPQuoteNumbers = new Set<String>();
            Id stdPricebookId;

            for(Quote q : quotes) {
                //system.debug('New Quote : '+q);
                //system.debug('q.OpportunityId : '+q.OpportunityId);
                //system.debug('q.SAP_Quote_Number__c : '+q.SAP_Quote_Number__c);
                if(q.OpportunityId == null && q.SAP_Quote_Number__c != null){
                    sAPAccountNumbers.add(q.SAP_Customer_Number__c);
                    //sAPQuoteNumbers.add(q.SAP_Quote_Number__c);
                }
            }
            
            if(!sAPAccountNumbers.isEmpty()){
                for(Account acc : [SELECT Id, SAP_Customer_Number__c, OwnerId FROM Account WHERE SAP_Customer_Number__c IN: sAPAccountNumbers]) {
                    accountMap.put(acc.SAP_Customer_Number__c, acc); // SAP Id , Account
                }
            }
            //system.debug(accountMap);
            
            if (!Test.isRunningTest()){
                stdPricebookId   = [select id, name from Pricebook2 where isStandard = true limit 1].Id;
            } 
            else{
                stdPricebookId = Test.getStandardPricebookId();
            }
            
            for(Quote q : quotes) {
                if(q.SAP_Quote_Number__c == null){continue;}
                
                if(!accountMap.containsKey(q.SAP_Customer_Number__c)) {
                    q.addError('Account ' +q.SAP_Customer_Number__c+ ' is not found. Please verify the account number or create a new account.');
                }
                else if(q.OpportunityId == null && accountMap.containsKey(q.SAP_Customer_Number__c)) {
                    Integer qNumber = 1;
                    Opportunity opp = new Opportunity();
                    opp.Name = 'SAP Quote - '+q.SAP_Quote_Number__c;
                    opp.AccountId = accountMap.get(q.SAP_Customer_Number__c).Id;
                    opp.CurrencyIsoCode = q.CurrencyIsoCode;
                    opp.StageName = 'Quotation';
                    opp.CloseDate = q.ExpirationDate;
                    opp.OwnerId = accountMap.get(q.SAP_Customer_Number__c).OwnerId;
                    opp.Backup_Quote_Id__c = q.SAP_Quote_Number__c;
                    opp.Pricebook2Id = stdPricebookId;
                    oppsToCreate.add(opp);
                    qNumber += 1;
                    system.debug('New Opp : '+opp);
                }
            }   
            
            
            if(!oppsToCreate.isEmpty()) {
                Database.SaveResult[] saveResultList = Database.insert(oppsToCreate, false);
                
                // Iterate through saveResultList based on isSuccess capture the failed records
                for (Database.SaveResult sr : saveResultList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        System.debug('Successfully inserted Opportunity ID: ' + sr.getId());
                        successOppIds.add(sr.getId());
                    }
                    else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Opportunity fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                
                Map<String, Opportunity> mapQuoteOpp = new Map<String, Opportunity>();
                List<Opportunity> successOpps = [SELECT Id, Backup_Quote_Id__c FROM Opportunity WHERE ID IN: successOppIds];
                
                if(!successOpps.isEmpty()) {
                    for(Opportunity opp : successOpps) {
                        system.debug('successOpps '+opp);
                        mapQuoteOpp.put(opp.Backup_Quote_Id__c , opp);
                    }
                    
                    for(Quote q : quotes) {
                        if(q.OpportunityId == null && mapQuoteOpp.containsKey(q.SAP_Quote_Number__c)) {
                            q.OpportunityId = mapQuoteOpp.get(q.SAP_Quote_Number__c).Id;
                            q.CurrencyIsoCode = q.CurrencyIsoCode;
                            q.Pricebook2Id = stdPricebookId;
                            q.OwnerId = accountMap.get(q.SAP_Customer_Number__c).OwnerId;
                            system.debug('new quote : '+q);
                        }
                    }
                }
            }  
        }
        catch (Exception e) { LogUtil.emit(e, new Map<String, String>{}); } 
    } 
    
    // After Quote created, Sync Quote using SyncQuoteQueueable class
    public static void syncSAPQuoteToOpportunity(List<Quote> quotes) { 
        Set<Id> quoteIds = new Set<Id>();
        List<Opportunity> oppsToUpdate = new List<Opportunity>();
        Map<Id, Id> quoteMap = new Map<Id, Id>();
        System.debug('syncSAPQuoteToOpportunity: ' + quotes);
        
        try{
            for (Quote qt : quotes){
                if(qt.SAP_Quote_Number__c != null){
                    quoteIds.add(qt.Id);
                }
            }
            
            String integrationUser = Settings.INTEGRATION_USER;
			system.debug('integrationUser=> '+integrationUser);
            
            List<Quote> sAPQuotes = [SELECT Id, OpportunityId, SAP_Quote_Number__c 
                                     FROM Quote 
                                     WHERE Id IN :quoteIds
                                     AND CreatedBy.Username = :integrationUser
                                     AND isSyncing = FALSE];
            
            system.debug('sAPQuotes=> '+sAPQuotes);
            
            if(!sAPQuotes.isEmpty()){
                for (Quote qt : sAPQuotes){
                    quoteMap.put(qt.Id, qt.OpportunityId);
                }
                system.debug('quoteMap=> '+quoteMap);
                ID jobID = System.enqueueJob(new SyncQuoteQueueable(quoteMap));
                //System.debug('jobID'+jobID);
            }
        }
        catch (Exception e) { LogUtil.emit(e, new Map<String, String>{}); }
    }

    public static void syncQuoteToOpportunityAndRelatedQuotes(List<Quote> quotes)
    {
        try
        {
            System.debug('quotes to process: ' + quotes.size());
            Set<Id> quoteIds = new Set<Id>();
            Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
            List<Quote> quotesToUpdate = new List<Quote>();
            for (Quote qt : quotes)
            {
                quoteIds.add(qt.Id);
                Opportunity opp = new Opportunity(Id = qt.OpportunityId);
                opp.Project__c = qt.Project__c;
                oppMap.put(qt.OpportunityId, opp);
            }
            List<Quote> relatedQuotes = [SELECT OpportunityId FROM Quote WHERE OpportunityId IN :oppMap.keySet()];
            for (Quote qt : relatedQuotes)
            {
                if (!quoteIds.contains(qt.Id)) //All related quotes except the ones being updated
                {
                    Quote quoteToUpdate = new Quote(Id = qt.Id);
                    quoteToUpdate.Project__c = oppMap.get(qt.OpportunityId).Project__c;
                    quotesToUpdate.add(quoteToUpdate);
                }
            }
            System.debug('opps to update: ' + oppMap.size());
            System.debug('quotes to update: ' + quotesToUpdate.size());
            update oppMap.values();
            update quotesToUpdate;
        }
        catch (Exception e) { LogUtil.emit(e, new Map<String, String>{}); } 
    }

    public static void populateLastVersionNumber(List<Quote> quotes)
    {
        try
        {
            Map<Id, List<Quote>> oppId2QuotesMap = new Map<Id, List<Quote>>();
            for (Quote qt : quotes)
            {
                if (!oppId2QuotesMap.containsKey(qt.OpportunityId))
                {
                    oppId2QuotesMap.put(qt.OpportunityId, new List<Quote>());                
                }
                oppId2QuotesMap.get(qt.OpportunityId).add(qt);
            }
            List<Opportunity> opps = [SELECT Id, (SELECT Version_Number__c FROM Quotes ORDER BY Version_Number__c DESC LIMIT 1) FROM Opportunity WHERE Id IN :oppId2QuotesMap.keySet()];
            for (Opportunity opp : opps)
            {
                Decimal lastNumber = 0;
                if (opp.Quotes.size() == 0)
                {                
                    for (Quote qt : oppId2QuotesMap.get(opp.Id))
                    {
                        qt.Version_Number__c = ++lastNumber;
                    }
                }
                else
                {
                    lastNumber = opp.Quotes.get(0).Version_Number__c;
                    for (Quote qt : oppId2QuotesMap.get(opp.Id))
                    {
                        qt.Version_Number__c = ++lastNumber;
                    }                
                }
            }    
        }        
        catch (Exception e) { LogUtil.emit(e, new Map<String, String>{}); } 
    }   
}