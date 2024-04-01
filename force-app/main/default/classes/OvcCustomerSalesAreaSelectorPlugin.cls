/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
/*
 * OvcCustomerSalesAreaSelectorPlugin is used by the Overcast Component ovcCustomerSalesAreaSelector.
 * It is used to provide all customer sales areas with key values & description
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OvcCustomerSalesAreaSelectorPlugin implements overcast.ComponentPluginV3 {
    @TestVisible
    private Map<String, Object> refValues = new Map<String, Object>();
    @TestVisible
    private String testDataOrgTxt;
    @TestVisible
    private String testDataDistChannelTxt; 
    @TestVisible
    private String testDataDivisionTxt;

    global OvcCustomerSalesAreaSelectorPlugin() {
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
        Map<String, Object> salesAreaMap = (Map<String, Object>) importParameters.get('KNVV');
        salesAreaMap.remove('ovcLanguage');
        this.refValues.putAll(referenceFieldValues);
        referenceFieldValues.clear();
    }

    global void afterScenarioCall(Map<String, Object> returnedData, overcast.ComponentDefinition.Component cmp, Map<String, Object> settings) {
        List<Object> customerSalesAreaList = (List<Object>) returnedData.get('KNVV');
        Map<String, Object> allSalesAreaMap = new Map<String, Object>();
        List<String> salesAreaKeys = new List<String>{ 'VKORG', 'VTWEG', 'SPART' };
        for (Object customerSalesAreaObj : customerSalesAreaList) {
            List<String> salesAreaValues = new List<String>();
            Map<String, Object> customerSalesAreaMap = (Map<String, Object>) customerSalesAreaObj;
            for (String sKey : salesAreaKeys) {
                String sValue = (String) customerSalesAreaMap.get(sKey);
                salesAreaValues.add(sValue);
                Set<String> salesAreaKeyFieldSet = (Set<String>) allSalesAreaMap.get(sKey);
                if (salesAreaKeyFieldSet == null) {
                    allSalesAreaMap.put(sKey, new Set<String>{ sValue });
                } else {
                    salesAreaKeyFieldSet.add(sValue);
                }
            }
            String salesAreaStr = String.join(salesAreaValues, '/');
            system.debug(salesAreaStr);
            customerSalesAreaMap.put('ovcSalesArea', salesAreaStr);
        }
        if (allSalesAreaMap.isEmpty()) {
            return;
        }

        Map<String, Object> customerSalesAreaLanguageMap = (Map<String, Object>) this.refValues.get('KNVV');
        String ovcLanguage = (String) customerSalesAreaLanguageMap.get('ovcLanguage');
        Map<String, String> salesOrgDescMap = getSalesOrgText((Set<String>) allSalesAreaMap.get('VKORG'), ovcLanguage);
        Map<String, String> salesDistChanMap = getSalesDistChanText((Set<String>) allSalesAreaMap.get('VTWEG'), ovcLanguage);
        Map<String, String> salesDivisionMap = getSalesDivisionText((Set<String>) allSalesAreaMap.get('SPART'), ovcLanguage);
        for (Object customerSalesAreaObj : customerSalesAreaList) {
            Map<String, Object> customerSalesAreaMap = (Map<String, Object>) customerSalesAreaObj;
            for (String sKey : salesAreaKeys) {
                String sValue = (String) customerSalesAreaMap.get(sKey);
                Set<String> searchStringSet = (Set<String>) allSalesAreaMap.get(sKey);
                if (sKey == 'VKORG') {
                    String salesOrgText = salesOrgDescMap.get(sValue);
                    customerSalesAreaMap.put('ovcSalesOrgWithID', salesOrgText);
                    system.debug(salesOrgText);
                } else if (sKey == 'VTWEG') {
                    String salesDistChanText = salesDistChanMap.get(sValue);
                    customerSalesAreaMap.put('ovcSalesDistChanWithID', salesDistChanText);
                    system.debug(salesDistChanText);
                } else if (sKey == 'SPART') {
                    String salesDivText = salesDivisionMap.get(sValue);
                    customerSalesAreaMap.put('ovcDivisionWithID', salesDivText);
                    system.debug(salesDivText);
                }    
            }
        }
    }

    global Boolean onScenarioException(Exception ex, Map<String, Object> retData) {
        return true;
    }

    @TestVisible
    private Map<String, String> getSalesOrgText(Set<String> salesOrgKeys, String language) {
        Map<String, String> shipSalesOrgText = new Map<String, String>();
        if (salesOrgKeys == null) {
            return shipSalesOrgText;
        }

        ovcSAPSalesOrganizationText request = new ovcSAPSalesOrganizationText();
        overcast.Predicate pred = new overcast.Predicate();
        pred.type = overcast.Predicate.FilterType.AND1;
        pred.add(new overcast.Predicate('VKORG', overcast.Predicate.FilterType.IN1, salesOrgKeys));
        pred.add(new overcast.Predicate('SPRAS', overcast.Predicate.FilterType.EQUALS, language));

        overcast.Query q = new overcast.Query();
        q.where_x = pred;
        if (testDataOrgTxt != null) {
            request.testResponse = testDataOrgTxt;
        }

        ovcSAPSalesOrganizationText respObj = request.runQuery(q, null, null);
        List<Object> salesOrgList = (List<Object>) respObj.get('TVKOT');

        for (Object salesOrgObj : SalesOrgList) {
            Map<String, Object> salesOrgMap = (Map<String, Object>) salesOrgObj;
            String salesOrgKey = (String) salesOrgMap.get('VKORG');
            String salesOrgText = (String) salesOrgMap.get('VTEXT');
            String salesOrgTextWithID = salesOrgText + ' (' + salesOrgKey + ')';
            shipSalesOrgText.put(salesOrgKey, salesOrgTextWithID);
        }
        return shipSalesOrgText;
    }

    @TestVisible
    private Map<String, String> getSalesDistChanText(Set<String> salesDistChanKeys, String language) {
        Map<String, String> shipSalesDistChanText = new Map<String, String>();
        if (salesDistChanKeys == null) {
            return shipSalesDistChanText;
        }

        ovcSAPDistributionChannelText request = new ovcSAPDistributionChannelText();
        overcast.Predicate pred = new overcast.Predicate();
        pred.type = overcast.Predicate.FilterType.AND1;
        pred.add(new overcast.Predicate('VTWEG', overcast.Predicate.FilterType.IN1, salesDistChanKeys));
        pred.add(new overcast.Predicate('SPRAS', overcast.Predicate.FilterType.EQUALS, language));

        overcast.Query q = new overcast.Query();
        q.where_x = pred;
        if (testDataDistChannelTxt != null) {
            request.testResponse = testDataDistChannelTxt;
        }

        ovcSAPDistributionChannelText respObj = request.runQuery(q, null, null);
        List<Object> salesDistChanList = (List<Object>) respObj.get('TVTWT');

        for (Object salesDistChanObj : salesDistChanList) {
            Map<String, Object> salesDistChanMap = (Map<String, Object>) salesDistChanObj;
            String salesDistChanKey = (String) salesDistChanMap.get('VTWEG');
            String salesDistChanText = (String) salesDistChanMap.get('VTEXT');
            String salesDistChanTextWithID = salesDistChanText + ' (' + salesDistChanKey + ')';
            shipsalesDistChanText.put(salesDistChanKey, salesDistChanTextWithID);
        }
        return shipSalesDistChanText;
    }

    @TestVisible
    private Map<String, String> getSalesDivisionText(Set<String> salesDivisionKeys, String language) {
        Map<String, String> shipSalesOrgText = new Map<String, String>();
        if (salesDivisionKeys == null) {
            return shipSalesOrgText;
        }

        ovcSAPSalesDivisionText request = new ovcSAPSalesDivisionText();
        overcast.Predicate pred = new overcast.Predicate();
        pred.type = overcast.Predicate.FilterType.AND1;
        pred.add(new overcast.Predicate('SPART', overcast.Predicate.FilterType.IN1, salesDivisionKeys));
        pred.add(new overcast.Predicate('SPRAS', overcast.Predicate.FilterType.EQUALS, language));

        overcast.Query q = new overcast.Query();
        q.where_x = pred;
        if (testDataDivisionTxt != null) {
            request.testResponse = testDataDivisionTxt;
        }

        ovcSAPSalesDivisionText respObj = request.runQuery(q, null, null);
        List<Object> salesDivisionList = (List<Object>) respObj.get('TSPAT');

        for (Object salesDivisionObj : salesDivisionList) {
            Map<String, Object> salesDivisionMap = (Map<String, Object>) salesDivisionObj;
            String salesDivisionKey = (String) salesDivisionMap.get('SPART');
            String salesDivisionText = (String) salesDivisionMap.get('VTEXT');
            String salesDivisionTextWithID = salesDivisionText + ' (' + salesDivisionKey + ')';
            shipSalesOrgText.put(salesDivisionKey, salesDivisionTextWithID);
        }
        return shipSalesOrgText;
    }
}