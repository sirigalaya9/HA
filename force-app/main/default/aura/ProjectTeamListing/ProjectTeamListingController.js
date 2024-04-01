({
	doInit : function(component, event, helper) {
        var parentRecordId = component.get("v.parentRecordId");
        if(parentRecordId == undefined)
        {
        	var value = helper.getParameterByName(component , event, 'inContextOfRef');
        	var context = JSON.parse(window.atob(value));
        	component.set("v.parentRecordId", context.attributes.recordId);
    	}
        for(var i=0;i<=0;i++){
        $A.enqueueAction(component.get('c.doAdd'));
        }
    },
    
    doAdd : function(component, event, helper) {

        var projectTeams = component.get("v.projectTeams");
        
        var newProjectTeam ='{"sobjectType": "Project_Team__c"}';
                            
    	var newProjectTeamParsed = JSON.parse(newProjectTeam);      
        
        projectTeams.push(newProjectTeamParsed);
        
        component.set("v.projectTeams", projectTeams);
        console.log("projectTeams "+projectTeams);
	
    },
    
    cancel: function(component, event, helper) {
        /*
        var viewRecordEvent = $A.get("e.force:navigateToURL");
        viewRecordEvent.setParams({
            "url": "/" + component.get("v.parentRecordId")
        });
        viewRecordEvent.fire();
        */
        var context = component.get("v.UserContext");
        
        if(context != undefined) 
        {
            if(context == 'Theme4t' || context == 'Theme4d') 
            {
                console.log('VF in S1 or LEX');
                sforce.one.navigateToSObject(component.get("v.parentRecordId"), "related");
            } 
            else 
            {
                console.log('VF in Classic'); 
                //var contactId = component.get("v.contact").Id;
                //window.location.assign('/'+contactId);
            }
        } 
        else 
        {
            console.log('standalone Lightning Component');
            var viewRecordEvent = $A.get("e.force:navigateToURL");
            viewRecordEvent.setParams({
                "url": "/" + component.get("v.parentRecordId")
            });
            viewRecordEvent.fire();
        }         
    },
    
    removeDeletedRow: function(component, event, helper) {
        // get the selected row Index for delete, from Lightning Event Attribute  
        //var index = event.getParam("indexVar");
        var index = event.target.getAttribute("id");
        // get the all List (contactList attribute) and remove the Object Element Using splice method    
        var AllRowsList = component.get("v.projectTeams");
        AllRowsList.splice(index, 1);
        // set the contactList after remove selected row element  
        component.set("v.projectTeams", AllRowsList);
    }, 
    
    removeRow : function(component, event, helper){
        // fire the DeleteRowEvt Lightning Event and pass the deleted Row Index to Event parameter/attribute
        component.getEvent("DeleteRowEvt").setParams({"indexVar" : component.get("v.rowIndex") }).fire();
    },
    
    submit: function(component, event, helper) {
        helper.submitHelper(component,event,helper);
        
    }
})