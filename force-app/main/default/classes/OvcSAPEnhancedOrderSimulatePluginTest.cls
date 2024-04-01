/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
@isTest
public with sharing class OvcSAPEnhancedOrderSimulatePluginTest {
    @IsTest
    static void testEmptyMethod() {
        OvcSAPEnhancedOrderSimulatePlugin plugin = new OvcSAPEnhancedOrderSimulatePlugin();
        plugin.afterComponentMetadataLoaded(null, null);
        plugin.afterReferenceValuesLoaded(null, null, null);
        plugin.afterReferenceValuesLoaded(null, null, null, null);
        plugin.onScenarioException(null, null);
        System.assert(true, 'always true');
    }

    @IsTest
    private static void pluginBeforeScenarioCall() {
        OvcSAPEnhancedOrderSimulatePlugin plugin = new OvcSAPEnhancedOrderSimulatePlugin();
        //Request Data
        Map<String, Object> inp = new Map<String, Object>{
            'ORDER_HEADER_IN' => new Map<String, Object>{ 'SALES_ORG' => '1710/10/00' },
            'ocf_PARTNERS' => new Map<String, Object>{
                'ocf_SHIPTO' => '0001000000',
                'ocf_SOLDTO' => '0001000000',
                'ocf_BILLTO' => '0001000001',
                'ocf_Payer' => '0001000001'
            }
        };
        Map<String, Object> orderHeader = new Map<String, Object>{ 'SALES_ORG' => '', 'DISTR_CHAN' => '', 'DIVISION' => '' };
        Map<String, Object> importParameters = new Map<String, Object>();

        importParameters.put('ORDER_HEADER_IN', orderHeader);
        importParameters.put('ocf_PageData', inp);

        Map<String, Object> referenceFieldValues = new Map<String, Object>();
        referenceFieldValues.put('ORDER_PARTNERS', new List<Object>{ new Map<String, Object>{ 'PARTN_ROLE' => 'SH', 'PARTN_NUMB' => '0001000005' } });

        plugin.beforeScenarioCall(null, referenceFieldValues, importParameters, null);

        Map<String, Object> ordHeader = (Map<String, Object>) importParameters.get('ORDER_HEADER_IN');
        List<Object> orderPartnerList = (List<Object>) importParameters.get('ORDER_PARTNERS');
        System.assertEquals(4, orderPartnerList.size(), 'Order Partner size is not 1!');
        System.assertEquals('1710', ordHeader.get('SALES_ORG'), 'Sales org. is not 1710');
        System.assertEquals('10', ordHeader.get('DISTR_CHAN'), 'Sales org. is not 1710');
        System.assertEquals('00', ordHeader.get('DIVISION'), 'Sales org. is not 1710');
    }

    @IsTest
    private static void pluginBeforeScenarioCallPrevPartner() {
        OvcSAPEnhancedOrderSimulatePlugin plugin = new OvcSAPEnhancedOrderSimulatePlugin();
        Map<String, Object> ovcSalesAreaMap = new Map<String, Object>{ 'SALES_ORG' => '1710', 'DISTR_CHAN' => '20', 'DIVISION' => '00' };
        //Request Data
        Map<String, Object> inp = new Map<String, Object>{
            'ORDER_HEADER_IN' => new Map<String, Object>{ 'SALES_ORG' => '1710/10/00', 'ovcSalesAreaKey' => JSON.serialize(ovcSalesAreaMap) },
            'ocf_PARTNERS' => new Map<String, Object>{
                'ocf_SHIPTO' => '0001000000',
                'ocf_SOLDTO' => '0001000000',
                'ocf_BILLTO' => '0001000001',
                'ocf_Payer' => '0001000001'
            }
        };
        Map<String, Object> orderHeader = new Map<String, Object>{
            'SALES_ORG' => '',
            'DISTR_CHAN' => '',
            'DIVISION' => '',
            'SALES_GRP' => '100',
            'SALES_OFF' => '1000'
        };
        Map<String, Object> importParameters = new Map<String, Object>();

        importParameters.put('ORDER_HEADER_IN', orderHeader);
        importParameters.put('ocf_PageData', inp);

        Map<String, Object> referenceFieldValues = new Map<String, Object>();
        referenceFieldValues.put('ORDER_PARTNERS', new List<Object>{ new Map<String, Object>{ 'PARTN_ROLE' => 'SH', 'PARTN_NUMB' => '0001000005' } });

        plugin.beforeScenarioCall(null, referenceFieldValues, importParameters, null);

        Map<String, Object> ordHeader = (Map<String, Object>) importParameters.get('ORDER_HEADER_IN');
        System.assertEquals(null, ordHeader.get('SALES_GRP'), 'Sales group is not removed!');
        System.assertEquals(null, ordHeader.get('SALES_OFF'), 'Sales office is not removed!');
    }

    @IsTest
    private static void pluginAfterScenarioCall() {
        OvcSAPEnhancedOrderSimulatePlugin plugin = new OvcSAPEnhancedOrderSimulatePlugin();
        Map<String, Object> returnedData = new Map<String, Object>();

        returnedData.put(
            'ORDER_HEADER_IN',
            new Map<String, Object>{
                'SALES_ORG' => '1710',
                'DISTR_CHAN' => '10',
                'DIVISION' => '00',
                'INCOTERMS1' => '',
                'INCOTERMS2L' => '',
                'SALES_DIST' => 'US000001',
                'SALES_OFF' => '',
                'SALES_GRP' => ''
            }
        );
        returnedData.put(
            'SOLD_TO_PARTY',
            new Map<String, Object>{
                'SOLD_TO' => '0001000005',
                'INCOTERMS1' => 'CFR',
                'INCOTERMS2L' => 'Test Incoterms',
                'SALES_DIST' => 'US000001',
                'SALES_OFF' => '170',
                'SALES_GRP' => '170'
            }
        );
        returnedData.put(
            'ORDER_PARTNERS',
            new List<Object>{
                new Map<String, Object>{ 'PARTN_ROLE' => 'SH', 'PARTN_NUMB' => '0001000004' },
                new Map<String, Object>{ 'PARTN_ROLE' => 'BP', 'PARTN_NUMB' => '0001000004' },
                new Map<String, Object>{ 'PARTN_ROLE' => 'PY', 'PARTN_NUMB' => '0001000004' }
            }
        );

        List<Map<String, Object>> custMasterPartnerList = new List<Map<String, Object>>{
            new Map<String, Object>{ 'PARVW' => 'WE', 'KUNN2' => '0001000001', 'DEFPA' => '' },
            new Map<String, Object>{ 'PARVW' => 'RE', 'KUNN2' => '0001000001', 'DEFPA' => 'X' },
            new Map<String, Object>{ 'PARVW' => 'RG', 'KUNN2' => '0001000002', 'DEFPA' => 'X' },
            new Map<String, Object>{ 'PARVW' => 'RG', 'KUNN2' => '0001000001', 'DEFPA' => '' }
        };
        overcast.Globals.isOCF = true;
        overcast.TestingUtilities.SetupTestEnvironment('ovcSAPCustomerMasterPartner');
        Map<String, Object> tr = new Map<String, Object>{ 'KNVP' => custMasterPartnerList };
        plugin.testData = JSON.serialize(new Map<String, Object>{ 'output' => tr });
        plugin.afterScenarioCall(returnedData, null, null);

        Map<String, Object> ordHeader = (Map<String, Object>) returnedData.get('ORDER_HEADER_IN');
        System.assertEquals('CFR', ordHeader.get('INCOTERMS1'), 'Incoterms is wrong!');
        System.assertEquals('Test Incoterms', ordHeader.get('INCOTERMS2L'), 'Incoterms location is wrong!');
        System.assertEquals('170', ordHeader.get('SALES_OFF'), 'Sales office is not 170!');
    }

    @isTest
    private static void pluginAfterScenarioCallSamePartner() {
        OvcSAPEnhancedOrderSimulatePlugin plugin = new OvcSAPEnhancedOrderSimulatePlugin();
        Map<String, Object> returnedData = new Map<String, Object>();

        returnedData.put(
            'ORDER_HEADER_IN',
            new Map<String, Object>{
                'SALES_ORG' => '1710',
                'DISTR_CHAN' => '10',
                'DIVISION' => '00',
                'INCOTERMS1' => '',
                'INCOTERMS2L' => '',
                'SALES_DIST' => 'US000001',
                'SALES_OFF' => '',
                'SALES_GRP' => ''
            }
        );
        returnedData.put(
            'SOLD_TO_PARTY',
            new Map<String, Object>{
                'SOLD_TO' => '0001000005',
                'INCOTERMS1' => 'CFR',
                'INCOTERMS2L' => 'Test Incoterms',
                'SALES_DIST' => 'US000001',
                'SALES_OFF' => '170',
                'SALES_GRP' => '170'
            }
        );
        returnedData.put(
            'ORDER_PARTNERS',
            new List<Object>{
                new Map<String, Object>{ 'PARTN_ROLE' => 'SP', 'PARTN_NUMB' => '0001000005' },
                new Map<String, Object>{ 'PARTN_ROLE' => 'SH', 'PARTN_NUMB' => '0001000004' },
                new Map<String, Object>{ 'PARTN_ROLE' => 'BP', 'PARTN_NUMB' => '0001000004' },
                new Map<String, Object>{ 'PARTN_ROLE' => 'PY', 'PARTN_NUMB' => '0001000004' }
            }
        );

        plugin.soldToPrev = '0001000005';
        plugin.afterScenarioCall(returnedData, null, null);

        List<Object> ordPartnerList = (List<Object>) returnedData.get('ORDER_PARTNERS');
        for (Object ordPartnerObj : ordPartnerList) {
            Map<String, Object> ordPartnerMap = (Map<String, Object>) ordPartnerObj;
            if ((String) ordPartnerMap.get('PARTN_ROLE') == 'BP') {
                System.assertEquals('0001000004', (String) ordPartnerMap.get('PARTN_NUMB'), 'Partner number is not expected!');
            }
        }
        System.assertEquals(4, ordPartnerList.size(), 'Partner number is different than 4!');
    }
}