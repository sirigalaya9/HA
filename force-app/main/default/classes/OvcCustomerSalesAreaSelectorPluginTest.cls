/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
@isTest
public with sharing class OvcCustomerSalesAreaSelectorPluginTest {
    @IsTest
    static void testEmptyMethod() {
        OvcCustomerSalesAreaSelectorPlugin plugin = new OvcCustomerSalesAreaSelectorPlugin();
        plugin.afterComponentMetadataLoaded(null, null);
        plugin.afterReferenceValuesLoaded(null, null, null);
        plugin.afterReferenceValuesLoaded(null, null, null,null);
        plugin.onScenarioException(null, null);
        System.assert(true, 'always true');
    }
    
     @isTest
    private static void testBeforeScenarioCall(){
        OvcCustomerSalesAreaSelectorPlugin plugin = new OvcCustomerSalesAreaSelectorPlugin();
        Map<String, Object> importParams = new Map<String,Object>{ 'KNVV' => new Map<String, Object>{ 'ovcLanguage' => 'E'} };
        Map<String, Object> referenceValues = new Map<String,Object>{ 'KNVV' => new Map<String, Object>{ 'ovcLanguage' => 'E'} };    
        plugin.beforeScenarioCall(null, referenceValues, importParams, null);
        
        Map<String, Object> referenceValuesMap =  (Map<String, Object>) plugin.refValues.get('KNVV');
        System.assertEquals(null, importParams.get('ovcLanguage'), 'Language not removed!');
        System.assertEquals('E', referenceValuesMap.get('ovcLanguage') , 'Language is wrong!');
    }   

    @IsTest
    private static void pluginAfterScenarioCallTest() {
        OvcCustomerSalesAreaSelectorPlugin plugin = new OvcCustomerSalesAreaSelectorPlugin();
        Map<String, Object> returnedData = new Map<String, Object>{
			'KNVV' => new List<Object>{
				new Map<String, Object>{ 'VKORG' => '1000', 'VTWEG' => '10', 'SPART' => '00'  },
                new Map<String, Object>{ 'VKORG' => '1000', 'VTWEG' => '20', 'SPART' => '00'}}
		};

        overcast.Globals.isOCF = true;
        overcast.TestingUtilities.SetupTestEnvironment('ovcSAPSalesOrganizationText');
        Map<String, Object> tr = new Map<String, Object>{ 'TVKOT' => new List<Object>{ new Map<String, Object>{ 'VKORG' => '1000', 'VTEXT' => 'Sales Organization Test' } } };
        plugin.testDataOrgTxt = JSON.serialize(new Map<String, Object>{ 'output' => tr });                 

        overcast.Globals.isOCF = true;
        overcast.TestingUtilities.SetupTestEnvironment('ovcSAPDistributionChannelText');
        Map<String, Object> trDist = new Map<String, Object>{ 'TVTWT' => new List<Object>{ new Map<String, Object>{ 'VTWEG' => '10', 'VTEXT' => 'Internal Dist. Channel Test' } } };
        plugin.testDataDistChannelTxt = JSON.serialize(new Map<String, Object>{ 'output' => trDist });   

        overcast.Globals.isOCF = true;
        overcast.TestingUtilities.SetupTestEnvironment('ovcSAPSalesDivisionText');
        Map<String, Object> trDiv = new Map<String, Object>{ 'TSPAT' => new List<Object>{ new Map<String, Object>{ 'SPART' => '00', 'VTEXT' => 'Product Division Test' } } };
        plugin.testDataDivisionTxt = JSON.serialize(new Map<String, Object>{ 'output' => trDiv });           
        
        Map<String,Object> refMap = new Map<String,Object>{ 'ovcLanguage' => 'E'};
        plugin.refValues.put('KNVV',refMap);            
        plugin.afterScenarioCall(returnedData, null, null);

        Map<String, Object> customerSalesAreaMap = (Map<String, Object>) ((List<Object>) returnedData.get('KNVV'))[0];
        System.assertEquals(2, ((List<Object>) returnedData.get('KNVV')).size(), 'The number of the displayed sales areas is not correct!');
        System.assertEquals('Sales Organization Test (1000)', customerSalesAreaMap.get('ovcSalesOrgWithID'), 'Sales organization with ID is wrong!');
        System.assertEquals('Internal Dist. Channel Test (10)', customerSalesAreaMap.get('ovcSalesDistChanWithID'), 'Sales distribution channel with ID is wrong!');
        System.assertEquals('Product Division Test (00)', customerSalesAreaMap.get('ovcDivisionWithID'), 'Sales division with ID is wrong!');
    }
    
    @isTest
    private static void testAfterReference(){
        OvcCustomerSalesAreaSelectorPlugin plugin = new OvcCustomerSalesAreaSelectorPlugin();
        Map<String, Map<String, Object>> refValues = new Map<String, Map<String, Object>>();
        refValues.put('ovcSalesAreaFieldLanguage', new Map<String, Object>{ 'ovcLanguage' => 'E' });
        plugin.afterReferenceValuesLoaded(null, null, refValues,null);
        System.assert(true, 'always true');
    }    
}