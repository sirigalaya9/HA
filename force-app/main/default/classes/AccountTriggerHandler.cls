public without sharing class AccountTriggerHandler {
    @testVisible
    private static TriggerOperation triggerContext;
    public void run() {
        TriggerOperation context = triggerContext != null ? triggerContext : Trigger.operationType;
        switch on context {
            when BEFORE_INSERT {
                //todo
                convertLangCode((List<Account>) Trigger.New, null);
                populateOwner((List<Account>) Trigger.New, null);
            }
            when BEFORE_UPDATE {
                //todo
                convertLangCode((List<Account>) Trigger.New, (Map<Id,Account>)Trigger.oldMap);
                populateOwner((List<Account>) Trigger.New, (Map<Id,Account>)Trigger.oldMap);
            }
            when AFTER_UPDATE {
                // convertLangCode((List<Account>) Trigger.New, (Map<Id,Account>)Trigger.oldMap);
            }
        }
    }
    private void convertLangCode(List<Account> accounts, Map<Id,Account> oldAccounts) {
        List<Account> accountToCheck = new List<Account>();
        for ( Account e : accounts ) {
            Account oldAccount = oldAccounts == null ? null : oldAccounts.get(e.Id);
            if ( (oldAccount == null ) || ( e.Language__c != oldAccount.Language__c ) ) {
                accountToCheck.add(e);
            }
        }
        if ( !accountToCheck.isEmpty() ) {
            for ( Account act : accountToCheck ) {
                if ( act.Language__c != null ) {
                    act.SAP_Language_Code__c = CommonServices.getBackendLangCode(act.Language__c);
                }
            }
        }
    }

    private void populateOwner(List<Account> accounts, Map<Id,Account> oldAccounts) {
        List<Account> accountToCheck = new List<Account>();
        for ( Account e : accounts ) {
            Account oldAccount = oldAccounts == null ? null : oldAccounts.get(e.Id);
            if ( (oldAccount == null ) || ( e.SAP_Account_Owner_ID__c != null && e.SAP_Account_Owner_ID__c != oldAccount.SAP_Account_Owner_ID__c ) ) {
                accountToCheck.add(e);
            }
        }
        if ( !accountToCheck.isEmpty() ) {
            AccountService.populateOwner(accountToCheck);
        }
    }
    
}