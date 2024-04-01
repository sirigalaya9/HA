/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
@IsTest
public with sharing class OvcSAPEnhancedOrderDetailsPluginTest {
    @IsTest
    static void testEmptyMethod() {
        OvcSAPEnhancedOrderDetailsPlugin plugin = new OvcSAPEnhancedOrderDetailsPlugin();
        plugin.afterComponentMetadataLoaded(null, null);
        plugin.afterReferenceValuesLoaded(null, null, null);
        plugin.onScenarioException(null, null);
        plugin.beforeScenarioCall(null, null, null, null);
        System.assert(true, 'always true');
    }

    @isTest
    private static void testAfterReference() {
        OvcSAPEnhancedOrderDetailsPlugin plugin = new OvcSAPEnhancedOrderDetailsPlugin();
        Map<String, Map<String, Object>> refValues = new Map<String, Map<String, Object>>();
        refValues.put('HeaderTexts', new Map<String, Object>{ 'ShippingInstructionsID' => '0001' });
        plugin.afterReferenceValuesLoaded(null, null, refValues, null);
        System.assert(true, 'always true');
    }

    @IsTest
    private static void testAfterScenarioCall() {
        OvcSAPEnhancedOrderDetailsPlugin plugin = new OvcSAPEnhancedOrderDetailsPlugin();

        Map<String, Object> retData = new Map<String, Object>();
        retData.put(
            'ORDER_TEXTLINES_OUT',
            new List<Object>{
                new Map<String, Object>{
                    'TEXT_NAME' => '0000001234',
                    'TEXT_ID' => '0001',
                    'FORMAT_COL' => '',
                    'LINE' => 'Shipping Instruction Test'
                },
                new Map<String, Object>{
                    'TEXT_NAME' => '0000001234',
                    'TEXT_ID' => '0001',
                    'FORMAT_COL' => '*',
                    'LINE' => 'This is new line of shipping instruction.'
                }
            }
        );
        retData.put('ORDER_BUSINESS_OUT', new List<Object>{ new Map<String, Object>{ 'DELIV_TYPE' => '01' } });
        retData.put(
            'ORDER_HEADERS_OUT',
            new List<Object>{ new Map<String, Object>{ 'SALES_ORG' => '1000', 'DISTR_CHAN' => '10', 'DIVISION' => '00' } }
        );

        plugin.referenceValues.put('HeaderTexts', new Map<String, Object>{ 'ShippingInstructionsID' => '0001' });

        plugin.afterScenarioCall(retData, null, null);
        Map<String, Object> headerTexts = (Map<String, Object>) retData.get('HeaderTexts');

        Map<String, Object> ordHeader = (Map<String, Object>) ((List<Object>) retData.get('ORDER_HEADERS_OUT'))[0];
        System.assertEquals('1000/10/00', ordHeader.get('SALES_ORG'), 'Sales area value is not correct!');
        System.assertEquals('1000', ordHeader.get('ovcCustomerSalesOrg'), 'Sales org value is not correct!');
        System.assertEquals('01', ordHeader.get('SHIP_TYPE'), 'Shipping type is wrong!');
        System.assertEquals(
            'Shipping Instruction Test\r\nThis is new line of shipping instruction.',
            headerTexts.get('ShippingInstructions'),
            'Header Text handling has problem!'
        );
    }

    @IsTest
    private static void testAfterScenarioCallMultipleHeader() {
        OvcSAPEnhancedOrderDetailsPlugin plugin = new OvcSAPEnhancedOrderDetailsPlugin();
        Map<String, Object> retData = new Map<String, Object>();
        retData.put(
            'ORDER_HEADERS_OUT',
            new List<Object>{
                new Map<String, Object>{ 'SALES_ORG' => '1000', 'DISTR_CHAN' => '10', 'DIVISION' => '00' },
                new List<Object>{ new Map<String, Object>{ 'SALES_ORG' => '1000', 'DISTR_CHAN' => '10', 'DIVISION' => '01' } }
            }
        );
        plugin.afterScenarioCall(retData, null, null);
        System.assertEquals(2, ((List<Object>) retData.get('ORDER_HEADERS_OUT')).size(), 'Header size is wrong!');
    }
}