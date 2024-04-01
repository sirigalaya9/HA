/*
* Reusable methods to create test data
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
public class TestDataFactory 
{

    public static Bypass__c createBypass(Boolean bypassRT, Boolean bypassPE, Boolean bypassTrigger)
    {
        Bypass__c bypass = new Bypass__c();  
        bypass.Bypass_RT__c = bypassRT; 
        bypass.Bypass_PE__c = bypassPE;
        bypass.Bypass_Trigger__c = bypassTrigger;
        insert bypass;
        return bypass;
    }
    /*
    public static Apex_Settings__c bypassOpportunityTrigger(Boolean bypass)
    {
        Apex_Settings__c apexSettings = new Apex_Settings__c();         
        apexSettings.Name = 'OpportunityTrigger';        
        apexSettings.IsActive__c = !bypass;        
        insert apexSettings;
        return apexSettings;
    }
    
    public static Apex_Settings__c bypassQuoteTrigger(Boolean bypass)
    {
        Apex_Settings__c apexSettings = new Apex_Settings__c();         
        apexSettings.Name = 'QuoteTrigger';        
        apexSettings.IsActive__c = !bypass;        
        insert apexSettings;
        return apexSettings;
    }     
    */
    public static Lead createLead()
    {
        Lead lead = new Lead();
        lead.LastName = 'Test';
        lead.Company = 'Test';
        lead.Data_Consent__c = true;
        lead.CurrencyIsoCode = 'EUR';
        lead.CountryCode = 'DE';
        insert lead;
        return lead;        
    }

    public static void convertLead(Lead lead)
    {
        Database.LeadConvert lc = new database.LeadConvert();
        lc.setLeadId(lead.id);
        lc.setDoNotCreateOpportunity(false);
        lc.setConvertedStatus('Qualified');
        Database.LeadConvertResult lcr = Database.convertLead(lc);       
    }    

    public static Lead_Item__c createLeadItem(Id leadId)
    {
        Lead_Item__c leadItem = new Lead_Item__c();
        leadItem.Lead__c = leadId;
        leadItem.Product_Interest_Category__c = 'Furniture construction';
        leadItem.Product_Interest__c = 'PCM - Shelf supports';
        insert leadItem;
        return leadItem;        
    }
    
    public static Product2 createProduct(Boolean isPCM, Integer level)
    {
        Product2 product = new Product2();
        product.Name = 'PCM - Shelf supports';
        product.ProductCode = 'PCM - Shelf supports';
        if (isPCM)
        {
            product.PCM_Product__c = true;            
        }
        if (level != null)
        {
            if (level >= 1)
            {
                product.PCM_Hierarchy_1__c = 'C1';                
            }
            if (level >= 3)
            {
                product.PCM_Hierarchy_3__c = 'C10506';
            }
        }
        product.IsActive = true;        
        insert product;
        return product;        
    }

    public static PricebookEntry createPricebookEntry(Id productId)
    {
        PricebookEntry pbe = new PricebookEntry();
        pbe.IsActive = true;
        pbe.Pricebook2Id = Test.getStandardPricebookId();
        pbe.Product2Id = productId;
        pbe.CurrencyIsoCode = 'EUR';
        pbe.UnitPrice = 0;
        insert pbe;
        return pbe;
    } 

    public static Sales_Organization__c createSalesOrg()
    {
        Sales_Organization__c salesOrg = new Sales_Organization__c();
        salesOrg.Name = 'Hafele Germany';
        salesOrg.Code__c = 'DE01';
        salesOrg.Active__c = true;
        insert salesOrg;
        return salesOrg;
    }

    public static User_Sales_Organization__c createUserSalesOrg(Id salesOrgId)
    {
        User_Sales_Organization__c userSalesOrg = new User_Sales_Organization__c();
        userSalesOrg.Name = 'Hafele Germany';
        userSalesOrg.User__c = System.UserInfo.getUserId();
        userSalesOrg.Sales_Organization__c = salesOrgId;
        insert userSalesOrg;
        return userSalesOrg;
    }    

    public static Account createAccount()
    {
        Account account = new Account();
        account.Name = 'Test';
        insert account;
        return account;
    }

    public static Sales_Area__c createSalesArea(Id accountId, String salesOrgCode, String salesOffice, String salesGroup)
    {
        Sales_Area__c salesArea = new Sales_Area__c();
        salesArea.Account__c = accountId;
        salesArea.SAP_SA_ID__c = 'TEST';
        salesArea.Sales_Organization__c = salesOrgCode;
        salesArea.Sales_Office__c = salesOffice;
        salesArea.Sales_Group__c = salesGroup;
        insert salesArea;
        return salesArea;
    }     

    public static Project__c createProject()
    {
        Project__c project = new Project__c();
        project.Name = 'Test';
        project.Project_Type__c = 'Hotel';
        insert project;
        return project;
    }    

    public static Opportunity createOpportunity(Id accountId)
    {
        Opportunity opp = new Opportunity();
        opp.Name = 'Test';
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.CurrencyIsoCode = 'EUR';
        opp.AccountId = accountId;
        opp.CloseDate = System.today();
        opp.StageName = 'Identification';
        opp.Project_Business__c = 'Yes';
        insert opp;
        return opp;
    }

    public static Quote createQuote(Id oppId)
    {
        Quote qt = new Quote();
        qt.OpportunityId = oppId;
        qt.Name = 'Test';
        insert qt;
        return qt;
    }    
}