/*
* LogUtil to generate platform event Log__e for debugging purposes
* @author manu.voramontri@kliqxe.com
* @since 29.02.2024
* @version 29.02.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 29.02.2024   manu.voramontri@kliqxe.com         Initial Version
*/
public without sharing class LogUtil 
{
    public static void emit(Exception e, Map<String, String> data)
    {        
        Bypass__c bypass = Bypass__c.getInstance();
        if (!bypass.Bypass_PE__c)
        {
            String message = '';
            message = '\nMessage: ' + e.getMessage();  
            message += '\nStack: ' + e.getStackTraceString();        
            message += '\nData: ' + data;
            message = message.abbreviate(100000);
            PE_Log__e log = new PE_Log__e();
            log.Message__c = message;
            log.Username__c = System.UserInfo.getUserName();
            log.Event_Date__c = System.now();
            EventBus.publish(log);
        }
    }
}