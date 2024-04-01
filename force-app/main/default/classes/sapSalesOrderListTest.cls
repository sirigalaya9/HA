/* 
 * Generated by Overcast UTC 2024-03-27 04:32:32Z.
 * Changes to this class may cause incorrect behavior and will be lost if the scenario is re-activated.
 */
@istest
private class sapSalesOrderListTest {
    @istest
    private static void testsapSalesOrderList() {
        sapSalesOrderList actual = new sapSalesOrderList();
        system.assertNotEquals(null, actual.BAPI_SALESORDER_GETLIST);
        system.assertNotEquals(null, actual.MATERIAL_EVG);
        system.assertNotEquals(null, actual.RETURN_x);
        system.assertNotEquals(null, actual.SALES_ORDERS);
        system.assertNotEquals(null, actual.EXTENSIONIN);
        system.assertNotEquals(null, actual.EXTENSIONEX);
    }

    @istest
    private static void testBAPI_SALESORDER_GETLIST() {
        sapSalesOrderList.BAPI_SALESORDER_GETLIST actual = new sapSalesOrderList.BAPI_SALESORDER_GETLIST();

        actual.CUSTOMER_NUMBER = 'a';
        actual.SALES_ORGANIZATION = 'a';
        actual.MATERIAL = 'a';
        actual.DOCUMENT_DATE = Date.newInstance(2000,1,1);
        actual.DOCUMENT_DATE_TO = Date.newInstance(2000,1,1);
        actual.PURCHASE_ORDER = 'a';
        actual.TRANSACTION_GROUP = 'a';
        actual.PURCHASE_ORDER_NUMBER = 'a';
        actual.MATERIAL_LONG = 'a';
        system.assertEquals('a', actual.CUSTOMER_NUMBER);
        system.assertEquals('a', actual.SALES_ORGANIZATION);
        system.assertEquals('a', actual.MATERIAL);
        system.assertEquals(Date.newInstance(2000,1,1), actual.DOCUMENT_DATE);
        system.assertEquals(Date.newInstance(2000,1,1), actual.DOCUMENT_DATE_TO);
        system.assertEquals('a', actual.PURCHASE_ORDER);
        system.assertEquals('a', actual.TRANSACTION_GROUP);
        system.assertEquals('a', actual.PURCHASE_ORDER_NUMBER);
        system.assertEquals('a', actual.MATERIAL_LONG);
    }
    @istest
    private static void testMATERIAL_EVG() {
        sapSalesOrderList.MATERIAL_EVG actual = new sapSalesOrderList.MATERIAL_EVG();

        actual.MATERIAL_EXT = 'a';
        actual.MATERIAL_VERS = 'a';
        actual.MATERIAL_GUID = 'a';
        system.assertEquals('a', actual.MATERIAL_EXT);
        system.assertEquals('a', actual.MATERIAL_VERS);
        system.assertEquals('a', actual.MATERIAL_GUID);
    }
    @istest
    private static void testRETURN_x() {
        sapSalesOrderList.RETURN_x actual = new sapSalesOrderList.RETURN_x();

        actual.TYPE_x = 'a';
        actual.CODE = 'a';
        actual.MESSAGE = 'a';
        actual.LOG_NO = 'a';
        actual.LOG_MSG_NO = 'a';
        actual.MESSAGE_V1 = 'a';
        actual.MESSAGE_V2 = 'a';
        actual.MESSAGE_V3 = 'a';
        actual.MESSAGE_V4 = 'a';
        system.assertEquals('a', actual.TYPE_x);
        system.assertEquals('a', actual.CODE);
        system.assertEquals('a', actual.MESSAGE);
        system.assertEquals('a', actual.LOG_NO);
        system.assertEquals('a', actual.LOG_MSG_NO);
        system.assertEquals('a', actual.MESSAGE_V1);
        system.assertEquals('a', actual.MESSAGE_V2);
        system.assertEquals('a', actual.MESSAGE_V3);
        system.assertEquals('a', actual.MESSAGE_V4);
    }
    @istest
    private static void testSALES_ORDERS() {
        sapSalesOrderList.SALES_ORDERS actual = new sapSalesOrderList.SALES_ORDERS();

        actual.SD_DOC = 'a';
        actual.ITM_NUMBER = 'a';
        actual.MATERIAL = 'a';
        actual.SHORT_TEXT = 'a';
        actual.DOC_TYPE = 'a';
        actual.DOC_DATE = Date.newInstance(2000,1,1);
        actual.REQ_QTY = 0;
        actual.REQ_DATE = Date.newInstance(2000,1,1);
        actual.PURCH_NO = 'a';
        actual.BATCH = 'a';
        actual.VALID_FROM = Date.newInstance(2000,1,1);
        actual.VALID_TO = Date.newInstance(2000,1,1);
        actual.BILL_BLOCK = 'a';
        actual.DLV_BLOCK = 'a';
        actual.SOLD_TO = 'a';
        actual.NAME = 'a';
        actual.EXCHG_RATE = 0;
        actual.DLV_QTY = 0;
        actual.BASE_UOM = 'a';
        actual.NET_PRICE = 0;
        actual.COND_P_UNT = 0;
        actual.COND_UNIT = 'a';
        actual.NET_VAL_HD = 0;
        actual.NET_VALUE = 0;
        actual.DIVISION = 'a';
        actual.DOC_STATUS = 'a';
        actual.SALES_GRP = 'a';
        actual.SALES_OFF = 'a';
        actual.SALES_ORG = 'a';
        actual.SALES_UNIT = 'a';
        actual.SHIP_POINT = 'a';
        actual.DISTR_CHAN = 'a';
        actual.GI_DATE = Date.newInstance(2000,1,1);
        actual.CURRENCY_x = 'a';
        actual.PLANT = 'a';
        actual.STORE_LOC = 'a';
        actual.ORD_REASON = 'a';
        actual.REASON_REJ = 'a';
        actual.B_UOM_ISO = 'a';
        actual.CD_UNT_ISO = 'a';
        actual.S_UNIT_ISO = 'a';
        actual.CURR_ISO = 'a';
        actual.PURCH_NO_C = 'a';
        actual.EXCHG_RATE_V = 0;
        actual.MAT_EXT = 'a';
        actual.MAT_GUID = 'a';
        actual.MAT_VERS = 'a';
        actual.CREATION_DATE = Date.newInstance(2000,1,1);
        actual.CREATION_TIME = 'a';
        actual.STATUS_DOC = 'a';
        actual.REQ_SEGMENT = 'a';
        actual.MATERIAL_LONG = 'a';
        system.assertEquals('a', actual.SD_DOC);
        system.assertEquals('a', actual.ITM_NUMBER);
        system.assertEquals('a', actual.MATERIAL);
        system.assertEquals('a', actual.SHORT_TEXT);
        system.assertEquals('a', actual.DOC_TYPE);
        system.assertEquals(Date.newInstance(2000,1,1), actual.DOC_DATE);
        system.assertEquals(0, actual.REQ_QTY);
        system.assertEquals(Date.newInstance(2000,1,1), actual.REQ_DATE);
        system.assertEquals('a', actual.PURCH_NO);
        system.assertEquals('a', actual.BATCH);
        system.assertEquals(Date.newInstance(2000,1,1), actual.VALID_FROM);
        system.assertEquals(Date.newInstance(2000,1,1), actual.VALID_TO);
        system.assertEquals('a', actual.BILL_BLOCK);
        system.assertEquals('a', actual.DLV_BLOCK);
        system.assertEquals('a', actual.SOLD_TO);
        system.assertEquals('a', actual.NAME);
        system.assertEquals(0, actual.EXCHG_RATE);
        system.assertEquals(0, actual.DLV_QTY);
        system.assertEquals('a', actual.BASE_UOM);
        system.assertEquals(0, actual.NET_PRICE);
        system.assertEquals(0, actual.COND_P_UNT);
        system.assertEquals('a', actual.COND_UNIT);
        system.assertEquals(0, actual.NET_VAL_HD);
        system.assertEquals(0, actual.NET_VALUE);
        system.assertEquals('a', actual.DIVISION);
        system.assertEquals('a', actual.DOC_STATUS);
        system.assertEquals('a', actual.SALES_GRP);
        system.assertEquals('a', actual.SALES_OFF);
        system.assertEquals('a', actual.SALES_ORG);
        system.assertEquals('a', actual.SALES_UNIT);
        system.assertEquals('a', actual.SHIP_POINT);
        system.assertEquals('a', actual.DISTR_CHAN);
        system.assertEquals(Date.newInstance(2000,1,1), actual.GI_DATE);
        system.assertEquals('a', actual.CURRENCY_x);
        system.assertEquals('a', actual.PLANT);
        system.assertEquals('a', actual.STORE_LOC);
        system.assertEquals('a', actual.ORD_REASON);
        system.assertEquals('a', actual.REASON_REJ);
        system.assertEquals('a', actual.B_UOM_ISO);
        system.assertEquals('a', actual.CD_UNT_ISO);
        system.assertEquals('a', actual.S_UNIT_ISO);
        system.assertEquals('a', actual.CURR_ISO);
        system.assertEquals('a', actual.PURCH_NO_C);
        system.assertEquals(0, actual.EXCHG_RATE_V);
        system.assertEquals('a', actual.MAT_EXT);
        system.assertEquals('a', actual.MAT_GUID);
        system.assertEquals('a', actual.MAT_VERS);
        system.assertEquals(Date.newInstance(2000,1,1), actual.CREATION_DATE);
        system.assertEquals('a', actual.CREATION_TIME);
        system.assertEquals('a', actual.STATUS_DOC);
        system.assertEquals('a', actual.REQ_SEGMENT);
        system.assertEquals('a', actual.MATERIAL_LONG);
    }
    @istest
    private static void testEXTENSIONIN() {
        sapSalesOrderList.EXTENSIONIN actual = new sapSalesOrderList.EXTENSIONIN();

        actual.STRUCTURE = 'a';
        actual.VALUEPART1 = 'a';
        actual.VALUEPART2 = 'a';
        actual.VALUEPART3 = 'a';
        actual.VALUEPART4 = 'a';
        system.assertEquals('a', actual.STRUCTURE);
        system.assertEquals('a', actual.VALUEPART1);
        system.assertEquals('a', actual.VALUEPART2);
        system.assertEquals('a', actual.VALUEPART3);
        system.assertEquals('a', actual.VALUEPART4);
    }
    @istest
    private static void testEXTENSIONEX() {
        sapSalesOrderList.EXTENSIONEX actual = new sapSalesOrderList.EXTENSIONEX();

        actual.STRUCTURE = 'a';
        actual.VALUEPART1 = 'a';
        actual.VALUEPART2 = 'a';
        actual.VALUEPART3 = 'a';
        actual.VALUEPART4 = 'a';
        system.assertEquals('a', actual.STRUCTURE);
        system.assertEquals('a', actual.VALUEPART1);
        system.assertEquals('a', actual.VALUEPART2);
        system.assertEquals('a', actual.VALUEPART3);
        system.assertEquals('a', actual.VALUEPART4);
    }

