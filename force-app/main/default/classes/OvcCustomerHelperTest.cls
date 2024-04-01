/*
 * Copyright © 2019 Vigience Co., Ltd. All Rights Reserved
 *
 * SAP Customer Replication Utility Test
 */
@istest
public with sharing class OvcCustomerHelperTest {

    @istest
    private static void testExecuteScenarioQueue() {
        string scenarioName = 'sapCustomerReplication';
        overcast__Scenario__c scen = overcast.TestingUtilities.SetupTestEnvironment(scenarioName);
        boolean isSuccess;
        overcast.EpgwWebServices.Operation ope;

        Test.startTest();
        try {
            OvcCustomerHelper.ExecuteScenarioQueue request = new OvcCustomerHelper.ExecuteScenarioQueue(scenarioName, 'testInput');
            request.execute(null);
            isSuccess = true;
            ope = request.operation;
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
        System.assertEquals(overcast.EpgwWebServices.Operation.EpgwRead, ope);
    }

    @istest
    private static void testExecuteScenarioQueue2() {
        string scenarioName = 'sapCustomerReplication';
        overcast__Scenario__c scen = overcast.TestingUtilities.SetupTestEnvironment(scenarioName);
        boolean isSuccess;
        overcast.EpgwWebServices.Operation ope;

        Test.startTest();
        try {
            OvcCustomerHelper.ExecuteScenarioQueue request = new OvcCustomerHelper.ExecuteScenarioQueue(scenarioName, 'testInput', overcast.EpgwWebServices.Operation.EpgwCreate);
            request.execute(null);
            isSuccess = true;
            ope = request.operation;
        } catch(Exception e) {
            isSuccess = false;
        }
        Test.stopTest();

        System.assertEquals(true, isSuccess);
        System.assertEquals(overcast.EpgwWebServices.Operation.EpgwCreate, ope);
    }
}