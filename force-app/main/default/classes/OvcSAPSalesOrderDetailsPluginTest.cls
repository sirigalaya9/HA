@isTest
global with sharing class OvcSAPSalesOrderDetailsPluginTest {
    @isTest
    global static void testPlugin() 
    {
    	overcast.Globals.isOCF = true;
        OvcSAPSalesOrderDetailsPlugin plugin = new OvcSAPSalesOrderDetailsPlugin();
        plugin.beforeScenarioCall(null, null,null,null);

        Map<String,Object> returndata = new Map<String,Object>{
            'ORDER_HEADERS_OUT' => new List<Object> {
                new Map<String,Object>{
                    'SD_PRIC_PR' => 'TEST'
                }
            },
            'ORDER_CONDITIONS_OUT' => new List<Object>{
                new Map<String,Object>{
                    'COND_ST_NO' => 'TEST',
                    'CALCTYPCON' => 'A'
                }
            }
        };
        plugin.testResponse = JSON.serialize(new Map<String, Object>{ 'output' => new Map<String, Object>{
            'T683T' => new List<Object>{
              new Map<String, Object>{ 'STUNR' => 'TEST', 'VTEXT' => 'TEST MESSAG' }
            }}});
        overcast.TestingUtilities.SetupTestEnvironment('ovcSAPConditionTypeText');
        Map<String,Object> settings = new Map<String,Object> {
            'ConditionCalclateTypeMap' => JSON.serialize(new Map<String, Object>{ 'A' => '%' })
        };
        plugin.afterScenarioCall(returndata, null, settings);

        List<Object> condOut = (List<Object>)returndata.get('ORDER_CONDITIONS_OUT');
        Map<String,Object> condMap = (Map<String,Object>)condOut[0];
        System.assertEquals('TEST MESSAG', condMap.get('ovcCondText'), 'should convert cond text');
        System.assertEquals('%', condMap.get('ovcCalcType'), 'should convert calc type');
    }
}