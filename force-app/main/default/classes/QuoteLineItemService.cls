/*
* QuoteLineItem Service
* @author ly.sirigalaya@kliqxe.com
* @since 12.03.2024
* @version 12.03.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 12.03.2024  ly.sirigalaya@kliqxe.com         	Initial Version
* 14.03.2024  manu.voramontri@kliqxe.com        syncQuoteItemsToOpportunityItems
* 28.03.2024  long@kliqxe.com         			populatePricebookID
*/

public class QuoteLineItemService {
    public static boolean isRunning = false;
    
    public static void populateProductDetails (List<QuoteLineItem> mNewQuoteItems) {
        Set<Id> prouductIdSet = new Set<Id>();
        Set<Id> quoteIdSet = new Set<Id>();
        Map<Id,Quote> QuoteMap = new Map<Id,Quote>();
        Map<Id,Product2> productMap = new Map<Id,Product2>();
        
        for(QuoteLineItem newQuote : mNewQuoteItems){
            prouductIdSet.add(newQuote.Product2Id);
            quoteIdSet.add(newQuote.QuoteId);     
        }
        
        if(!quoteIdSet.isEmpty()) {
            QuoteMap = new Map<Id,Quote>([SELECT Id, Name, AccountId, Account.Language__c
                                                      FROM Quote
                                                      WHERE Id IN: quoteIdSet]);   
        }
        
        if(!prouductIdSet.isEmpty()) {
            productMap = new Map<Id,Product2>([SELECT
                                               Id, 
                                               Description, 
                                               Description_1E__c, 
                                               Description_1F__c, 
                                               Description_1G__c, 
                                               Description_1I__c, 
                                               Description_1P__c, 
                                               Description_1X__c, 
                                               Description_3E__c, 
                                               Description_3F__c, 
                                               Description_4G__c, 
                                               Description_4H__c, 
                                               Description_6E__c, 
                                               Description_8E__c, 
                                               Description_AF__c, 
                                               Description_AR__c, 
                                               Description_BG__c, 
                                               Description_CA__c, 
                                               Description_CS__c, 
                                               Description_DA__c, 
                                               Description_DE__c, 
                                               Description_EL__c, 
                                               Description_EM__c, 
                                               Description_EN__c, 
                                               Description_ES__c, 
                                               Description_ET__c, 
                                               Description_FI__c, 
                                               Description_FR__c, 
                                               Description_HE__c, 
                                               Description_HR__c, 
                                               Description_HU__c, 
                                               Description_ID__c, 
                                               Description_IS__c, 
                                               Description_IT__c, 
                                               Description_JA__c, 
                                               Description_KK__c, 
                                               Description_KO__c, 
                                               Description_LT__c, 
                                               Description_LV__c, 
                                               Description_MS__c, 
                                               Description_NL__c, 
                                               Description_NO__c, 
                                               Description_PL__c, 
                                               Description_PT__c, 
                                               Description_RO__c, 
                                               Description_RU__c, 
                                               Description_SH__c, 
                                               Description_SK__c, 
                                               Description_SL__c, 
                                               Description_SV__c, 
                                               Description_TH__c, 
                                               Description_TR__c, 
                                               Description_UK__c, 
                                               Description_VI__c, 
                                               Description_Z1__c, 
                                               Description_Z2__c, 
                                               Description_ZF__c, 
                                               Description_ZH__c, 
                                               PCM_Product__c, 
                                               OHA_Classification__c, 
                                               ProductCode
                                               FROM
                                               Product2
                                               WHERE
                                               Id in: prouductIdSet]);
            
            system.debug('productMap : '+productMap);
            for(QuoteLineItem newQuote : mNewQuoteItems){
                try{
                    if(productMap.containsKey(newQuote.Product2Id)){
                        String languageCode;
                        String fieldApiName;
                        String dynamicDesc;
                        
                        //-----get Dynamic Description
                        languageCode = quoteMap.containsKey(newQuote.QuoteId)? quoteMap.get(newQuote.QuoteId).Account.Language__c : null; // DE
                        system.debug('languageCode : '+languageCode);
                        if(languageCode != null){
                            fieldApiName = 'Description_' + languageCode + '__c';
                            dynamicDesc = (String)productMap.get(newQuote.Product2Id).get(fieldApiName);
                            system.debug('dynamicDesc : '+dynamicDesc);
                        }
                        
                        newQuote.Description = dynamicDesc != null ? dynamicDesc : productMap.get(newQuote.Product2Id).Description;
                    } 
                }   
                catch (Exception e) { LogUtil.emit(e, new Map<String, String>{}); throw new AuraHandledException(e.getMessage()); }
            }   
        }   
    }
    