    @istest
    private static void testRun() {
        sapSalesOrderList request = testSetup();
        sapSalesOrderList response = request.run();
        system.assertEquals('a', response.BAPI_SALESORDER_GETLIST.CUSTOMER_NUMBER);
        string requestid = request.runAsync(null, null, new Continuation(10));
    }

    private static sapSalesOrderList testSetup() {
        overcast.TestingUtilities.SetupTestEnvironment('sapSalesOrderList');
        sapSalesOrderList request = new sapSalesOrderList();
        request.BAPI_SALESORDER_GETLIST.CUSTOMER_NUMBER = 'a';

        string s = request.serialize();
        request.testResponse = '{"output":' + s + '}';
        return request;
    }


    @istest
    private static void testSerialize() {
        sapSalesOrderList input = new sapSalesOrderList();
        input.BAPI_SALESORDER_GETLIST.CUSTOMER_NUMBER = 'a';
        sapSalesOrderList actual = (sapSalesOrderList)JSON.deserialize(input.serialize(), sapSalesOrderList.class);
        system.assertEquals('a', actual.BAPI_SALESORDER_GETLIST.CUSTOMER_NUMBER);
    }

    @istest
    private static void testDeserialize() {
        sapSalesOrderList output = new sapSalesOrderList();
        output.BAPI_SALESORDER_GETLIST.CUSTOMER_NUMBER = 'a';

        string s = output.serialize();
        sapSalesOrderList actual = sapSalesOrderList.deserialize('{"output":' + s + '}');
        system.assertEquals('a', actual.BAPI_SALESORDER_GETLIST.CUSTOMER_NUMBER);
    }

