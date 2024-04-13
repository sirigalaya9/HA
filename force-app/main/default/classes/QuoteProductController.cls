/*
* Custom Quote Product Screen controller methods to query and save QuoteLineItem
* @author manu.voramontri@kliqxe.com
* @since 30.01.2024
* @version 30.01.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 30.01.2024   ly.sirigalkaya@kliqxe.com         Initial Version
* 22.02.2024   ly.sirigalkaya@kliqxe.com         get SAP Price (STD)
* 11.04.2024   ly.sirigalkaya@kliqxe.com         getSAPPricing (Custom)
*/
public with sharing class QuoteProductController {
     
    @AuraEnabled
    public static Map<String, Object> getSAPPricing(Id recordId, List<QuoteLineItem> quoteItems){
        Map<String, Object> returnedData = new Map<String, Object>();
        
        //Validation 
        //Opportunity.Sales_Organization__c != null
        //Account.overcast__SAP_BP_Number__c != null
        //There is Line item
        
        List<Quote> quote =  [SELECT Id, OpportunityId, Opportunity.CloseDate, Opportunity.AccountId, CurrencyIsoCode,
                              Opportunity.Sales_Organization__c, Opportunity.Sales_Office__c,Opportunity.Division__c, Opportunity.Distribution_Channel__c, 
                              Requested_Delivery_Date__c, Account.overcast__SAP_BP_Number__c
                              //Account.Customer_SAP_Number__c   
                              FROM Quote
                              WHERE Id = :recordId LIMIT 1];
        
        if(!quote.isEmpty() && !quoteItems.isEmpty()){
            if(quote[0].Opportunity.Sales_Organization__c != null){
                returnedData = SAPQuotePricingSimulateService.sendRequest(quote[0], quoteItems);   
            }
            else{
                String error = 'Please assign SalesOrg on Opportunity';
                throw new AuraHandledException(error);
            }
        }
        return returnedData;
    }

    @AuraEnabled
    public static PricingATPCallout.ReturnValues getPriceATP(Id recordId, List<QuoteLineItem> quoteItems)
    {
        system.debug('getPriceATP');
        PricingATPCallout.ReturnValues pricingResults;
        
        List<Quote> quote =  [SELECT Id, OpportunityId, Opportunity.CloseDate, Opportunity.AccountId, Opportunity.Sales_Organization__c, Account.overcast__SAP_BP_Number__c   
                              FROM Quote
                              WHERE Id = :recordId LIMIT 1];

        if(!quote.isEmpty() && !quoteItems.isEmpty()){
            system.debug('Call sendRequest');
            system.debug(quote.get(0));
            
            PricingATPWrapper.ORDER_PARTNERS ORDER_PARTNERS = new PricingATPWrapper.ORDER_PARTNERS();
            ORDER_PARTNERS.PARTN_NUMB = quote[0].Account.overcast__SAP_BP_Number__c; //Account.overcast__SAP_BP_Number__c
            ORDER_PARTNERS.PARTN_ROLE = 'AG';
            
            PricingATPWrapper.ORDER_HEADER_IN ORDER_HEADER_IN = new PricingATPWrapper.ORDER_HEADER_IN();
            ORDER_HEADER_IN.REQ_DATE_H = quote[0].Opportunity.CloseDate; //Opportunity.CloseDate
            ORDER_HEADER_IN.SALES_ORG = quote[0].Opportunity.Sales_Organization__c;  //Opportunity.Sales_Organization__c
            ORDER_HEADER_IN.DOC_TYPE = 'ZQS';
            
            List<PricingATPWrapper.ORDER_ITEMS_IN> ORDER_ITEMS_IN_LIST = new List<PricingATPWrapper.ORDER_ITEMS_IN>();
            Integer ItemNo = 0;
            
            for (QuoteLineItem item : quoteItems) {
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
                    ORDER_ITEMS_IN.REQ_DATE = quote[0].Opportunity.CloseDate; //Opportunity.CloseDate
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
    public static List<QuoteLineItem> getItems(Id recordId)
    {
        List<QuoteLineItem> items = [SELECT Id,         
        QuoteId, 
        Quote.OpportunityId,
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
        Product2.Product_Code_Format__c,
        TotalPrice,
        is_SAP_Price__c,
        Delivery_Date__c,
        Rejected__c 
        FROM QuoteLineItem 
        WHERE QuoteId = :recordId ORDER BY Product2.PCM_Product__c,CreatedDate ASC];
        
        System.debug('items size: ' + items.size());

        return items;
    }

    @AuraEnabled
    public static void saveItems(List<QuoteLineItem> items, List<QuoteLineItem> itemsToDelete)
    {
        try {
            for (QuoteLineItem item : items)
            {
                System.debug(item.Product2Id);                
                String id = (String) item.Id;
                if (!(id instanceof Id))
                {                
                    item.Id = null;
                }                                
            }          
            System.debug(items);
            upsert items;            
            delete itemsToDelete;            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }  
}