/*
 * Copyright © 2019 Vigience Co., Ltd. All Rights Reserved
 */
 
// This code was generated by Overcast for running the outbound mappings. 2019-11-19 12:31:35Z
//
// Update this test class to correspond to your updates to Mapping_ovcSapMaterialRep_Product.
@istest
private class Mapping_ovcSapMaterialRep_ProductTest {
    
    // Assert in code that your mapping configuration is correct
    @istest
    private static void testObjectMapping() {
        overcast__Run__c r = getExecution();
        
        overcast__IntegrationFieldMap__c mapping = new overcast__IntegrationFieldMap__c(overcast__Active__c=true, overcast__Direction__c='Inbound');
        mapping.overcast__ApexClass__c = 'Mapping_ovcSapMaterialRep_Product';
        mapping.overcast__ScenarioName__c = 'ovcSapMaterialRep';
        mapping.overcast__Target__c = 'Product2';
        mapping.overcast__TargetObjectName__c = 'Product2';
        mapping.overcast__Source__c = 'ovcSapMaterialRep_MARAV__c';
        mapping.overcast__SourceObjectName__c = 'ovcSapMaterialRep_MARAV__c';
        // Query your actual mapping records and add the field data here
        // mapping.overcast__Joins__c = '';
        // mapping.overcast__Map__c = '';
        
        // set the input record fields and assert that output record matches your mapping.
        ovcSapMaterialRep_MARAV__c input = new ovcSapMaterialRep_MARAV__c();
        
        Mapping_ovcSapMaterialRep_Product plugin = new Mapping_ovcSapMaterialRep_Product();
        
        Test.startTest();
        
        plugin.execute(r, new ovcSapMaterialRep_MARAV__c[]{ input });
        
        Test.stoptest();
        
        Product2[] output = [SELECT Id FROM Product2 LIMIT 1];
        // Add your assertions about your mapping configuration here.
        system.assert(true);
    }
    
    @istest
    private static void testBeforeUpsert() {
        Mapping_ovcSapMaterialRep_Product plugin = new Mapping_ovcSapMaterialRep_Product();
        plugin.m_logger = new overcast.Logger(getExecution().Id);
        ovcSapMaterialRep_MARAV__c source = new ovcSapMaterialRep_MARAV__c();
        Product2 target = new Product2();
        boolean response = plugin.beforeUpsert(source, target);
        
        // Assert any transformations on the target record you perform in beforeUpsert()
        system.assertEquals(true, response);
    }
    
    @istest
    private static void testAfterInsert() {
        Mapping_ovcSapMaterialRep_Product plugin = new Mapping_ovcSapMaterialRep_Product();
        plugin.m_logger = new overcast.Logger(getExecution().Id);
        Product2 target = new Product2(Name='a');
        
        overcast.ObjectMapping.InboundMappingIsRunning = true;
        sobject[] inserted = new sobject[]{ target };
        Database.SaveResult[] saveResults = Database.insert(inserted, false);
        plugin.afterInsert(inserted, saveResults);
        
        // afterInsert allows for post-processing and may not require any assertions.
        system.assert(true);
    }
    
    @istest
    private static void testAfterUpdate() {
        Mapping_ovcSapMaterialRep_Product plugin = new Mapping_ovcSapMaterialRep_Product();
        plugin.m_logger = new overcast.Logger(getExecution().Id);
        Product2 target = new Product2(Name='a');
        
        overcast.ObjectMapping.InboundMappingIsRunning = true;
        sobject[] updated = new sobject[]{ target };
        Database.SaveResult[] saveResults = Database.insert(updated, false);
        plugin.afterUpdate(updated, saveResults);
        
        // afterUpdate allows for post-processing and may not require any assertions.
        system.assert(true);
    }
    
    @istest
    private static void testLogging() {
        overcast__Run__c r = getExecution();
        Mapping_ovcSapMaterialRep_Product plugin = new Mapping_ovcSapMaterialRep_Product();
        plugin.m_logger = new overcast.Logger(r.Id);
        
        plugin.logInfo('MESSAGE');
        plugin.logWarning('WARNING');
        plugin.setStatusToWarning();
        plugin.logError('ERROR');
        plugin.logDEBUG('DEBUG');
        plugin.setStatusToError();
        plugin.saveLogs();
        
        overcast__Log__c[] logs = [SELECT Id, overcast__LogLevel__c, overcast__Message__c FROM overcast__Log__c];
        system.assert(logs.size() >= 3);
        for (overcast__Log__c l : logs) {
            if (l.overcast__LogLevel__c == 'DEBUG') {
                system.assert(false, 'DEBUG message not filtered out');
            }
        }
        system.assertEquals(400, plugin.m_logger.getStatusCode());
        overcast__Run__c r2 = [SELECT overcast__StatusCode__c FROM overcast__Run__c WHERE Id = :r.Id];
        system.assertEquals(400, r2.overcast__StatusCode__c);
    }

	@istest
    private static void testFailure() {
        Mapping_ovcSapMaterialRep_Product plugin = new Mapping_ovcSapMaterialRep_Product();
        plugin.m_logger = new overcast.Logger(getExecution().Id);
        Product2 target = new Product2();
		target.Name = 'a';
        overcast.ObjectMapping.InboundMappingIsRunning = true;
        sobject[] inserted = new sobject[]{ target };
        Database.SaveResult failed1 = (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"Inserted bad data","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION","fields":["Name"]}]}', Database.SaveResult.class);
        plugin.afterUpdate(inserted, new Database.SaveResult[]{ failed1 });
        list<overcast__Log__c> logs = plugin.m_logger.getLogs();
		system.assert(logs.size() >= 2);
        
        system.assertEquals('[Mapping_ovcSapMaterialRep_Product] Failed to save record [ID=null, Message=FIELD_CUSTOM_VALIDATION_EXCEPTION:Inserted bad data, Name=a]', logs[0].overcast__Message__c);
    }

    private static overcast__Run__c getExecution() {
        overcast__Scenario__c scen = overcast.TestingUtilities.SetupTestEnvironment('ovcSapMaterialRep');
        scen.overcast__LogLevel__c = 'INFO';
        update scen;
        overcast__Run__c r = new overcast__Run__c(overcast__Scenario__c=scen.Id, overcast__Input__c='A', overcast__Mode__c='Run', overcast__Operation__c='Read');
        insert r;
        return r;
    }
}