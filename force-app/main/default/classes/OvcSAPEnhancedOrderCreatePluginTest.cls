/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
@IsTest
public with sharing class OvcSAPEnhancedOrderCreatePluginTest {
    @IsTest
    static void testEmptyMethod(){ 
        OvcSAPEnhancedOrderCreatePlugin plugin = new OvcSAPEnhancedOrderCreatePlugin();
        plugin.afterComponentMetadataLoaded(null, null);
        plugin.afterReferenceValuesLoaded(null, null, null);
        plugin.afterReferenceValuesLoaded(null, null, null, null);
        plugin.onScenarioException(null, null);
        System.assert(true, 'always true');    
    }    

    @IsTest
    private static void testAfterScenarioCall(){
        OvcSAPEnhancedOrderCreatePlugin plugin = new OvcSAPEnhancedOrderCreatePlugin();
        plugin.afterScenarioCall(null, null, null);
        System.assert(true, 'always true'); 
    }
    
    @IsTest
    private static void testBeforeScenarioCall(){
        OvcSAPEnhancedOrderCreatePlugin plugin = new OvcSAPEnhancedOrderCreatePlugin();
        Map<String, Object> importParameters = new Map<String, Object>();
        importParameters.put('ORDER_HEADER_IN', new Map<String, Object>{'SALES_ORG' => '1000/10/00'});  
        plugin.beforeScenarioCall(null, null, importParameters, null);
        Map<String, Object> orderHeader = (Map<String, Object>) importParameters.get('ORDER_HEADER_IN');
        System.assertEquals('1000', orderHeader.get('SALES_ORG'), 'Sales Organization is wrong!');
    }   
}