@isTest
public class QuoteTriggerHandlerTest 
{
    @TestSetup
    static void setupData()
    {
        Bypass__c bypass = TestDataFactory.createBypass(true, true, false);        
        bypass.Bypass_Trigger_Opportunity__c = true;
        update bypass;        
        Product2 product = TestDataFactory.createProduct(true, 3);
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id); 
        Account account = TestDataFactory.createAccount();
        Opportunity opp = TestDataFactory.createOpportunity(account.Id);
        opp.Pricebook2Id = Test.getStandardPricebookId();
        Quote qt = TestDataFactory.createQuote(opp.Id);        
        Project__c project = TestDataFactory.createProject();
    }

    @isTest
    static void testSyncProjectToOpportunity()
    {                        
        Quote qt = [SELECT Id FROM Quote];
        qt.Project__c = [SELECT Id FROM Project__c].Id;
        Opportunity opp = [SELECT Id FROM Opportunity];
        TestDataFactory.createQuote(opp.Id);         

        Test.startTest();
        update qt;
        Test.stopTest();

        List<Opportunity> oppResults = [SELECT Id, Project__c FROM Opportunity WHERE Project__c = :qt.Project__c];
        List<Quote> quoteResults = [SELECT Id FROM Quote WHERE Project__c = :qt.Project__c];
        System.assertEquals(1, oppResults.size(), '1 Opp should be updated');
        System.assertEquals(2, quoteResults.size(), '2 Quotes should be updated');
    }

    @isTest
    static void testQuoteVersionNumber()
    {
        Test.startTest();
        Opportunity opp = [SELECT Id FROM Opportunity];
        Quote qt = TestDataFactory.createQuote(opp.Id);    
        Test.stopTest();
        Quote result = [SELECT Version_Number__c FROM Quote WHERE Id = :qt.Id];
        System.assertEquals(2, result.Version_Number__c, 'Version number should be incremented');
    }    
}