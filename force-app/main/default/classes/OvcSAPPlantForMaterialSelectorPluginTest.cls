/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
@isTest
public with sharing class OvcSAPPlantForMaterialSelectorPluginTest {
    @IsTest
    static void testEmptyMethod() {
        OvcSAPPlantForMaterialSelectorPlugin plugin = new OvcSAPPlantForMaterialSelectorPlugin();
        plugin.afterComponentMetadataLoaded(null, null);
        plugin.afterReferenceValuesLoaded(null, null, null);
        plugin.afterReferenceValuesLoaded(null, null, null,null);
        plugin.onScenarioException(null, null);
        System.assert(true, 'always true');
    }   

    @isTest
    private static void testBeforeScenarioCall(){
        OvcSAPPlantForMaterialSelectorPlugin plugin = new OvcSAPPlantForMaterialSelectorPlugin();
        Map<String, Object> importParams = new Map<String,Object>{ 'MARC' => new Map<String, Object>{ 'ovcPlantDescLanguage' => 'E'} };
        Map<String, Object> referenceValues = new Map<String,Object>{ 'MARC' => new Map<String, Object>{ 'ovcPlantDescLanguage' => 'E'} };    
        plugin.beforeScenarioCall(null, referenceValues, importParams, null);
        
        Map<String, Object> referenceValuesMap =  (Map<String, Object>) plugin.refValues.get('MARC');
        System.assertEquals(null, importParams.get('ovcPlantDescLanguage'), 'Language not removed!');
        System.assertEquals('E', referenceValuesMap.get('ovcPlantDescLanguage') , 'Language is wrong!');
    }
    
    @IsTest
    private static void pluginAfterScenarioCall() {
        OvcSAPPlantForMaterialSelectorPlugin plugin = new OvcSAPPlantForMaterialSelectorPlugin();
        Map<String, Object> retData = new Map<String, Object>{
			'MARC' => new List<Object>{
				new Map<String, Object>{ 'WERKS' => '100' },
                new Map<String, Object>{ 'WERKS' => '200' }
			},
            'ovcKeySection' => new Map<String,Object>{ 'SalesGroupDescLanguage' => 'E'}    
		};

        overcast.Globals.isOCF = true;
        overcast.TestingUtilities.SetupTestEnvironment('ovcSAPPlantData');
        Map<String, Object> tr = new Map<String, Object>{ 'T001W' => new List<Object>{ new Map<String, Object>{ 'WERKS' => '100', 'NAME1' => 'Main Plant' },
            																		   new Map<String, Object>{ 'WERKS' => '200', 'NAME1' => 'Additional Plant' }} };
        plugin.testData = JSON.serialize(new Map<String, Object>{ 'output' => tr });  
        Map<String,Object> refMap = new Map<String,Object>{ 'ovcPlantDescLanguage' => 'E'};
        plugin.refValues.put('MARC',refMap);
        
        plugin.afterScenarioCall(retData, null, null);

        List<Object> plantList = (List<Object>) retData.get('MARC');
        for(Object plantObj : plantList){
            Map<String, Object> plantMap = (Map<String, Object>) plantObj; 
            String plantCode = (String) plantMap.get('WERKS');
            if(plantCode == '100'){
            	System.assertEquals('Main Plant' , (String) plantMap.get('ovcPlantText'), 'Plant Name is different than expected!');    
            }		
        }          
        System.assertEquals(2, plantList.size(), 'Plant list size is different than 2!');
    }
}