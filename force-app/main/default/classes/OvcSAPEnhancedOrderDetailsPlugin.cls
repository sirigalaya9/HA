/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
/*
 * OvcSAPEnhancedOrderDetailsPlugin is used by the Overcast Component ovcSAPEnhancedOrderDetails.
 * It is used to populate initial values of sales order change component!
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OvcSAPEnhancedOrderDetailsPlugin implements overcast.ComponentPluginV3 {
    @TestVisible
    private Map<String, Object> referenceValues = new Map<String, Object>();
    global OvcSAPEnhancedOrderDetailsPlugin() {
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
        this.referenceValues = referenceValues.clone();
    }

    global Boolean onScenarioException(Exception ex, Map<String, Object> retData) {
        return true;
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
        List<Object> headers = (List<Object>) returnedData.get('ORDER_HEADERS_OUT');
        if (headers.size() != 1) {
            return;
        }

        Map<String, Object> headerOut = (Map<String, Object>) headers[0];
        String salesOrg = (String) headerOut.get('SALES_ORG');
        String distChan = (String) headerOut.get('DISTR_CHAN');
        String division = (String) headerOut.get('DIVISION');
        headerOut.put('ovcCustomerSalesOrg', salesOrg);
        headerOut.put('SALES_ORG', salesOrg + '/' + distChan + '/' + division);

        Map<String, Object> orderBusOut = (Map<String, Object>) ((List<Object>) returnedData.get('ORDER_BUSINESS_OUT'))[0];
        headerOut.put('SHIP_TYPE', (String) orderBusOut.get('DELIV_TYPE'));

        Map<String, Object> headerTexts = getHeaderTexts(returnedData);
        if (!headerTexts.isEmpty()) {
            returnedData.put('HeaderTexts', headerTexts);
        }
    }

    private Map<String, Object> getHeaderTexts(Map<String, Object> retData) {
        List<Object> orderTexts = (List<Object>) retData.get('ORDER_TEXTLINES_OUT');

        Map<String, Object> headerTextMap = new Map<String, Object>();
        Map<String, Map<String, String>> textDataItem = new Map<String, Map<String, String>>();

        for (Object textObj : orderTexts) {
            Map<String, Object> textRec = (Map<String, Object>) textObj;
            String textId = (String) textRec.get('TEXT_ID');
            String format = (String) textRec.get('FORMAT_COL');
            String textLine = (String) textRec.get('LINE');
            String textItemNumber;
            if (((String) textRec.get('TEXT_NAME')).length() == 16) {
                textItemNumber = ((String) textRec.get('TEXT_NAME')).substring(10, 16);
            } else {
                textItemNumber = '000000';
            }

            Map<String, String> exisTextObj = textDataItem.get(textItemNumber);
            if (exisTextObj == null) {
                exisTextObj = new Map<String, String>();
            }
            String existText = exisTextObj.get(textId);
            if (existText == null) {
                existText = '';
            }
            if (format == '*') {
                existText += '\r\n';
            }
            existText += textLine;
            exisTextObj.put(textId, existText);
            textDataItem.put(textItemNumber, exisTextObj);
        }

        Map<String, Object> textDataItemMap = (Map<String, Object>) textDataItem.get('000000');
        Map<String, Object> headerTextParams = (Map<String, Object>) this.referenceValues.get('HeaderTexts');
        if (textDataItemMap != null && headerTextParams != null) {
            for (String headerTextFieldwithID : headerTextParams.keyset()) {
                String headerTextId = (String) headerTextParams.get(headerTextFieldwithID);
                String textInfo = (String) textDataItemMap.get(headerTextId);
                String headerTextField = headerTextFieldwithID.substringBefore('ID');
                headerTextMap.put(headerTextField, textInfo);
            }
        }
        return headerTextMap;
    }
}