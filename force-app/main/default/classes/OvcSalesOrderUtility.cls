/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
public class OvcSalesOrderUtility {
    private static String rmvMessageId = 'V4';
    private static String rmvMessageNo = '233';

    public static void setOrderHeaderText(Map<String, Object> importParams) {
        if (importParams == null) {
            return;
        }
        Map<String, Object> headerTextMap = (Map<String, Object>) importParams.get('HeaderTexts');
        List<Object> salesOrderTextObj = new List<Object>();
        if (headerTextMap == null) {
            return;
        }
        for (String textField : headerTextMap.keySet()) {
            String sTextIdField = textField + 'ID';
            String textLanguage = (String) headerTextMap.get('HeaderTextLanguage');
            if (!textField.contains('ID') && headerTextMap.containsKey(sTextIdField) && textLanguage != null) {
                String textLine = (String) headerTextMap.get(textField);
                Decimal textDiv = ((Decimal) textLine.length()) / 132;
                Integer roundedTxtNumbers = (Integer) textDiv.round(System.RoundingMode.CEILING);
                String textId = (String) headerTextMap.get(sTextIdField);
                for (Integer i = 0; i < roundedTxtNumbers; i++) {
                    Integer stringEnd = (i + 1) * 132;
                    if (i == roundedTxtNumbers - 1) {
                        stringEnd = textLine.length();
                    }
                    Map<String, String> textInfo = new Map<String, String>{
                        'ITM_NUMBER' => '000000',
                        'TEXT_ID' => textId,
                        'TEXT_LINE' => textLine.substring(i * 132, stringEnd),
                        'LANGU' => textLanguage
                    };
                    salesOrderTextObj.add(textInfo);
                }
            }
        }
        importParams.put('ORDER_TEXT', salesOrderTextObj);
    }

    public static void setReturnMessages(Map<String, Object> retData) {
        if (retData == null) {
            return;
        }
        List<Object> returnMessageList = (List<Object>) retData.get('RETURN_x');
        if (returnMessageList != null && !returnMessageList.isEmpty()) {
            for (Integer i = returnMessageList.size() - 1; i >= 0; i--) {
                Map<String, Object> retMap = (Map<String, Object>) returnMessageList[i];
                String retMessageType = (String) retMap.get('TYPE_x');
                if (retMessageType != 'S') {
                    continue;
                }
                if ((String) retMap.get('NUMBER_x') == rmvMessageNo && (String) retMap.get('ID') == rmvMessageId) {
                    returnMessageList.remove(i);
                }
            }
        }
    }

    public static void setTextWithId(Map<String, Object> retData, String tableName, String idField, String descField, String fieldToBeSet) {
        if (retData == null) {
            return;
        }
        List<Object> sFieldList = (List<Object>) retData.get(tableName);
        for (Object sFieldObj : sFieldList) {
            Map<String, Object> sFieldMap = (Map<String, Object>) sFieldObj;
            String fieldId = (String) sFieldMap.get(idField);
            String fieldText = (String) sFieldMap.get(descField);
            String fieldDescWithId = fieldText + ' (' + fieldId + ')';
            sFieldMap.put(fieldToBeSet, fieldDescWithId);
        }
    }
}