/*
* Custom Opportunity/Quote Product Screen controller methods for custom lookup component
* @author ly.sirigalaya@kliqxe.com
* @since 30.01.2024
* @version 30.01.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 30.01.2024   ly.sirigalaya@kliqxe.com         Initial Version
* 01.03.2024   ly.sirigalaya@kliqxe.com         Product Sales Org Filter
*/
public with sharing class ProductLookupController
{
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(Id recordId, String currencyIsoCode, String pricebookId, String searchTerm, 
                                             String salesOrgCode, String hierarchy1, String hierarchy3, String languageCode) {
        
        List<String> productFields = new List<String>{'Name', 'ProductCode', 'Description', 'OHA_Classification__c', 'PCM_Product__c','Product_Code_Format__c'};
        List<Product2> products = new  List<Product2>();
        
        try{
            String objectApiName = recordId.getSObjectType().getDescribe().getName();
            String descFieldApiName;
            String dynamicDesc;
            
            if(languageCode != null){
                descFieldApiName = 'Description_' + languageCode + '__c';
                productFields.add(descFieldApiName);
            }
            
            products = ProductLookupController.queryProductsWithSalesOrg(objectApiName, productFields, salesOrgCode, pricebookId, currencyIsoCode, 
                                                                         searchTerm, hierarchy1, hierarchy3);
            if(languageCode != null){
                for(Product2 pro : products){
                    dynamicDesc = (String) pro.get(descFieldApiName);
                    pro.Description = dynamicDesc != null ? dynamicDesc : pro.Description;
                }
            }
            
            return products;
        } catch (QueryException e) {
            throw new AuraHandledException('Error get products: ' + e.getMessage());
        }
    }
    
    public static List<Product2> queryProductsWithSalesOrg (String objectApiName, List<String> productFields, String salesOrgCode, String pricebookId, String currencyIsoCode, String searchTerm,
                                                            String hierarchy1, String hierarchy3) { 
        String query = 'SELECT Id, '+ String.join(productFields, ', ') + ' ' +
            ',(SELECT Id, UnitPrice, Product2Id FROM PricebookEntries ' +
            'WHERE Pricebook2Id = :pricebookId AND CurrencyIsoCode = :currencyIsoCode) ' +
            ',(SELECT Id, Name, Product__c, SAP_PSO_ID__c, DChain__c, Deletion__c, Deletion_Date__c, Block__c ' +
            'FROM Product_Sales_Organizations__r '+
            'WHERE NAME =: salesOrgCode) '+
            'FROM Product2 '+
            'WHERE IsActive = TRUE ' +
            'AND Id IN ' +
            '(SELECT Product2Id '+
            'FROM PricebookEntry '+
            'WHERE Pricebook2Id = :pricebookId AND CurrencyIsoCode = :currencyIsoCode) '+
            'AND Id IN ' +
            '(SELECT Product__c '+
            'FROM Product_Sales_Organization__c '+
            'WHERE Deletion__c = false AND Block__c = false AND NAME =: salesOrgCode) ';
        
        if(objectApiName == 'Quote' || String.isNotBlank(hierarchy1) || String.isNotBlank(hierarchy3)) query += 'AND PCM_Product__c = FALSE ';
        // Adding search term conditions 
        if (!String.isEmpty(searchTerm)) {
            query += 'AND (';
            for (String field : productFields) {
                //if (field.toLowerCase() == 'name' || field.toLowerCase() == 'description' || field.toLowerCase() == 'productcode' || field.toLowerCase() == 'product_code_format__c') {
                if(field != 'OHA_Classification__c' && field != 'PCM_Product__c'){
                    query += field + ' LIKE \'%' + searchTerm + '%\' OR ';
                }
            }
            query = query.removeEnd(' OR '); 
            query += ')';
        }
        //Hierarchy 3
        if (String.isNotBlank(hierarchy3)) {
            query += ' AND PCM_Hierarchy_3__c = :hierarchy3';
        }
        else if (String.isNotBlank(hierarchy1)) {
            query += ' AND PCM_Hierarchy_1__c = :hierarchy1';
        }
        query += ' LIMIT 20';
        system.debug(query);
        
        try{
            return Database.query(query);
        } catch (QueryException e) {
            throw new AuraHandledException('Error get products: ' + e.getMessage());
        }       
    }
}