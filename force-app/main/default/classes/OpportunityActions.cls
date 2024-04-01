// Will be removed

public without sharing class OpportunityActions {
    
    public static Map<Id, Account> accountMap = new Map<Id, Account>();
    public static Map<Id, List<User_Sales_Organization__c>> useSaleOrgMap = new Map<Id, List<User_Sales_Organization__c>>();
    public static Map<Id, List<Quote>> oppQuotesMap = new Map<Id, List<Quote>>();
    public static FINAL String TERRITORY_NAME = 'Hafele_Territories';
    
    private static Boolean shouldUpdateSalesArea(Opportunity newOpp, Opportunity oldOpp) {
        return (oldOpp == null || // INSERT
                newOpp.User_Sales_Organization__c != oldOpp.User_Sales_Organization__c ||
                newOpp.OwnerId != oldOpp.OwnerId);
    }
    
    public static void assignEnterpriseStructure (List<Opportunity> mNewOpps, Map<Id, Opportunity> mOldOpps) { 
        List<Id> ownerIdList = new List<Id>();
        Set<Id> accountIdSet = new Set<Id>();
        for(Opportunity newOpp : mNewOpps){
            Opportunity oldOpp = mOldOpps != null ? mOldOpps.get(newOpp.Id) : null;
            
            //------- Opp Sales Area is changed OR on INSERT----------//
            if(oldOpp == null || // INSERT
               newOpp.User_Sales_Organization__c != oldOpp.User_Sales_Organization__c ||
               newOpp.Sales_Office__c != oldOpp.Sales_Office__c ||
               newOpp.Sales_Group__c != oldOpp.Sales_Group__c ||
               newOpp.OwnerId != oldOpp.OwnerId){ 
                   ownerIdList.add(newOpp.OwnerId);
                   accountIdSet.add(newOpp.AccountId);
               }   
        }
        
        //system.debug('ownerIdList ' +ownerIdList);
        //system.debug('accountIdSet ' +accountIdSet);
        
        if(!accountIdSet.isEmpty()){
            List<Account> accounts = [SELECT Id, overcast__SAP_BP_Number__c, Prospect__c,CurrencyISOCode, 
                                      No_of_Sales_Area__c, SAP_Customer_Number__c, First_Assigned_Sales_Org__c, No_of_Opportunity__c,
                                      (Select Id, Sales_Organization__c, Sales_Office__c, Sales_Group__c, Distribution_Channel__c, Division__c 
                                       FROM Sales_Areas__r) 
                                      FROM Account 
                                      WHERE Id IN: accountIdSet];
            
            for(Account acc: accounts){
                if(!accountMap.containsKey(acc.Id)){
                    accountMap.put(acc.Id, acc);
                } 
            }   
        }
        if(!ownerIdList.isEmpty()){
            List<User_Sales_Organization__c> userSaleOrgs = [SELECT Id, Name, Code__c, User__c, Sales_Organization__c 
                                                             FROM User_Sales_Organization__c 
                                                             WHERE User__c IN: ownerIdList];
            for(User_Sales_Organization__c uso : userSaleOrgs){
                if(!useSaleOrgMap.containsKey(uso.User__c)){
                    useSaleOrgMap.put(uso.User__c, new List<User_Sales_Organization__c >{uso});
                }
                else{
                    useSaleOrgMap.get(uso.User__c).add(uso);
                }        
            }
            
            system.debug('useSaleOrgMap ' +useSaleOrgMap);
        }
        
        for(Opportunity newOpp : mNewOpps){
            Opportunity oldOpp = mOldOpps != null ? mOldOpps.get(newOpp.Id) : null;
            //------- User_Sales_Organization__c is changed OR on INSERTED----------//
            
            try {
                if (shouldUpdateSalesArea(newOpp, oldOpp)) {
                    system.debug('assignSalesArea');
                    assignSalesArea(newOpp, oldOpp);
                    
                }
                else if(newOpp.Sales_Office__c != oldOpp.Sales_Office__c ||
                        newOpp.Sales_Group__c != oldOpp.Sales_Group__c ){
                            system.debug('assignTerritory');
                            assignTerritory(newOpp);
                        }
            } catch (Exception e) {
                newOpp.addError('Sales area assignment failed: ' + e.getMessage());
            }
            
        }
    }

    private static void assignSalesArea(Opportunity newOpp, Opportunity oldOpp) {
        List<Account> accountsToUpdate = new List<Account>();
        
        if(useSaleOrgMap.containsKey(newOpp.OwnerId)){
            if((useSaleOrgMap.get(newOpp.OwnerId).size()==1 && oldOpp == null) || 
               newOpp.User_Sales_Organization__c != null
              ){
                  system.debug('User has 1 SalesOrg assigned OR Manual populate User Sales Orgs');
                  system.debug('newOpp.User_Sales_Organization__c : '+newOpp.User_Sales_Organization__c);
                  //---------- Inserted:User has 1 SalesOrg assigned OR Updated:Manual populate User Sales Orgs-----
                  if(newOpp.User_Sales_Organization__c != null){
                      for(User_Sales_Organization__c uso : useSaleOrgMap.get(newOpp.OwnerId)){
                          system.debug('uso : '+uso);
                          if(uso.Id == newOpp.User_Sales_Organization__c) {
                              newOpp.Sales_Organization__c = uso.Code__c;
                              newOpp.Sales_Office__c = null;
                              newOpp.Sales_Group__c = null;
                              break;
                          }                                       
                      } 
                  }
                  else{
                      newOpp.User_Sales_Organization__c = useSaleOrgMap.get(newOpp.OwnerId)[0].Id; //Auto assign User's SalesOrg
                      newOpp.Sales_Organization__c = useSaleOrgMap.get(newOpp.OwnerId)[0].Code__c;// Assign Sales Org
                  }
                  
                  if(accountMap.get(newOpp.AccountId).SAP_Customer_Number__c != null && accountMap.get(newOpp.AccountId).No_of_Sales_Area__c > 0){
                      Boolean salesAreaFound = false;
                      String salesOffice;
                      String salesGroup;
                      for(Sales_Area__c sa : accountMap.get(newOpp.AccountId).Sales_Areas__r){
                          if(newOpp.Sales_Organization__c == sa.Sales_Organization__c &&
                             newOpp.Division__c == sa.Division__c &&
                             newOpp.Distribution_Channel__c == sa.Distribution_Channel__c) {
                                 salesAreaFound = true;
                                 //newOpp.Sales_Organization__c = sa.Sales_Organization__c;
                                 newOpp.Sales_Office__c = sa.Sales_Office__c; // Assign Sales Office
                                 newOpp.Sales_Group__c = sa.Sales_Group__c; // Assign Sales Group
                                 break;
                             }   
                      }
                      if(!salesAreaFound){
                          newOpp.addError(System.Label.MSG_Opportunity_UserSalesOrgNotMatchAccount);
                      }
                  }
                  else { // No Sales Area
                      if((oldOpp == null && accountMap.get(newOpp.AccountId).First_Assigned_Sales_Org__c != null) ||
                         (newOpp.User_Sales_Organization__c != null && accountMap.get(newOpp.AccountId).No_of_Opportunity__c > 1)){
                             if(newOpp.Sales_Organization__c != accountMap.get(newOpp.AccountId).First_Assigned_Sales_Org__c){
                                 newOpp.addError(System.Label.MSG_Opportunity_UserSalesOrgNotMatchFirstAccount);
                             }
                         }
                      else if((newOpp.User_Sales_Organization__c != null && accountMap.get(newOpp.AccountId).No_of_Opportunity__c == 1) || 
                              accountMap.get(newOpp.AccountId).First_Assigned_Sales_Org__c == null){
                                  Account acc = new Account();
                                  acc.Id = newOpp.AccountId;
                                  acc.First_Assigned_Sales_Org__c  = newOpp.Sales_Organization__c;
                                  accountsToUpdate.add(acc);
                              } 
                  }
              }
            else if((useSaleOrgMap.get(newOpp.OwnerId).size()>1 && oldOpp == null) || 
                    newOpp.User_Sales_Organization__c == null
                   ){
                       //-------- Inserted:User has multiple SalesOrg assigned OR Updated:Removed -----------------
                       newOpp.User_Sales_Organization__c = null; // clear
                       newOpp.Sales_Organization__c = null;
                       newOpp.Sales_Office__c = null; 
                       newOpp.Sales_Group__c = null;
                       newOpp.Territory2Id = null;
                       system.debug('User has multiple SalesOrg assigned OR Removed');
                   }
        }
        else{
            //-------------------- User has no SalesOrg assigned -----------------------
            newOpp.addError(System.Label.MSG_Opportunity_NoUserSalesOrg);
        }
        
        if(!accountsToUpdate.isEmpty()){
            try {
                Database.SaveResult[] results = Database.update(accountsToUpdate, false);
                // iterate over the list of returned results
                for(Database.SaveResult result : results) {
                    if(result.isSuccess()) {
                        System.debug('Successfully updated Accounts : ' + result.getId());
                    } else {
                        // iterate over the failed ones
                        for(Database.Error error : result.getErrors()) {
                            System.debug('Error Status : ' + error.getStatusCode() + ' : ' + 'Error Fields : ' + error.getFields());
                        }
                    }
                }
            } catch(DMLException e) {
                throw new DMLException('Unable to Perform the DML Operation on Account : ' +e.getMessage());
            }
        }
        
        if(newOpp.Sales_Organization__c != null){
            assignTerritory(newOpp);
        }
        
    }
    
    private static void assignTerritory(Opportunity newOpp) {
        List<Territory2> territories = [SELECT Id, Name, Sales_Organization__c, Sales_Office__c, Sales_Group__c 
                                        FROM Territory2 
                                        WHERE Territory2Model.DeveloperName =: TERRITORY_NAME
                                        AND Sales_Organization__c =: newOpp.Sales_Organization__c 
                                        AND Sales_Office__c =: newOpp.Sales_Office__c 
                                        AND Sales_Group__c =: newOpp.Sales_Group__c LIMIT 1];
        
        system.debug('territories : '+territories);
        if(!territories.isEmpty()){
            newOpp.Territory2Id = territories[0].Id;
        }else newOpp.Territory2Id = null;
        
    }
    
    public static void syncProjectToAllRelatedQuotes (List<Opportunity> mNewOpps, Map<Id, Opportunity> mOldOpps) {       
        try{
            Map<Id, Id> oppProjectMap = new Map<Id, Id>();
            List<Quote> quotesToUpdate = new List<Quote>();
            
            Set<Id> oppIds = new Set<Id>();
            for(Opportunity newOpp : mNewOpps){
                Opportunity oldOpp = mOldOpps != null ? mOldOpps.get(newOpp.Id) : null;
                
                //------- AFTER UPDATE : Project is changed----------//
                if(newOpp.Project__c != oldOpp.Project__c){ 
                    oppProjectMap.put(newOpp.Id, newOpp.Project__c);
                }   
            }
            
            // get all related Quotes from Oppids
            List<Quote> quotes = [SELECT Id, OpportunityId, Project__c
                                  FROM Quote
                                  WHERE OpportunityId IN: oppProjectMap.keyset()];
            
            if(!quotes.isEmpty()){
                for(Quote quote : quotes){
                    if(!oppQuotesMap.containsKey(quote.OpportunityId)){
                        oppQuotesMap.put(quote.OpportunityId, new List<Quote >{quote});
                    }
                    else{
                        oppQuotesMap.get(quote.OpportunityId).add(quote);
                    }        
                }
            }
            
            for(Opportunity newOpp : mNewOpps){
                if(oppQuotesMap.containsKey(newOpp.id)){
                    for(Quote quote : oppQuotesMap.get(newOpp.id)) {
                        if(oppProjectMap.containsKey(quote.OpportunityId)){
                            Quote quoteToUpdate = new Quote(
                                Id = quote.Id,
                                Project__c = oppProjectMap.get(quote.OpportunityId)
                            );
                            quotesToUpdate.add(quoteToUpdate); 
                        }   
                    }
                }
            }
            system.debug('quotesToUpdate ' +quotesToUpdate);
            if(!quotesToUpdate.isEmpty()){
                update quotesToUpdate;
            } 
        }
        catch (Exception e) { 
            system.debug('syncProjectToAllRelatedQuotes Error ' +e.getMessage());
            //LogUtil.emit(e, new Map<String, String>{}); throw new AuraHandledException(e.getMessage()); 
        }   
    }
    
    //--------- When user click Sync button, sync custom fields from QLI to OLI
    public static void syncQuoteToOpportunity (List<Opportunity> mNewOpps, Map<Id, Opportunity> mOldOpps) {
        Set<Id> updatedOppIds = new Set<Id>();
        Map<Id, Id> quoteIdToOppIdMap = new Map<Id, Id>();
        List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
        // Find Updated Opportunities with populated SyncedQuoteId
        for (Opportunity newOpp : mNewOpps) {
            if (newOpp.SyncedQuoteId != null && newOpp.SyncedQuoteId != mOldOpps.get(newOpp.Id).SyncedQuoteId) {
                updatedOppIds.add(newOpp.Id);            
            }
        }
        
        if (!updatedOppIds.isEmpty()) {
            oppLineItemsToUpdate = syncQuoteLineItems(quoteIdToOppIdMap);
            system.debug('syncQuoteLineItems');
            system.debug(oppLineItemsToUpdate);
        } 
        
        if (!oppLineItemsToUpdate.isEmpty()) {
            /*try {
                upsert oppLineItemsToUpdate;
            } catch (Exception e) {
                System.debug('Error syncing fields: ' + e.getMessage());
            }*/
        }
    }
    
    private static List<OpportunityLineItem> syncQuoteLineItems(Map<Id, Id> quoteIdToOppIdMap) {
        List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
        List<QuoteLineItem> quoteLineItems = [
            SELECT Id, List_Price__c // custom fields
            FROM QuoteLineItem 
            WHERE QuoteId IN :quoteIdToOppIdMap.keySet()
        ];
        
        for (QuoteLineItem qli : quoteLineItems) {
            OpportunityLineItem oli = new OpportunityLineItem(
                OpportunityId = quoteIdToOppIdMap.get(qli.QuoteId)
                //UnitPrice = qli.List_Price__c,
            );
            oppLineItemsToUpdate.add(oli); 
        }
        return oppLineItemsToUpdate;
    }
    
 
}