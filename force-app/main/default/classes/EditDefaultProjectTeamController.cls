public class EditDefaultProjectTeamController
{
    public User user { get; set; }
    public User_Setting__c userSetting { get; set; }
    public Boolean updateProjectTeam { get; set; }
    public Default_Project_Team__c defaultProjectTeam { get; set; }
    
    public EditDefaultProjectTeamController(ApexPages.StandardController stdController)
    {
        defaultProjectTeam = (Default_Project_Team__c) stdController.getRecord();
        init();
    }
    
    public void init()
    {        
        defaultProjectTeam = [SELECT OwnerId, Project_Access__c, Team_Role__c, Team_Member__c, Team_Member__r.Name FROM Default_Project_Team__c WHERE Id = :defaultProjectTeam.Id];
        user = [SELECT Name FROM User WHERE Id = :defaultProjectTeam.OwnerId];
        userSetting = User_Setting__c.getInstance(user.Id);
        updateProjectTeam = false;
    }

    public PageReference save()
    {        
        List<Default_Project_Team__c> defaultProjectTeams = new List<Default_Project_Team__c>();
        defaultProjectTeams.add(defaultProjectTeam);
        boolean success = ProjectTeamController.createOrUpdateDefaultProjectTeam(defaultProjectTeams, user.Id, updateProjectTeam);
        if (success)
        {
        	upsert userSetting;   
        }
        return new PageReference('/' + userSetting.SetupOwnerId);
    }  
    
    public PageReference cancel()
    {		       
        return new PageReference('/' + userSetting.SetupOwnerId);
    }
}