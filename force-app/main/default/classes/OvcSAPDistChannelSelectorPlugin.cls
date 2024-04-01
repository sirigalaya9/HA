/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
/*
 * OvcSAPDistChannelSelectorPlugin is used by the Overcast Component ovcSAPDistChannelSelector.
 * It is used to display distribution channels with ID in desired format.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OvcSAPDistChannelSelectorPlugin implements overcast.ComponentPluginV3 {
    global OvcSAPDistChannelSelectorPlugin() {
        return;
    }

    global void afterComponentMetadataLoaded(Id recordId, overcast.ComponentDefinition.Component cmp) {
        return;
    }

    global void afterReferenceValuesLoaded(Id recordId, String componentName, Map<String, Map<String, Object>> referenceValues) {
        return;
    }
    
	@SuppressWarnings('PMD.ExcessiveParameterList')
    global void afterReferenceValuesLoaded(
        Id recordId,
        String componentName,
        Map<String, Map<String, Object>> referenceValues,
        Map<String, List<Map<String, Object>>> referenceChildValues
    ) {
		return; 
    }

	@SuppressWarnings('PMD.ExcessiveParameterList')    
    global void beforeScenarioCall(
        Id recordId,
        Map<String, Object> referenceFieldValues,
        Map<String, Object> importParameters,
        Map<String, Object> settings
    ) {
		return;
    }

    global void afterScenarioCall(Map<String, Object> returnedData, overcast.ComponentDefinition.Component cmp, Map<String, Object> settings) {
        OvcSalesOrderUtility.setTextWithId(returnedData,'TVTWT','VTWEG','VTEXT','ovcDistChanDescWithID');
    }

    global Boolean onScenarioException(Exception ex, Map<String, Object> retData) {
        return true;
    }
}