    @istest
    private static void testDeserializeError() {
        try {
            sapSalesOrderList actual = sapSalesOrderList.deserialize('{"error":["A test error"]}');
            system.assert(false, 'No exception thrown');
        } catch (sapSalesOrderList.sapSalesOrderListException e) {
            system.assertEquals('A test error', e.getMessage());
            system.assertEquals(0, e.getBackendMessages().size());
        }

        try {
            sapSalesOrderList actual = sapSalesOrderList.deserialize('{"error":["A test error"],"backendErrorMessages":["A test message"]}');
            system.assert(false, 'No exception thrown');
        } catch (sapSalesOrderList.sapSalesOrderListException e) {
            system.assertEquals('A test error', e.getMessage());
            system.assertEquals(1, e.getMessages().size());
            system.assertEquals('A test error', e.getMessages()[0]);
            system.assertEquals(1, e.getBackendMessages().size());
            system.assertEquals('A test message', e.getBackendMessages()[0]);
        }
    }

    @istest
    private static void testGetterSetter() {
        sapSalesOrderList output = new sapSalesOrderList();
        output.set('SAMPLE1', new map<string, object>{
            'FIELD1' => 'VALUE1'
        });
        
        system.assertEquals(null, output.get('NOVAL'));
        
        map<string, object> sample1 = (map<string, object>)output.get('SAMPLE1');
        system.assertNotEquals(null, sample1);
        system.assertEquals('VALUE1', sample1.get('FIELD1'));		
    }
    
