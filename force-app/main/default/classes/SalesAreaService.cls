/*
* SalesArea Service
* @author long@kliqxe.com
* @since 28.03.2024
* @version 28.03.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 27.03.2024  long@kliqxe.com         			 Initial Version
*/

public without sharing class SalesAreaService {
    public static void assignTerritory(List<Sales_Area__c> salesAreas) { 
        List<ObjectTerritory2Association> territoryAssociationsToInsert = new List<ObjectTerritory2Association>();
        Set<String> salesOrganizations = new Set<String>();
        Set<String> salesOffices = new Set<String>();
        Set<String> salesGroups = new Set<String>();
        for (Sales_Area__c sa : salesAreas) {
            salesOrganizations.add(sa.Sales_Organization__c);
            salesOffices.add(sa.Sales_Office__c);
            salesGroups.add(sa.Sales_Group__c);
        }
        Map<String, Territory2> keyToTerritoryMap = new Map<String, Territory2>();

        for (Territory2 terr : [SELECT Id, Sales_Organization__c, Sales_Office__c, Sales_Group__c FROM Territory2 WHERE Sales_Organization__c IN :salesOrganizations AND Sales_Office__c IN :salesOffices AND Sales_Group__c IN :salesGroups]) {
            keyToTerritoryMap.put(terr.Sales_Organization__c + terr.Sales_Office__c + terr.Sales_Group__c, terr);
        }
                
        System.debug('territories==>' + salesOrganizations + '-' + salesOffices + '-' + salesGroups + '-' + keyToTerritoryMap);
        for (Sales_Area__c sa : salesAreas) {
            String key = sa.Sales_Organization__c + sa.Sales_Office__c + sa.Sales_Group__c;
            Territory2 territory = keyToTerritoryMap.get(key);            
            if ( territory != null ) {
                ObjectTerritory2Association association = new ObjectTerritory2Association();
                association.ObjectId = sa.Account__c; 
                association.Territory2Id = territory.Id;
                association.AssociationCause = 'Territory2Manual'; 
                territoryAssociationsToInsert.add(association);
            }                        
        }
        if (!territoryAssociationsToInsert.isEmpty()) {
            insert territoryAssociationsToInsert;
        }
    }

    static public void removeTerritory (List<Sales_Area__c> salesAreas) {        
        Set<Id> accountIds = new Set<Id>();        
        for (Sales_Area__c sa : salesAreas) {
            accountIds.add(sa.Account__c);
        }
        
        Set<String> salesOrganizations = new Set<String>();
        Set<String> salesOffices = new Set<String>();
        Set<String> salesGroups = new Set<String>();
        for (Sales_Area__c sa : salesAreas) {
            salesOrganizations.add(sa.Sales_Organization__c);
            salesOffices.add(sa.Sales_Office__c);
            salesGroups.add(sa.Sales_Group__c);
        }        

        List<Territory2> territories = [SELECT Id, Sales_Organization__c, Sales_Office__c, Sales_Group__c FROM Territory2 WHERE Sales_Organization__c IN :salesOrganizations AND Sales_Office__c IN :salesOffices AND Sales_Group__c IN :salesGroups];
        
        // Query existing ObjectTerritory2Association records to delete
        List<ObjectTerritory2Association> associationsToDelete = [SELECT Id FROM ObjectTerritory2Association WHERE ObjectId IN :accountIds AND Territory2Id IN :territories AND AssociationCause = 'Territory2Manual'];
        System.debug('territories==>' + salesOrganizations + '-' + salesOffices + '-' + salesGroups + '-' + territories + '-' + associationsToDelete);
        // Delete existing ObjectTerritory2Association records
        if (!associationsToDelete.isEmpty()) {
            delete associationsToDelete;
        }
    }
}