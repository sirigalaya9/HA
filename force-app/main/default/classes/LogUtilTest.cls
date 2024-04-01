/*
* Unit Test for LogUtil
* @author manu.voramontri@kliqxe.com
* @since 29.02.2024
* @version 29.02.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 29.02.2024   manu.voramontri@kliqxe.com         Initial Version
*/
@isTest
public class LogUtilTest 
{
    @IsTest
    static void testEmit()
    {
        CustomException e = new CustomException();
        Map<String, String> data = new Map<String, String>();
        Test.startTest();
        LogUtil.emit(e, data);
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(1, logs.size(), '1 log should be returned');
    }  

    @IsTest
    static void testEmit_Bypass()
    {
        Bypass__c bypass = new Bypass__c();
        bypass.Bypass_PE__c = true;
        insert bypass;
        CustomException e = new CustomException();
        Map<String, String> data = new Map<String, String>();
        Test.startTest();
        LogUtil.emit(e, data);
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c];
        System.assertEquals(0, logs.size(), '0 log should be returned');        
    }     
}