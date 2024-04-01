/*
 * Copyright © 2022 Vigience Co., Ltd. All Rights Reserved
 */
/*
 * OvcCustMasterPartnerSelectorPlugin is used by the Overcast Component ovcCustMasterPartnerSelector.
 * It is used to display partner name and address information using replicated accounts.
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class OvcCustMasterPartnerSelectorPlugin implements overcast.ComponentPluginV3 {
    @TestVisible
    private String testDataCustomer;
    @TestVisible
    private String testDataAddress;
    global OvcCustMasterPartnerSelectorPlugin() {
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
        return;
    }

    global void afterScenarioCall(Map<String, Object> returnedData, overcast.ComponentDefinition.Component cmp, Map<String, Object> settings) {
        List<Object> partnerList = (List<Object>) returnedData.get('KNVP');
        if (partnerList.isEmpty()) {
            return;
        }
        List<String> funcPartnerList = new List<String>();
        for (Object partnerObj : partnerList) {
            Map<String, Object> partnerMap = (Map<String, Object>) partnerObj;
            String funcPartnerCode = (String) partnerMap.get('KUNN2');
            funcPartnerList.add(funcPartnerCode);
        }

        Map<String, List<Account>> bpMap = new Map<String, List<Account>>();
        List<Account> accList = databaseAccess.getAccounts(funcPartnerList);
        for (Account acc : accList) {
            if (!bpMap.containsKey(acc.AccountNumber)) {
                bpMap.put(acc.AccountNumber, new List<Account>());
            }
            bpMap.get(acc.AccountNumber).add(acc);
        }
        removeReplicatedAccounts(funcPartnerList, bpMap.keyset());
        Map<String, Map<String, Object>> addressInfoMap = new Map<String, Map<String, Object>>();
        if (funcPartnerList.size() > 0) {
            Map<String, String> customerAddresses = getCustomerAddressNumberRT(funcPartnerList);
            if (!customerAddresses.isEmpty()) {
                addressInfoMap = getCustomerAddressWithRT(customerAddresses);
            }
        }

        for (Object partnerObj : partnerList) {
            Map<String, Object> partnerMap = (Map<String, Object>) partnerObj;
            String bpCode = (String) partnerMap.get('KUNN2');
            if (bpMap.containsKey(bpCode)) {
                Account acc = bpMap.get(bpCode)[0];
                partnerMap.put('ovcPartnerName', acc.Name);
                partnerMap.put('ovcPartnerNameWithNo', acc.Name + ' (' + bpCode + ')');
                System.Address addr = (System.Address) acc.BillingAddress;
                if (addr != null) {
                    partnerMap.put('ovcBillingAddress_street', addr.street);
                    partnerMap.put('ovcBillingAddress_city', addr.city);
                    partnerMap.put('ovcBillingAddress_state', addr.state);
                    partnerMap.put('ovcBillingAddress_postalCode', addr.postalcode);
                    partnerMap.put('ovcBillingAddress_country', addr.country);
                }
            } else {
                Map<String, Object> partnerAddressMapRT = addressInfoMap.get(bpCode);
                String partnerName = (String) partnerAddressMapRT.get('NAME1');
                partnerMap.put('ovcPartnerName', partnerName);
                partnerMap.put('ovcPartnerNameWithNo', partnerName + ' (' + bpCode + ')');
                partnerMap.put('ovcBillingAddress_street', (String) partnerAddressMapRT.get('STREET'));
                partnerMap.put('ovcBillingAddress_city', (String) partnerAddressMapRT.get('CITY1'));
                partnerMap.put('ovcBillingAddress_state', (String) partnerAddressMapRT.get('REGION'));
                partnerMap.put('ovcBillingAddress_postalCode', (String) partnerAddressMapRT.get('POST_CODE1'));
                partnerMap.put('ovcBillingAddress_country', (String) partnerAddressMapRT.get('COUNTRY'));
            }
        }
    }

    global Boolean onScenarioException(Exception ex, Map<String, Object> retData) {
        return true;
    }

    //DatabaseAccess interface implementation
    @TestVisible
    private static IDatabaseAccess databaseAccess {
        get {
            // prettier-ignore
            return databaseAccess == null ? (databaseAccess = new DatabaseAccess()) : databaseAccess;
        }
        set {
            databaseAccess = value;
        }
    }
    @TestVisible
    private interface IDatabaseAccess {
        List<Account> getAccounts(List<String> bpNumber);
    }

    private with sharing class DatabaseAccess implements IDatabaseAccess {
        public List<Account> getAccounts(List<String> bpNumber) {
            List<Account> accounts = new List<Account>();
            if (bpNumber != null) {
                accounts = [SELECT AccountNumber, Name, BillingAddress FROM Account WHERE AccountNumber IN :bpNumber WITH SECURITY_ENFORCED];
            }
            for (Integer i = accounts.size() - 1; i >= 0; i--) {
                System.Address addr = (System.Address) accounts[i].BillingAddress;
                if (addr == null) {
                    accounts.remove(i);
                }
            }
            return accounts;
        }
    }

    @TestVisible
    private Map<String, String> getCustomerAddressNumberRT(List<String> customerNumbers) {
        Map<String, String> customerAddressMap = new Map<String, String>();
        if (customerNumbers == null) {
            return customerAddressMap;
        }
        ovcSAPCustomerMasterGeneral request = new ovcSAPCustomerMasterGeneral();
        overcast.Predicate pred = new overcast.Predicate();
        pred.type = overcast.Predicate.FilterType.AND1;
        pred.add(new overcast.Predicate('KUNNR', overcast.Predicate.FilterType.IN1, new Set<String>(customerNumbers)));

        overcast.Query q = new overcast.Query();
        q.where_x = pred;
        if (testDataCustomer != null) {
            request.testResponse = testDataCustomer;
        }
        ovcSAPCustomerMasterGeneral respObj = request.runQuery(q, null, null);
        List<Object> customerMasterList = (List<Object>) respObj.get('KNA1');
        for (Object customerMasterObj : customerMasterList) {
            Map<String, Object> customerMasterMap = (Map<String, Object>) customerMasterObj;
            String customerNumber = (String) customerMasterMap.get('KUNNR');
            String customerAddress = (String) customerMasterMap.get('ADRNR');
            customerAddressMap.put(customerNumber, customerAddress);
        }
        return customerAddressMap;
    }

    @TestVisible
    private Map<String, Map<String, Object>> getCustomerAddressWithRT(Map<String, String> customerAddressNumbers) {
        Map<String, Map<String, Object>> customerAddress = new Map<String, Map<String, Object>>();
        ovcSAPAddresses request = new ovcSAPAddresses();
        overcast.Predicate pred = new overcast.Predicate();
        pred.type = overcast.Predicate.FilterType.AND1;
        pred.add(new overcast.Predicate('ADDRNUMBER', overcast.Predicate.FilterType.IN1, new Set<String>(customerAddressNumbers.values())));

        overcast.Query q = new overcast.Query();
        q.where_x = pred;
        if (testDataAddress != null) {
            request.testResponse = testDataAddress;
        }

        ovcSAPAddresses respObj = request.runQuery(q, null, null);
        List<Object> addressList = (List<Object>) respObj.get('ADRC');
        for (String customerNumber : customerAddressNumbers.keyset()) {
            String custAddressNumber = customerAddressNumbers.get(customerNumber);
            for (Object addressObj : addressList) {
                Map<String, Object> addressMap = (Map<String, Object>) addressObj;
                String addressNumber = (String) addressMap.get('ADDRNUMBER');
                if (custAddressNumber == addressNumber) {
                    customerAddress.put(customerNumber, addressMap);
                }
            }
        }
        return customerAddress;
    }

    private void removeReplicatedAccounts(List<String> allPartners, Set<String> replicatedPartners) {
        for (Integer i = (allPartners.size() - 1); i >= 0; i--) {
            if (replicatedPartners.contains(allPartners[i])) {
                allPartners.remove(i);
            }
        }
    }
}