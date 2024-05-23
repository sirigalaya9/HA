/* OvcHafeleSAPPricingSimulatePlugin is used by the Overcast Component ovcHafeleQuoteCreateRealtimePricing.
 * It is used to simulate sales quote/order in order poster.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global class OvcHafeleSAPPricingSimulatePlugin extends overcast.ComponentPluginV6 {
    private overcast.Logger logger;
    
    global override void setLogger(overcast.Logger logger) {
        this.logger = logger;
    }
    OvcSAPEnhancedOrderSimulatePlugin stdPlugin = new OvcSAPEnhancedOrderSimulatePlugin();
    Map<String, Object> orderHeaderIn;
    List<Object> orderPartners;
    Map<String,object> returnX;
    Map<String, Map<String, Object>> ordItemsInMap = new Map<String, Map<String, Object>>();
    Set<String> listTypes = new Set<String>{ 'ORDER_ITEMS_IN', 'ORDER_PARTNERS', 'IT_POS', 'ET_POS', 'ET_EINT_OUT', 'ET_KOMV_OUT', 'ET_MSG_OUT' };
    Map<String, Map<String, String>> structureMaps = new Map<String, Map<String, String>>{
        'beforeScenarioCall' => new Map<String, String>{ 
        	'ORDER_HEADER_IN' => 'I_HEADER',
        	'ORDER_ITEMS_IN' => 'IT_POS',
        	'ORDER_PARTNERS' => 'ORDER_PARTNERS'
         },
         'afterScenarioCall' => new Map<String, String>{ 
        	'E_HEADER' => 'ORDER_HEADER_IN',
        	'IT_POS' => 'ORDER_ITEMS_IN',
            'ET_POS' => 'ORDER_ITEMS_OUT',
            'ET_EINT_OUT' => 'ORDER_SCHEDULE_EX',
            'ET_KOMV_OUT' => 'ORDER_CONDITION_EX',
            'ET_MSG_OUT' => 'RETURN_x'
         }
    };
    Map<String, Map<String, String>> fieldMaps = new Map<String, Map<String, String>>{
        'ORDER_HEADER_IN/I_HEADER' => new Map<String, String>{
            'SALES_ORG' => 'VKORG',
            'SALES_OFF' => 'VKBUR',
            'DISTR_CHAN' => 'VTWEG',
            'DIVISION' => 'SPART',
            'INCOTERMS1' => 'ZZINCO1',
            'INCOTERMS2' => 'ZZINCO2',
            'PURCH_NO_C' => 'ORDSIGNS',
            'DOC_TYPE' => 'AUART',
            'ORD_REASON' => 'AUGRU'
            //'Z_REQ_DATE_H_CUSTOM' => 'LFDAT_H'
        },
        'ORDER_ITEMS_IN/IT_POS' => new Map<String, String>{
        	'ITM_NUMBER' => 'ORDPOSNO',
            'MATERIAL' => 'ARTNO',
            'TARGET_QTY' => 'ORDPOSQT',
            //'T_UNIT_ISO' => 'MMUISO',
            'SHORT_TEXT' => 'ARKTX',
            'PICKING' => 'CMSNTEXT'            
            // 'COND_TYPE' => 'COND_TYPE',
            // 'COND_VALUE' => 'COND_VALUE'
        },
        'E_HEADER/ORDER_HEADER_IN' => new Map<String, String>{
            'INCO1' => 'INCOTERMS1',
            'INCO2' => 'INCOTERMS2',
            'ORDSIGNS' => 'PURCH_NO_C',
            'AUART' => 'DOC_TYPE',
            'CONTRIBUTION_MARGIN_PROZ' => 'grossProfit'
        },
        'ET_POS/ORDER_ITEMS_OUT' => new Map<String, String>{
        	'ORDPOSNO' => 'ITM_NUMBER',
            'ARTNO' => 'MATERIAL',
            'WERKS' => 'PLANT',
            'WERKS' => 'PLANT_CUSTOM', 
            'ORDPOSQT' => 'TARGET_QTY',
            'MMU' => 'T_UNIT_ISO',
            'ARTDESC' => 'SHORT_TEXT',
            'CMSNTEXT' => 'PICKING',
            'PSTYV' => 'ITEM_CATEG',
            'UEPOS' => 'HG_LV_ITEM'
        },
        'ET_EINT_OUT/ORDER_SCHEDULE_EX' => new Map<String, String>{
            'ORDPOSNO' => 'ITM_NUMBER',
            'RUNNPOSNO' => 'SCHED_LINE',
            'COM_QTY' => 'CONFIR_QTY'
        },
        'ET_KOMV_OUT/ORDER_CONDITION_EX' => new Map<String, String>{
            'ORDPOSNO' => 'ITM_NUMBER',
            'STUNR' => 'COND_ST_NO',
            'KNUMV' => 'COND_TYPE',
            'KBETR' => 'COND_VALUE',
            'KWERT' => 'COND_VALUE1',
            'KAWRT' => 'COND_VALUE2',
            'WAERS' => 'CURRENCY_x'
        }
    };
    
        
        global override void beforeScenarioCall(Id recordId, Map<String, Object> referenceFieldValues, Map<String, Object> importParameters, Map<String, Object> settings) {
            stdPlugin.beforeScenarioCall(recordId, referenceFieldValues, importParameters, settings);
        }
    
    global override void beforeScenarioCall(overcast.ComponentPluginV6.BeforeScenarioCallParams param) {
        List<Map<String, Object>> zBapi_itKomvList = new List<Map<String, Object>>();
        
        orderHeaderIn = new Map<String, Object>((Map<String, Object>)param.parameters.get('ORDER_HEADER_IN'));
        
        List<Object> ordItemsIn = (List<Object>)param.parameters.get('ORDER_ITEMS_IN');
        System.debug('orderHeaderIn==>' + JSON.serialize(orderHeaderIn));
        System.debug('ordItemsIn==>' + JSON.serialize(ordItemsIn));
        if(ordItemsIn != null){
            for (Object oi : ordItemsIn) {
                Map<String, Object> ordItm = (Map<String, Object>)oi;
                ordItm.put('TARGET_QTY', ((Decimal)ordItm.get('TARGET_QTY'))/1000);
                //000001
                ordItemsInMap.put(String.valueOf(Integer.valueOf((String)ordItm.get('ITM_NUMBER')) * 100).leftPad(6, '0'), new Map<String, Object>(ordItm));
                //000100
                //ordItemsInMap.put((String)ordItm.get('ITM_NUMBER'), new Map<String, Object>(ordItm));
                ordItm.put('MATERIAL',this.unformatHafeleMaterialString((String)ordItm.get('MATERIAL')));
                
                //logger.addLog('INFO','ZPB ORDER ITEM IN ' + JSON.serialize(ordItm));
                //Conditions handling for items
                if(ordItm.get('COND_TYPE') != null && ordItm.get('COND_VALUE') != null){
                    //ZPM=>Manual Price because of field json config in posted
                    zBapi_itKomvList.add(new Map<String, Object>{
                        'ORDPOSNO' => ordItm.get('ITM_NUMBER'),
                            'RUNNPOSNO' => String.valueOf(Integer.valueOf((String)ordItm.get('ITM_NUMBER'))),
                            'MATRN' => ordItm.get('MATERIAL'),
                            'KSCHL' => ordItm.get('COND_TYPE'),
                            'KBETR' => ordItm.get('COND_VALUE'),
                            'WAERS' => (String)orderHeaderIn.get('CURRENCY_x'),//ordItm.get('CURRENCY_x'),
                            'KPEIN' => 100 //ordItm.get('TARGET_QTY')
                            });
                }
                
                if(ordItm.get('CD_TYPE2') != null && ordItm.get('CD_VALUE2') != null){
                    //ZRP=>Discount because of field json config in posted
                    zBapi_itKomvList.add(new Map<String, Object>{
                        'ORDPOSNO' => ordItm.get('ITM_NUMBER'),
                            'RUNNPOSNO' => String.valueOf(Integer.valueOf((String)ordItm.get('ITM_NUMBER'))),
                            'MATRN' => ordItm.get('MATERIAL'),
                            'KSCHL' => ordItm.get('CD_TYPE2'),
                            'KBETR' => ordItm.get('CD_VALUE2')
                            });
                }
                
            }
            
            //Calling Standard BAPI
            sapSalesOrderSimulate request = new sapSalesOrderSimulate();
            request.ORDER_HEADER_IN = (sapSalesOrderSimulate.ORDER_HEADER_IN)createInstanceFromMap('sapSalesOrderSimulate.ORDER_HEADER_IN',orderHeaderIn);
            request.ORDER_PARTNERS =  (List<sapSalesOrderSimulate.ORDER_PARTNERS>)JSON.deserialize(JSON.serialize(param.parameters.get('ORDER_PARTNERS')),List<sapSalesOrderSimulate.ORDER_PARTNERS>.class); 
            //request.ORDER_SCHEDULE_IN =  (List<sapSalesOrderSimulate.ORDER_SCHEDULE_IN>)JSON.deserialize(JSON.serialize(param.parameters.get('ORDER_SCHEDULE_IN')),List<sapSalesOrderSimulate.ORDER_SCHEDULE_IN>.class); 
            request.ORDER_ITEMS_IN =  (List<sapSalesOrderSimulate.ORDER_ITEMS_IN>)JSON.deserialize(JSON.serialize(param.parameters.get('ORDER_ITEMS_IN')),List<sapSalesOrderSimulate.ORDER_ITEMS_IN>.class);
            system.debug('Calling Standard BAPI : ' +request);
            
            for(sapSalesOrderSimulate.ORDER_ITEMS_IN oitIn : request.ORDER_ITEMS_IN){
                //Integer itemNo = Integer.valueOf(oitIn.ITM_NUMBER);
                //oitIn.ITM_NUMBER = String.valueOf(itemNo * 100).leftPad(6, '0'); Convert 1 to 000100
                
                System.debug('Original TARGET_QTY: ' + oitIn.TARGET_QTY);
                Decimal targetQty = Decimal.valueOf(oitIn.TARGET_QTY) * 1000;
                oitIn.TARGET_QTY = String.valueOf(Integer.valueOf(targetQty));
                oitIn.REQ_QTY = oitIn.TARGET_QTY;
                System.debug('Converted TARGET_QTY: ' + oitIn.TARGET_QTY);
                //oitIn.TARGET_QTY = String.valueOf(Integer.valueOf(oitIn.TARGET_QTY)*1000);
                oitIn.MATERIAL = this.unformatHafeleMaterialString(oitIn.MATERIAL);
                if(oitIn.CD_VALUE2 == null || oitIn.CD_VALUE2 <= 0){
                    oitIn.CD_TYPE2 = null;
                }
            }
            sapSalesOrderSimulate response = request.run(this.logger,null);
            returnX = ( Map<String,object>)response.get('RETURN_x');
            //system.debug('returnX : ' +returnX);
            /*if(returnX != null && returnX.get('TYPE_x') == 'E'){
               throw new overcast.ComponentFrameworkUtility.ComponentPluginException((String)returnX.get('MESSAGE'));
            }*/
        }
        translateStructures(structureMaps.get('beforeScenarioCall'), param.parameters);
        
        // Handle partners
        Map<String, Object> ordHdrIn = (Map<String, Object>)param.parameters.get('I_HEADER');
        
        
        List<Object> ordPartns = (List<Object>)param.parameters.get('ORDER_PARTNERS');
        for (Object op : ordPartns) {
            system.debug('ordPartns : ' +op);
            Map<String, Object> ordPartn = (Map<String, Object>)op;
            switch on (String)ordPartn.get('PARTN_ROLE') {
                when 'AG' { // Sold-to
                    ordHdrIn.put('CUSNO', ordPartn.get('PARTN_NUMB'));
                }
                when 'WE' { // Ship-to
                    ordHdrIn.put('DVCUSNR', ordPartn.get('PARTN_NUMB'));
                }
            }
        }
        
        //Add conditions for header discount if any
        //!String.isEmpty((String)orderHeaderIn.get('HD00'))
        if ( orderHeaderIn.get('HD00') != null) {
            zBapi_itKomvList.add(new Map<String, Object>{
                'ORDPOSNO' => '000000',
                    'RUNNPOSNO' => '000',
                    'KPOSN'=> '000000',    
                    'KSCHL' => 'ZRH',
                    'KBETR' => String.valueOf(orderHeaderIn.get('HD00'))
                    });
        }
        
        param.parameters.put('IT_KOMV', zBapi_itKomvList);
        orderPartners = ordPartns;
        //add RUNNPOSNO to IT_POS
        List<Object> ordItemsPos = (List<Object>)param.parameters.get('IT_POS');
        if(ordItemsPos != null){
            for (Object oi : ordItemsPos) {
                Map<String, Object> ordItm = (Map<String, Object>)oi;
                ordItm.put('RUNNPOSNO', String.valueOf(Integer.valueOf((String)ordItm.get('ORDPOSNO'))));
                if(orderHeaderIn.get('Z_REQ_DATE_H_CUSTOM') != null) {
                    System.debug('Requested Delivery Date ==>' + (String)orderHeaderIn.get('Z_REQ_DATE_H_CUSTOM'));
                    ordItm.put('DVCUSDT', ((String)orderHeaderIn.get('Z_REQ_DATE_H_CUSTOM')).replace('-', ''));
                }
            }
        }
        
    }
    
    global override void afterScenarioCall(Map<String, Object> returnedData, overcast.ComponentDefinition.Component cmp, Map<String, Object> settings) {
        //System.debug('afterScenarioCall returnedData==>' + JSON.serialize(returnedData));
        translateStructures(structureMaps.get('afterScenarioCall'), returnedData);
        
        List<Object> returnMessageList = (List<Object>) returnedData.get('RETURN_x');        
        string returnLogs = '';
        if (returnMessageList != null && !returnMessageList.isEmpty()) {
            for (Object returnMessageObj : returnMessageList) {
                Map<String, Object> retMap = (Map<String, Object>) returnMessageObj;                
                system.debug('returnMessage : '+retMap);
                String retMessageType = (String) retMap.get('TYPE_x');
                if(!String.isBlank((String)retMap.get('MESSAGE')) && retMessageType == 'E') {
                    //system.debug('MESSAGE: '+retMap.get('MESSAGE'));
                    returnX = ( Map<String,object>)retMap;
                    //system.debug('returnX: '+returnX);
                    break;
                }   
            }
        }
        
        // Handle header & partners
        Map<String, Object> ordHead = (Map<String, Object>)returnedData.get('ORDER_HEADER_IN');
        ordHead.put('SALES_ORG', orderHeaderIn.get('SALES_ORG'));
        ordHead.put('DISTR_CHAN', orderHeaderIn.get('DISTR_CHAN'));
        ordHead.put('DIVISION', orderHeaderIn.get('DIVISION'));
        ordHead.put('SALES_OFF', orderHeaderIn.get('SALES_OFF'));
        returnedData.put('SOLD_TO_PARTY', new Map<String, Object>{ 'SOLD_TO' => ordHead.get('CUSNO') });
        returnedData.put('SHIP_TO_PARTY', new Map<String, Object>{ 'SHIP_TO' => ordHead.get('DVCUSNR') });
        
        // Handle items
        List<Object> ordItemsOut = (List<Object>)returnedData.get('ORDER_ITEMS_OUT');
        Map<String, Map<String, Object>> ordItemsOutMap = new Map<String, Map<String, Object>>();
        for (Object oi : ordItemsOut) {
            Map<String, Object> itmOut = (Map<String, Object>)oi;
            ordItemsOutMap.put((String)itmOut.get('ITM_NUMBER'), itmOut);
            itmOut.put('REQ_QTY', itmOut.get('TARGET_QTY'));
            itmOut.put('MATERIAL',this.formatHafeleMaterialString((String)itmOut.get('MATERIAL')));
            Map<String, Object> itmIn = ordItemsInMap.get((String)itmOut.get('ITM_NUMBER'));
            if (itmIn != null) {
                itmOut.put('ITM_NUMBER', itmIn.get('ITM_NUMBER'));
                itmOut.put('PO_ITM_NO', itmIn.get('PO_ITM_NO'));
            }
            
        }
        returnedData.put('ORDER_ITEMS_IN', ordItemsInMap.values());
        
        // Handle schedules
        List<Object> schedsOut = (List<Object>)returnedData.get('ORDER_SCHEDULE_EX');
        for (Object so : schedsOut) {
            Map<String, Object> schedOut = (Map<String, Object>)so;
            Map<String, Object> itmIn = ordItemsInMap.get((String)schedOut.get('ITM_NUMBER'));
            if (itmIn != null) {
                schedOut.put('ITM_NUMBER', itmIn.get('ITM_NUMBER'));
            }
        }
        returnedData.put('ORDER_SCHEDULE_IN', new List<Object>());
        returnedData.put('ORDER_PARTNERS',orderPartners);
        
        // Handle conditions
        List<Object> condsOut = (List<Object>)returnedData.get('ORDER_CONDITION_EX');
        System.debug('ordItemsOutMap==>' + JSON.serialize(ordItemsOutMap));
        for (Object co : condsOut) {
            Map<String, Object> condOut = (Map<String, Object>)co;
            Map<String, Object> itmOut = ordItemsOutMap.get((String)condOut.get('ITM_NUMBER'));
            if (itmOut != null) {
                switch on (String)condOut.get('COND_ST_NO') {
                    when '090' { //base price
                        itmOut.put('basePrice', ((Decimal) condOut.get('COND_VALUE')));
                    }
                    when '800' { //std price
                        itmOut.put('stdPrice', ((Decimal) condOut.get('COND_VALUE')));
                    }
                    when '818' { 
                        //total price
                        itmOut.put('NET_VALUE1', ((Decimal) condOut.get('COND_VALUE1')));  
                        //unit price 
                        // Decimal qty = (Decimal)itmOut.get('REQ_QTY');
                        itmOut.put('uPrice', (((Decimal) condOut.get('COND_VALUE'))));                      
                    }
                    when '985' { //grossProfit 
                        itmOut.put('grossProfit', ((Decimal) condOut.get('COND_VALUE'))/10);
                    }
                }
            }
            Map<String, Object> itmIn = ordItemsInMap.get((String)condOut.get('ITM_NUMBER'));
            if (itmIn != null) {
                condOut.put('ITM_NUMBER', itmIn.get('ITM_NUMBER'));
            }
            
        }
        
        if(returnX != null && returnX.get('TYPE_x') == 'E'){
            returnedData.put('RETURN_x',returnX);
        }
        
        stdPlugin.afterScenarioCall(returnedData, cmp, settings);
        
        logger.addLog('INFO','Returned Data= > ' + JSON.serializePretty(returnedData));
    }
    
    
    public void translateStructures(Map<String, String> structureMap, Map<String, Object> sourceData) {
        for (String key : structureMap.keySet()) {
            Map<String, String> fieldMap = fieldMaps.get(key + '/' + structureMap.get(key));
            if (listTypes.contains(key)) {
                List<Object> srcList = (List<Object>)sourceData.remove(key);
                if (fieldMap == null) {
                    sourceData.put(structureMap.get(key), srcList);
                } else {
                    if(srcList == null){
                        continue;
                    }
                    for (Object itm : srcList) {
                        Map<String, Object> item = (Map<String, Object>)itm;
                        for (String fKey : fieldMap.keySet()) {
                            item.put(fieldMap.get(fKey), item.remove(fKey));
                        }
                    }
                    sourceData.put(structureMap.get(key), srcList);
                }
                
            } else {
                Map<String, Object> item = (Map<String, Object>)sourceData.remove(key);
                for (String fKey : fieldMap.keySet()) {
                    item.put(fieldMap.get(fKey), item.remove(fKey));
                }
                sourceData.put(structureMap.get(key), item);
            }
        }
    }
    
    public  Date parseIso8601DateTime(String isoDateTime) {
        if (isoDateTime.endsWith('Z')) {
            isoDateTime = isoDateTime.substringBefore('T');
        }
        return (Date)JSON.deserialize('"' + isoDateTime + '"', Date.class);
    }
    
    /*public Boolean isIso8601DateTime(String value) {
        system.debug('isIso8601DateTime : '+value);
        // Basic check to see if the string follows a common pattern for ISO 8601 datetime
        String iso8601Regex = '^(\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}(\\.\\d+)?(Z|[+-]\\d{2}:\\d{2}))$';
        Pattern p = Pattern.compile(iso8601Regex);
        Matcher m = p.matcher(value);
        return m.matches();
    }*/
    
    public  Object createInstanceFromMap(String className, Map<String, Object> fieldMap) {
        system.debug('createInstanceFromMap');
        Type targetType = Type.forName(className);
        if (targetType == null) {
            throw new overcast.ComponentFrameworkUtility.ComponentPluginException('Class not found.');
        }
        Object instance = targetType.newInstance();
        Map<String, Object> instanceMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(instance));
        
        for (String key : fieldMap.keySet()) {
            if (instanceMap.containsKey(key)) {
                Object value = fieldMap.get(key);
                // Check if the value is a datetime string
                if (value instanceof String && ((String)value).endsWith('Z')) {
                    instanceMap.put(key, parseIso8601DateTime((String)value));
                } else {
                    instanceMap.put(key, value);
                }
            }
        }
        instance = JSON.deserialize(JSON.serialize(instanceMap), targetType);
        return instance;
    }
    
    private String formatHafeleMaterialString(String input) {
        // Check if the input is of the expected length
        if (input == null || input.length() != 8) {
            return input; // Return the original input if it does not meet the expected criteria
        }

        // Use substring to extract parts and concatenate with dots
        String partOne = input.substring(0, 3); // Extracts the first three characters
        String partTwo = input.substring(3, 5); // Extracts the next two characters
        String partThree = input.substring(5, 8); // Extracts the last three characters

        // Concatenate the parts with dots between them
        return partOne + '.' + partTwo + '.' + partThree;
    }
    
    private String unformatHafeleMaterialString(String formattedString){
        return formattedString.replace('.', '');
    }
    
    global override void afterReferenceValuesLoaded(
        Id recordId,
        String componentName,
        Map<String, Map<String, Object>> referenceValues, 
        Map<String, List<Map<String, Object>>> referenceChildValues
    ) {
        //system.debug('afterReferenceValuesLoaded');
        //System.debug('ZPB ==>' + JSON.serialize(referenceValues));
    }
}