trigger AccountTrigger on Account (before insert, before update, after insert, after update) {
  Bypass__c bypass = Bypass__c.getInstance();
    if (!bypass.Bypass_Trigger__c && !bypass.Bypass_Trigger_Account__c) {
      new AccountTriggerHandler().run();  
    }
  
}