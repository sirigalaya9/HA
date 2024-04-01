@isTest
public class OpportunityTriggerHandlerTest 
{
    @TestSetup
    static void setupData()
    {
        TestDataFactory.createBypass(true, true, false);
        Sales_Organization__c salesOrg = TestDataFactory.createSalesOrg();      
        TestDataFactory.createUserSalesOrg(salesOrg.Id);  
        Account account = TestDataFactory.createAccount();
        TestDataFactory.createOpportunity(account.Id);
        Product2 product = TestDataFactory.createProduct(true, 3);
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id); 
        Project__c project = TestDataFactory.createProject();
    }

    @isTest
    static void testValidateOPP001()
    {        
        delete [SELECT Id FROM User_Sales_Organization__c];
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = System.today();
        opp.StageName = 'Identification';
        try
        {
            insert opp;
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('OPP-001'), 'Error User has no sales org');
        }
    }

    @isTest
    static void testValidateOPP002()
    {        
        Account account = [SELECT Id FROM Account];
        account.SAP_Customer_Number__c = 'TEST';
        update account;
        TestDataFactory.createSalesArea(account.Id, 'AA01', 'AA10', 'AA0');
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = System.today();
        opp.StageName = 'Identification';
        opp.AccountId = account.Id;
        try
        {
            insert opp;
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('OPP-002'), 'Error User sales org not matched Account Sales Org/Division/Distribution channel');
        }
    }    

    @isTest
    static void testValidateOPP003()
    {        
        Account account = [SELECT Id FROM Account];
        account.First_Assigned_Sales_Org__c = 'AA01';
        update account;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.CloseDate = System.today();
        opp.StageName = 'Identification';
        opp.AccountId = account.Id;
        try
        {
            insert opp;
        }
        catch (Exception e)
        {
            System.assert(e.getMessage().contains('OPP-003'), 'Error User sales org not matched First Account Sales Org');
        }
    } 

    @isTest
    static void testSyncProjectToQuote()
    {                        
        Opportunity opp = [SELECT Id FROM Opportunity];
        TestDataFactory.createQuote(opp.Id); 
        TestDataFactory.createQuote(opp.Id);        

        Test.startTest();
        opp.Project__c = [SELECT Id FROM Project__c].Id;
        update opp;
        Test.stopTest();

        List<Opportunity> oppResults = [SELECT Id, Project__c FROM Opportunity WHERE Project__c = :opp.Project__c];
        List<Quote> quoteResults = [SELECT Id FROM Quote WHERE Project__c = :opp.Project__c];
        System.assertEquals(1, oppResults.size(), '1 Opp should be updated');
        System.assertEquals(2, quoteResults.size(), '2 Quotes should be updated');
    }    
}