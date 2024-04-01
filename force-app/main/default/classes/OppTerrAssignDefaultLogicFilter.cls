/*** Apex version of the default logic modified
*/
global class OppTerrAssignDefaultLogicFilter implements TerritoryMgmt.OpportunityTerritory2AssignmentFilter { 
    /**
     * No-arg constructor.
     */ 
     global OppTerrAssignDefaultLogicFilter() {}

     /**
      * Get mapping of opportunity to territory2Id. The incoming list of opportunityIds contains only those with IsExcludedFromTerritory2Filter=false.
      */
    global Map<Id,Id> getOpportunityTerritory2Assignments(List<Id> opportunityIds) { 
        Map<Id, Id> OppIdTerritoryIdResult = new Map<Id, Id>();

        // Get the active territory model Id
        Id activeModelId = getActiveModelId();

        if(activeModelId != null){
            List<Opportunity> opportunities =
              [Select Id, AccountId, Territory2Id, Sales_Organization__c, Sales_Office__c, Sales_Group__c from Opportunity where Id IN :opportunityIds];
            Set<String> salesOrgIds = new Set<String>();
            Set<String> salesOffices = new Set<String>();
            Set<String> salesGroups = new Set<String>();
            // Create set of parent accountIds
            for(Opportunity opp:opportunities){
                if(opp.Sales_Organization__c != null){
                    salesOrgIds.add(opp.Sales_Organization__c);
                }
                if(opp.Sales_Office__c != null){
                    salesOffices.add(opp.Sales_Office__c);
                }
                if(opp.Sales_Group__c != null){
                    salesGroups.add(opp.Sales_Group__c);
                }                                
            }

            List<Territory2> territories = [SELECT Id, Name, Sales_Organization__c, Sales_Office__c, Sales_Group__c 
            FROM Territory2 
            WHERE Territory2Model.Id = :activeModelId
            AND Sales_Organization__c IN: salesOrgIds
            AND Sales_Organization__c != NULL
            AND Sales_Office__c IN: salesOffices
            AND Sales_Office__c != NULL
            AND Sales_Group__c IN: salesGroups
            AND Sales_Group__c != NULL
            ];

            // For each opportunity, assign the highest priority territory if there is no conflict, else assign null.
            for(Opportunity opp: opportunities)
            {
                for (Territory2 territory : territories)
                {
                    if (opp.Sales_Organization__c != null && opp.Sales_Organization__c.equalsIgnoreCase(territory.Sales_Organization__c) 
                    && opp.Sales_Office__c != null && opp.Sales_Office__c.equalsIgnoreCase(territory.Sales_Office__c)
                    && opp.Sales_Group__c != null && opp.Sales_Group__c.equalsIgnoreCase(territory.Sales_Group__c))
                    {
                        OppIdTerritoryIdResult.put(opp.Id, territory.Id);
                        break;                        
                    }
                }
            }
        }
        return OppIdTerritoryIdResult;
    }

    /**
     * Get the Id of the Active Territory Model.
     * If none exists, return null.
     */
    private Id getActiveModelId() {
        List<Territory2Model> models = [Select Id from Territory2Model where State = 'Active'];
        Id activeModelId = null;
        if(models.size() == 1){
            activeModelId = models.get(0).Id;
        }

        return activeModelId;
    }
}