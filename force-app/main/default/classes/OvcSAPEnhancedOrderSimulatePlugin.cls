/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
/*
 * OvcSAPEnhancedOrderSimulatePlugin is used by the Overcast Component ovcSAPEnhancedOrderSimulate.
 * It is used to simulate sales order in order poster.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OvcSAPEnhancedOrderSimulatePlugin implements overcast.ComponentPluginV3 {
    @TestVisible
    private String soldToPrev;
    @TestVisible
    private String testData;    
    
    global OvcSAPEnhancedOrderSimulatePlugin() {
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
        Map<String, Object> pageInfo = (Map<String, Object>) importParameters.get('ocf_PageData');
        Map<String, Object> orderHeaderIn = (Map<String, Object>) importParameters.get('ORDER_HEADER_IN');
		if (pageInfo != null) {
            Map<String, Object> ordHeader = (Map<String, Object>) pageInfo.get('ORDER_HEADER_IN');
            String salesAreaCode = (String) ordHeader.get('SALES_ORG');
            List<String> salesAreaKeys = salesAreaCode.split('/');
            if(salesAreaKeys.size() == 3){
            	orderHeaderIn.put('SALES_ORG',salesAreaKeys[0]); 
                orderHeaderIn.put('DISTR_CHAN',salesAreaKeys[1]); 
                orderHeaderIn.put('DIVISION',salesAreaKeys[2]); 
            }

            List<Object> newPartners = getSimulationPartners(pageInfo);
            if (!newPartners.isEmpty()) {
                referenceFieldValues.remove('ORDER_PARTNERS');
                importParameters.put('ORDER_PARTNERS', newPartners);
            }           
          
			String ovcSalesAreaPrev = (String) ordHeader.get('ovcSalesAreaKey');
			if (!String.isEmpty(ovcSalesAreaPrev)) {
				Map<String, Object> ovcSalesAreaPrevMap = (Map<String, Object>) JSON.deserializeUntyped(
					ovcSalesAreaPrev
				);
                
                List<String> salesAreaKeyList = new List<String>{'SALES_ORG', 'DISTR_CHAN', 'DIVISION'};
                for(String sField: salesAreaKeyList){
                    if((String) ovcSalesAreaPrevMap.get(sField) != (String) orderHeaderIn.get(sField)){
                    	orderHeaderIn.remove('SALES_GRP');
                    	orderHeaderIn.remove('SALES_OFF');  
                        break;
                    }   
                }        
			}
        }       
    }

    global void afterScenarioCall(Map<String, Object> returnedData, overcast.ComponentDefinition.Component cmp, Map<String, Object> settings) {
        Map<String, Object> orderHeaderIn = (Map<String, Object>) returnedData.get('ORDER_HEADER_IN');
        String salesOrg = (String)orderHeaderIn.get('SALES_ORG');
        String distChannel = (String)orderHeaderIn.get('DISTR_CHAN');
        String division = (String)orderHeaderIn.get('DIVISION');        
        if(orderHeaderIn != null){
            Map<String,Object> salesAreaKeyMap = new Map<String,Object>{'SALES_ORG' => salesOrg, 'DISTR_CHAN' => distChannel, 'DIVISION' => division};
            orderHeaderIn.put('ovcSalesOfficeKey', JSON.serialize(salesAreaKeyMap));
        }
        
        Map<String, Object> soldToPartyMap = (Map<String, Object>) returnedData.get('SOLD_TO_PARTY');
        if(soldToPartyMap != null){
            String currSoldTo = (String) soldToPartyMap.get('SOLD_TO');
            orderHeaderIn.put('ovcSalesAreaCustomer', currSoldTo);
            //Set Default WE, RE, RG Partners
            setDefaultPartnerFunctions(currSoldTo, returnedData); 
			orderHeaderIn.put('ovcSoldToPrev', currSoldTo);            
        }   
        
        //Default value set for customer
        List<String> defaultValuesList = new List<String>{'INCOTERMS1','INCOTERMS2L','SALES_DIST','SALES_OFF','SALES_GRP'};
        for(String defaultValueKey : defaultValuesList){
        	String sValue = (String) orderHeaderIn.get(defaultValueKey);
            if(String.isBlank(sValue)){
                orderHeaderIn.put(defaultValueKey, (String) soldToPartyMap.get(defaultValueKey)); 	   
            }
        }
    }

    @TestVisible
    public Map<String, String> getDefaultPartnerFunctions(String customerNumber, Map<String, Object> retData ) {
        Map<String, Object> orderHeaderIn = (Map<String, Object>) retData.get('ORDER_HEADER_IN');
        String salesOrg = (String)orderHeaderIn.get('SALES_ORG');
        String distChannel = (String)orderHeaderIn.get('DISTR_CHAN');
        String division = (String)orderHeaderIn.get('DIVISION');     

        Map<String, String> defaultCustPartners = new Map<String, String>();
        Set<String> partReq = new Set<String>{ 'WE', 'RE', 'RG' };
        ovcSAPCustomerMasterPartner request = new ovcSAPCustomerMasterPartner();
        overcast.Predicate pred = new overcast.Predicate();
        pred.type = overcast.Predicate.FilterType.AND1;
        pred.add(new overcast.Predicate('KUNNR', overcast.Predicate.FilterType.EQUALS, customerNumber));
        pred.add(new overcast.Predicate('VKORG', overcast.Predicate.FilterType.EQUALS, salesOrg));
        pred.add(new overcast.Predicate('VTWEG', overcast.Predicate.FilterType.EQUALS, distChannel));
        pred.add(new overcast.Predicate('SPART', overcast.Predicate.FilterType.EQUALS, division));
        pred.add(new overcast.Predicate('PARVW', overcast.Predicate.FilterType.IN1, partReq));

        overcast.Query q = new overcast.Query();
        q.where_x = pred;
        if (testData != null) {
        	request.testResponse = testData;
    	} 

        ovcSAPCustomerMasterPartner respObj = request.runQuery(q, null, null);        
        List<Object> custPartnerList = (List<Object>) respObj.get('KNVP');

        if (!custPartnerList.isEmpty()) {
            List<String> defpaPartn = new List<String>();
            for (Object custPartner : custPartnerList) {
                Map<String, Object> custPartnerMap = (Map<String, Object>) custPartner;
                String partnRole = (String) custPartnerMap.get('PARVW');
                String defaultPartCheck = (String) custPartnerMap.get('DEFPA');
                if(defpaPartn.contains(partnRole)){
                    continue;
                }
                if (!String.isblank(defaultPartCheck)) {
                    defpaPartn.add(partnRole);
                } 
                switch on partnRole {
                    when 'WE' {
                    	partnRole = 'WE';   //SH 
                    }
                    when 'RE' {
                    	partnRole = 'RE';   //BP
                    }
                    when 'RG' {
                    	partnRole = 'RG';   //PY
                    }
                }
                defaultCustPartners.put(partnRole, (String) custPartnerMap.get('KUNN2'));                
            }
        }
        return defaultCustPartners;
    } 
    
    private void setDefaultPartnerFunctions(String currSoldTo, Map<String, Object> retData){
		Map<String, Object> ordHeaderIn = (Map<String, Object>) retData.get('ORDER_HEADER_IN');
        Map<String, String> partnerDefaultMap = new Map<String, String>{
            'WE' => 'ovcShipToDefPartner', //SH
            'RE' => 'ovcBillToDefPartner', //BP
            'RG' => 'ovcPayerDefPartner'   //PY
        };
            
        Map<String, String> defPartnFuncPartnNo = new Map<String, String>(); 
        if(currSoldTo != this.soldToPrev){
        	Map<String, String> partFuncDefPartner = (Map<String, String>) getDefaultPartnerFunctions(currSoldTo,retData); 
            defPartnFuncPartnNo.putAll(partFuncDefPartner);
        }
        else{
            List<Object> ordPartnerList = (List<Object>) retData.get('ORDER_PARTNERS'); 
            for (Object ordPartnerObj : ordPartnerList) {
                Map<String, Object> ordPartnerMap = (Map<String, Object>) ordPartnerObj;
                defPartnFuncPartnNo.put((String)ordPartnerMap.get('PARTN_ROLE'),(String)ordPartnerMap.get('PARTN_NUMB'));  
            }
        }
        for(String partnRole : partnerDefaultMap.keySet()){
            String defaultPartnerNumber = defPartnFuncPartnNo.get(partnRole);
            if( defaultPartnerNumber != null){
            	ordHeaderIn.put(partnerDefaultMap.get(partnRole),defaultPartnerNumber);     
            }  
        }      
    }

    private List<Object> getSimulationPartners(Map<String, Object> pageInfo){
        List<Object> newPartners = new List<Object>();
        Map<String, Object> partners = (Map<String, Object>) pageInfo.get(
            'ocf_PARTNERS'
        );
        Map<String, String> partnerMap = new Map<String, String>{
            'ocf_SHIPTO' => 'WE', //SH => WE
            'ocf_SOLDTO' => 'AG', //SP => AG
            'ocf_BILLTO' => 'RE', //BP => RE
            'ocf_Payer' => 'RG'   //PY => RG
        };
        for (String field : partners.keySet()) {
            String p = (String) partners.get(field);
            if (String.isNotEmpty(p) && partnerMap.get(field) != null && p.length() <= 10) {
                newPartners.add(
                    new Map<String, Object>{
                        'ITM_NUMBER' => '000000',
                        'PARTN_ROLE' => partnerMap.get(field),
                        'PARTN_NUMB' => p
                    }
                );
            }
        }
        this.soldToPrev = (String) partners.get('ovcSoldToPrev'); 
        return newPartners;
    }
}