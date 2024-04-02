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
* 02.04.2024  ly.sirigalaya@kliqxe.com         	 assignTerritoryToRelatedOpportunity
*/

public without sharing class SalesAreaService {
    public static void assignTerritory(List<Sales_Area__c> salesAreas) { 
        List<ObjectTerritory2Association> territoryAssociationsToInsert = new List<ObjectTerritory2Association>();
        Set<String> salesOrganizations = new Set<String>();
        Set<String> salesOffices = new Set<String>();
        Set<String> salesGroups = new Set<String>();
        Map<Id, Sales_Area__c> accSalesAreaMap = new Map<Id, Sales_Area__c>();
        //Map<Id, List<Sales_Area__c>> accSalesAreaMap = new Map<Id, List<Sales_Area__c>>();
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
                
                /*if(accSalesAreaMap.containsKey(sa.Account__c)) {
                    accSalesAreaMap.get(sa.Account__c).add(sa);
                } else {
                    accSalesAreaMap.put(sa.Account__c, new List<Sales_Area__c> { sa });
                }*/
                accSalesAreaMap.put(sa.Account__c, sa);
            }                        
        }
        if (!territoryAssociationsToInsert.isEmpty()) {
            insert territoryAssociationsToInsert;
            assignTerritoryToRelatedOpportunity(accSalesAreaMap, keyToTerritoryMap);
        }
    }

    public static void removeTerritory (List<Sales_Area__c> salesAreas) {        
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
    
    public static void assignTerritoryToRelatedOpportunity(Map<Id, Sales_Area__c> accSalesAreaMap, Map<String, Territory2> keyToTerritoryMap){
        
        //System.debug('accSalesAreaMap==>'+accSalesAreaMap);
        //System.debug('keyToTerritoryMap==>'+keyToTerritoryMap);
        try{
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            for (Account acc : [SELECT Id, Name, No_of_Sales_Area__c,
                                (SELECT Id, Name, Sales_Organization__c, Sales_Office__c, Sales_Group__c, Distribution_Channel__c, Division__c, Territory2Id 
                                 FROM Opportunities)
                                FROM Account 
                                WHERE Id IN :accSalesAreaMap.keyset()]) 
            {
                if(!acc.Opportunities.isEmpty() && acc.Opportunities.size() > 0){
                    System.debug('acc==>'+acc);
                    for(Opportunity opp : acc.Opportunities){
                        if(accSalesAreaMap.containsKey(acc.Id) && accSalesAreaMap.get(acc.Id) != null){
                            Sales_Area__c sa = accSalesAreaMap.get(acc.Id);
                            String key = sa.Sales_Organization__c + sa.Sales_Office__c + sa.Sales_Group__c;
                            Territory2 territory = keyToTerritoryMap.get(key);
                            System.debug('sa==>'+sa);
                            System.debug('territory==>'+territory);
                            if ( territory != null && 
                                opp.Sales_Organization__c == sa.Sales_Organization__c && 
                                opp.Distribution_Channel__c == sa.Distribution_Channel__c &&
                                opp.Division__c == sa.Division__c) {
                                    Opportunity newOpp = new Opportunity(
                                        Id = opp.Id,
                                        Sales_Office__c = sa.Sales_Office__c,
                                        Sales_Group__c = sa.Sales_Group__c,
                                        Territory2Id = territory.Id
                                    );
                                    oppsToUpdate.add(newOpp);
                                }
                        }
                    }
                    if(!oppsToUpdate.isEmpty()){
                        update oppsToUpdate;
                    }
                }
            }
        }
        catch (Exception e) { LogUtil.emit(e, new Map<String, String>{}); }   
    }
}