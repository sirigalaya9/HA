public without sharing class CommonServices {
    private static Map<String, Map<String, String>> mapLanguages;
    public static Map<String, Map<String, String>> buildMapLanguages() {
        if ( mapLanguages == null ) {
            String langSetting = Settings.LANGUAGE_MAPPING;
            System.debug('langSetting==>' + langSetting);
             
            mapLanguages = new Map<String, Map<String, String>>{
                'iso_to_sap'=> new Map<String, String>(),
                'sap_to_iso'=> new Map<String, String>()
    
            };            
            Map<String, Object> jsonObj = (Map<String, Object>) JSON.deserializeUntyped(langSetting);
            
            for (String key : jsonObj.keySet()) {
                String value = (String) jsonObj.get(key);
                mapLanguages.get('sap_to_iso').put(key, value);
                mapLanguages.get('iso_to_sap').put(value, key);                
            }        
        }
        
        return mapLanguages;
    }

    public static String getLangISOCode(String backendLangCode) {
        return buildMapLanguages().get('sap_to_iso').get(backendLangCode);
    }

    public static String getBackendLangCode(String langISOCode) {
        return buildMapLanguages().get('iso_to_sap').get(langISOCode);
    }
}