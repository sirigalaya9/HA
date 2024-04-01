@isTest
public class ProjectTeamTest 
{
	static final String TEST_USERNAME = 'testuser@mail.weir.invalid';
    static final String ACCOUNT_NAME = 'Test';
    static final String PROJECT_NAME = 'Test';
    static final String SHARING_REASON = 'Team__c';
    static final String TEAM_ACCESS_EDIT = 'Edit';
    static final String TEAM_ROLE_ACCOUNT_MANAGER = 'Account Manager';
    static final String TEAM_ROLE_CHANNEL_MANAGER = 'Channel Manager';
    
    @testSetup
    static void setupData()
    {
        Profile profile = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User user = new User(Alias = 'standt', Email='standarduser@example.com', EmailEncodingKey='UTF-8', 
                          LastName='Testing', LanguageLocaleKey='en_US',LocaleSidKey='en_US', ProfileId = profile.Id,
        				  TimeZoneSidKey='America/Los_Angeles', UserName = TEST_USERNAME);
        insert user;
        //Account account = new Account(Name = ACCOUNT_NAME, BillingCity = 'Kuala Lumpur', BillingPostalCode = '12345', BillingCountry = 'Malaysia');
        //insert account;
        //Project__c project = new Project__c(Name = PROJECT_NAME, Account__c = account.Id);
        Project__c project = new Project__c(Name = PROJECT_NAME);
        insert project; 
    }
    
    @isTest
    static void testInsertProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Project_Team__c projectTeam = new Project_Team__c(Project__c = project.Id, Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT);
        
        Test.startTest();
        insert projectTeam;
        Test.stopTest();
        
