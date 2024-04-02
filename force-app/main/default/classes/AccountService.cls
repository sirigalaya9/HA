/*
* Account Service
* @author long@kliqxe.com
* @since 26.03.2024
* @version 26.03.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 26.03.2024  long@kliqxe.com         			 Initial Version
*/

public without sharing class AccountService {
    public static List<Account>  populateOwner(List<Account> accounts) {
        Set<String> sapUserIds = new Set<String>();
        for (Account acc : accounts) {
            if (acc.SAP_Account_Owner_ID__c != null) {
                sapUserIds.add(acc.SAP_Account_Owner_ID__c);
            }
        }
        System.debug('sapUserIds==>' + sapUserIds);
        Map<String, User> sapUserIdToUserMap = new Map<String, User>();
        for (User usr : [SELECT Id, SAP_User_Id__c FROM User WHERE SAP_User_Id__c IN :sapUserIds]) {
            sapUserIdToUserMap.put(usr.SAP_User_Id__c, usr);
        }
        List<Account> accountWithoutSAPUser = new List<Account>();
        for (Account acc : accounts) {
            if (acc.SAP_Account_Owner_ID__c != null) {
                User ownerUser = sapUserIdToUserMap.get(acc.SAP_Account_Owner_ID__c);
                if (ownerUser != null) {
                    acc.OwnerId = ownerUser.Id;                    
                }
                else {
                    accountWithoutSAPUser.add(acc);
                }
            }
            else {
                accountWithoutSAPUser.add(acc);
            }
        }
        if ( !accountWithoutSAPUser.isEmpty() ) {
            Set<String> salesOrganizations = new Set<String>();
            Set<String> salesOffices = new Set<String>();
            Map<Id, List<Sales_Area__c>> accountSalesAreaMap = new Map<Id, List<Sales_Area__c>>();
            for (Sales_Area__c sa : [SELECT Account__c, Sales_Organization__c, Sales_Office__c FROM Sales_Area__c WHERE Account__c IN :accountWithoutSAPUser]) {
                if (!accountSalesAreaMap.containsKey(sa.Account__c)) {
                    accountSalesAreaMap.put(sa.Account__c, new List<Sales_Area__c>());
                }
                accountSalesAreaMap.get(sa.Account__c).add(sa);
            }

            for (List<Sales_Area__c> salesAreas : accountSalesAreaMap.values()) {
                for (Sales_Area__c sa : salesAreas) {
                    salesOrganizations.add(sa.Sales_Organization__c);
                    salesOffices.add(sa.Sales_Office__c);
                }
            }
            // Query Custom Metadata records based on Sales Organization and Sales Office values
            List<Account_Owner__mdt> metadataList = [SELECT Sales_Organization__c, Sales_Office__c, User__c FROM Account_Owner__mdt WHERE Sales_Organization__c IN :salesOrganizations AND Sales_Office__c IN :salesOffices];

            // Create a mapping between Sales Organization + Sales Office and Username
            Map<String, String> salesOrgOfficeToUsernameMap = new Map<String, String>();
            for (Account_Owner__mdt metadata : metadataList) {
                String key = metadata.Sales_Organization__c + metadata.Sales_Office__c;
                salesOrgOfficeToUsernameMap.put(key, metadata.User__c);
            }

            // Query User records based on the usernames
            Map<String, Id> usernameToUserIdMap = new Map<String, Id>();
            for (User user : [SELECT Id, Username FROM User WHERE Username IN :salesOrgOfficeToUsernameMap.values()]) {
                usernameToUserIdMap.put(user.Username, user.Id);
            }
            System.debug('usernameToUserIdMap - salesOrgOfficeToUsernameMap' + salesOrgOfficeToUsernameMap + '-' + usernameToUserIdMap);
            // Update Account Owner based on Sales Organization and Sales Office match            
            for (Account acc : accountWithoutSAPUser) {
                if (accountSalesAreaMap.containsKey(acc.Id)) {
                    for (Sales_Area__c sa : accountSalesAreaMap.get(acc.Id)) {
                        String key = sa.Sales_Organization__c + sa.Sales_Office__c;
                        if (salesOrgOfficeToUsernameMap.containsKey(key)) {
                            String username = salesOrgOfficeToUsernameMap.get(key);
                            if (usernameToUserIdMap.containsKey(username)) {
                                acc.OwnerId = usernameToUserIdMap.get(username);                                
                                break; // Exit inner loop once OwnerId is set
                            }
                        }
                    }
                }
            }
        }
        return accounts;
    }

    public static List<Account>  populateOwnerAndUpsert(List<Account> accounts) {
        populateOwner(accounts);
        upsert accounts;
        return accounts;
    }
}