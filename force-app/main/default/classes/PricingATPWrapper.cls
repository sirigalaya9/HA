public class PricingATPWrapper {
    
    public class sapPricingATP
    {
        @AuraEnabled public ORDER_PARTNERS ORDER_PARTNERS { get; set; }
        @AuraEnabled public ORDER_HEADER_IN ORDER_HEADER_IN { get; set; }
        @AuraEnabled public List<ORDER_ITEMS_IN> ORDER_ITEMS_IN_LIST{ get; set; }
    }
    
    public class ORDER_PARTNERS
    {
        @AuraEnabled public String PARTN_NUMB { get; set; }
        @AuraEnabled public String PARTN_ROLE{ get; set; }       
    }
    
    public class ORDER_HEADER_IN
    {
        @AuraEnabled public Date REQ_DATE_H { get; set; }
        @AuraEnabled public String SALES_ORG{ get; set; }
        @AuraEnabled public String DOC_TYPE{ get; set; }
    }
    
    public class ORDER_ITEMS_IN
    {
        @AuraEnabled public String TARGET_QTY { get; set; }
        @AuraEnabled public String PO_ITM_NO{ get; set; }
        @AuraEnabled public String ITM_NUMBER{ get; set; }
        @AuraEnabled public String REQ_QTY{ get; set; }
        @AuraEnabled public Date REQ_DATE{ get; set; }
        @AuraEnabled public String MATERIAL{ get; set; }
    }
}