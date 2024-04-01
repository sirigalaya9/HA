public class CreateDefaultProjectTeamController 
{
    public User user { get; set; }    
    public Boolean enableDefaultProjectTeam { get; set; }
    public Boolean updateProjectTeam { get; set; }
    public List<Default_Project_Team__c> defaultProjectTeams { get; set; }
    
    
    public CreateDefaultProjectTeamController(ApexPages.StandardSetController stdController)
    {
        init();
    }
    
    public void init()
    {
        Id userId = ApexPages.currentPage().getParameters().get('Id');
        if (userId == NULL)
        {
            userId = System.UserInfo.getUserId();
        }
        user = [SELECT Name FROM User WHERE Id =:userId];
        User_Setting__c userSetting = User_Setting__c.getInstance(user.Id);
        enableDefaultProjectTeam = userSetting.Enable_Default_Project_Team__c;
        updateProjectTeam = false;
        defaultProjectTeams = new List<Default_Project_Team__c>();
        for (Integer i=0; i<5; i++)
        {
            Default_Project_Team__c defaultProjectTeam = new Default_Project_Team__c(OwnerId = userId);
            defaultProjectTeams.add(defaultProjectTeam);
        }
    }
    
    public PageReference save()
    {
        boolean success = ProjectTeamController.createOrUpdateDefaultProjectTeam(defaultProjectTeams, user.Id, updateProjectTeam);
        if (success)
        {
			User_Setting__c userSetting = User_Setting__c.getInstance(user.Id);
            userSetting.Enable_Default_Project_Team__c = enableDefaultProjectTeam;
			upsert userSetting;   
            
            Id userId = ApexPages.currentPage().getParameters().get('Id');
            if (userId == null)
                return new PageReference('/' + Default_Project_Team__c.sObjectType.getDescribe().getKeyPrefix());
            else
                return new PageReference('/' + user.Id);            
        }
        else return null;
    }

    public void saveAndMore()
    {        
        boolean success = ProjectTeamController.createOrUpdateDefaultProjectTeam(defaultProjectTeams, user.Id, updateProjectTeam);
        if (success)
        {
			User_Setting__c userSetting = User_Setting__c.getInstance(user.Id);
            userSetting.Enable_Default_Project_Team__c = enableDefaultProjectTeam;
			upsert userSetting;        
        }
        init();
    }  
    
    public PageReference cancel()
    {		       
        Id userId = ApexPages.currentPage().getParameters().get('Id');
        if (userId == null)
        	return new PageReference('/' + Default_Project_Team__c.sObjectType.getDescribe().getKeyPrefix());
        else
        	return new PageReference('/' + user.Id);
    }    
}