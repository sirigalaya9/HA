public with sharing class OpportunityProductConvertController 
{
    public class OptionDTO
    {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        @AuraEnabled
        public String productId { get; set; }        
        @AuraEnabled
        public List<OptionDTO> dependentOptions { get; set; }
    }

    @AuraEnabled
    public static List<OptionDTO> getProductHierarchy()
    {
        List<Product2> products = OpportunityService.getProductHierarchy();
        Map<String, OptionDTO> hierarchyMap = new Map<String, OptionDTO>();
        List<OptionDTO> results = new List<OptionDTO>();
        for (Product2 product : products)
        {
            if (!hierarchyMap.containsKey(product.PCM_Hierarchy_1__c) && product.PCM_Hierarchy_2__c == null && product.PCM_Hierarchy_3__c == null)
            {
                OptionDTO option = new OptionDTO();
                option.label = product.Name;
                option.value = product.PCM_Hierarchy_1__c;
                option.productId = product.Id;
                option.dependentOptions = new List<OptionDTO>();
                hierarchyMap.put(product.PCM_Hierarchy_1__c, option);
                results.add(option);
            }
            OptionDTO option = hierarchyMap.get(product.PCM_Hierarchy_1__c);
            if (product.PCM_Hierarchy_3__c != null)
            {
                OptionDTO dependentOption = new OptionDTO();
                dependentOption.label = product.Name;
                dependentOption.value = product.PCM_Hierarchy_3__c;
                dependentOption.productId = product.Id;
                option.dependentOptions.add(dependentOption);
            }
        }
        return results;
    } 

    @AuraEnabled
    public static OpportunityLineItem convertOppItem(Id oppId, Id oppItemId, Id productId, Decimal quantity, Decimal unitPrice, String oha)
    {
        return OpportunityService.convertOppItem(oppId, oppItemId, productId, quantity, unitPrice, oha);
    }    
}