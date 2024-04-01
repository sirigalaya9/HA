trigger ProjectTeamTrigger on Project_Team__c (before insert, before update, before delete) 
{

    if (Trigger.isInsert || Trigger.isUpdate)
    {
        ProjectTeamController.createShares(Trigger.new);
    }
    else if (Trigger.isDelete)
    {
        ProjectTeamController.deleteShares(Trigger.old);
    }
}