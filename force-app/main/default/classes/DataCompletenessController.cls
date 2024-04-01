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
    }    

    @AuraEnabled
    public static FieldSet getFields(Id recordId)
    {
        FieldSet fieldSet = new FieldSet();
        fieldSet.requiredFields = new List<Field>();
        fieldSet.optionalFields = new List<Field>();
        String objectApiName = recordId.getSObjectType().getDescribe().getName();

        try
        {
            List<Data_Completeness__mdt> metas = [SELECT Id,
            ObjectApiName__c,
            FieldApiName__c,
            Type__c,
            Description__c,
            DependentFieldApiName__c,
            DependentFieldValue__c,
            Sequence_Number__c
            FROM Data_Completeness__mdt
            WHERE ObjectApiName__c = :objectApiName
            ORDER BY Sequence_Number__c ASC];
            
            {
                Set<String> fieldNames = new Set<String>();
                String query = 'SELECT Id';
                for (Data_Completeness__mdt meta : metas)
                {
                    if (!fieldNames.contains(meta.FieldApiName__c))
                    {
                        query += ', ' + meta.FieldApiName__c;
                        fieldNames.add(meta.FieldApiName__c);
                    }
                    if (meta.DependentFieldApiName__c != null && !fieldNames.contains(meta.DependentFieldApiName__c))
                    {
                        query += ', ' + meta.DependentFieldApiName__c;
                        fieldNames.add(meta.DependentFieldApiName__c);
                    }                    
                }            
                query += ' FROM ' + objectApiName;
                query += ' WHERE Id = :recordId';
    
                sObject record = Database.query(query);
    
                Map<String, Schema.SObjectField> fields = record.getSObjectType().getDescribe().fields.getMap();            
    
                for (Data_Completeness__mdt meta : metas)
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
                    if (currentRecord.get(currentFieldApiName) == null || currentRecord.get(currentFieldApiName) == false)
                    {
                        Field field = new Field();
                        field.name = currentFieldApiName;
                        field.label = fields.get(currentFieldApiName).getDescribe().getLabel(); 
                        field.description = meta.Description__c;
                        if (meta.Type__c.equalsIgnoreCase('Required'))
                        {
                            fieldSet.requiredFields.add(field);
                        }
                        else if (meta.Type__c.equalsIgnoreCase('Optional'))
                        {
                            fieldSet.optionalFields.add(field);
                        }                    
                    }
                }
            }
        }
        catch (Exception e) { throw new AuraHandledException(e.getMessage()); }
        return fieldSet;
    }

}