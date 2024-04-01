/*
 * Copyright © 2021 Vigience Co., Ltd. All Rights Reserved
 */
@isTest
private with sharing  class OvcSAPSalesOrdersPerOppWoOrderPluginTest {
    @isTest
    private static void testEmptyMethod() {
        overcast.Globals.isOCF = true;
        OvcSAPSalesOrdersPerOppWoOrderPlugin plugin = new OvcSAPSalesOrdersPerOppWoOrderPlugin();
        plugin.afterComponentMetadataLoaded(null, null);
        plugin.afterReferenceValuesLoaded(null, null, null);
        plugin.afterReferenceValuesLoaded(null, null, null, null);
        plugin.afterScenarioCall(null,null,null);
        plugin.setLogger(null);
        plugin.onBackendMessageReceived(null);
        System.assertEquals(true, plugin.onScenarioException(null, null));
    }

    @isTest
    private static void testBeforeScenarioCall() {
        overcast.Globals.isOCF = true;
        overcast.TestingUtilities.SetupTestEnvironment('ovcSAPSalesDocumentHeader');
        OvcSAPSalesOrdersPerOppWoOrderPlugin plugin = new OvcSAPSalesOrdersPerOppWoOrderPlugin();
        plugin.testData = '{"output":{"VBAK":[{"VBELN":"0000005013","TELF1":"0511-347589-0"},{"VBELN":"0000005046","TELF1":"0511-347589-0"},{"VBELN":"0000005163","TELF1":"0511-347589-0"},{"VBELN":"0000005164","TELF1":"0511-347589-0"},{"VBELN":"0000005194","TELF1":"0511-347589-0"}]}}';
        Map<String,Object> importParameters = new Map<String,Object>();
        Map<String,Object> settings = new Map<String,Object>();
        plugin.beforeScenarioCall(null, null, importParameters, settings);
        System.assert(importParameters.containsKey('SALES_DOCUMENTS'), 'SALES_DOCUMENTS should be exists in parameter if no settings');
        System.assertEquals(1, ((List<Object>)importParameters.get('SALES_DOCUMENTS')).size(), 'SALES_DOCUMENTS size should be 1 if no settings');
        System.assertEquals('XXXXXXXXXX', ((Map<String,Object>)((List<Object>)importParameters.get('SALES_DOCUMENTS'))[0]).get('VBELN'), 'SALES_DOCUMENTS.VBELN should be "XXXXXXXXXX" if no settings');

        Map<String,Object> settings2 = new Map<String,Object>{'OpportunityData' => 'data', 'VBAKField' => 'TELF1'};
        plugin.beforeScenarioCall(null, null, importParameters, settings2);
        System.assert(importParameters.containsKey('SALES_DOCUMENTS'), 'SALES_DOCUMENTS should be exists in parameter if no settings');
        System.assertEquals(5, ((List<Object>)importParameters.get('SALES_DOCUMENTS')).size(), 'SALES_DOCUMENTS size should be 5 if run with valid settings');
        System.assertEquals('0000005013', ((Map<String,Object>)((List<Object>)importParameters.get('SALES_DOCUMENTS'))[0]).get('VBELN'), 'first of SALES_DOCUMENTS.VBELN should be "0000005013" if run with valid settings');

        Map<String,Object> settings3 = new Map<String,Object>{'OpportunityData' => 'data', 'VBAKField' => 'TELF1', 'Limit' => '100'};
        plugin.beforeScenarioCall(null, null, importParameters, settings3);

        Map<String,Object> settings4 = new Map<String,Object>{'OpportunityData' => 'data', 'VBAKField' => 'TELF1', 'Limit' => 'xxx'};
        plugin.beforeScenarioCall(null, null, importParameters, settings4);

        plugin.testData = '{"output":{"VBAK":[]}}';
        plugin.beforeScenarioCall(null, null, importParameters, settings3);
        System.assert(importParameters.containsKey('SALES_DOCUMENTS'), 'SALES_DOCUMENTS should be exists in parameter if vbak is empry');
        System.assertEquals(1, ((List<Object>)importParameters.get('SALES_DOCUMENTS')).size(), 'SALES_DOCUMENTS size should be 1 if vbak is empry');
        System.assertEquals('XXXXXXXXXX', ((Map<String,Object>)((List<Object>)importParameters.get('SALES_DOCUMENTS'))[0]).get('VBELN'), 'SALES_DOCUMENTS.VBELN should be "XXXXXXXXXX" if vbak is empry');        
    }
}