    public static void syncQuoteItemsToOpportunityItems (List<QuoteLineItem> mNewQuoteItems) {        
        // Only sync if IsSyncing flag is true on the related quote
        Set<Id> quoteIds = new Set<Id>();
        for (QuoteLineItem lineItem : mNewQuoteItems) {
            quoteIds.add(lineItem.QuoteId);
         }
        
        Map<Id, Quote> quotesWithSyncFlag = new Map<Id, Quote>([SELECT Id, IsSyncing FROM Quote WHERE Id IN :quoteIds]);
        
        List<QuoteLineItem> quoteLineItemsToProcess = new List<QuoteLineItem>();
        for (QuoteLineItem qli : mNewQuoteItems) {
            if (quotesWithSyncFlag.get(qli.QuoteId).IsSyncing == true) {
                quoteLineItemsToProcess.add(qli);
            }
            
            system.debug('quoteLineItemsToProcess : '+quoteLineItemsToProcess);
        }

         if (!QuoteLineItemService.isRunning) {
             QuoteLineItemService.syncCustomFields(quoteLineItemsToProcess);
         } 
    }
    
    public static void syncCustomFields(List<QuoteLineItem> quoteLineItems) {
        isRunning = true; 
        try {
            List<OpportunityLineItem> oppLineItemsToUpdate = new List<OpportunityLineItem>();
            
            for (QuoteLineItem qli : quoteLineItems) {
                OpportunityLineItem oli = new OpportunityLineItem(
                    Id = qli.OpportunityLineItemId,
                    is_SAP_Price__c = qli.is_SAP_Price__c
                ); 
                
                oppLineItemsToUpdate.add(oli);
            }
            
            system.debug('oppLineItemsToUpdate : '+oppLineItemsToUpdate);

            if (!oppLineItemsToUpdate.isEmpty()) {
                update oppLineItemsToUpdate; 
            }
        } catch (Exception e) {
            System.debug('Error syncing field: ' + e.getMessage());
        } finally {
            isRunning = false;
        }
    }

    public static List<QuoteLineItem> populatePricebookID(List<QuoteLineItem> lineItems) {        
        Set<Id> quoteIds = new Set<Id>();
        Set<Id> productIds = new Set<Id>();
        for (QuoteLineItem qli : lineItems) {
            quoteIds.add(qli.QuoteId);
            productIds.add(qli.Product2Id);
        }
        
        Map<Id, Quote> quoteMap = new Map<Id, Quote>([SELECT Id, Pricebook2Id, CurrencyIsoCode FROM Quote WHERE Id IN :quoteIds]);        
        Map<String, Map<Id, Id>> pricebookEntryIdMap = new Map<String, Map<Id, Id>>();
        
        for (PricebookEntry pbEntry : [SELECT Id, Product2Id, CurrencyIsoCode FROM PricebookEntry WHERE Product2Id IN :productIds]) {
            String currencyIsoCode = pbEntry.CurrencyIsoCode;
            Id productId = pbEntry.Product2Id;

            Map<Id, Id> productPricebookEntryMap = pricebookEntryIdMap.get(currencyIsoCode);
            if (productPricebookEntryMap == null) {
                productPricebookEntryMap = new Map<Id, Id>();
                pricebookEntryIdMap.put(currencyIsoCode, productPricebookEntryMap);
            }

            productPricebookEntryMap.put(productId, pbEntry.Id);
        }
        
        for (QuoteLineItem qli : lineItems) {
            Id quoteId = qli.QuoteId;
            String currencyIsoCode = quoteMap.get(quoteId).CurrencyIsoCode;
            Id productId = qli.Product2Id;

            Map<Id, Id> productPricebookEntryMap = pricebookEntryIdMap.get(currencyIsoCode);
            if (productPricebookEntryMap != null && productPricebookEntryMap.containsKey(productId)) {
                qli.PricebookEntryId = productPricebookEntryMap.get(productId);
            }
        }

        return lineItems;
    }
}