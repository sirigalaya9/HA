public without sharing class Settings {
    private static Map<String, String> configInstance;
    public static Map<String, String> getConfigs() {
        if ( configInstance == null ) {
            configInstance = new Map<String, String>();
            for ( Admin_Settings__mdt config : [select id, DeveloperName, Value__c from Admin_Settings__mdt] ) {
                configInstance.put(config.DeveloperName, config.Value__c);
            }          
        }    
        
        return  configInstance;   
    }
    public static String LANGUAGE_MAPPING {
        get {
            LANGUAGE_MAPPING = getConfigs().containsKey('Language_Mapping')? (getConfigs().get('Language_Mapping')) : '';
            return LANGUAGE_MAPPING;
        }

        set;
    }

    public static String INTEGRATION_USER {
        get {
            INTEGRATION_USER = getConfigs().containsKey('Integration_User')? (getConfigs().get('Integration_User')) : '';
            return INTEGRATION_USER;
        }

        set;
    }
}