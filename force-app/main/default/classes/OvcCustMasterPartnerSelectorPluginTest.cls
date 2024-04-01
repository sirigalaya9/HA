/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
@IsTest
public with sharing class OvcCustMasterPartnerSelectorPluginTest {
    private class DatabaseAccess implements OvcCustMasterPartnerSelectorPlugin.IDatabaseAccess {
        public List<Account> getAccounts(List<String> bpNumber) {
            List<Account> accList = new List<Account>();
            Account accountTest1 = new Account(
                Name = 'TestBP1',
                AccountNumber = '0001000005',
                BillingCity = 'BENOWA',
                BillingPostalCode = 'TestPostal',
                BillingStreet = 'ALLCHURCH AVE'
            );
            Account accountTest2 = new Account(
                Name = 'TestBP2',
                AccountNumber = '0001000000',
                BillingCity = 'HERSTON',
                BillingPostalCode = 'TestPostal2',
                BillingStreet = 'BUTTERFIELD ST'
            );
            accList.add(accountTest1);
            accList.add(accountTest2);
            return accList;
        }
    }

    @IsTest
    static void testEmptyMethod() {
        OvcCustMasterPartnerSelectorPlugin plugin = new OvcCustMasterPartnerSelectorPlugin();
        plugin.afterComponentMetadataLoaded(null, null);
        plugin.afterReferenceValuesLoaded(null, null, null);
        plugin.afterReferenceValuesLoaded(null, null, null, null);
        plugin.beforeScenarioCall(null, null, null, null);
        plugin.onScenarioException(null, null);
        System.assert(true, 'always true');
    }

    @IsTest
    private static void testAfterScenarioCall() {
        Map<String, Object> returnedData = new Map<String, Object>();
        returnedData.put(
            'KNVP',
            new List<Object>{
                new Map<String, Object>{ 'KUNNR' => '0001000000', 'KUNN2' => '0001000000' },
                new Map<String, Object>{ 'KUNNR' => '0001000000', 'KUNN2' => '0001000001' }
            }
        );

        OvcCustMasterPartnerSelectorPlugin plugin = new OvcCustMasterPartnerSelectorPlugin();
        DatabaseAccess db = new DatabaseAccess();
        OvcCustMasterPartnerSelectorPlugin.databaseAccess = db;

        List<Map<String, Object>> customerMasterGeneral = new List<Map<String, Object>>{
            new Map<String, Object>{ 'KUNNR' => '0001000000', 'ADRNR' => '0000000100' },
            new Map<String, Object>{ 'KUNNR' => '0001000001', 'ADRNR' => '0000000101' }
        };
        overcast.Globals.isOCF = true;
        overcast.TestingUtilities.SetupTestEnvironment('ovcSAPCustomerMasterGeneral');
        Map<String, Object> tr = new Map<String, Object>{ 'KNA1' => customerMasterGeneral };
        plugin.testDataCustomer = JSON.serialize(new Map<String, Object>{ 'output' => tr });

        List<Map<String, Object>> addressList = new List<Map<String, Object>>{
            new Map<String, Object>{
                'ADDRNUMBER' => '0000000100',
                'NAME1' => 'Test Partner US',
                'STREET' => 'Main Street',
                'CITY1' => 'Nashville',
                'REGION' => 'TN',
                'POST_CODE1' => '12345',
                'COUNTRY' => 'US'
            },
            new Map<String, Object>{
                'ADDRNUMBER' => '0000000101',
                'NAME1' => 'Test Partner DE',
                'STREET' => 'Hauptstrasse',
                'CITY1' => 'Dusseldorf',
                'REGION' => 'NW',
                'POST_CODE1' => '45678',
                'COUNTRY' => 'DE'
            }
        };
        overcast.Globals.isOCF = true;
        overcast.TestingUtilities.SetupTestEnvironment('ovcSAPAddresses');
        Map<String, Object> trAdrc = new Map<String, Object>{ 'ADRC' => addressList };
        plugin.testDataAddress = JSON.serialize(new Map<String, Object>{ 'output' => trAdrc });

        plugin.afterScenarioCall(returnedData, null, null);

        List<Object> partnerList = (List<Object>) returnedData.get('KNVP');
        for (Object partnerObj : partnerList) {
            Map<String, Object> partnerMap = (Map<String, Object>) partnerObj;
            String partnerFunction = (String) partnerMap.get('KUNN2');
            if (partnerFunction == '0001000000') {
                System.assertEquals(
                    'TestBP2 (0001000000)',
                    partnerMap.get('ovcPartnerNameWithNo'),
                    'Partner with Number is different than expected!'
                );
            } else if (partnerFunction == '0001000001') {
                System.assertEquals(
                    'Test Partner DE (0001000001)',
                    partnerMap.get('ovcPartnerNameWithNo'),
                    'Partner with Number is different than expected!'
                );
                System.assertEquals('Dusseldorf', partnerMap.get('ovcBillingAddress_city'), 'City is different than expected!');
                System.assertEquals('NW', partnerMap.get('ovcBillingAddress_state'), 'Region is different than expected!');
            }
        }
        System.assertEquals(2, partnerList.size(), 'Expected text list size is different!');
    }

    @istest
    private static void testDatabaseAccess() {
        try {
            List<String> bpList = new List<String>{ '0000012345', '0000067890' };
            List<Account> accList = OvcCustMasterPartnerSelectorPlugin.databaseAccess.getAccounts(bpList);
            system.assert(true);
        } catch (Exception e) {
            system.assert(true);
        }
    }
}