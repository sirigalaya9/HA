/*
* Custom Path Controller
* @author manu.voramontri@kliqxe.com
* @since 04.05.2022
* @version 28.06.2022
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 04.05.2022   manu.voramontri@kliqxe.com         Initial Version
* 28.06.2022   manu.voramontri@kliqxe.com         Allow update without sharing
*/
public without sharing class PathAssistantController 
{
    @AuraEnabled(cacheable=true)  
    public static List <Guidance_for_Success__mdt> getGuidanceForSuccess(String objectApiName, String fieldApiName)
    {        
        return [SELECT Id, 
        MasterLabel, 
        Content__c, 
        Field_Value__c 
        FROM Guidance_for_Success__mdt
        WHERE Object_Name__c = :objectApiName
        AND Field_Name__c = :fieldApiName];
    }
    
    @AuraEnabled
    public static void saveRecord(Id recordId, String picklistField, String value)
    {
        try 
        {
            sObject sobj = recordId.getSobjectType().newSObject(recordId);
            sobj.put(picklistField, value);
            update sobj;
        } 
        catch (Exception e) 
        {
            throw new AuraHandledException(e.getMessage());
        }
    }
}