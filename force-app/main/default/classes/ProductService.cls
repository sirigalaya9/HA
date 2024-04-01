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
public with sharing class ProductService 
{
    @AuraEnabled(cacheable=true)
    public static List<Product2> getProducts(String currencyIsoCode, String pricebookId, String searchTerm, String hierarchy1, String hierarchy3) {
        List<String> productFields = new List<String>{'Name', 'ProductCode', 'Description', 'OHA_Classification__c'};
        List<String> userSalesOrgs = new List<String>(); 
        
        //------ get User's Sales Orgs
        Id userId = UserInfo.getUserId(); // Current User ID
        List<User_Sales_Organization__c> userSaleOrgs = [SELECT Id, Name, Code__c, User__c, Sales_Organization__c 
                                                         FROM User_Sales_Organization__c 
                                                         WHERE User__c =: userId];
        
        for(User_Sales_Organization__c uso : userSaleOrgs){
            userSalesOrgs.add(uso.Code__c);
        }
        
        List<Product2> products = queryProductsWithSalesOrg(productFields, userSalesOrgs, pricebookId, currencyIsoCode, searchTerm, hierarchy1, hierarchy3);
        return products;        
    }

    public static List<Product2> queryProductsWithSalesOrg (List<String> productFields, List<String> userSalesOrgs, String pricebookId, String currencyIsoCode, String searchTerm, 
    String hierarchy1, String hierarchy3) { 
        String query = 'SELECT Id, '+ String.join(productFields, ', ') + ' ' +
            ',(SELECT Id, UnitPrice, Product2Id FROM PricebookEntries ' +
            'WHERE Pricebook2Id = :pricebookId AND CurrencyIsoCode = :currencyIsoCode) ' +
            ',(SELECT Id, Name, Product__c, SAP_PSO_ID__c, DChain__c, Deletion__c, Deletion_Date__c, Block__c ' +
            'FROM Product_Sales_Orgnizations__r '+
            'WHERE NAME IN: userSalesOrgs) '+
            'FROM Product2 '+
            'WHERE IsActive = TRUE ' +
            'AND Id IN ' +
            '(SELECT Product2Id '+
            'FROM PricebookEntry '+
            'WHERE Pricebook2Id = :pricebookId AND CurrencyIsoCode = :currencyIsoCode) '+
            'AND Id IN ' +
            '(SELECT Product__c '+
            'FROM Product_Sales_Orgnization__c '+
            'WHERE Deletion__c = false AND Block__c = false AND NAME IN: userSalesOrgs) ';
        
        // Adding search term conditions 
        if (!String.isEmpty(searchTerm)) {
            query += 'AND (';
            for (String field : productFields) {
                if (field.toLowerCase() == 'name' || field.toLowerCase() == 'description' || field.toLowerCase() == 'productcode') {
                    query += field + ' LIKE \'%' + searchTerm + '%\' OR ';
                }
            }
            // Remove trailing 'OR'
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