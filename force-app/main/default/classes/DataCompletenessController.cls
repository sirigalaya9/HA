public with sharing class DataCompletenessController 
{
    public class FieldSet
    {
        @AuraEnabled
        public List<Field> requiredFields { get; set; }
        @AuraEnabled
        public List<Field> optionalFields { get; set; }        
    }
    
    public class Field
    {
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String label { get; set; }  
        @AuraEnabled
        public String description { get; set; }
        @AuraEnabled
        public Object value { get; set; }
        @AuraEnabled
        public String regex { get; set; }
    }
    
    public static final String MDT_TAX_NUMBER_OBJ = 'TaxNumber_Validation_Config__mdt';
    public static final String MDT_PHONE_OBJ = 'Phone_Validation_Config__mdt';
    public static final String MDT_DATA_OBJ = 'Data_Completeness__mdt';
    
    @AuraEnabled
    public static FieldSet getFields(Id recordId)
    {
        FieldSet fieldSet = new FieldSet();
        fieldSet.requiredFields = new List<Field>();
        fieldSet.optionalFields = new List<Field>();
        String objectApiName = recordId.getSObjectType().getDescribe().getName();
        String billingCountryCode;
        
        try
        {
            Map<String, Data_Completeness__mdt> metasByField = DataCompletenessService.getCompletenessConfig(MDT_DATA_OBJ,recordId.getSObjectType().getDescribe().getName()); 
            
            sObject record = DataCompletenessService.queryRecordWithFields(recordId, metasByField.keySet());
            system.debug(record);
            
            Map<String, Boolean> validationFlags = new Map<String, Boolean> {'Tax_Number__c' => false,'Phone' => false,'Email__c' => false};
                
                for (Data_Completeness__mdt meta : metasByField.values())
            { 
                if (record.get(meta.FieldApiName__c) != null) {
                    validationFlags.put(meta.FieldApiName__c, true);
                    
                    if (meta.FieldApiName__c == 'BillingCountryCode') {
                        billingCountryCode = String.valueOf(record.get(meta.FieldApiName__c));
                    }
                }
            }
            system.debug('validateTaxNumberRegex : '+validationFlags.get('Tax_Number__c'));
            system.debug('validatePhoneRegex : '+validationFlags.get('Phone'));
            //system.debug('validatePhoneRegex : '+validationFlags.get('Email__c'));
            
            String taxNumberRegex = validationFlags.get('Tax_Number__c') && billingCountryCode != null ? DataCompletenessService.getRegex(MDT_TAX_NUMBER_OBJ , billingCountryCode) : null;
            String phoneRegex = validationFlags.get('Phone') && billingCountryCode != null ? DataCompletenessService.getRegex(MDT_PHONE_OBJ , billingCountryCode) : null;
            
            system.debug(taxNumberRegex +' : '+ phoneRegex);
            
            Map<String, Schema.SObjectField> fields = record.getSObjectType().getDescribe().fields.getMap();            
            
            for (Data_Completeness__mdt meta : metasByField.values())
            {                
                if (meta.DependentFieldApiName__c != null)
                {
                    System.debug(meta.DependentFieldApiName__c);
                    System.debug(meta.DependentFieldValue__c);
                    System.debug(record.get(meta.DependentFieldApiName__c));
                    if (String.valueOf(record.get(meta.DependentFieldApiName__c)) != meta.DependentFieldValue__c)
                    {
                        System.debug('continue');
                        continue;
                    }
                }
                sObject currentRecord = record;
                String currentObjectApiName = meta.ObjectApiName__c;
                String currentFieldApiName = meta.FieldApiName__c;
                if (meta.FieldApiName__c.contains('.'))
                {
                    System.debug(meta.FieldApiName__c);
                    currentObjectApiName = meta.FieldApiName__c.split('\\.')[0];
                    currentFieldApiName = meta.FieldApiName__c.split('\\.')[1];
                    currentRecord = (sObject) record.getSObject(currentObjectApiName);
                    
                }
                fields = currentRecord.getSObjectType().getDescribe().fields.getMap();
                
                if (currentRecord.get(currentFieldApiName) == null || currentRecord.get(currentFieldApiName) == false ||
                    (validationFlags.get('Tax_Number__c') && (currentFieldApiName == 'Tax_Number__c')) || 
                    (validationFlags.get('Phone') && (currentFieldApiName == 'Phone'))
                    //(validationFlags.get('Email__c') &&  (currentFieldApiName == 'Email__c'))
                   )
                {
                    Field field = new Field();
                    field.name = currentFieldApiName;
                    field.label = fields.get(currentFieldApiName).getDescribe().getLabel(); 
                    field.description = meta.Description__c;
                    field.value = currentRecord.get(currentFieldApiName);
                    if(currentFieldApiName == 'Tax_Number__c') {
                        if(taxNumberRegex != null){
                            field.regex = taxNumberRegex;
                        }
                    }
                    
                    if(currentFieldApiName == 'Phone') {
                        if(phoneRegex != null){
                            field.regex = phoneRegex;
                        }
                    }

                    if (meta.Type__c.equalsIgnoreCase('Required')){
                        fieldSet.requiredFields.add(field);
                    }
                    else if (meta.Type__c.equalsIgnoreCase('Optional')){
                        fieldSet.optionalFields.add(field);
                    }                    
                } 
            }
            
        }
        catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
        return fieldSet;
    }
}