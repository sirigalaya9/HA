/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
@isTest
public with sharing class OvcCustomerIncotermsSelectorPluginTest {
    @IsTest
    static void testEmptyMethod() {
        OvcCustomerIncotermsSelectorPlugin plugin = new OvcCustomerIncotermsSelectorPlugin();
        plugin.afterComponentMetadataLoaded(null, null);
        plugin.afterReferenceValuesLoaded(null, null, null);
        plugin.afterReferenceValuesLoaded(null, null, null, null);
        plugin.beforeScenarioCall(null, null, null, null);
        plugin.onScenarioException(null, null);
        System.assert(true, 'always true');
    }

    @IsTest
    private static void pluginAfterScenarioCall() {
        OvcCustomerIncotermsSelectorPlugin plugin = new OvcCustomerIncotermsSelectorPlugin();
        plugin.afterScenarioCall(null, null, null);
        System.assert(true, 'always true'); 
    }
}