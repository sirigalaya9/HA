/*
* Lead Trigger handler - After lead converted, copy lead items to opp items
* @author manu.voramontri@kliqxe.com
* @since 01.03.2024
* @version 01.03.2024
* @log 
* ==============================================================================
* Version      Author                             Modification
* ==============================================================================
* 01.03.2024   manu.voramontri@kliqxe.com         Initial Version
*/
public without sharing class LeadTriggerHandler 
{
    public void onAfterUpdate() {
        system.debug('LeadTrigger onAfter Update');
        List<Lead> leads = new List<Lead>();
        for (sObject lead : Trigger.new)
        {
            Lead newLead = (Lead) lead;
            Lead oldLead = (Lead) Trigger.oldMap.get(lead.Id);
            if (newLead.IsConverted == true && oldLead.IsConverted == false && newLead.ConvertedOpportunityId != null)
            {
                leads.add(newLead);
            }
        }
        if (!leads.isEmpty())
        {
            OpportunityService.copyLeadItemsToOppItems(leads);
        }        
    }
}