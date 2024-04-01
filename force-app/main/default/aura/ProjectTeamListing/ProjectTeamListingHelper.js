({ 
    submitHelper: function(component,event,helper) 
    {
        let res = component.find("recordEditForm");
        var allValid = true;
        var MemberField = component.find("MemberField");
        var RoleField = component.find("RoleField");
        var AccessField = component.find("AccessField");
        var projectTeamsInForm = component.get("v.projectTeams");       
        if(res)
        {
            if (typeof res.length === 'undefined')
            {
                var isMemberValid = true;
                var isRoleValid = true;
                var isAccessValid = true;                            
                isMemberValid = MemberField.reportValidity();
                isRoleValid = RoleField.reportValidity();
                isAccessValid = AccessField.reportValidity();
                if(isMemberValid == false || isRoleValid == false || isAccessValid == false){
                    allValid = false;
                }                
            }
            else
            {
                let output = "Array of "+res.length+" ";
                console.log(output);
                res.forEach(function(v,i) {
                    var isMemberValid = true;
                    var isRoleValid = true;
                    var isAccessValid = true;                            
                    isMemberValid = MemberField[i].reportValidity();
                    isRoleValid = RoleField[i].reportValidity();
                    isAccessValid = AccessField[i].reportValidity();
                    if(isMemberValid == false || isRoleValid == false || isAccessValid == false){
                        allValid = false;
                    }
                    console.log("allValid : "+allValid);
                });
            } 
            
            if(allValid == true){
                var projectTeams = [];
                if (typeof res.length === 'undefined')
                {
                    var projectTeam = {};                   
                    projectTeam.Team_Member__c = MemberField.get("v.value");
                    projectTeam.Team_Role__c = RoleField.get("v.value");
                    projectTeam.Project_Access__c = AccessField.get("v.value");
                    projectTeam.Project__c = component.get("v.parentRecordId");
                    projectTeams.push(projectTeam);                    
                }
                else
                {
                    res.forEach(function(v,i) {
                        //v.submit();
                        var projectTeam = {};                   
                        projectTeam.Team_Member__c = MemberField[i].get("v.value");
                        projectTeam.Team_Role__c = RoleField[i].get("v.value");
                        projectTeam.Project_Access__c = AccessField[i].get("v.value");
                        projectTeam.Project__c = component.get("v.parentRecordId");
                        projectTeams.push(projectTeam);
                        /*
                        helper.showToast("success","Success","Add Project Team Members Sucessfully");
                        var viewRecordEvent = $A.get("e.force:navigateToURL");
                        viewRecordEvent.setParams({
                            "url": "/" + component.get("v.parentRecordId")
                        });
                        viewRecordEvent.fire();
                        */
                    });                    
                }				
               
                var action = component.get("c.createOrUpdateProjectTeam");
                action.setParams({ projectTeams : projectTeams });
        		action.setCallback(this, function(response)
				{
                    var state = response.getState();
                    var context = component.get("v.UserContext");
                    
                    if (state === "SUCCESS") 
                    {
                        if(context != undefined) 
                        {
                            if(context == 'Theme4t' || context == 'Theme4d') 
                            {
                                console.log('VF in S1 or LEX');
                                sforce.one.showToast({         
                                    "message": "Add Project Team Members Sucessfully",
                                    "type": "success"
                                });                        
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
                            helper.showToast("success","Success","Add Project Team Members Sucessfully");
                            var viewRecordEvent = $A.get("e.force:navigateToURL");
                            viewRecordEvent.setParams({
                                "url": "/" + component.get("v.parentRecordId")
                            });
                            viewRecordEvent.fire();
                        }
        			}
                    else if (state === "INCOMPLETE")
                    {
                        // do something
                    }
                    else if (state === "ERROR") 
                    {
                        var errors = response.getError();
                        if (errors) 
                        {
                            if (errors[0] && errors[0].pageErrors[0]) 
                            {
                                console.log("Error message: " + errors[0].pageErrors[0].message);
                                if(context != undefined) 
                                {
                                    if(context == 'Theme4t' || context == 'Theme4d') 
                                    {
                                        console.log('VF in S1 or LEX');
                                        sforce.one.showToast({         
                                            "message": errors[0].pageErrors[0].message,
                                            "type": "error"
                                        });                                                                
                                    } 
                                    else 
                                    {
                                        console.log('VF in Classic');
                                    }
                                }
                                else 
                                {
                                    console.log('standalone Lightning Component');
                                    helper.showToast("error","Error",errors[0].pageErrors[0].message);
                                }                                
                            }
                        } 
                        else 
                        {
                            console.log("Unknown error");
                        }
                    }
                });       	
                $A.enqueueAction(action);
                                 
            }
            else{
                console.log("Some fields missing");
            }
        }
    },
    
    showToast : function (type, title, message) {
        //$A.get("e.force:closeQuickAction").fire()
        var resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
            "type": type,
            "title": title,
            "message": message});
        resultsToast.fire();
    },
    
    getParameterByName: function(component, event, name) {
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
    
    validateCaseForm : function(component)
    {
        var validCase = true;
        var allValid = component.find('projectTeamField');
        console.log(allValid);
        for(var i=0;i<=allValid.length;i++){
           console.log(allValid[i].get('v.validity').valid);
                //inputCmp.showHelpMessageIfInvalid();
                //console.log(inputCmp.showHelpMessageIfInvalid());
                //return validFields && inputCmp.get('v.validity').valid;
            if (allValid) 
            {
                return(validCase);    
            }
        }
        
       /* var validCase = true;
        var allValid = component.find('projectTeamField').reduce(function (validFields, inputCmp) {
            console.log(allValid);
            inputCmp.showHelpMessageIfInvalid();
            console.log(inputCmp);
            return validFields && inputCmp.get('v.validity').valid;
        }, true);
        if (allValid) 
        {
        	return(validCase);    
        } */ 

    }
    
})