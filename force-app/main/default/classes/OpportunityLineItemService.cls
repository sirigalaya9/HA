/*
* OpportunityLineItem Service
* @author ly.sirigalaya@kliqxe.com
* @since 05.03.2024
* @version 05.03.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 05.03.2024  ly.sirigalaya@kliqxe.com         	Initial Version
* 14.03.2024  manu.voramontri@kliqxe.com        syncQuoteLineItems
*/

public class OpportunityLineItemService {
    
    public static Map<Id, Account> accountMap = new Map<Id, Account>();
    public static Map<Id, List<User_Sales_Organization__c>> useSaleOrgMap = new Map<Id, List<User_Sales_Organization__c>>();
    public static List<Id> ownerIdList = new List<Id>();
    public static Set<Id> accountIdSet = new Set<Id>();
    public static List<Account> accountsToUpdate = new List<Account>();
    
    /*public static void validateSalesOrg (List<OpportunityLineItem> mNewOppItems, Map<Id, OpportunityLineItem> mOldOppItems) {   
        for(OpportunityLineItem newOppItem : mNewOppItems){
            OpportunityLineItem oldOppItem = mOldOppItems != null ? mOldOppItems.get(newOppItem.Id) : null;
            
            //------- User_Sales_Organization__c is changed OR on INSERT----------//
            if(oldOppItem == null) {
                //ownerIdList.add(newOpp.OwnerId);
                //accountIdSet.add(newOpp.AccountId);
            }   
        }
        
    }*/
    
    public static void populateProductDetails (List<OpportunityLineItem> mNewOppItems) {
        Set<Id> prouductIdSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        Map<Id,Opportunity> opportunityMap = new Map<Id,Opportunity>();
        Map<Id,Product2> productMap = new Map<Id,Product2>();
        
        for(OpportunityLineItem newOppItem : mNewOppItems){
            prouductIdSet.add(newOppItem.Product2Id);
            oppIdSet.add(newOppItem.OpportunityId);     
        }
        
        if(!oppIdSet.isEmpty()) {
            opportunityMap = new Map<Id,Opportunity>([SELECT Id, Name, AccountId, Account.Language__c
                                                      FROM Opportunity
                                                      WHERE Id IN: oppIdSet]);   
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
                                               PCM_Product__c , 
                                               OHA_Classification__c, 
                                               ProductCode
                                               FROM
                                               Product2
                                               WHERE
                                               Id in: prouductIdSet]);
            
            system.debug('productMap : '+productMap);
            for(OpportunityLineItem newOppItem : mNewOppItems){
                try{
                    if(productMap.containsKey(newOppItem.Product2Id)){
                        String languageCode;
                        String fieldApiName;
                        String dynamicDesc;
                        
                        //-----get PCM_Product__c
                        newOppItem.PCM_Product__c = productMap.get(newOppItem.Product2Id).PCM_Product__c ;
                        
                        //-----get OHA__c
                        if(String.isBlank(newOppItem.OHA__c) || newOppItem.PCM_Product__c == false){
                            if(productMap.get(newOppItem.Product2Id).OHA_Classification__c != null){
                                newOppItem.OHA__c = 'Yes';
                            }
                            else{
                                newOppItem.OHA__c = 'No';
                            }
                        }
                        
                        //-----get Dynamic Description
                        languageCode = opportunityMap.containsKey(newOppItem.OpportunityId)? opportunityMap.get(newOppItem.OpportunityId).Account.Language__c : null; // DE
                        system.debug('languageCode : '+languageCode);
                        if(languageCode != null){
                            fieldApiName = 'Description_' + languageCode + '__c';
                            dynamicDesc = (String)productMap.get(newOppItem.Product2Id).get(fieldApiName);
                            system.debug('dynamicDesc : '+dynamicDesc);
                        }
                        
                        newOppItem.Description = dynamicDesc != null ? dynamicDesc : productMap.get(newOppItem.Product2Id).Description;
                        
                        system.debug('ProductCode : '+productMap.get(newOppItem.Product2Id).ProductCode);
                        system.debug('newOppItem.PCM_Product__c : '+newOppItem.PCM_Product__c);
                        system.debug('newOppItem.OHA__c : '+newOppItem.OHA__c);
                    } 
                }   
                catch (Exception e) { LogUtil.emit(e, new Map<String, String>{}); throw new AuraHandledException(e.getMessage()); }
            }   
        }   
    }
    
    
    public static void updateItemDetails(List<OpportunityLineItem> mNewOppItems, Map<Id, OpportunityLineItem> mOldOppItems) {
        try
        {
            for(OpportunityLineItem newOppItem : mNewOppItems){
                OpportunityLineItem oldOppItem = mOldOppItems != null ? mOldOppItems.get(newOppItem.Id) : null;
                
                if(oldOppItem.Quantity != newOppItem.Quantity) {
                    newOppItem.is_SAP_Price__c = false;
                }  
            }
        }   
        catch (Exception e) { LogUtil.emit(e, new Map<String, String>{}); throw new AuraHandledException(e.getMessage()); }
    }
        
    
    public static void syncQuoteLineItems(Map<Id, OpportunityLineItem> mNewOppItems, Map<Id, OpportunityLineItem> mOldOppItems) 
    {
        try
        {
            List<OpportunityLineItem> oppLinesToUpdate = new List<OpportunityLineItem>();
            List<QuoteLineItem> quoteLinesToUpdate = new List<QuoteLineItem>();
            List<QuoteLineItem> qlis = [SELECT Id, 
            is_SAP_Price__c,
            OpportunityLineItemId 
            FROM QuoteLineItem 
            WHERE OpportunityLineItemId IN :mNewOppItems.keySet()
            AND Quote.IsSyncing = TRUE];
            System.debug('qlis.size():' + qlis.size());
            for (QuoteLineItem qli : qlis)
            {
                System.debug('qli.is_SAP_Price__c: ' + qli.is_SAP_Price__c);
                if (mOldOppItems == null || !mOldOppItems.containsKey(qli.OpportunityLineItemId)) //Opp Line is being inserted through QLI
                {
                    OpportunityLineItem oppLineItem = new OpportunityLineItem(Id = qli.OpportunityLineItemId);
                    oppLineItem.is_SAP_Price__c = qli.is_SAP_Price__c;
                    oppLinesToUpdate.add(oppLineItem);
                }                
                else if (mOldOppItems != null && mOldOppItems.containsKey(qli.OpportunityLineItemId)) //Opp Line is being updated through QLI
                {                       
                    mNewOppItems.get(qli.OpportunityLineItemId).is_SAP_Price__c = qli.is_SAP_Price__c;
                }
            }
            update oppLinesToUpdate;
        }   
        catch (Exception e) { LogUtil.emit(e, new Map<String, String>{}); throw new AuraHandledException(e.getMessage()); }
    }    

}