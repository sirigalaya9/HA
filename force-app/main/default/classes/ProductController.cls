public with sharing class ProductController {


    @AuraEnabled
    public static List<Product2> getProducts(String pricebookId, String CurrencyCode) {
        /*List<RecordType> rtypes = [SELECT Id,Name FROM RecordType WHERE SobjectType='Product2'];
        Schema.DescribeSObjectResult d = Schema.SObjectType.Product2; 
        Map<Id,Schema.RecordTypeInfo> rtMapById = d.getRecordTypeInfosById();
        List<Id> holderId = new List<Id>();
        for (RecordType rt : rtypes){
        Schema.RecordTypeInfo rtById =  rtMapById.get(rt.id);
            if (rtById.isAvailable() == true){
                holderId.add(rtById.getRecordTypeId());
            }        
        }*/
        
        system.debug(pricebookId);
        system.debug(CurrencyCode);
         //system.debug(searchTerm);
        
        return [SELECT Id, Name, ProductCode, Description, 
                //Product_Range__c, Product_Size__c, Product_Type__c,           
                (SELECT Id, 
                UnitPrice        
                FROM PricebookEntries 
                WHERE CurrencyIsoCode = :CurrencyCode 
                AND Pricebook2Id = :pricebookId)
            FROM Product2 
            WHERE IsActive = TRUE
            AND Id IN 
                (SELECT Product2Id 
                FROM PricebookEntry 
                WHERE CurrencyIsoCode = :CurrencyCode 
                AND Pricebook2Id = :pricebookId) ORDER BY CreatedDate DESC LIMIT 500];
        

    }

    @AuraEnabled
    public static List<Product2> getSearchResult(Product2 product, String pricebookId, String currencyCode, String searchTerm)
    {
        system.debug(product);
        system.debug(searchTerm);
        
        String qString = 'SELECT Id, Name, ProductCode, Description, IsActive, ';
        qString += '(SELECT Id, UnitPrice FROM PricebookEntries ';
        qString += 'WHERE CurrencyIsoCode = \'' + currencyCode + '\' AND Pricebook2Id = \'' + pricebookId + '\') ';
        qString += 'FROM Product2 ';
        qString += 'WHERE IsActive = TRUE ';
        qString += 'AND Id IN ';
        qString += '(SELECT Product2Id FROM PricebookEntry ';
        qString += 'WHERE CurrencyIsoCode = \'' + currencyCode + '\' AND Pricebook2Id = \'' + pricebookId + '\') ';
        if (String.isNotBlank(searchTerm))
            qString += 'AND (Name LIKE \'%' + searchTerm + '%\') ';
            //qString += 'AND (Name LIKE \'' + searchTerm + '\' OR Description LIKE \'' + searchTerm + '\' OR ProductCode LIKE \'' + searchTerm + '\') ';
        
        /*if (String.isNotBlank(product.Product_Range__c)){
            //if(first == false) qString += ' AND ';
            qString += ' AND Product_Range__c = \'' + product.Product_Range__c + '\' ';
            //if(first) first = false;
        }
         if (String.isNotBlank(product.Product_Size__c)){
            //if(first == false) qString += ' AND ';
            qString += ' AND Product_Size__c = \'' + product.Product_Size__c + '\' ';
            //if(first) first = false;
        }*/
        
        qString += 'ORDER BY LastmodifiedDate DESC LIMIT 500 ';
        
        
        /*String qString = 'SELECT Id, Name, ProductCode, Description, IsActive, Product_Range__c, Product_Size__c, Product_Type__c, ';
        qString += '(SELECT Id, UnitPrice FROM PriceBookEntries WHERE PriceBook2Id = \'' + pricebookId + '\' LIMIT 1) FROM Product2 WHERE ';

        Boolean first = true;
        if (String.isNotBlank(product.Product_Range__c)){
            if(first == false) qString += ' AND ';
            qString += ' Product_Range__c = \'' + product.Product_Range__c + '\' ';
            if(first) first = false;
        }
        if (String.isNotBlank(product.Product_Size__c)){
            if(first == false) qString += ' AND ';
            qString += ' Product_Size__c = \'' + product.Product_Size__c + '\' ';
            if(first) first = false;
        }
  
        qString += ' LIMIT 1000 ';*/

        system.debug(qString);
        return database.query(qString);

        }

    @AuraEnabled
    public static List<OpportunityLineItem> getOpportunityLineItems(Id oliRecordId) {
        List<OpportunityLineItem> oliProducts = new List<OpportunityLineItem> ();
        return [SELECT Id, Name, UnitPrice, ListPrice, Product2.Name, Product2.Description, 
                Quantity, TotalPrice from OpportunityLineItem WHERE OpportunityId = :oliRecordId Order by CreatedDate];
    }

    @AuraEnabled
    public static void saveOLI (Id OpId, Id ProdId, Integer qty, Decimal sprice, Id PriceBId, Decimal Discounts){
        try{
            OpportunityLineItem OLI = new OpportunityLineItem();
            OLI.OpportunityId = OpId;
            OLI.Product2Id = ProdId;
            OLI.Quantity = qty;
            OLI.UnitPrice = sprice;
            OLI.PricebookEntryId = PriceBId;
            //OLI.Discount__c = Discounts;
            insert OLI;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void saveItems(List<OppItemWrap> OppItemWraps, Id accountId, String country, String channel)
    {
        system.debug(accountId+' '+country+' '+channel);
        system.debug(OppItemWraps);
        
        Map<String, String> productRangeMap = new Map<String, String>();
        List<OpportunityLineItem> oppItemsToInsert = new List<OpportunityLineItem>();
        
        for(OppItemWrap pro : OppItemWraps){
			//Discount__c dis = ProductLookupController.getDiscount(accountId,country,pro.productRange,channel);
            //system.debug(dis);
            OpportunityLineItem oppitem = pro.oppLineItem;
			//oppitem.Discount__c = dis.Discount__c != null ? dis.Discount__c : 0;
            oppItemsToInsert.add(oppItem);
        }
        
        
        try {
            insert oppItemsToInsert;          
            //delete itemsToDelete;    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        } 
    }
    
    public class OppItemWrap
    {
        @AuraEnabled
        public OpportunityLineItem oppLineItem { get; set; }
        @AuraEnabled
        public String productRange { get; set; }

        
    }
    
}