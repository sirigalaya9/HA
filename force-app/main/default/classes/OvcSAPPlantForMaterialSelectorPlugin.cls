/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
/*
 * OvcSAPPlantForMaterialSelectorPlugin is used by the Overcast Component ovcSAPPlantForMaterialSelector.
 * It is used to display avaiable plants for material.
 */

@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OvcSAPPlantForMaterialSelectorPlugin implements overcast.ComponentPluginV3 {
    @TestVisible
    private Map<String, Object> refValues = new Map<String, Object>();
    @TestVisible
    private String testData;

    global OvcSAPPlantForMaterialSelectorPlugin() {
        return;
    }

    global void afterComponentMetadataLoaded(Id recordId, overcast.ComponentDefinition.Component cmp) {
        return;
    }

    global void afterReferenceValuesLoaded(Id recordId, String componentName, Map<String, Map<String, Object>> referenceValues) {
        return;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    global void afterReferenceValuesLoaded(
        Id recordId,
        String componentName,
        Map<String, Map<String, Object>> referenceValues,
        Map<String, List<Map<String, Object>>> referenceChildValues
    ) {
        return;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    global void beforeScenarioCall(
        Id recordId,
        Map<String, Object> referenceFieldValues,
        Map<String, Object> importParameters,
        Map<String, Object> settings
    ) {
        Map<String, Object> plantForMaterialMap = (Map<String, Object>) importParameters.get('MARC');
        plantForMaterialMap.remove('ovcPlantDescLanguage');
        this.refValues.putAll(referenceFieldValues);
        referenceFieldValues.clear();
    }

    global void afterScenarioCall(Map<String, Object> returnedData, overcast.ComponentDefinition.Component cmp, Map<String, Object> settings) {
        List<Object> materialPlantList = (List<Object>) returnedData.get('MARC');
        Set<String> matPlants = new Set<String>();
        for (Object materialPlantObj : materialPlantList) {
            Map<String, Object> materialPlant = (Map<String, Object>) materialPlantObj;
            String matPlant = (String) materialPlant.get('WERKS');
            matPlants.add(matPlant);
        }
        if (!matPlants.isEmpty()) {
            Map<String, Object> plantDescMap = (Map<String, Object>) this.refValues.get('MARC');
            String plantDescLang = (String) plantDescMap.get('ovcPlantDescLanguage');
            Map<String, String> plantTextMap = getPlantText(matPlants, plantDescLang);
            for (Object materialPlantObj : materialPlantList) {
                Map<String, Object> materialPlant = (Map<String, Object>) materialPlantObj;
                String matPlant = (String) materialPlant.get('WERKS');
                String plantText = plantTextMap.get(matPlant);
                materialPlant.put('ovcPlantText', plantText);
                materialPlant.put('ovcPlantTextWithId', plantText + ' (' + matPlant + ')');
            }
        }
    }

    global Boolean onScenarioException(Exception ex, Map<String, Object> retData) {
        return true;
    }

    @TestVisible
    private Map<String, String> getPlantText(Set<String> plants, String plantDescLang) {
        Map<String, String> plantTextMap = new Map<String, String>();
        if (plants == null) {
            return plantTextMap;
        }

        ovcSAPPlantData request = new ovcSAPPlantData();
        overcast.Predicate pred = new overcast.Predicate();
        pred.type = overcast.Predicate.FilterType.AND1;
        pred.add(new overcast.Predicate('WERKS', overcast.Predicate.FilterType.IN1, plants));
        overcast.Query q = new overcast.Query();
        q.where_x = pred;
        if (testData != null) {
            request.testResponse = testData;
        }

        ovcSAPPlantData respObj = request.runQuery(q, null, null);
        List<Object> plantDataList = (List<Object>) respObj.get('T001W');

        for (Object plantData : plantDataList) {
            Map<String, Object> plantDataMap = (Map<String, Object>) plantData;
            String plantName = (String) plantDataMap.get('NAME1');
            String plantCode = (String) plantDataMap.get('WERKS');
            plantTextMap.put(plantCode, plantName);
        }
        return plantTextMap;
    }
}