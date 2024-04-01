@isTest
public class DataCompletenessControllerTest 
{
    @TestSetup
    static void setupData()
    {
        Contact contact = new Contact();
        contact.LastName = 'Test';
        insert contact;
    }

    @isTest
    static void testGetFields()
    {
        Contact Contact = [SELECT Id FROM Contact];
        DataCompletenessController.FieldSet result = DataCompletenessController.getFields(contact.Id);
        System.assertNotEquals(null, result, 'Result should be returned');
    }
}