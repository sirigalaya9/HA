@isTest
public class PathAssistantTest 
{
    @isTest
    static void test_Get()
    {
        PathAssistantController.getGuidanceForSuccess('Quote', 'Order_Confirmation__c');
    }

    @isTest
    static void test_Save()
    {
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        insert contact;
        PathAssistantController.saveRecord(contact.Id, 'Salutation', 'Mr.');
    }  
    @isTest
    static void test_SaveFail()
    {
        Contact contact = new Contact();
        contact.FirstName = 'Test';
        contact.LastName = 'Test';
        insert contact;
        try {
            PathAssistantController.saveRecord(contact.Id, '', 'Mr.');
        } catch (Exception e) {
            System.debug(e);
        }
        
    }      
}