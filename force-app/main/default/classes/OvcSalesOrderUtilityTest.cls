/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
@isTest
public with sharing class OvcSalesOrderUtilityTest {
    @isTest
    private static void setOrderHeaderTextTest() {
        Map<String, Object> inpParams = new Map<String, Object>{
            'HeaderTexts' => new Map<String, Object>{
                'SalesNoteforCustomer' => 'TestTextSalesNoteforCustomer',
                'SalesNoteforCustomerID' => 'TX02',
                'ShippingInstructions' => 'Shipping Instructions Test',
                'ShippingInstructionsID' => 'TX03',
                'BillingNote' => 'Shipping Instructions Test',
                'HeaderTextLanguage' => 'EN'
            }
        };

        OvcSalesOrderUtility.setOrderHeaderText(inpParams);

        List<Object> orderTextList = (List<Object>) inpParams.get('ORDER_TEXT');
        for (Object orderText : orderTextList) {
            Map<String, Object> orderTextMap = (Map<String, Object>) orderText;
            if ('TX02' == (String) orderTextMap.get('TEXT_ID')) {
                String textLineTest = (String) orderTextMap.get('TEXT_LINE');
                System.assertEquals('TestTextSalesNoteforCustomer', textLineTest, 'Text line is different than expected!');
            }
        }
        System.assertEquals(2, orderTextList.size(), 'List size is different than 2!');
    }

    @isTest
    private static void setReturnMessagesTest() {
        Map<String, Object> retMessage1 = new Map<String, Object>{
            'TYPE_x' => 'S',
            'MESSAGE_V1' => 'KONVKOM',
            'NUMBER_x' => '233',
            'ID' => 'V4',
            'MESSAGE' => 'Test message 1'
        };

        Map<String, Object> retMessage2 = new Map<String, Object>{
            'TYPE_x' => 'S',
            'MESSAGE_V1' => 'VBAPKOM',
            'NUMBER_x' => '233',
            'ID' => 'V4',
            'MESSAGE' => 'Test message 2'
        };

        Map<String, Object> warningMessage = new Map<String, Object>{
            'TYPE_x' => 'W',
            'MESSAGE_V1' => 'VBAPKOM',
            'NUMBER_x' => '233',
            'ID' => 'V4',
            'MESSAGE' => 'Header warning!'
        };

        Map<String, Object> retMessage3 = new Map<String, Object>{
            'TYPE_x' => 'S',
            'MESSAGE_V1' => 'TESTMESSAGE',
            'NUMBER_x' => '311',
            'ID' => 'V1',
            'MESSAGE' => 'Sales order succesfully created!'
        };

        List<Object> retDataMessage = new List<Object>{ retMessage1, retMessage2, retMessage3, warningMessage };
        Map<String, Object> retData = new Map<String, Object>{ 'RETURN_x' => retDataMessage };

        OvcSalesOrderUtility.setReturnMessages(retData);

        List<Object> retDataMessageList = (List<Object>) retData.get('RETURN_x');
        for (Object retDataMessageObj : retDataMessageList) {
            Map<String, Object> retDataMessageMap = (Map<String, Object>) retDataMessageObj;
            String retType = (String) retDataMessageMap.get('TYPE_x');
            if ('S' == retType) {
                String successMsg = (String) retDataMessageMap.get('MESSAGE');
                System.assertEquals('Sales order succesfully created!', successMsg, 'The message is not expected!');
            } else if ('W' == retType) {
                String warningMsg = (String) retDataMessageMap.get('MESSAGE');
                System.assertEquals('Header warning!', warningMsg, 'The message is not expected!');
            }
        }
        System.assertEquals(2, retDataMessageList.size(), 'The message not removed as expected!');
    }

    @isTest
    private static void setTextWithIdTest() {
        Map<String, Object> retLine1 = new Map<String, Object>{ 'VTWEG' => '10', 'VTEXT' => 'Test Chan. ABC' };

        Map<String, Object> retLine2 = new Map<String, Object>{ 'VTWEG' => '20', 'VTEXT' => 'Test Chan. DEF' };

        List<Object> retDataFieldWithIds = new List<Object>{ retLine1, retLine2 };
        Map<String, Object> retData = new Map<String, Object>{ 'TVTWT' => retDataFieldWithIds };

        OvcSalesOrderUtility.setTextWithId(retData, 'TVTWT', 'VTWEG', 'VTEXT', 'ovcDistChanDescWithID');

        List<Object> retDataList = (List<Object>) retData.get('TVTWT');
        for (Object retDataObj : retDataList) {
            Map<String, Object> retDataMap = (Map<String, Object>) retDataObj;
            String testValue = (String) retDataMap.get('VTWEG');
            if (testValue == '10') {
                String descWithId = (String) retDataMap.get('ovcDistChanDescWithID');
                System.assertEquals('Test Chan. ABC (10)', descWithId, 'Field with Id value is wrong!');
            }
        }
        System.assertEquals(2, retDataList.size(), 'The number of lines is wrong!');
    }
}