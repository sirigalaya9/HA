/*
* SalesArea Trigger Handler
* @author long@kliqxe.com
* @since 27.03.2024
* @version 27.03.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 27.03.2024  long@kliqxe.com         			 Initial Version
*/

public without sharing class SalesAreaTriggerHandler {
    @testVisible
    private static TriggerOperation triggerContext;
    public void run() {
        TriggerOperation context = triggerContext != null ? triggerContext : Trigger.operationType;
        switch on context {
            when BEFORE_INSERT {
                //todo
                assignTerritory((List<Sales_Area__c>) Trigger.New);                   
            }
            when AFTER_INSERT {
                populateOwnerOnAccount((List<Sales_Area__c>) Trigger.New);                
            }
            when BEFORE_UPDATE {
                //todo                
            }
            when AFTER_UPDATE {
                // todo
            }
            when BEFORE_DELETE {
                // todo
                removeTerritory((List<Sales_Area__c>) Trigger.Old);
            }
        }
    }

    private void assignTerritory(List<Sales_Area__c> salesAreas) { 
        SalesAreaService.assignTerritory(salesAreas);
    }

    private void removeTerritory (List<Sales_Area__c> salesAreas) {        
        SalesAreaService.removeTerritory(salesAreas);
    }

    private void populateOwnerOnAccount(List<Sales_Area__c> salesAreas){
        Set<Id> accountIds = new Set<Id>();        
        for (Sales_Area__c sa : salesAreas) {
            accountIds.add(sa.Account__c);
        }
        String integrationUser = Settings.INTEGRATION_USER;
        List<Account> accounts = [SELECT Id, SAP_Account_Owner_ID__c, OwnerId FROM Account WHERE ID IN :accountIds AND Owner.Username = :integrationUser];
        System.debug('populateOwnerOnAccount==>' + integrationUser + '-' + accounts);
        if ( !accounts.isEmpty() ) {
            AccountService.populateOwnerAndUpsert(accounts);
        }
    }
}