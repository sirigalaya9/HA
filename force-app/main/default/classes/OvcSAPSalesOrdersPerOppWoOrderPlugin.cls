/*
 * Copyright © 2021 Vigience Co., Ltd. All Rights Reserved
 */
global with sharing class OvcSAPSalesOrdersPerOppWoOrderPlugin implements overcast.ComponentPluginV4, overcast.Loggable {
    private overcast.Logger logger;
    @TestVisible
    private String testData {get;set;}

    global void beforeScenarioCall(
        Id recordId,
        Map<String, Object> referenceFieldValues,
        Map<String, Object> importParameters,
        Map<String, Object> settings
    ) {
        if (!settings.containsKey('OpportunityData') || !settings.containsKey('VBAKField')) {
            importParameters.put('SALES_DOCUMENTS', new List<Object>{ new Map<String,Object>{
                'VBELN' => 'XXXXXXXXXX'
            }});
            return;
        }

        ovcSAPSalesDocumentHeader docHeader = new ovcSAPSalesDocumentHeader();
        overcast.Query q = new overcast.Query();
        Integer queryLimit = 50;
        try {
            if (settings.containsKey('Limit')) {
                queryLimit = Integer.valueOf(settings.get('Limit'));
            }
        }
        catch (Exception ex) {

        }
        q.fields = new List<String> {'VBELN', (String) settings.get('VBAKField')};
        q.limit_x = queryLimit;
        q.offset = 0;
        q.where_x = new overcast.Predicate((String)settings.get('VBAKField'), overcast.Predicate.FilterType.EQUALS, settings.get('OpportunityData'));
        if (testData != null) {
            docHeader.testResponse = testData;
        }
        ovcSAPSalesDocumentHeader result = docHeader.runQuery(q, logger, null);
        List<Object> vbak = (List<Object>) result.get('VBAK');
        if (vbak.isEmpty()) {
            importParameters.put('SALES_DOCUMENTS', new List<Object>{ new Map<String,Object>{
                'VBELN' => 'XXXXXXXXXX'
            }});
            return;            
        }
        List<Object> salesDocs = new List<Object>();
        for (Object vbakRow : vbak) {
            Map<String,Object> vbakMap = (Map<String,Object>)vbakRow;
            Object vbeln = vbakMap.get('VBELN');
            salesDocs.add(new Map<String,Object>{'VBELN' => vbeln});
        }
        importParameters.put('SALES_DOCUMENTS', salesDocs);
    }

    global void afterScenarioCall(
        Map<String, Object> returnedData, 
        overcast.ComponentDefinition.Component cmp, 
        Map<String, Object> settings
    ) {
        // empty
    }

    global void afterComponentMetadataLoaded(Id recordId, overcast.ComponentDefinition.Component cmp) {
        // empty
    }


    global void afterReferenceValuesLoaded(
        Id recordId, 
        String componentName, 
        Map<String, Map<String, Object>> referenceValues
    ) {
        // empty
    }

    global void afterReferenceValuesLoaded(
        Id recordId,
        String componentName,
        Map<String, Map<String, Object>> referenceValues,
        Map<String, List<Map<String, Object>>> referenceChildValues
    ) {
        // empty
    }

    global Boolean onScenarioException(Exception ex, Map<String, Object> retData) {
        return true;
    }

    global void onBackendMessageReceived(String backendMessage) {
        // empty
    }

    global void setLogger(overcast.Logger logger) {
        this.logger = logger;
    }
}