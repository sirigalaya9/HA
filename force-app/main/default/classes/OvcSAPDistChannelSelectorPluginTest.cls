/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
@IsTest
public with sharing class OvcSAPDistChannelSelectorPluginTest {
    @IsTest
    static void testEmptyMethod() {
        OvcSAPDistChannelSelectorPlugin plugin = new OvcSAPDistChannelSelectorPlugin();
        plugin.afterComponentMetadataLoaded(null, null);
        plugin.afterReferenceValuesLoaded(null, null, null);
        plugin.afterReferenceValuesLoaded(null, null, null, null);
        plugin.beforeScenarioCall(null, null, null, null);
        plugin.onScenarioException(null, null);
        System.assert(true, 'always true');
    }
    
    @IsTest
    private static void pluginAfterScenarioCall() {
        OvcSAPDistChannelSelectorPlugin plugin = new OvcSAPDistChannelSelectorPlugin();
        plugin.afterScenarioCall(null, null, null);
        System.assert(true, 'always true'); 
    }    

}