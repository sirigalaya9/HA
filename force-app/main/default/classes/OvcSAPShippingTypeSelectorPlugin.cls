/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
/*
 * OvcSAPShippingTypeSelectorPlugin is used by the Overcast Component ovcSAPShippingTypeSelector.
 * It is used to display shipping type with ID.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OvcSAPShippingTypeSelectorPlugin implements overcast.ComponentPluginV3 {
    global OvcSAPShippingTypeSelectorPlugin() {
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
        OvcSalesOrderUtility.setTextWithId(returnedData,'T173T','VSART','BEZEI','ovcShipTypeWithID');
    }

    global Boolean onScenarioException(Exception ex, Map<String, Object> retData) {
        return true;
    }
}