/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
/*
 * OvcSAPEnhancedOrderEditPlugin is used by the Overcast Component ovcSAPEnhancedOrderEdit.
 * It is used to change sales order!
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OvcSAPEnhancedOrderEditPlugin implements overcast.ComponentPluginV3 {
    global OvcSAPEnhancedOrderEditPlugin() {
        return;
    }

    global void afterComponentMetadataLoaded(Id recordId, overcast.ComponentDefinition.Component cmp) {
        return;
    }

    global void afterReferenceValuesLoaded(Id recordId, String componentName, Map<String, Map<String, Object>> referenceValues) {
        return;
    }

    global void afterReferenceValuesLoaded(
        Id recordId,
        String componentName,
        Map<String, Map<String, Object>> referenceValues,
        Map<String, List<Map<String, Object>>> referenceChildValues
    ) {
        return;
    }

    global void beforeScenarioCall(
        Id recordId,
        Map<String, Object> referenceFieldValues,
        Map<String, Object> importParameters,
        Map<String, Object> settings
    ) {
        Map<String, Object> orderHeaderIn = (Map<String, Object>) importParameters.get('ORDER_HEADER_IN');
        if(orderHeaderIn == null){
			return;        
        }        
        String salesOrg = (String) orderHeaderIn.get('SALES_ORG');
        orderHeaderIn.put('SALES_ORG', salesOrg.substringBefore('/'));    
        //Text Handling - Send Header Text
        OvcSalesOrderUtility.setOrderHeaderText(importParameters);            
    }

    global void afterScenarioCall(Map<String, Object> returnedData, overcast.ComponentDefinition.Component cmp, Map<String, Object> settings) {
        //Return Message Handling
        OvcSalesOrderUtility.setReturnMessages(returnedData);
    }

    global Boolean onScenarioException(Exception ex, Map<String, Object> retData) {
        return true;
    }
}