public class DeleteDefaultProjectTeamController 
{
    public User user { get; set; }    
    public Boolean deleteProjectTeam { get; set; }
    public Default_Project_Team__c defaultProjectTeam { get; set; }
    
    public DeleteDefaultProjectTeamController(ApexPages.StandardController stdController)
    {
        defaultProjectTeam = (Default_Project_Team__c) stdController.getRecord();
        init();
    }
    
    public void init()
    {                
        defaultProjectTeam = [SELECT OwnerId, Team_Member__c FROM Default_Project_Team__c WHERE Id =:defaultProjectTeam.Id];
        user = [SELECT Name FROM User WHERE Id = :defaultProjectTeam.OwnerId];        
        deleteProjectTeam = false;
    }

    public PageReference deleteRecord()
    {        
        if (deleteProjectTeam == true)
        {
            List<Project__c> ownedProjects = [SELECT Id, (SELECT Team_Member__c FROM Project_Teams__r WHERE Team_Member__c = :defaultProjectTeam.Team_Member__c) FROM Project__c WHERE OwnerId =: user.Id];            
            List<Project_Team__c> existingProjectTeams = new List<Project_Team__c>();            
            for (Project__c ownedProject : ownedProjects)
            {      
                for (Project_Team__c existingProjectTeam : ownedProject.Project_Teams__r)
                {                                           
                    existingProjectTeams.add(existingProjectTeam);                        
                }
            } 
            delete existingProjectTeams;
        }
        delete defaultProjectTeam;        
        return new PageReference('/' + user.Id);
    }  
    
    public PageReference cancel()
    {		       
        return new PageReference('/' + user.Id);
    }
}