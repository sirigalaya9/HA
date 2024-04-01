global class OvcHafeleOrderCreatePlugin extends overcast.ComponentPluginV6 {
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
        
        RT_SAP_SalesOrder_Create rtSAPOrderCreate = new RT_SAP_SalesOrder_Create ();
        List<RT_SAP_SalesOrder_Create.IT_POS> IT_POS_List = new List<RT_SAP_SalesOrder_Create.IT_POS>();
        List<RT_SAP_SalesOrder_Create.IT_KOMV> IT_KOMV_List = new List<RT_SAP_SalesOrder_Create.IT_KOMV>();
        
        Map<String, Object> z_hwwpiwsMap = (Map<String, Object>) referenceFieldValues.get('Z_HWWPIWS_CREATE_SALESORDER');
        RT_SAP_SalesOrder_Create.Z_HWWPIWS_CREATE_SALESORDER z_hwwpiws = new RT_SAP_SalesOrder_Create.Z_HWWPIWS_CREATE_SALESORDER();
        z_hwwpiws.I_SESSION = (String) z_hwwpiwsMap.get('I_SESSION');
        z_hwwpiws.I_SOURCE = (String) z_hwwpiwsMap.get('I_SOURCE');
        z_hwwpiws.I_LGCONTNO = (String) z_hwwpiwsMap.get('I_LGCONTNO');
        //z_hwwpiws.I_SIMULATION = (String) z_hwwpiwsMap.get('I_SIMULATION');  
        z_hwwpiws.I_SIMULATION = ' ';
        
        system.debug('Start'+(String) z_hwwpiwsMap.get('I_SIMULATION')+'End');
        
        Map<String, Object> orderHeaderIn = (Map<String, Object>) importParameters.get('ORDER_HEADER_IN');
        RT_SAP_SalesOrder_Create.I_HEADER I_HEADER = new RT_SAP_SalesOrder_Create.I_HEADER();

        String salesOrg = (String) orderHeaderIn.get('SALES_ORG'); // --- AA01/01/01
        if(salesOrg != null){
        	orderHeaderIn.put('SALES_ORG', salesOrg.substringBefore('/'));    
        }
        OvcSalesOrderUtility.setOrderHeaderText(importParameters);
        
        I_HEADER.VKORG = salesOrg.substringBefore('/');
        I_HEADER.VKBUR = (String)orderHeaderIn.get('SALES_OFF');
        I_HEADER.SPART = (String)orderHeaderIn.get('DIVISION');
        I_HEADER.VTWEG = (String)orderHeaderIn.get('DISTR_CHAN');
        I_HEADER.ZZINCO1 = (String)orderHeaderIn.get('INCOTERMS1');
        I_HEADER.ZZINCO2 = (String)orderHeaderIn.get('INCOTERMS2');
        I_HEADER.ORDSIGNS = (String)orderHeaderIn.get('PURCH_NO_C'); // BSTKD 
        I_HEADER.AUART  = (String)orderHeaderIn.get('DOC_TYPE');
        I_HEADER.LFDAT_H  = (String)orderHeaderIn.get('REQ_DATE_H_CUSTOM');
        I_HEADER.AUGRU  = (String)orderHeaderIn.get('ORD_REASON'); //Quote Reason
        
        //VBELN --- Sales and Distribution Document Number	??
        

          
        I_HEADER.CUSNO = (String)orderHeaderIn.get('SOLD_TO'); // Sold To
        I_HEADER.DVCUSNR = (String)orderHeaderIn.get('SOLD_TO'); // Ship To
        
        system.debug('salesOrg : '+salesOrg);
        system.debug('VKORG : '+I_HEADER.VKORG);
        system.debug('VKBUR : '+I_HEADER.VKBUR);
        system.debug('SPART : '+I_HEADER.SPART);
        system.debug('VTWEG : '+I_HEADER.VTWEG);
        system.debug('ZZINCO1 : '+I_HEADER.ZZINCO1);
        system.debug('ZZINCO2 : '+I_HEADER.ZZINCO2);
        system.debug('ORDSIGNS : '+I_HEADER.ORDSIGNS);

        system.debug('HD00: '+(String)orderHeaderIn.get('HD00'));
        
        String headerDiscount;
        if(orderHeaderIn.get('HD00') != null){
            headerDiscount = (String)orderHeaderIn.get('HD00'); // Header Discount (ZRH)
            
            RT_SAP_SalesOrder_Create.IT_KOMV IT_KOMV = new RT_SAP_SalesOrder_Create.IT_KOMV();

            IT_KOMV.KBETR  = Decimal.valueof(headerDiscount);
            IT_KOMV_List.add(IT_KOMV);
            system.debug('IT_KOMV --ZRH---: '+IT_KOMV);
        }
        system.debug('headerDiscount : '+headerDiscount);
        
        //---------------------------------orderItems-----------------------------------
        if (!importParameters.containsKey('ORDER_ITEMS_IN')) {
            return;
        }
        
        List<Object> orderItems = (List<Object>) importParameters.get('ORDER_ITEMS_IN');
        
        system.debug('orderItems: '+orderItems);
        
        if(!orderItems.isEmpty() && orderItems != null){
            for (Object itemObj : orderItems) {
                Map<String, Object> orderItem = (Map<String, Object>) itemObj;
                RT_SAP_SalesOrder_Create.IT_POS IT_POS = new RT_SAP_SalesOrder_Create.IT_POS();
                IT_POS.RUNNPOSNO = (String) orderItem.get('ITM_NUMBER'); //0001
                IT_POS.ARTNO = (String) orderItem.get('MATERIAL');
                IT_POS.ORDPOSQT = (Integer) orderItem.get('TARGET_QTY');
                IT_POS.DVCUSYRWK = (String) orderItem.get('REQ_DATE_H');
                IT_POS.MMUISO = (String) orderItem.get('T_UNIT_ISO');
                IT_POS.ARKTX = (String) orderItem.get('SHORT_TEXT');
                
                system.debug('IT_POS ---: '+IT_POS.RUNNPOSNO+' : '+IT_POS);
                IT_POS_List.add(IT_POS);
                
                String itemDiscount;
                if(!String.isBlank((String)orderItem.get('RB00'))){
                    itemDiscount = (String)orderItem.get('RB00'); // item Discount(ZRP)
                    system.debug('itemDiscount : '+itemDiscount);
                }
                
                String manualPrice;
                if(!String.isBlank((String)orderItem.get('mPrice'))){
                    manualPrice = (String)orderItem.get('mPrice');// Manual Price(ZPM)
                    system.debug('manualPrice : '+manualPrice);
                }
                
                if(itemDiscount != null){ // item Discount(ZRP)
                    RT_SAP_SalesOrder_Create.IT_KOMV IT_KOMV = new RT_SAP_SalesOrder_Create.IT_KOMV();
                    IT_KOMV.KSCHL = 'ZRP';
                    IT_KOMV.ORDPOSNO = (String) orderItem.get('ITM_NUMBER'); //0001
                    IT_KOMV.KBETR  = Decimal.valueof(itemDiscount);
                    IT_KOMV_List.add(IT_KOMV);
                    system.debug('IT_KOMV --ZRP---: '+IT_KOMV);
                }
                
                if(manualPrice != null){ // Manual Price(ZPM)
                    RT_SAP_SalesOrder_Create.IT_KOMV IT_KOMV = new RT_SAP_SalesOrder_Create.IT_KOMV();
                    IT_KOMV.KSCHL = 'ZPM';
                    IT_KOMV.ORDPOSNO = (String) orderItem.get('ITM_NUMBER'); //0001
                    IT_KOMV.KBETR  = Decimal.valueof(manualPrice);
                    IT_KOMV.WAERS = (String) orderItem.get('CURRENCY_x'); //AUD   
                    IT_KOMV.KPEIN = (Decimal) orderItem.get('TARGET_QTY'); //1000 
                    IT_KOMV_List.add(IT_KOMV);
                    system.debug('IT_KOMV --ZPM---: '+IT_KOMV);
                }
            }
        }

        
        //---------------------------------orderItems-----------------------------------
        
        
        rtSAPOrderCreate.Z_HWWPIWS_CREATE_SALESORDER = z_hwwpiws;
        rtSAPOrderCreate.I_HEADER = I_HEADER;
        rtSAPOrderCreate.IT_POS = IT_POS_List;
        rtSAPOrderCreate.IT_KOMV = IT_KOMV_List;
        
        String rtSAPOrderCreateJson = JSON.serialize(rtSAPOrderCreate);
        system.debug(rtSAPOrderCreateJson);
        logger.addLog('INFO','beforeScenarioCall rtSAPOrderCreate: ' + rtSAPOrderCreate);
        
        
        // Serialize and log importParameters
        String importParametersJson = JSON.serialize(importParameters);
        logger.addLog('INFO','beforeScenarioCall importParameters: ' + importParametersJson);
    
        // Serialize and log settings
        String settingsJson = JSON.serialize(settings);
        logger.addLog('INFO','beforeScenarioCall settings: ' + settingsJson);
        
        referenceFieldValues.clear();
        referenceFieldValues.put('Z_HWWPIWS_CREATE_SALESORDER',rtSAPOrderCreate);
        
        referenceFieldValuesJson = JSON.serialize(referenceFieldValues);
        logger.addLog('INFO','beforeScenarioCall referenceFieldValuesJson Quote: ' + referenceFieldValuesJson);
        
    }

    global override void afterScenarioCall(
        Map<String, Object> returnedData, 
        overcast.ComponentDefinition.Component cmp, 
        Map<String, Object> settings
    ) {
        
        // Serialize and log settings
        String settingsJson = JSON.serialize(settings);
        system.debug(settingsJson);
        system.debug('Quote Id : '+(String) settings.get('Quote_Id'));
        
        String returnedDataJson = JSON.serialize(returnedData);
        logger.addLog('INFO','afterScenarioCall - returnedData: ' + returnedDataJson);
        system.debug(returnedDataJson);
        String errorMessage;
        
        Map<String, Object> E_HEADER = (Map<String, Object>) returnedData.get('E_HEADER');
        String orderSAPNo = (String)E_HEADER.get('ORDNO');
        system.debug('E_HEADER.ORDNO : '+(String) E_HEADER.get('ORDNO'));
       
        try{
            List<Object> returnMessageList = (List<Object>) returnedData.get('ET_MSG_OUT');
            string returnLogs = '';
            if (returnMessageList != null && !returnMessageList.isEmpty()) {
                for (Object returnMessageObj : returnMessageList) {
                    Map<String, Object> retMap = (Map<String, Object>) returnMessageObj;                
                    system.debug('retMap : '+retMap);
                    if(!String.isBlank((String) retMap.get('MESSAGE'))) {
                        system.debug('MESSAGE: '+retMap.get('MESSAGE'));
                        sapSalesOrderCreate.RETURN_x RETURN_x = new sapSalesOrderCreate.RETURN_x();
                        RETURN_x.MESSAGE = (String) retMap.get('MESSAGE');
                        returnLogs += RETURN_x.MESSAGE+'\n';
                        
                    }   
                }
                
                returnedData.put('RETURN_x', returnMessageList);
                OvcSalesOrderUtility.setReturnMessages(returnedData);
                
            }
            
            if(settings.get('Quote_Id') != null){
                Quote q = new Quote();
                q.Id = (String)settings.get('Quote_Id');
                
                /*if(quoteSAPNo != null){
                    q.SAP_Quote_Number__c = quoteSAPNo;
                }*/
                
                if(returnLogs != null) {
                    q.Return_Logs__c = returnLogs;
                }
                
                update q;
            }
            
        } catch (Exception e) {
            System.debug('Error Quote afterScenarioCall: ' + e.getMessage());
            if(settings.get('Quote_Id') != null){
                Quote q = new Quote();
                q.Id = (String)settings.get('Quote_Id');
                q.Return_Logs__c = e.getMessage();
                q.Return_Logs__c += ' : '+orderSAPNo;
                update q;
            }
            //throw new AuraHandledException(e.getMessage());
        }
        
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
        
        if (!referenceValues.containsKey('ORDER_HEADER_IN')) {
            return;
        }
        
        Map<String,Object> ORDER_HEADER_IN = referenceValues.get('ORDER_HEADER_IN');
        //Map<String,Object> SETTINGS = referenceValues.get('SETTINGS');
        
        //System.debug('afterReferenceValuesLoaded No_of_SalesArea: ' + SETTINGS.get('No_of_SalesArea')); 
                
        String referenceFieldValuesJson = JSON.serialize(ORDER_HEADER_IN);
        //logger.addLog('INFO','afterReferenceValuesLoaded ORDER_HEADER_IN: ' + referenceFieldValuesJson);
        
        System.debug(recordId.getSObjectType().getDescribe().getName());
        if (recordId.getSObjectType().getDescribe().getName() == 'Account') {
            String SALES_ORG;
            if (!ORDER_HEADER_IN.containsKey('SALES_ORG')) {
                List<Sales_Area__c> salesArea = [SELECT Id, Account__c, Sales_Organization__c, Sales_Office__c, Sales_Group__c, 
                                                 Distribution_Channel__c, Division__c, Order_Block__c, SAP_SA_ID__c 
                                                 FROM Sales_Area__c
                                                 WHERE Account__c =: recordId];
                if(!salesArea.isEmpty() && salesArea.size() == 1){
                    SALES_ORG = salesArea[0].Sales_Organization__c +'/'+ salesArea[0].Division__c +'/'+ salesArea[0].Distribution_Channel__c;
                    ORDER_HEADER_IN.put('SALES_ORG', SALES_ORG);
                }   
            }
        }
    }

    global override void onBackendMessageReceived(String backendMessage) {
    }

    global override void afterStoredDataLoaded(Map<string, object> storedData, Map<string, object> slpData) {
    }
}