global with sharing class OvcSAPSalesOrderDetailsPlugin implements overcast.ComponentPlugin {

    @TestVisible
    private String testResponse;
    global void beforeScenarioCall(
        Id recordId,
        Map<String, Object> referenceFieldValues,
        Map<String, Object> importParameters,
        Map<String, Object> settings
    ) {
        return;
    }

    global void afterScenarioCall(Map<String, Object> returnedData, overcast.ComponentDefinition.Component cmp, Map<String, Object> settings) {

        List<Object> headers = (List<Object>)returnedData.get('ORDER_HEADERS_OUT');
        List<Object> conditions = (List<Object>)returnedData.get('ORDER_CONDITIONS_OUT');
        if (headers.size() != 1) {
            return;
        }
        Map<String,Object> header = (Map<String,Object>)headers[0];
        String pricProcedure = (String)header.get('SD_PRIC_PR');
        if (String.isEmpty(pricProcedure)) {
            return;
        }

        ovcSAPConditionTypeText condTypeText = new ovcSAPConditionTypeText();

        overcast.Predicate pred = new overcast.Predicate('', overcast.Predicate.FilterType.AND1, '');


        
        pred.add(new overcast.Predicate('KALSM', overcast.Predicate.FilterType.EQUALS, pricProcedure));
        String saplang =  overcast.ComponentFrameworkUtility.getSAPIntenalOneCharLanguageCode('ovcSAPConditionTypeText');
        pred.add(new overcast.Predicate('SPRAS', overcast.Predicate.FilterType.EQUALS, saplang));
        overcast.Query q = new overcast.Query();
        q.where_x = pred;
        if (!String.isEmpty(testResponse)) {
            condTypeText.testResponse = testResponse;
        }
        ovcSAPConditionTypeText resp = condTypeText.runQuery(q, null, null);
        Map<String,String> stepTextMap = new Map<String,String>();

        for (Object textObj : (List<Object>)resp.get('T683T') ) {
            Map<String,Object> textMap = (Map<String,Object>) textObj;
            stepTextMap.put((String)textMap.get('STUNR'), (String)textMap.get('VTEXT'));            
        }

        Map<String,Object> calcTypeTable;
        try {
            if (settings != null && settings.containsKey('ConditionCalclateTypeMap')) {
                calcTypeTable = (Map<String,Object>)JSON.deserializeUntyped((String)settings.get('ConditionCalclateTypeMap'));
            }
        }
        catch (Exception e) {
            System.debug(e.getMessage());
        }


        for (Object condObj : conditions) {
            Map<String,Object> condMap = (Map<String,Object>) condObj;
            String key = (String) condMap.get('COND_ST_NO');
            String text = stepTextMap.get(key);
            condMap.put('ovcCondText', text);
            String calctype = (String) condMap.get('CALCTYPCON');
            String currency_s = (String) condMap.get('CURREN_ISO');
            String crcy = currency_s;
            if (calcTypeTable != null && calcTypeTable.containsKey(calctype)) {
                crcy = (String)calcTypeTable.get(calctype);
            }
            condMap.put('ovcCalcType', crcy);
            condMap.put('ovcDocCurrency', header.get('CURREN_ISO'));
        }
    }
}