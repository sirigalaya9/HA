global class HafeleQuoteCreatePlugin_1 extends overcast.ComponentPluginV6{
    private overcast.Logger logger;
	//Map<String, String>
    global override void setLogger(overcast.Logger logger) {
        this.logger = logger;
    }

    global override void beforeScenarioCall(
        Id recordId,
        Map<String, Object> referenceFieldValues,
        Map<String, Object> importParameters,
        Map<String, Object> settings
    ) {
         // Convert recordId to String and log it
        logger.addLog('INFO','beforeScenarioCall recordId: ' + String.valueOf(recordId));
    
        // Serialize and log referenceFieldValues
        String referenceFieldValuesJson = JSON.serialize(referenceFieldValues);
        logger.addLog('INFO','beforeScenarioCall referenceFieldValues: ' + referenceFieldValuesJson);
        
        system.debug(referenceFieldValues);
        
        RT_SAP_Quotation_Create rtSAPQuoteCreate = new RT_SAP_Quotation_Create();
        List<RT_SAP_Quotation_Create.IT_POS> IT_POS_List = new List<RT_SAP_Quotation_Create.IT_POS>();
        List<RT_SAP_Quotation_Create.IT_KOMV> IT_KOMV_List = new List<RT_SAP_Quotation_Create.IT_KOMV>();
        
        // Map<String, Object> z_hwwpiwsMap = (Map<String, Object>) referenceFieldValues.get('Z_HWWPIWS_CREATE_QUOTATION');
        RT_SAP_Quotation_Create.Z_HWWPIWS_CREATE_QUOTATION z_hwwpiws = new RT_SAP_Quotation_Create.Z_HWWPIWS_CREATE_QUOTATION();
        z_hwwpiws.I_SESSION = 'hkg419-20211112100000';
        z_hwwpiws.I_SOURCE = 'EAS';
        z_hwwpiws.I_LGCONTNO = '1I';
        
        
        Map<String, Object> orderHeaderIn = (Map<String, Object>) importParameters.get('ORDER_HEADER_IN');
        RT_SAP_Quotation_Create.I_HEADER I_HEADER = new RT_SAP_Quotation_Create.I_HEADER();
        String salesOrg = (String)orderHeaderIn.get('SALES_ORG');
        I_HEADER.VKORG = salesOrg.substringBefore('/');
        I_HEADER.VKBUR = (String)orderHeaderIn.get('SALES_OFF');
        I_HEADER.SPART = (String)orderHeaderIn.get('DIVISION');
        I_HEADER.VTWEG = (String)orderHeaderIn.get('DISTR_CHAN');
        I_HEADER.ZZINCO1 = (String)orderHeaderIn.get('INCOTERMS1');
        I_HEADER.ZZINCO2 = (String)orderHeaderIn.get('INCOTERMS2');
        
        I_HEADER.CUSNO = (String)orderHeaderIn.get('SOLD_TO');
        I_HEADER.DVCUSNR = (String)orderHeaderIn.get('SOLD_TO');
        I_HEADER.IDMAREFNR = 'HDE9419';
        
        system.debug('salesOrg : '+salesOrg);
        system.debug('VKORG : '+I_HEADER.VKORG);
        system.debug('VKBUR : '+I_HEADER.VKBUR);
        system.debug('SPART : '+I_HEADER.SPART);
        system.debug('VTWEG : '+I_HEADER.VTWEG);
        system.debug('ZZINCO1 : '+I_HEADER.ZZINCO1);
        system.debug('ZZINCO2 : '+I_HEADER.ZZINCO2);
        system.debug('CUSNO : '+I_HEADER.CUSNO);
        system.debug('DVCUSNR : '+I_HEADER.DVCUSNR);
        system.debug('IDMAREFNR : '+I_HEADER.IDMAREFNR);
        
        if(I_HEADER.VKORG != null){
            //system.debug('salesOrg : '+salesOrg);
            orderHeaderIn.put('SALES_ORG', salesOrg.substringBefore('/')); // --- AA01/01/01
        }
        //Text Handling - Send Header Text
        OvcSalesOrderUtility.setOrderHeaderText(importParameters);
        
        //---------------------------------orderItems-----------------------------------
        List<Object> orderItems = (List<Object>) importParameters.get('ORDER_ITEMS_IN');
        
        for (Object itemObj : orderItems) {
            Map<String, Object> orderItem = (Map<String, Object>) itemObj;
            RT_SAP_Quotation_Create.IT_POS IT_POS = new RT_SAP_Quotation_Create.IT_POS();
            IT_POS.ARTNO = (String) orderItem.get('MATERIAL');
            IT_POS.ORDPOSQT = (Integer) orderItem.get('TARGET_QTY');
            IT_POS.MMUISO  = 'PCE';
            
            String ITM_NUMBER  = (String) orderItem.get('ITM_NUMBER'); //0001
            String zDiscount = (String) orderItem.get('RB00');  // ZDiscount
            system.debug('IT_POS : '+IT_POS);
            IT_POS_List.add(IT_POS);
        }
        system.debug('IT_POS_List : '+IT_POS_List);
        
        //---------------------------------orderItems-----------------------------------
        
        List<Object> orderSchedules = (List<Object>) importParameters.get('ORDER_SCHEDULES_IN');
        Integer ItemNo = 0;
        for (Object itemObj : orderSchedules) {
            Map<String, Object> orderSch = (Map<String, Object>) itemObj;
            ItemNo += 1;
            RT_SAP_Quotation_Create.IT_KOMV IT_KOMV = new RT_SAP_Quotation_Create.IT_KOMV();
            IT_KOMV.RUNNPOSNO = String.valueOf(ItemNo);
            IT_KOMV.KSCHL = 'ZPM';
            IT_KOMV.KBETR = 12;
            IT_KOMV.WAERS = 'AUD';
            IT_KOMV.KPEIN = 100;
            system.debug('IT_KOMV : '+IT_KOMV);
            IT_KOMV_List.add(IT_KOMV);
        }
        
        system.debug('IT_KOMV_List : '+IT_KOMV_List);
       
        
        rtSAPQuoteCreate.Z_HWWPIWS_CREATE_QUOTATION = z_hwwpiws;
        rtSAPQuoteCreate.I_HEADER = I_HEADER;
        rtSAPQuoteCreate.IT_POS = IT_POS_List;
        rtSAPQuoteCreate.IT_KOMV = IT_KOMV_List;
        system.debug('rtSAPQuoteCreate==>' + JSON.serialize(rtSAPQuoteCreate));
        logger.addLog('INFO','beforeScenarioCall rtSAPQuoteCreate: ' + rtSAPQuoteCreate);
        
        
        // Serialize and log importParameters
        String importParametersJson = JSON.serialize(importParameters);
        logger.addLog('INFO','beforeScenarioCall importParameters: ' + importParametersJson);
    
        // Serialize and log settings
        String settingsJson = JSON.serialize(settings);
        logger.addLog('INFO','beforeScenarioCall settings: ' + settingsJson);
        
        referenceFieldValues.clear();
        referenceFieldValues.put('Z_HWWPIWS_CREATE_QUOTATION',rtSAPQuoteCreate);
        
        referenceFieldValuesJson = JSON.serialize(referenceFieldValues);
        logger.addLog('INFO','beforeScenarioCall referenceFieldValues 2: ' + referenceFieldValuesJson);
    }

    global override void afterScenarioCall(
        Map<String, Object> returnedData, 
        overcast.ComponentDefinition.Component cmp, 
        Map<String, Object> settings
    ) {
        
        String returnedDataJson = JSON.serialize(returnedData);
        System.debug('returnedDataJson==>' + returnedDataJson);
        logger.addLog('INFO','afterScenarioCall - returnedData: ' + returnedDataJson);
    }

    global override void afterComponentMetadataLoaded(Id recordId, overcast.ComponentDefinition.Component cmp) {
    }

    global override Boolean onScenarioException(Exception ex, Map<String, Object> retData) {
        return true;
    }

    global override void afterReferenceValuesLoaded(
        Id recordId,
        String componentName,
        Map<String, Map<String, Object>> referenceValues, 
        Map<String, List<Map<String, Object>>> referenceChildValues
    ) {
    }

    global override void onBackendMessageReceived(String backendMessage) {
    }

    global override void afterStoredDataLoaded(Map<string, object> storedData, Map<string, object> slpData) {
    }
}