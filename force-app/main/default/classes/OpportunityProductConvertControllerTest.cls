@isTest
public class OpportunityProductConvertControllerTest 
{
    @TestSetup
    static void setupData()
    {
        Bypass__c bypass = TestDataFactory.createBypass(true, true, true);        
        bypass.Bypass_Trigger_Opportunity__c = true;
        update bypass;
        Lead lead = TestDataFactory.createLead();
        Lead_Item__c leadItem = TestDataFactory.createLeadItem(lead.Id);
        Product2 productLevel1 = TestDataFactory.createProduct(true, 1);        
        Product2 productLevel3 = TestDataFactory.createProduct(true, 3);
        TestDataFactory.createPricebookEntry(productLevel1.Id);
        TestDataFactory.createPricebookEntry(productLevel3.Id);
        Account account = TestDataFactory.createAccount();
        Opportunity opp = TestDataFactory.createOpportunity(account.Id);
        opp.Pricebook2Id = Test.getStandardPricebookId();
        update opp;
    }

    @isTest
    static void testGetProductHierarchy()
    {
        List<OpportunityProductConvertController.OptionDTO> results = OpportunityProductConvertController.getProductHierarchy();
        System.assert(results.size() > 0);
    }

    @isTest
    static void testConvertOppItem_New()
    {
        Opportunity opp = [SELECT Id FROM Opportunity];
        Product2 product = [SELECT Id FROM Product2 WHERE PCM_Hierarchy_3__c != NULL];
        OpportunityProductConvertController.convertOppItem(opp.Id, null, product.Id, 1, 1, 'No');
        List<OpportunityLineItem> items = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, items.size(), '1 line item should be created');
    }     
}