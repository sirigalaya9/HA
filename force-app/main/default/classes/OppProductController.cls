/*
* Custom Opportunity Product Screen controller methods to query and save OpportunityProduct
* @author manu.voramontri@kliqxe.com
* @since 30.01.2024
* @version 30.01.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 30.01.2024   ly.sirigalkaya@kliqxe.com         Initial Version
* 01.03.2024   ly.sirigalkaya@kliqxe.com         get SAP Price
*/
public with sharing class OppProductController {
    
    @AuraEnabled
    public static List<OpportunityLineItem> getItems(Id oppId)
    {
        List<OpportunityLineItem> items = [SELECT Id, 
        Name, 
        OpportunityId, 
        Opportunity.AccountId, 
        PricebookEntryId, 
        Product2Id, 
        Quantity, 
        UnitPrice,        
        ListPrice,
        Description,
        Product2.Description,
        Product2.Name,
        Product2.ProductCode,
        Product2.PCM_Product__c,
        Product2.PCM_Hierarchy_1__c,
        Product2.PCM_Hierarchy_2__c,
        Product2.PCM_Hierarchy_3__c,
        Product2.Product_Code_Format__c,
        TotalPrice,
        is_SAP_Price__c,
        is_Price_Locked__c,
        OHA__c,
        PCM_Product__c
        FROM OpportunityLineItem 
        WHERE OpportunityId = :oppId ORDER BY Product2.PCM_Product__c,CreatedDate ASC];

        return items;
    }
    
    @AuraEnabled
    public static PricingATPCallout.ReturnValues getPriceATP(Id recordId, List<OpportunityLineItem> oppItems)
    {
        system.debug('Opp getPriceATP');
        PricingATPCallout.ReturnValues pricingResults;
        
        List<Opportunity> opp =  [SELECT Id, CloseDate, AccountId, Sales_Organization__c, Account.overcast__SAP_BP_Number__c   
                                  FROM Opportunity
                                  WHERE Id = :recordId LIMIT 1];

        if(!opp.isEmpty() && !oppItems.isEmpty()){
            system.debug('Call sendRequest');
            system.debug(opp.get(0));
            
            PricingATPWrapper.ORDER_PARTNERS ORDER_PARTNERS = new PricingATPWrapper.ORDER_PARTNERS();
            ORDER_PARTNERS.PARTN_NUMB = opp[0].Account.overcast__SAP_BP_Number__c; //Account.overcast__SAP_BP_Number__c
            ORDER_PARTNERS.PARTN_ROLE = 'AG';
            
            PricingATPWrapper.ORDER_HEADER_IN ORDER_HEADER_IN = new PricingATPWrapper.ORDER_HEADER_IN();
            ORDER_HEADER_IN.REQ_DATE_H = opp[0].CloseDate; //Opportunity.CloseDate
            ORDER_HEADER_IN.SALES_ORG = opp[0].Sales_Organization__c;  //Opportunity.Sales_Organization__c
            ORDER_HEADER_IN.DOC_TYPE = 'ZQS';
            
            List<PricingATPWrapper.ORDER_ITEMS_IN> ORDER_ITEMS_IN_LIST = new List<PricingATPWrapper.ORDER_ITEMS_IN>();
            Integer ItemNo = 0;
            
            for (OpportunityLineItem item : oppItems) {
                if(!item.Product2.PCM_Product__c){
                    //system.debug('original quantity : '+item.quantity);
                    String SAPQty = String.valueOf(Integer.valueOf(item.quantity)*1000);
                    //system.debug('SAP Qty : '+SAPQty);
                    
                    ItemNo += 1;
                    PricingATPWrapper.ORDER_ITEMS_IN ORDER_ITEMS_IN = new PricingATPWrapper.ORDER_ITEMS_IN();
                    ORDER_ITEMS_IN.TARGET_QTY = SAPQty; //0000000001000 = 1qty (*1000)  (13digit)
                    ORDER_ITEMS_IN.PO_ITM_NO = String.valueOf(ItemNo);
                    ORDER_ITEMS_IN.ITM_NUMBER = String.valueOf(ItemNo);
                    ORDER_ITEMS_IN.REQ_QTY = SAPQty;  //0000000001000 = 1qty (*1000)  (13digit)
                    ORDER_ITEMS_IN.REQ_DATE = opp[0].CloseDate; //Opportunity.CloseDate
                    ORDER_ITEMS_IN.MATERIAL = item.Product2.ProductCode;
                    ORDER_ITEMS_IN_LIST.add(ORDER_ITEMS_IN);
                }
            }
            
            PricingATPWrapper.sapPricingATP data = new PricingATPWrapper.sapPricingATP();
            data.ORDER_PARTNERS = ORDER_PARTNERS;
            data.ORDER_HEADER_IN = ORDER_HEADER_IN;
            data.ORDER_ITEMS_IN_LIST = ORDER_ITEMS_IN_LIST;
            
            pricingResults = PricingATPCallout.sendRequest(data);  
        }
        
        return pricingResults;
    }

    @AuraEnabled
    public static void saveItems(List<OpportunityLineItem> items, List<OpportunityLineItem> itemsToDelete)
    {
        try {
            for (OpportunityLineItem item : items)
                System.debug(item.Product2Id);
            upsert items;            
            delete itemsToDelete;    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}