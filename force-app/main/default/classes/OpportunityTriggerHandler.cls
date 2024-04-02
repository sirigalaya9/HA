/*
* Opportunity Trigger Handler
* @author ly.sirigalaya@kliqxe.com
* @since 01.03.2024
* @version 01.03.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 01.03.2024  ly.sirigalaya@kliqxe.com         	Initial Version
* 20.03.2024  ly.sirigalaya@kliqxe.com         	syncProjectToAllRelatedQuotes
*/

public without sharing class OpportunityTriggerHandler {
    
    public void onBeforeInsert() {
        system.debug('OpportunityTrigger onBefore Insert');
        OpportunityService.assignEnterpriseStructure((List<Opportunity>) Trigger.New, null);
    }
    
    public void onBeforeUpdate() {
        system.debug('OpportunityTrigger onBefore Update');
        OpportunityService.assignEnterpriseStructure((List<Opportunity>)Trigger.New, (Map<Id, Opportunity>)Trigger.oldMap);
    }

    public void onAfterUpdate() {
        system.debug('OpportunityLineItemTrigger onAfter Update');
        System.debug('quoteSyncRunning: ' + QuoteService.quoteSyncRunning);
        if (!QuoteService.quoteSyncRunning)
        {
            QuoteService.quoteSyncRunning = true;
            OpportunityService.syncProjectToAllRelatedQuotes((List<Opportunity>)Trigger.New, (Map<Id, Opportunity>)Trigger.oldMap);
            QuoteService.quoteSyncRunning = false;
        }
    }   
}