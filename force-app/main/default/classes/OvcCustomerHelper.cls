/*
 * Copyright © 2019 Vigience Co., Ltd. All Rights Reserved
 *
 * SAP Customer Replication Utility
 */
public with sharing class OvcCustomerHelper {
    @SuppressWarnings('PMD.AvoidDebugStatements')

    public class ExecuteScenarioQueue implements Queueable {
        @TestVisible
        private String scenario;
        @TestVisible
        private String inputSet;
        @TestVisible
        private overcast.EpgwWebServices.Operation operation;

        public ExecuteScenarioQueue(String scen, String input) {
            this.scenario = scen;
            this.inputSet = input;
            this.operation = overcast.EpgwWebServices.Operation.EpgwRead;
        }

        public ExecuteScenarioQueue(String scen, String input, overcast.EpgwWebServices.Operation ope) {
            this.scenario = scen;
            this.inputSet = input;
            this.operation = ope;
        }

        public void execute(QueueableContext context) {
            overcast.EpgwWebServices.EpgwWebServiceResult res = overcast.EpgwWebServices.ExecuteScenario(scenario, overcast.EpgwWebServices.Action.Populate, operation, inputSet);
            
            System.debug(LoggingLevel.INFO, res);
        }

    }
}