    @istest
    private static void testLoadAsyncResponse() {
        sapSalesOrderList output = new sapSalesOrderList();
        output.loadAsyncResponse('{"output":{"SAMPLE1":{"FIELD1":"VALUE1"}}}');
        system.assertEquals(null, output.get('NOVAL'));
        map<string, object> sample1 = (map<string, object>)output.get('SAMPLE1');
        system.assertNotEquals(null, sample1);
        system.assertEquals('VALUE1', sample1.get('FIELD1'));

        overcast.Globals.IsOCF = true;
        sapSalesOrderList output2 = new sapSalesOrderList();
        output2.loadAsyncResponse('{"output":{"SAMPLE1":{"FIELD1":"VALUE1"}}}');
        overcast.Globals.IsOCF = false;
        system.assertEquals(null, output2.get('NOVAL'));
        map<string, object> sample2 = (map<string, object>)output2.get('SAMPLE1');
        system.assertNotEquals(null, sample2);
        system.assertEquals('VALUE1', sample2.get('FIELD1'));
    }

    @istest
    private static void testGetMetadata() {
        sapSalesOrderList output = new sapSalesOrderList();
        map<string, overcast.TypeInfo> metadata = output.getMetadata();
        
        set<string> keys = metadata.keySet();
        system.assert(keys.contains('BAPI_SALESORDER_GETLIST'));
        system.assert(keys.contains('MATERIAL_EVG'));
        system.assert(keys.contains('RETURN_x'));
        system.assert(keys.contains('SALES_ORDERS'));
        system.assert(keys.contains('EXTENSIONIN'));
        system.assert(keys.contains('EXTENSIONEX'));
        
        overcast.TypeInfo first = metadata.get(output.getTopTypeName());
        system.assertNotEquals(null, first);
        system.assertEquals('BAPI_SALESORDER_GETLIST', first.name);
    }

