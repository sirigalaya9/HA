public class ProjectTeamController 
{
    public static final String SHARING_REASON = 'Team__c';
    public static final String ACCESS_READ = 'Read';
    
    public static void createShares(List<Project_Team__c> projectTeams)
    {                
        //If current user is not project owner or above owner in role hierarchy then need to prevent them from managing team
        Map<Id, UserRecordAccess> userAccessMap = new Map<Id, UserRecordAccess>();
        for (Project_Team__c projectTeam : projectTeams)
        {
            userAccessMap.put(projectTeam.Project__c, null);
        }
        List<UserRecordAccess> userAccesses = [SELECT RecordId, HasEditAccess, HasTransferAccess, MaxAccessLevel FROM UserRecordAccess 
                                               WHERE UserId = :System.UserInfo.getUserId() AND RecordId IN :userAccessMap.keySet()];
        for (UserRecordAccess userAccess : userAccesses)
        {            
			userAccessMap.put(userAccess.RecordId, userAccess);
        }
            
        List<Project__Share> projectShares = new List<Project__Share>();
        for (Project_Team__c projectTeam : projectTeams)
        {            
            UserRecordAccess userAccess = userAccessMap.get(projectTeam.Project__c);            
            if (!userAccess.MaxAccessLevel.equalsIgnoreCase('All')) //Only owners and users above project owner in role hierarchy have 'All', team members have 'Edit'
            {
                projectTeam.addError('insufficient access rights on object id');
                continue;
            }		
            if (projectTeam.Project_Access__c.equalsIgnoreCase(ACCESS_READ))
            {
                continue;
            }            		
            Project__Share projectShare = new Project__Share();
            projectShare.AccessLevel = projectTeam.Project_Access__c;
            projectShare.UserOrGroupId = projectTeam.Team_Member__c;
            projectShare.ParentId = projectTeam.Project__c;
            projectShare.RowCause = Schema.Project__Share.RowCause.Team__c;
            projectShares.add(projectShare);
        }
        insert projectShares;        
    }
    
    public static void deleteShares(List<Project_Team__c> projectTeams)
    {        
        //If current user is not project owner or above owner in role hierarchy then need to prevent them from managing team
        Map<Id, UserRecordAccess> userAccessMap = new Map<Id, UserRecordAccess>();
        for (Project_Team__c projectTeam : projectTeams)
        {
			userAccessMap.put(projectTeam.Project__c, null);            
        }
        List<UserRecordAccess> userAccesses = [SELECT RecordId, HasEditAccess, HasTransferAccess, MaxAccessLevel FROM UserRecordAccess 
                                               WHERE UserId = :System.UserInfo.getUserId() AND RecordId IN :userAccessMap.keySet()];
        for (UserRecordAccess userAccess : userAccesses)
        {            
			userAccessMap.put(userAccess.RecordId, userAccess);
        }
        
        List<Id> userIds = new List<Id>();        
        for (Project_Team__c projectTeam : projectTeams)
        {
            UserRecordAccess userAccess = userAccessMap.get(projectTeam.Project__c);            
            if (!userAccess.MaxAccessLevel.equalsIgnoreCase('All')) //Only owners and users above project owner in role hierarchy have 'All', team members have 'Edit'
            {
                projectTeam.addError('insufficient access rights on object id');                
                continue;
            }
            userIds.add(projectTeam.Team_Member__c);
        }
        
        List<Project__Share> projectShares = [SELECT Id FROM Project__Share WHERE UserOrGroupId IN :userIds AND ParentId IN :userAccessMap.keySet() AND RowCause = :SHARING_REASON];
        delete projectShares;         
    }
    
    @AuraEnabled
    public static void createOrUpdateProjectTeam(List<Project_Team__c> projectTeams)
    {
        System.debug(projectTeams);
        
        Map<Id, Project_Team__c> projectTeamMap = new Map<Id, Project_Team__c>();
        Id projectId;
        for(Project_Team__c projectTeam : projectTeams)
        {
            projectTeamMap.put(projectTeam.Team_Member__c, projectTeam);
            projectId = projectTeam.Project__c;
        }
        
        {
            List<Project__c> ownedProjects = [SELECT Id, (SELECT Team_Member__c FROM Project_Teams__r WHERE Team_Member__c IN :projectTeamMap.keySet()) FROM Project__c WHERE Id = :projectId];
            List<Project_Team__c> newProjectTeams = new List<Project_Team__c>();
            List<Project_Team__c> existingProjectTeams = new List<Project_Team__c>();
            List<Id> ownedProjectIds = new List<Id>();
            for (Project__c ownedProject : ownedProjects)
            {
                Set<Id> teamMemberExisting = new Set<Id>();
                if (ownedProject.Project_Teams__r != NULL && ownedProject.Project_Teams__r.size() > 0)
                {                        
                    for (Project_Team__c existingProjectTeam : ownedProject.Project_Teams__r)
                    {
                        if (projectTeamMap.containsKey(existingProjectTeam.Team_Member__c))
                        {
                            Project_Team__c projectTeam = projectTeamMap.get(existingProjectTeam.Team_Member__c);
                            existingProjectTeam.Project_Access__c = projectTeam.Project_Access__c;
                            existingProjectTeam.Team_Role__c = projectTeam.Team_Role__c;
                            existingProjectTeams.add(existingProjectTeam);
                            teamMemberExisting.add(existingProjectTeam.Team_Member__c);
                        }
                    }                       
                }
                for (Id teamMemberId : projectTeamMap.keySet())
                {
                    if (!teamMemberExisting.contains(teamMemberId))
                    {
                        Project_Team__c projectTeam = projectTeamMap.get(teamMemberId);
                        Project_Team__c newProjectTeam = new Project_Team__c(Project__c = ownedProject.Id);
                        newProjectTeam.Team_Member__c = teamMemberId;
                        newProjectTeam.Project_Access__c = projectTeam.Project_Access__c;
                        newProjectTeam.Team_Role__c = projectTeam.Team_Role__c;
                        newProjectTeams.add(newProjectTeam);
                    }                          
                }
            }
            insert newProjectTeams;
            update existingProjectTeams;
        }        
	}
    
    @AuraEnabled
    public static boolean createOrUpdateDefaultProjectTeam(List<Default_Project_Team__c> defaultProjectTeams, Id userId, boolean updateProjectTeam)
    {        
        Map<Id, Default_Project_Team__c> allDefaultProjectTeamMap = new Map<Id, Default_Project_Team__c>();   
        Map<Id, Default_Project_Team__c> newDefaultProjectTeamMap = new Map<Id, Default_Project_Team__c>();
        for (Default_Project_Team__c item : defaultProjectTeams)
        {
            if (item.Team_Member__c == NULL)
            {
                continue;
            }
            if (item.Team_Member__c != NULL && (item.Team_Role__c == null || item.Project_Access__c == null))
            {
                return false;
            }            
            allDefaultProjectTeamMap.put(item.Team_Member__c, item); 
            newDefaultProjectTeamMap.put(item.Team_Member__c, item);
        }
        if (allDefaultProjectTeamMap.size() > 0)
        {    
            List<Default_Project_Team__c> existingDefaultProjectTeams = [SELECT Team_Member__c FROM Default_Project_Team__c WHERE Team_Member__c IN :allDefaultProjectTeamMap.keySet() AND OwnerId = :userId];
            List<Default_Project_Team__c> newDefaultProjectTeams = new List<Default_Project_Team__c>();
            for (Default_Project_Team__c item : existingDefaultProjectTeams)
            {
                Default_Project_Team__c matchedDefaultProjectTeam = allDefaultProjectTeamMap.get(item.Team_Member__c);
                item.Project_Access__c = matchedDefaultProjectTeam.Project_Access__c;
                item.Team_Role__c = matchedDefaultProjectTeam.Team_Role__c;
                newDefaultProjectTeamMap.remove(item.Team_Member__c);
            }
            newDefaultProjectTeams = newDefaultProjectTeamMap.values();
            insert newDefaultProjectTeams;             
            update existingDefaultProjectTeams;
            if (updateProjectTeam == true)
            {
                List<Project__c> ownedProjects = [SELECT Id, (SELECT Team_Member__c FROM Project_Teams__r WHERE Team_Member__c IN :allDefaultProjectTeamMap.keySet()) FROM Project__c WHERE OwnerId =: userId];
                List<Project_Team__c> newProjectTeams = new List<Project_Team__c>();
                List<Project_Team__c> existingProjectTeams = new List<Project_Team__c>();
                List<Id> ownedProjectIds = new List<Id>();
                for (Project__c ownedProject : ownedProjects)
                {
                    Set<Id> teamMemberExisting = new Set<Id>();
                    if (ownedProject.Project_Teams__r != NULL && ownedProject.Project_Teams__r.size() > 0)
                    {                        
                        for (Project_Team__c existingProjectTeam : ownedProject.Project_Teams__r)
                        {
                            if (allDefaultProjectTeamMap.containsKey(existingProjectTeam.Team_Member__c))
                            {
                                Default_Project_Team__c defaultProjectTeam = allDefaultProjectTeamMap.get(existingProjectTeam.Team_Member__c);
                                existingProjectTeam.Project_Access__c = defaultProjectTeam.Project_Access__c;
                                existingProjectTeam.Team_Role__c = defaultProjectTeam.Team_Role__c;
                                existingProjectTeams.add(existingProjectTeam);
                                teamMemberExisting.add(existingProjectTeam.Team_Member__c);
                            }
                        }                       
                    }
                    for (Id teamMemberId : allDefaultProjectTeamMap.keySet())
                    {
                        if (!teamMemberExisting.contains(teamMemberId))
                        {
                            Default_Project_Team__c defaultProjectTeam = allDefaultProjectTeamMap.get(teamMemberId);
                            Project_Team__c newProjectTeam = new Project_Team__c(Project__c = ownedProject.Id);
                            newProjectTeam.Team_Member__c = teamMemberId;
                            newProjectTeam.Project_Access__c = defaultProjectTeam.Project_Access__c;
                            newProjectTeam.Team_Role__c = defaultProjectTeam.Team_Role__c;
                            newProjectTeams.add(newProjectTeam);
                        }                          
                    }
                }
                insert newProjectTeams;
                update existingProjectTeams;
            }            
        }        
        return true;
    }
}