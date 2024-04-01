
public without sharing class QuoteCreationController {

    public class ReturnValues
        {
            @AuraEnabled public Boolean isSuccess { get; set; }
            @AuraEnabled public String quoteSAPId{ get; set; }
            @AuraEnabled public String errorMessage { get; set; }        
        }

    public static ReturnValues sendQuoteToSAP(HeaderWrapper header, String quoteId){

        List<QuoteLineItem> items = [SELECT Id,         
        QuoteId, 
        Product2Id, 
        Quantity, 
        UnitPrice,  
        ListPrice,      
        Description,
        Product2.Description,
        Product2.Name,
        Product2.ProductCode,
        is_SAP_Price__c,
        Delivery_Date__c,
        FROM QuoteLineItem 
        WHERE QuoteId = :quoteId
        ];
        



    }

}