    @istest
    private static void testException() {
        sapSalesOrderList.sapSalesOrderListException e = new sapSalesOrderList.sapSalesOrderListException();
        e.setMessages(new List<String>{'M1', 'M2'});
        System.assertEquals(2, e.getMessages().size());
    }

    @istest
    private static void testErrorResponse() {
        try {
            sapSalesOrderList.deserialize('');
            System.assert(false, 'Expected exception not thrown.');
        } catch (sapSalesOrderList.sapSalesOrderListException e) {
            System.assert(true);
        }
        
        try {
            sapSalesOrderList output = new sapSalesOrderList();
            output.loadAsyncResponse('{"error":["ERROR1","ERROR2"]}');
            System.assert(false, 'Expected exception not thrown.');
        } catch (sapSalesOrderList.sapSalesOrderListException e) {
            System.assertEquals('ERROR1;ERROR2', e.getMessage());
            System.assertEquals('ERROR1', e.getMessages()[0]);
        }
        
        try {
            sapSalesOrderList output = new sapSalesOrderList();
            output.loadAsyncResponse('{"backendMessage":"TEST RESULT"}');
            System.assert(false, 'Expected exception not thrown.');
        } catch (sapSalesOrderList.sapSalesOrderListException e) {
            System.assert(true);
        }

        try {
            sapSalesOrderList output = new sapSalesOrderList();
            output.loadAsyncResponse('{"error":["ERROR1","ERROR2"],"backendErrorMessages":["A test message"]}');
            System.assert(false, 'Expected exception not thrown.');
        } catch (sapSalesOrderList.sapSalesOrderListException e) {
            System.assertEquals('ERROR1;ERROR2', e.getMessage());
            System.assertEquals(2, e.getMessages().size());
            System.assertEquals('ERROR1', e.getMessages()[0]);
            System.assertEquals('ERROR2', e.getMessages()[1]);
            System.assertEquals(1, e.getBackendMessages().size());
            System.assertEquals('A test message', e.getBackendMessages()[0]);
        }

        overcast.Globals.IsOCF = true;
        
        try {
            sapSalesOrderList.deserialize('');
            System.assert(false, 'Expected exception not thrown.');
        } catch (sapSalesOrderList.sapSalesOrderListException e) {
            System.assert(true);
        }
        
        try {
            sapSalesOrderList.deserialize('{"error":["ERROR1","ERROR2"]}');
            System.assert(false, 'Expected exception not thrown.');
        } catch (sapSalesOrderList.sapSalesOrderListException e) {
            System.assertEquals('ERROR1;ERROR2', e.getMessage());
            System.assertEquals(0, e.getBackendMessages().size());
        }

        try {
            sapSalesOrderList.deserialize('{"error":["ERROR1","ERROR2"],"backendErrorMessages":["A test message"]}');
            System.assert(false, 'Expected exception not thrown.');
        } catch (sapSalesOrderList.sapSalesOrderListException e) {
            System.assertEquals('ERROR1;ERROR2', e.getMessage());
            System.assertEquals(2, e.getMessages().size());
            System.assertEquals('ERROR1', e.getMessages()[0]);
            System.assertEquals('ERROR2', e.getMessages()[1]);
            System.assertEquals(1, e.getBackendMessages().size());
            System.assertEquals('A test message', e.getBackendMessages()[0]);
        }
    }

    @istest
    private static void testGetBackendMessage() {
        sapSalesOrderList output = new sapSalesOrderList();
        output.loadAsyncResponse('{"output":{}, "backendMessage":"TEST RESULT"}');
        system.assertEquals('TEST RESULT', output.getBackendMessage());
    }

}