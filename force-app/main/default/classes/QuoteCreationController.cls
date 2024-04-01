public with sharing class QuoteCreationController {
   
    public class ReturnValues
    {
        @AuraEnabled public Boolean isSuccess { get; set; }
        @AuraEnabled public String quoteSAPId{ get; set; }
        @AuraEnabled public List<ErrorMessage> errorMessages { get; set; }        
    }
    
    public class ErrorMessage
    {
        @AuraEnabled public Integer no { get; set; }
        @AuraEnabled public String message { get; set; } 
    }
    
     @AuraEnabled
    public static List<ovcSAPCustomerIncotermsText.TINCT> getIncoterm(String languageCode){
        try
        {
            ovcSAPCustomerIncotermsText request = new ovcSAPCustomerIncotermsText();
            overcast.Query q = new overcast.Query();
            q.limit_x = 100;
            q.offset = 0;
            q.where_x = new overcast.Predicate('SPRAS', overcast.Predicate.FilterType.EQUALS, languageCode);
            ovcSAPCustomerIncotermsText response = request.runQuery(q);
            system.debug(response);
            
            List<ovcSAPCustomerIncotermsText.TINCT> incoterms = new List<ovcSAPCustomerIncotermsText.TINCT>();
            System.debug('incoterms==>' + incoterms);
            for (ovcSAPCustomerIncotermsText.TINCT item : response.TINCT) {
                String bezei = item.BEZEI;
                String inco1 = item.INCO1; 
                
                incoterms.add(item);
            }    
            return incoterms; 
            
        } catch (Exception e) {
            System.debug('Error getIncoterm: ' + e.getMessage()); 
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<Account> getShipTo(String accSAPNumber){
        
        try
        {
            ovcSAPCustomerMasterPartner request = new ovcSAPCustomerMasterPartner();
            overcast.Query q = new overcast.Query();
            q.limit_x = 10;
            q.offset = 0;overcast.Predicate pAnd = new overcast.Predicate();
            pAnd.type = overcast.Predicate.FilterType.AND1;
            pAnd.add(new overcast.Predicate('KUNNR', overcast.Predicate.FilterType.EQUALS, accSAPNumber));
            pAnd.add(new overcast.Predicate('PARVW', overcast.Predicate.FilterType.EQUALS, 'WE'));
            q.where_x = pAnd;ovcSAPCustomerMasterPartner response = request.runQuery(q);
            system.debug(response);
            List<String> accountSAPIds = new List<String>();
            
            List<ovcSAPCustomerMasterPartner.KNVP> shipTos = new List<ovcSAPCustomerMasterPartner.KNVP>();
            for (ovcSAPCustomerMasterPartner.KNVP item : response.KNVP) {
                accountSAPIds.add(item.KUNN2);
                
            } 
            
            List<Account> accounts = [SELECT Id, Name, overcast__SAP_BP_Number__c, BillingCity,BillingStreet,BillingState, BillingPostalCode,BillingCountry 
                                      FROM Account 
                                      WHERE overcast__SAP_BP_Number__c IN: accountSAPIds];
            
            return accounts;  
            
        } catch (Exception e) {
            System.debug('Error getShipTo: ' + e.getMessage()); 
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
    @AuraEnabled
    public static ReturnValues sendQuoteToSAP(HeaderWrapper header, String quoteId){
        
        List<QuoteLineItem> quoteItems = [SELECT Id,         
                                          QuoteId, 
                                          Product2Id, 
                                          Quantity, 
                                          UnitPrice,  
                                          ListPrice,      
                                          Description,
                                          Product2.Description,
                                          Product2.Name,
                                          Product2.ProductCode,
                                          Product2.QuantityUnitOfMeasure,
                                          is_SAP_Price__c,
                                          Delivery_Date__c
                                          FROM QuoteLineItem 
                                          WHERE QuoteId = :quoteId
                                         ];
 
        RT_SAP_Quotation_Create rtSAPQuoteCreate = new RT_SAP_Quotation_Create();
        List<RT_SAP_Quotation_Create.IT_POS> IT_POS_List = new List<RT_SAP_Quotation_Create.IT_POS>();
        List<RT_SAP_Quotation_Create.IT_KOMV> IT_KOMV_List = new List<RT_SAP_Quotation_Create.IT_KOMV>();
        
        
        //---------------------------------Z_HWWPIWS_CREATE_QUOTATION-----------------------------------   
        RT_SAP_Quotation_Create.Z_HWWPIWS_CREATE_QUOTATION z_hwwpiws = new RT_SAP_Quotation_Create.Z_HWWPIWS_CREATE_QUOTATION();
        z_hwwpiws.I_SESSION = '1I';
        z_hwwpiws.I_SOURCE = 'hkg419-20211112100000';
        z_hwwpiws.I_LGCONTNO = 'EAS';
        z_hwwpiws.I_SIMULATION = ' ';
        
        //---------------------------------I_HEADER-----------------------------------    
        
        RT_SAP_Quotation_Create.I_HEADER I_HEADER = new RT_SAP_Quotation_Create.I_HEADER();
        I_HEADER.VKORG = header.salesOrg;
        I_HEADER.VKBUR = header.salesOffice;
        I_HEADER.SPART = header.division;
        I_HEADER.VTWEG = header.disChannel;
        I_HEADER.ZZINCO1 = header.incoterm1;
        I_HEADER.ZZINCO2 = header.incoterm2;
        
        I_HEADER.CUSNO = header.soldTo;
        I_HEADER.DVCUSNR = header.shipTo;
       
        system.debug('VKORG : '+I_HEADER.VKORG);
        system.debug('VKBUR : '+I_HEADER.VKBUR);
        system.debug('SPART : '+I_HEADER.SPART);
        system.debug('VTWEG : '+I_HEADER.VTWEG);
        system.debug('ZZINCO1 : '+I_HEADER.ZZINCO1);
        system.debug('ZZINCO2 : '+I_HEADER.ZZINCO2);
        system.debug('CUSNO : '+I_HEADER.CUSNO);
        system.debug('DVCUSNR : '+I_HEADER.DVCUSNR);
        system.debug('IDMAREFNR : '+I_HEADER.IDMAREFNR);
        
        //---------------------------------IT_POS-----------------------------------
        Integer itemNo = 0;
        for (QuoteLineItem qli : quoteItems) {
            RT_SAP_Quotation_Create.IT_POS IT_POS = new RT_SAP_Quotation_Create.IT_POS();
            itemNo += 1;
            IT_POS.RUNNPOSNO = String.valueOf(ItemNo);
            IT_POS.ARTNO = qli.Product2.ProductCode;
            IT_POS.MMUISO = qli.Product2.QuantityUnitOfMeasure;
            IT_POS.ORDPOSQT = qli.Quantity;
            IT_POS.DVCUSYRWK = String.valueOf(qli.Delivery_Date__c);
            IT_POS.RUNNPOSNO = String.valueOf(ItemNo);
            
            system.debug('IT_POS : '+IT_POS);
            IT_POS_List.add(IT_POS);
            
            RT_SAP_Quotation_Create.IT_KOMV IT_KOMV = new RT_SAP_Quotation_Create.IT_KOMV();
            IT_KOMV.RUNNPOSNO = String.valueOf(ItemNo);
            IT_KOMV.KSCHL = 'ZPM';
            IT_KOMV.KBETR = 12;
            IT_KOMV.WAERS = 'AUD';
            IT_KOMV.KPEIN = 100;
            system.debug('IT_KOMV : '+IT_KOMV);
            IT_KOMV_List.add(IT_KOMV);
        }
        system.debug('IT_POS_List : '+IT_POS_List);
        
        /*//---------------------------------IT_KOMV-----------------------------------
        
        itemNo = 0;
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
        
        system.debug('IT_KOMV_List : '+IT_KOMV_List);*/

        rtSAPQuoteCreate.Z_HWWPIWS_CREATE_QUOTATION = z_hwwpiws;
        rtSAPQuoteCreate.I_HEADER = I_HEADER;
        rtSAPQuoteCreate.IT_POS = IT_POS_List;
        rtSAPQuoteCreate.IT_KOMV = IT_KOMV_List;
        
        ReturnValues result = new ReturnValues();
        
        try {
            RT_SAP_Quotation_Create response = rtSAPQuoteCreate.run();
            system.debug('response==>' + JSON.serialize(response));
            result = processResponse(response);
            System.debug(result);
            
            return result;
            
        } catch (Exception e) {
            //result.errorMessage = 'Error during Quote Create callout: ' + e.getMessage();
            System.debug('Error occurred: ' + e.getMessage()); 
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    private static ReturnValues processResponse(RT_SAP_Quotation_Create response) {
        ReturnValues result = new ReturnValues();
        
        if(response.E_HEADER != NULL){
            result.isSuccess = true;
            result.quoteSAPId = response.E_HEADER.ORDNO;
        }
        else if(!response.ET_MSG_OUT.isEmpty()){
            result.errorMessages = new List<ErrorMessage>();// Initialize
            for (RT_SAP_Quotation_Create.ET_MSG_OUT item : response.ET_MSG_OUT) {
                if(item.TYPE_x == 'E'){
                    ErrorMessage er = new ErrorMessage();
                    er.message = item.MESSAGE;
                    result.errorMessages.add(er);
                }
            }
        }
        return result;
    }   
    public QuoteCreationController() {
        
    }
    
    public class HeaderWrapper {
        public String salesOrg;
        public String salesOffice;
        public String poNumber;
        public String division;
        public String disChannel;
        public String discount;
        public String incoterm1;
        public String incoterm2;
        public String soldTo;
        public String shipTo;
        
    }
}