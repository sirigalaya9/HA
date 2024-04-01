public class DynamicDMLHandler {
    
    public class DMLResult {
        Set<Id> successIds { get; set; }
        List<Database.Error> errors { get; set; }
    }
    
    public static DMLResult upsertRecords(List<SObject> records) {
        DMLResult result = new DMLResult();
        Database.SaveResult[] resultList = Database.insert(records, false);
        
        // Iterate through saveResultList based on isSuccess capture the failed records
        for (Database.SaveResult sr : resultList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Opportunity ID: ' + sr.getId());
                result.successIds.add(sr.getId());
            }
            else {
                // Operation failed, so get all errors
                result.errors = sr.getErrors(); 
                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Opportunity fields that affected this error: ' + err.getFields());
                }
            }
        }   
        return result; 
    }
    
    /*public static List<Database.DeleteResult> deleteRecords(List<SObject> records) {
        DMLResult result = new DMLResult();
        Database.DeleteResult[] resultList = Database.delete(records, false);
        
        // Iterate through saveResultList based on isSuccess capture the failed records
        for (Database.DeleteResult sr : resultList) {
            if (sr.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully inserted Opportunity ID: ' + sr.getId());
                result.successIds.add(sr.getId());
            }
            else {
                // Operation failed, so get all errors
                result.errors = sr.getErrors(); 
                
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Opportunity fields that affected this error: ' + err.getFields());
                }
            }
        }   
        return result; 
    }*/
    
}