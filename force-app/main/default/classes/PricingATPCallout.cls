public class PricingATPCallout {
    
    //public static final string OVC_NAMED_CREDENTIAL = 'OvercastComponentLibrary';
    //public static FINAL Integer SAP_QTY_Length = 13;
    
    public class ReturnValues
    {
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public List<SAPData> data{ get; set; }
        @AuraEnabled public String errorMessage { get; set; }        
    }
    
    public class SAPData
    {
        @AuraEnabled public String productCode { get; set; } //  MATERIAL
        @AuraEnabled public Decimal unitPrice { get; set; } //  NET_VALUE1/REQ_QTY
        @AuraEnabled public Date deliveryDate { get; set; } //  DLV_DATE
    }

    public static ReturnValues sendRequest(PricingATPWrapper.sapPricingATP data) {
        ReturnValues result = new ReturnValues();
        result.data = new List<SAPData>();
        sapSalesOrderSimulate request = new sapSalesOrderSimulate();
        sapSalesOrderSimulate.ORDER_PARTNERS ORDER_PARTNERS = new sapSalesOrderSimulate.ORDER_PARTNERS();
        sapSalesOrderSimulate.ORDER_HEADER_IN ORDER_HEADER_IN = new sapSalesOrderSimulate.ORDER_HEADER_IN();
        sapSalesOrderSimulate.BAPI_SALESORDER_SIMULATE BAPI_SALESORDER_SIMULATE = new sapSalesOrderSimulate.BAPI_SALESORDER_SIMULATE();
        sapSalesOrderSimulate.ORDER_ITEMS_IN ORDER_ITEMS_IN = new sapSalesOrderSimulate.ORDER_ITEMS_IN();
        List<sapSalesOrderSimulate.ORDER_ITEMS_IN> ORDER_ITEMS_IN_LIST = new List<sapSalesOrderSimulate.ORDER_ITEMS_IN>();
        List<sapSalesOrderSimulate.ORDER_PARTNERS> ORDER_PARTNERS_LIST = new List<sapSalesOrderSimulate.ORDER_PARTNERS>();
        
        //SAP Request Setup
        ORDER_PARTNERS.PARTN_NUMB = data.ORDER_PARTNERS.PARTN_NUMB; //Account.overcast__SAP_BP_Number__c
        ORDER_PARTNERS.PARTN_ROLE = data.ORDER_PARTNERS.PARTN_ROLE;
        ORDER_PARTNERS_LIST.add(ORDER_PARTNERS);
        
        ORDER_HEADER_IN.REQ_DATE_H = data.ORDER_HEADER_IN.REQ_DATE_H; //Opportunity.CloseDate
        ORDER_HEADER_IN.SALES_ORG = data.ORDER_HEADER_IN.SALES_ORG;  //Account.ovcSAPSalesOrg__c
        ORDER_HEADER_IN.DOC_TYPE = data.ORDER_HEADER_IN.DOC_TYPE;
        
        BAPI_SALESORDER_SIMULATE.CONVERT_PARVW_AUART = 'X';
        
        for(PricingATPWrapper.ORDER_ITEMS_IN item : data.ORDER_ITEMS_IN_LIST){
            ORDER_ITEMS_IN = new sapSalesOrderSimulate.ORDER_ITEMS_IN();
            ORDER_ITEMS_IN.TARGET_QTY = item.TARGET_QTY; //0000000001000 = 1qty (*1000)  (13digit)
            ORDER_ITEMS_IN.PO_ITM_NO = item.PO_ITM_NO;
            ORDER_ITEMS_IN.ITM_NUMBER = item.ITM_NUMBER;
            ORDER_ITEMS_IN.REQ_QTY = item.REQ_QTY;  //0000000001000 = 1qty (*1000)  (13digit)
            ORDER_ITEMS_IN.REQ_DATE = item.REQ_DATE; //Opportunity.CloseDate
            ORDER_ITEMS_IN.MATERIAL = item.MATERIAL;
            ORDER_ITEMS_IN_LIST.add(ORDER_ITEMS_IN);
            
        }

        //SAP Request Object Creation  
        request.ORDER_PARTNERS = ORDER_PARTNERS_LIST;
        request.ORDER_HEADER_IN = ORDER_HEADER_IN;
        request.BAPI_SALESORDER_SIMULATE = BAPI_SALESORDER_SIMULATE;
        request.ORDER_ITEMS_IN = ORDER_ITEMS_IN_LIST;
        
        //Callout Logic
        try {
            sapSalesOrderSimulate response = request.run();
            result = processResponse(response);
            System.debug(result);
    
        } catch (Exception e) {
            // Consider more informative error handling
            result.errorMessage = 'Error during pricing callout: ' + e.getMessage();
            System.debug('Error occurred: ' + e.getMessage()); 
        }
        
        return result;
        
    }
    
    private static ReturnValues processResponse(sapSalesOrderSimulate response) {
        ReturnValues result = new ReturnValues();
        
        if(!response.ORDER_ITEMS_OUT.isEmpty()){
            result.isSuccess = true;
            result.data = new List<SAPData>();// Initialize
            for (sapSalesOrderSimulate.ORDER_ITEMS_OUT item : response.ORDER_ITEMS_OUT) {
                system.debug('MATERIAL : '+ item.MATERIAL);
                system.debug('REQ_QTY : '+ item.REQ_QTY); //20
                system.debug('NET_VALUE1 : '+ item.NET_VALUE1);
                system.debug('DLV_DATE :' + item.DLV_DATE);
                system.debug('------------------');
                //T_UNIT_ISO: Target ISO UoM 
                
                SAPData data = new SAPData();
                data.productCode = item.MATERIAL;
                data.unitPrice = item.NET_VALUE1/item.REQ_QTY;
                data.deliveryDate = item.DLV_DATE;
                result.data.add(data);  
            }
        }
        else if(response.RETURN_x != NULL){
            result.errorMessage = response.RETURN_x.MESSAGE;
        }
        return result;
    }   
}