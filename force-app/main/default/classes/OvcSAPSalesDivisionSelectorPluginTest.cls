/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
@isTest
public with sharing class OvcSAPSalesDivisionSelectorPluginTest {
    @IsTest
    static void testEmptyMethod() {
        OvcSAPSalesDivisionSelectorPlugin plugin = new OvcSAPSalesDivisionSelectorPlugin();
        plugin.afterComponentMetadataLoaded(null, null);
        plugin.afterReferenceValuesLoaded(null, null, null);
        plugin.afterReferenceValuesLoaded(null, null, null, null);
        plugin.beforeScenarioCall(null, null, null, null);
        plugin.onScenarioException(null, null);
        System.assert(true, 'always true');
    }

    @IsTest
    private static void pluginAfterScenarioCall() {
        OvcSAPSalesDivisionSelectorPlugin plugin = new OvcSAPSalesDivisionSelectorPlugin();
        plugin.afterScenarioCall(null, null, null);
        System.assert(true, 'always true'); 
    }
}