        List<Project__Share> projectShares = [SELECT Id FROM Project__Share WHERE ParentId = :project.Id AND UserOrGroupId = :user.Id AND RowCause = :SHARING_REASON];
        System.assertEquals(1, projectShares.size());
    }
    
    @isTest
    static void testUpdateProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Project_Team__c projectTeam = new Project_Team__c(Project__c = project.Id, Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT);
        
        Test.startTest();
        insert projectTeam;        
        update projectTeam;
        Test.stopTest();
        
        List<Project__Share> projectShares = [SELECT Id FROM Project__Share WHERE ParentId = :project.Id AND UserOrGroupId = :user.Id AND RowCause = :SHARING_REASON];
        System.assertEquals(1, projectShares.size());
    }

    @isTest
    static void testDeleteProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Project_Team__c projectTeam = new Project_Team__c(Project__c = project.Id, Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT);
        
        Test.startTest();
        insert projectTeam;        
        delete projectTeam;
        Test.stopTest();
        
        List<Project__Share> projectShares = [SELECT Id FROM Project__Share WHERE ParentId = :project.Id AND UserOrGroupId = :user.Id AND RowCause = :SHARING_REASON];
        System.assertEquals(0, projectShares.size());
    }

	@isTest
	static void testDeleteDefaultProjectTeam()
    {
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Default_Project_Team__c defaultProjectTeam = new Default_Project_Team__c(Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT, Team_Role__c = TEAM_ROLE_ACCOUNT_MANAGER);
        insert defaultProjectTeam;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(defaultProjectTeam);
        DeleteDefaultProjectTeamController ctrl = new DeleteDefaultProjectTeamController(sc);
        ctrl.deleteRecord();
        Test.stopTest();
        
        List<Default_Project_Team__c> defaultProjectTeams = [SELECT Id FROM Default_Project_Team__c WHERE Id = :defaultProjectTeam.Id];
        System.assertEquals(0, defaultProjectTeams.size());        
    }
    
	@isTest
	static void testDeleteDefaultProjectTeam_WithDeleteProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Default_Project_Team__c defaultProjectTeam = new Default_Project_Team__c(Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT, Team_Role__c = TEAM_ROLE_ACCOUNT_MANAGER);
        insert defaultProjectTeam;        
        Project_Team__c projectTeam = new Project_Team__c(Project__c = project.Id, Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT);
        insert projectTeam;

        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(defaultProjectTeam);
        DeleteDefaultProjectTeamController ctrl = new DeleteDefaultProjectTeamController(sc);
        ctrl.deleteProjectTeam = true;
        ctrl.deleteRecord();
        ctrl.cancel();
        Test.stopTest();
        
        List<Default_Project_Team__c> defaultProjectTeams = [SELECT Id FROM Default_Project_Team__c WHERE Id = :defaultProjectTeam.Id];
        System.assertEquals(0, defaultProjectTeams.size()); 
        List<Project_Team__c> projectTeams = [SELECT Id FROM Project_Team__c WHERE Project__c = :project.Id];
        System.assertEquals(0, projectTeams.size());          
    } 
    
	@isTest
	static void testCreateDefaultProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Default_Project_Team__c defaultProjectTeam = new Default_Project_Team__c(Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT, Team_Role__c = TEAM_ROLE_ACCOUNT_MANAGER);        		        
        
        Test.startTest();
        List<Default_Project_Team__c> defaultProjectTeams = new List<Default_Project_Team__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(defaultProjectTeams);
        CreateDefaultProjectTeamController ctrl = new CreateDefaultProjectTeamController(sc);    
        ctrl.defaultProjectTeams.add(defaultProjectTeam);        
        ctrl.save();        
        Test.stopTest();
        
        List<Default_Project_Team__c> defaultProjectTeamsInDB = [SELECT Id FROM Default_Project_Team__c WHERE OwnerId = :System.UserInfo.getUserId()];
        System.assertEquals(1, defaultProjectTeamsInDB.size());        
    }

	@isTest
	static void testCreateDefaultProjectTeam_WithUpdateProjectTeam_ExistingProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Default_Project_Team__c defaultProjectTeam = new Default_Project_Team__c(Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT, Team_Role__c = TEAM_ROLE_ACCOUNT_MANAGER);        		          
        Project_Team__c projectTeam = new Project_Team__c(Project__c = project.Id, Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT);
        insert projectTeam;       
        
        Test.startTest();
        List<Default_Project_Team__c> defaultProjectTeams = new List<Default_Project_Team__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(defaultProjectTeams);
        CreateDefaultProjectTeamController ctrl = new CreateDefaultProjectTeamController(sc);    
        ctrl.defaultProjectTeams.add(defaultProjectTeam);
		ctrl.updateProjectTeam = true;        
        ctrl.saveAndMore();
		ctrl.cancel();        
        Test.stopTest();
        
        List<Project_Team__c> projectTeamsInDB = [SELECT Id FROM Project_Team__c WHERE Project__c = :project.Id];
        System.assertEquals(1, projectTeamsInDB.size());        
    }
    
	@isTest
	static void testCreateDefaultProjectTeam_WithUpdateProjectTeam_NewProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Default_Project_Team__c defaultProjectTeam = new Default_Project_Team__c(Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT, Team_Role__c = TEAM_ROLE_ACCOUNT_MANAGER);  		                  
        
        Test.startTest();
        List<Default_Project_Team__c> defaultProjectTeams = new List<Default_Project_Team__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(defaultProjectTeams);
        CreateDefaultProjectTeamController ctrl = new CreateDefaultProjectTeamController(sc);    
        ctrl.defaultProjectTeams.add(defaultProjectTeam);
		ctrl.updateProjectTeam = true;        
        ctrl.saveAndMore();
		ctrl.cancel();        
        Test.stopTest();
        
        List<Project_Team__c> projectTeamsInDB = [SELECT Id FROM Project_Team__c WHERE Project__c = :project.Id];
        System.assertEquals(1, projectTeamsInDB.size());        
    }    
    
	@isTest
	static void testCreateDefaultProjectTeam_ExistingDefaultProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Default_Project_Team__c defaultProjectTeam = new Default_Project_Team__c(Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT, Team_Role__c = TEAM_ROLE_ACCOUNT_MANAGER);
		insert defaultProjectTeam;     
        
        Test.startTest();
        List<Default_Project_Team__c> defaultProjectTeams = new List<Default_Project_Team__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(defaultProjectTeams);
        CreateDefaultProjectTeamController ctrl = new CreateDefaultProjectTeamController(sc);    
        defaultProjectTeam.Id = null;
        defaultProjectTeam.Team_Role__c = TEAM_ROLE_CHANNEL_MANAGER;
        ctrl.defaultProjectTeams.add(defaultProjectTeam);		        
        ctrl.save();		
        Test.stopTest();
        
        List<Default_Project_Team__c> defaultProjectTeamsInDB = [SELECT Team_Role__c FROM Default_Project_Team__c WHERE OwnerId = :System.UserInfo.getUserId()];
        System.assertEquals(1, defaultProjectTeamsInDB.size()); 
        System.assertEquals(TEAM_ROLE_CHANNEL_MANAGER, defaultProjectTeamsInDB.get(0).Team_Role__c); 
    }
    
	static void testCreateDefaultProjectTeam_ExistingProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Default_Project_Team__c defaultProjectTeam = new Default_Project_Team__c(Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT, Team_Role__c = TEAM_ROLE_ACCOUNT_MANAGER);		        		          
        Project_Team__c projectTeam = new Project_Team__c(Project__c = project.Id, Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT, Team_Role__c = TEAM_ROLE_CHANNEL_MANAGER);
        insert projectTeam;       
        
        Test.startTest();
        List<Default_Project_Team__c> defaultProjectTeams = new List<Default_Project_Team__c>();
        ApexPages.StandardSetController sc = new ApexPages.StandardSetController(defaultProjectTeams);
        CreateDefaultProjectTeamController ctrl = new CreateDefaultProjectTeamController(sc);    
        ctrl.updateProjectTeam = true;
        defaultProjectTeam.Id = null;        
        ctrl.defaultProjectTeams.add(defaultProjectTeam);		        
        ctrl.save();		
        Test.stopTest();
        
        List<Project_Team__c> projectTeamsInDB = [SELECT Team_Role__c FROM Project_Team__c WHERE Project__c = :project.Id];
        System.assertEquals(1, projectTeamsInDB.size());  
        System.assertEquals(TEAM_ROLE_CHANNEL_MANAGER, projectTeamsInDB.get(0).Team_Role__c);
    }
    
	@isTest
	static void testEditDefaultProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Default_Project_Team__c defaultProjectTeam = new Default_Project_Team__c(Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT, Team_Role__c = TEAM_ROLE_ACCOUNT_MANAGER);        		        
        insert defaultProjectTeam;
        
        Test.startTest();
        List<Default_Project_Team__c> defaultProjectTeams = new List<Default_Project_Team__c>();
        ApexPages.StandardController sc = new ApexPages.StandardController(defaultProjectTeam);
        EditDefaultProjectTeamController ctrl = new EditDefaultProjectTeamController(sc);  
        defaultProjectTeam.Team_Role__c = TEAM_ROLE_CHANNEL_MANAGER;
        ctrl.defaultProjectTeam = defaultProjectTeam;
        ctrl.save();     
        ctrl.cancel();
        Test.stopTest();
        
        List<Default_Project_Team__c> defaultProjectTeamsInDB = [SELECT Team_Role__c FROM Default_Project_Team__c WHERE OwnerId = :System.UserInfo.getUserId()];
        System.assertEquals(1, defaultProjectTeamsInDB.size()); 
        System.assertEquals(TEAM_ROLE_CHANNEL_MANAGER, defaultProjectTeamsInDB.get(0).Team_Role__c);
    }

    @isTest
    static void testCreateOrUpdateProjectTeam_NewProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Project_Team__c projectTeam = new Project_Team__c(Project__c = project.Id, Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT);
        List<Project_Team__c> projectTeams = new List<Project_Team__c>();
        projectTeams.add(projectTeam);
        
        Test.startTest();
        ProjectTeamController.createOrUpdateProjectTeam(projectTeams);
        Test.stopTest();
        
        List<Project_Team__c> projectTeamsInDB = [SELECT Id FROM Project_Team__c WHERE Project__c = :project.Id];
        System.assertEquals(1, projectTeamsInDB.size());
    } 
    
    @isTest
    static void testCreateOrUpdateProjectTeam_ExistingProjectTeam()
    {
        Project__c project = [SELECT Id FROM Project__c WHERE Name = :PROJECT_NAME];
        User user = [SELECT Id FROM User WHERE Username = :TEST_USERNAME];
        Project_Team__c projectTeam = new Project_Team__c(Project__c = project.Id, Team_Member__c = user.Id, Project_Access__c = TEAM_ACCESS_EDIT, Team_Role__c = TEAM_ROLE_ACCOUNT_MANAGER);
        insert projectTeam;
        List<Project_Team__c> projectTeams = new List<Project_Team__c>();
        projectTeams.add(projectTeam);
        
        Test.startTest();
        projectTeam.Team_Role__c = TEAM_ROLE_CHANNEL_MANAGER;
        ProjectTeamController.createOrUpdateProjectTeam(projectTeams);
        Test.stopTest();
        
        List<Project_Team__c> projectTeamsInDB = [SELECT Team_Role__c FROM Project_Team__c WHERE Project__c = :project.Id];
        System.assertEquals(1, projectTeamsInDB.size());
        System.assertEquals(TEAM_ROLE_CHANNEL_MANAGER, projectTeamsInDB.get(0).Team_Role__c);
    }     
}