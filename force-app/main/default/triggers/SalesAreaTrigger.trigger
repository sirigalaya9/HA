trigger SalesAreaTrigger on Sales_Area__c (before insert, before update, after insert, after update, before delete) {
  new SalesAreaTriggerHandler().run();  
}