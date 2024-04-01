/*
* Opportunity Service Unit Test
* @author manu.voramontri@kliqxe.com
* @since 29.02.2024
* @version 29.02.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 29.02.2024   manu.voramontri@kliqxe.com         Initial Version
*/
@isTest
public class OpportunityServiceTest 
{
    @TestSetup
    static void setupData()
    {
        TestDataFactory.createBypass(true, true, true);              
        Lead lead = TestDataFactory.createLead();
        Lead_Item__c leadItem = TestDataFactory.createLeadItem(lead.Id);
        Product2 product = TestDataFactory.createProduct(true, 3);        
        PricebookEntry pbe = TestDataFactory.createPricebookEntry(product.Id);
    }

    @isTest
    static void testCopyLeadItemsToOppItems_Success()
    {                   
        Lead lead = [SELECT Id FROM Lead];
        TestDataFactory.convertLead(lead);

        Opportunity opp = [SELECT Id FROM Opportunity];
        opp.Pricebook2Id = System.Test.getStandardPricebookId();
        update opp;       

        List<Lead> leads = [SELECT Id, ConvertedOpportunityId FROM Lead];        
        OpportunityService.copyLeadItemsToOppItems(leads);
        
        List<OpportunityLineItem> oppItems = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(1, oppItems.size(), '1 item should be returned');      
    }

    @isTest
    static void testCopyLeadItemsToOppItems_Error_NoPB()
    {                   
        Bypass__c bypass = Bypass__c.getOrgDefaults();
        bypass.Bypass_Trigger__c = false;
        bypass.Bypass_Trigger_Opportunity__c = true;
        update bypass;

        Lead lead = [SELECT Id FROM Lead];
        TestDataFactory.convertLead(lead);
        
        List<OpportunityLineItem> oppItems = [SELECT Id FROM OpportunityLineItem];
        System.assertEquals(0, oppItems.size(), '0 item should be returned');      
    }
    /*
    @isTest
    static void testTerritoryAssignment()
    {
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<Id> oppIds = new List<Id>();        
        for (Opportunity opp : opps)
        {
            oppIds.add(opp.Id);
        }
        OppTerrAssignDefaultLogicFilter filter = new OppTerrAssignDefaultLogicFilter();
        Map<Id, Id> oppId2TerritoryIdMap = filter.getOpportunityTerritory2Assignments(oppIds);
        System.debug(oppId2TerritoryIdMap);
        for (Id oppId : oppId2TerritoryIdMap.keySet())
        {
            System.debug(oppId + ':' + oppId2TerritoryIdMap.get(oppId));
        }
    }
    */
}