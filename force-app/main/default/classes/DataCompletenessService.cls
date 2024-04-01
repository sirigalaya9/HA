public class DataCompletenessService {

    public static String getRegex(String objectName, String countryCode) {
        try {
            List<sObject> mdts = Database.query(
                'SELECT Regex_Pattern__c ' +
                'FROM ' + String.escapeSingleQuotes(objectName) + ' ' +
                'WHERE Country_Code__c = :countryCode ' +
                'LIMIT 1' 
            );
            return mdts.isEmpty() ? null : (String)mdts[0].get('Regex_Pattern__c');
        } catch (QueryException e) {
            throw new AuraHandledException('Error fetching regex: ' + e.getMessage());
        }
    }
    
    public static Map<String, Data_Completeness__mdt> getCompletenessConfig(String mdtObjectName, String currentObjectName) {
        Map<String, Data_Completeness__mdt> result = new Map<String, Data_Completeness__mdt>(); 
        String fields = SObjectUtil.getFieldsStr(mdtObjectName); 
        String test = 'SELECT ' + fields +
                'FROM ' + String.escapeSingleQuotes(mdtObjectName) + ' ' +
                'WHERE ObjectApiName__c = :currentObjectName ' +
                'ORDER BY Sequence_Number__c ASC';
        system.debug(test);
        
        try {
            List<Data_Completeness__mdt> mdts = Database.query(
                'SELECT ' + fields + ' ' +
                'FROM ' + String.escapeSingleQuotes(mdtObjectName) + ' ' +
                'WHERE ObjectApiName__c = :currentObjectName ' +
                'ORDER BY Sequence_Number__c ASC'
            );
            
            if(!mdts.isEmpty()){
                for (Data_Completeness__mdt mdt : mdts) {
                    result.put(mdt.FieldApiName__c, mdt);  
                }
            }
            
            return result;
        } catch (QueryException e) {
            throw new AuraHandledException('Error fetching regex: ' + e.getMessage());
        }
        
        
        /*for (Data_Completeness__mdt meta : [
            SELECT Id,
            ObjectApiName__c,
            FieldApiName__c,
            Type__c,
            Description__c,
            DependentFieldApiName__c,
            DependentFieldValue__c,
            Sequence_Number__c
            FROM Data_Completeness__mdt
            WHERE ObjectApiName__c = :objectApiName
            ORDER BY Sequence_Number__c ASC
        ]) {
            result.put(meta.FieldApiName__c, meta);  
        }
        return result; */
    }
    
    public static sObject queryRecordWithFields(Id recordId, Set<String> fields) {
        String query = 'SELECT Id, '; 
        query += String.join(fields, ', '); 
        query += ' FROM ' + recordId.getSObjectType() + ' WHERE Id = :recordId'; 
        return Database.query(query);
    }
}