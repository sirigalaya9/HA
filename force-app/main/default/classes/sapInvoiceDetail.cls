global class sapInvoiceDetail extends overcast.Realtime.ScenarioExtension implements overcast.Realtime.Runnable {
/* 
 * Generated by Overcast UTC 2024-03-12 09:38:01Z.
 * This class belongs to the sapInvoiceDetail Real-time Integration Scenario.
 * Changes to this class may cause incorrect behavior and will be lost if the scenario is re-activated.
 */
     global class sapInvoiceDetailException extends overcast.Realtime.ScenarioException {
         private List<String> messages;
        global override List<String> getMessages() {
            return messages;
        }
        public void setMessages(List<String> messages) {
            this.messages = messages;
        }

        private List<String> backendMessages;
        global override List<String> getBackendMessages() {
            return backendMessages;
        }
        public void setBackendMessages(List<String> backendMessages) {
            this.backendMessages = backendMessages;
        }

        public sapInvoiceDetailException(List<object> messages, List<object> backendMessages) {
            super(string.join(messages, ';'));
            this.messages = new List<String>();
            for (object message : messages) {
                this.messages.add((String)message);
            }
            this.backendMessages = new List<String>();
            if (backendMessages != null) {
                for (object message : backendMessages) {
                    this.backendMessages.add((String)message);
                }
            }
        }
    }
    global sapInvoiceDetail() {
        this.BAPI_WEBINVOICE_GETDETAIL = new sapInvoiceDetail.BAPI_WEBINVOICE_GETDETAIL();
        this.WEBINVOICEDOCUMENT = new sapInvoiceDetail.WEBINVOICEDOCUMENT();
        this.RETURN_x = new sapInvoiceDetail.RETURN_x();
        this.WEBINVOICEITEMS = new list<sapInvoiceDetail.WEBINVOICEITEMS>();
        this.WEBINVOICEPARTNERS = new list<sapInvoiceDetail.WEBINVOICEPARTNERS>();
    }

    public class BAPI_WEBINVOICE_GETDETAIL {
        @AuraEnabled public String PARTNER_NUMBER { get; set; }
        @AuraEnabled public String PARTNER_ROLE { get; set; }
        @AuraEnabled public String BILLINGDOC { get; set; }
        @AuraEnabled public String LANGU { get; set; }

        public BAPI_WEBINVOICE_GETDETAIL() {}
    }

    public class WEBINVOICEDOCUMENT {
        @AuraEnabled public String BILLINGDOC { get; set; }
        @AuraEnabled public String BILL_TYPE { get; set; }
        @AuraEnabled public String BILL_TYPE_TEXT { get; set; }
        @AuraEnabled public String BILLCATEG { get; set; }
        @AuraEnabled public String BILLCATEG_TEXT { get; set; }
        @AuraEnabled public String SD_DOC_CAT { get; set; }
        @AuraEnabled public String SD_DOC_CAT_TEXT { get; set; }
        @AuraEnabled public String CURRENCY_x { get; set; }
        @AuraEnabled public String CURRENCY_ISO { get; set; }
        @AuraEnabled public Decimal NET_VALUE { get; set; }
        @AuraEnabled public String SOLD_TO { get; set; }
        @AuraEnabled public String PAYER { get; set; }
        @AuraEnabled public Decimal TAX_AMOUNT { get; set; }
        @AuraEnabled public String CANCELLED { get; set; }
        @AuraEnabled public Date BILL_DATE { get; set; }
        @AuraEnabled public String INCOTERMS1 { get; set; }
        @AuraEnabled public String INCOTERMS1_TEXT { get; set; }
        @AuraEnabled public String INCOTERMS2 { get; set; }
        @AuraEnabled public String PMNTTRMS { get; set; }
        @AuraEnabled public String PMNTTRMS_TEXT { get; set; }
        @AuraEnabled public String COMP_CODE { get; set; }
        @AuraEnabled public String COMP_NAME { get; set; }
        @AuraEnabled public String REFERENCE { get; set; }
        @AuraEnabled public Date BLINE_DATE { get; set; }
        @AuraEnabled public Date DSCT_DATE1 { get; set; }
        @AuraEnabled public Date DSCT_DATE2 { get; set; }
        @AuraEnabled public Date NET_DATE { get; set; }
        @AuraEnabled public Decimal DSCT_PCT1 { get; set; }
        @AuraEnabled public Decimal DSCT_PCT2 { get; set; }
        @AuraEnabled public String INCOTERMSV { get; set; }
        @AuraEnabled public String INCOTERMS2L { get; set; }
        @AuraEnabled public String INCOTERMS3L { get; set; }
        @AuraEnabled public String SD_DOC_CAT_LONG { get; set; }
        @AuraEnabled public String INCOTERMSV_TEXT { get; set; }

        public WEBINVOICEDOCUMENT() {}
    }

    public class RETURN_x {
        @AuraEnabled public String TYPE_x { get; set; }
        @AuraEnabled public String ID { get; set; }
        @AuraEnabled public String NUMBER_x { get; set; }
        @AuraEnabled public String MESSAGE { get; set; }
        @AuraEnabled public String LOG_NO { get; set; }
        @AuraEnabled public String LOG_MSG_NO { get; set; }
        @AuraEnabled public String MESSAGE_V1 { get; set; }
        @AuraEnabled public String MESSAGE_V2 { get; set; }
        @AuraEnabled public String MESSAGE_V3 { get; set; }
        @AuraEnabled public String MESSAGE_V4 { get; set; }
        @AuraEnabled public String PARAMETER { get; set; }
        @AuraEnabled public Integer ROW { get; set; }
        @AuraEnabled public String FIELD { get; set; }
        @AuraEnabled public String SYSTEM_x { get; set; }

        public RETURN_x() {}
    }

    public class WEBINVOICEITEMS {
        @AuraEnabled public String BILLINGDOC { get; set; }
        @AuraEnabled public String ITEM_NUMBER { get; set; }
        @AuraEnabled public String HG_LV_ITEM { get; set; }
        @AuraEnabled public Decimal INV_QTY { get; set; }
        @AuraEnabled public String SALES_UNIT { get; set; }
        @AuraEnabled public String SALES_UNIT_ISO { get; set; }
        @AuraEnabled public Decimal NETVAL_INV { get; set; }
        @AuraEnabled public String REF_DOC_NUMBER { get; set; }
        @AuraEnabled public String REF_DOC_ITEM { get; set; }
        @AuraEnabled public String REF_DOC_CAT { get; set; }
        @AuraEnabled public String REF_DOC_CAT_TEXT { get; set; }
        @AuraEnabled public String SD_DOC_NUMBER { get; set; }
        @AuraEnabled public String SD_DOC_ITEM { get; set; }
        @AuraEnabled public String SD_DOC_REF { get; set; }
        @AuraEnabled public String SD_DOC_CAT { get; set; }
        @AuraEnabled public String SD_DOC_CAT_TEXT { get; set; }
        @AuraEnabled public String MATERIAL { get; set; }
        @AuraEnabled public String SHORT_TEXT { get; set; }
        @AuraEnabled public String ITEM_TYPE { get; set; }
        @AuraEnabled public String ITEM_TYPE_TEXT { get; set; }
        @AuraEnabled public String ITEM_CATEG { get; set; }
        @AuraEnabled public String ITEM_CATEG_TEXT { get; set; }
        @AuraEnabled public String DIVISION { get; set; }
        @AuraEnabled public String DIVISION_TEXT { get; set; }
        @AuraEnabled public String PLANT { get; set; }
        @AuraEnabled public String PLANT_NAME { get; set; }
        @AuraEnabled public String CASH_DISC { get; set; }
        @AuraEnabled public Decimal CSHDISCBAS { get; set; }
        @AuraEnabled public String RETURNS { get; set; }
        @AuraEnabled public String EAN_UPC { get; set; }
        @AuraEnabled public String TAXJURCODE { get; set; }
        @AuraEnabled public Decimal TAX_AMOUNT { get; set; }
        @AuraEnabled public String ITEM_TEXT { get; set; }
        @AuraEnabled public Decimal BRVAL_INV { get; set; }
        @AuraEnabled public Decimal STVAL_INV { get; set; }
        @AuraEnabled public Decimal COND_SUBTOTAL1 { get; set; }
        @AuraEnabled public Decimal COND_SUBTOTAL2 { get; set; }
        @AuraEnabled public Decimal COND_SUBTOTAL3 { get; set; }
        @AuraEnabled public Decimal COND_SUBTOTAL4 { get; set; }
        @AuraEnabled public Decimal COND_SUBTOTAL5 { get; set; }
        @AuraEnabled public Decimal COND_SUBTOTAL6 { get; set; }
        @AuraEnabled public String REF_DOC_CAT_LONG { get; set; }
        @AuraEnabled public String SD_DOC_CAT_LONG { get; set; }
        @AuraEnabled public String MATERIAL_LONG { get; set; }

        public WEBINVOICEITEMS() {}
    }

    public class WEBINVOICEPARTNERS {
        @AuraEnabled public String PARTN_ROLE { get; set; }
        @AuraEnabled public String PARTN_ROLE_TEXT { get; set; }
        @AuraEnabled public String CUSTOMER { get; set; }
        @AuraEnabled public String FORMOFADDR { get; set; }
        @AuraEnabled public String NAME { get; set; }
        @AuraEnabled public String NAME_2 { get; set; }
        @AuraEnabled public String NAME_3 { get; set; }
        @AuraEnabled public String NAME_4 { get; set; }
        @AuraEnabled public String STREET { get; set; }
        @AuraEnabled public String COUNTRY { get; set; }
        @AuraEnabled public String COUNTRY_ISO { get; set; }
        @AuraEnabled public String POSTL_CODE { get; set; }
        @AuraEnabled public String POBX_PCD { get; set; }
        @AuraEnabled public String POBX_CTY { get; set; }
        @AuraEnabled public String CITY { get; set; }
        @AuraEnabled public String DISTRICT { get; set; }
        @AuraEnabled public String REGION { get; set; }
        @AuraEnabled public String REGION_TEXT { get; set; }
        @AuraEnabled public String CITY_CODE { get; set; }
        @AuraEnabled public String CITY_CODE_TEXT { get; set; }
        @AuraEnabled public String COUNTRY_CDE { get; set; }
        @AuraEnabled public String COUNTRY_CDE_TEXT { get; set; }
        @AuraEnabled public String PO_BOX { get; set; }
        @AuraEnabled public String TELEPHONE { get; set; }
        @AuraEnabled public String TELEPHONE2 { get; set; }
        @AuraEnabled public String TELEBOX { get; set; }
        @AuraEnabled public String FAX_NUMBER { get; set; }
        @AuraEnabled public String TELETEX { get; set; }
        @AuraEnabled public String TELEX { get; set; }
        @AuraEnabled public String TRANSPZONE { get; set; }
        @AuraEnabled public String TRANSPZONE_TEXT { get; set; }
        @AuraEnabled public String HOUSE_NO { get; set; }
        @AuraEnabled public String GENDER { get; set; }
        @AuraEnabled public String GENDER_TEXT { get; set; }
        @AuraEnabled public String NAME_LIST { get; set; }

        public WEBINVOICEPARTNERS() {}
    }

    @AuraEnabled public sapInvoiceDetail.BAPI_WEBINVOICE_GETDETAIL BAPI_WEBINVOICE_GETDETAIL { get; set; }
    @AuraEnabled public sapInvoiceDetail.WEBINVOICEDOCUMENT WEBINVOICEDOCUMENT { get; set; }
    @AuraEnabled public sapInvoiceDetail.RETURN_x RETURN_x { get; set; }
    @AuraEnabled public list<sapInvoiceDetail.WEBINVOICEITEMS> WEBINVOICEITEMS { get; set; }
    @AuraEnabled public list<sapInvoiceDetail.WEBINVOICEPARTNERS> WEBINVOICEPARTNERS { get; set; }

    public string inputSetName { get; set; }

    public sapInvoiceDetail run() {
        overcast.Logger logger1 = createLogger();
        try {
            sapInvoiceDetail response = this.run(logger1, null);
            logger1.commitToDatabase();
            return response;
        }
        catch (Exception e) {
            logger1.addLog('ERROR', e.getTypeName() + ': ' + e.getMessage());
            logger1.setStatusCode(300);
            logger1.commitToDatabase();
            throw e;
        }
    }
    
    public sapInvoiceDetail run(overcast.Logger logger, string namedCredential) {
        overcast.SynchronousHandler sh = setup(logger, namedCredential);

        if (Test.isRunningTest()) {
            if (this.dynamicBody != null) {
                return this;
            }
            return sapInvoiceDetail.deserialize(this.testResponse);
        }
        overcast.EpgwController.ExecuteScenarioSynchronously(sh, logger);
        
        return sapInvoiceDetail.deserialize(sh.Response);
    }

    public string runAsync(overcast.Logger logger, string namedCredential, Continuation con) {
        overcast.SynchronousHandler sh = setup(logger, namedCredential);

        sh.ContinuationWebRequest = new HttpRequest();
        overcast.EpgwController.ExecuteScenarioSynchronously(sh, logger);

        return con.addHttpRequest(sh.ContinuationWebRequest);
    }

    public static sapInvoiceDetail handleAsyncResponse(HttpResponse resp) {
        return sapInvoiceDetail.deserialize(resp.getBody());
    }

    public static sapInvoiceDetail getAsyncResponse(String requestLabel) {
        HttpResponse response = Continuation.getResponse(requestLabel);
        return handleAsyncResponse(response);
    }

    private overcast.SynchronousHandler setup(overcast.Logger logger, string namedCredential) {
        overcast.SynchronousHandler sh = overcast.SynchronousHandler.CreateFromName('sapInvoiceDetail');

        sh.InputSetName = this.inputSetName;
        sh.InputJson = this.serialize();
        sh.NamedCredential = namedCredential;
        if (logger != null) {
            logger.setInputSetName(String.isBlank(this.inputSetName) ? sh.CorrelationId : this.inputSetName);
            logger.setIdemId(sh.CorrelationId);
        }
                sh.loadExtensions(this);

        return sh;
    }

    private static overcast.Logger createLogger() {
        return new overcast.Logger('sapInvoiceDetail');
    }

    global override string getBackendMessage() {
        return this.backendMessage;
    }

    global string serialize() {
        if (dynamicBody != null) {
            return JSON.serialize(dynamicBody, true);
        }
        return JSON.serialize(this, true);
    }

        
    public class BodyContents extends overcast.Realtime.ContentsBody {
        public sapInvoiceDetail output { get; set; }
    }

    private static sapInvoiceDetail.BodyContents getBodyContents(string responseData) {
        if (string.isblank(responseData)) {
            throw new sapInvoiceDetailException('Response null for sapInvoiceDetail request.');
        }

        sapInvoiceDetail.BodyContents contents = (sapInvoiceDetail.BodyContents) JSON.deserialize(responseData, sapInvoiceDetail.BodyContents.class);
        if (contents.error != null) {
            sapInvoiceDetailException ex = new sapInvoiceDetailException(string.join(contents.error, ';'));
            ex.setMessages(contents.error);
            ex.setBackendMessages(contents.backendErrorMessages == null ? new List<String>() : contents.backendErrorMessages);
            throw ex;
        }
        return contents;
    }

    public static sapInvoiceDetail deserialize(string responsedata) {
        if (overcast.Globals.IsOCF) {
            sapInvoiceDetail obj = new sapInvoiceDetail();
            obj.loadAsyncResponse(responsedata);
            return obj;
        }
        sapInvoiceDetail.BodyContents contents = getBodyContents(responsedata);
        contents.output.backendMessage = contents.backendMessage;

        return contents.output;
    }

    private static map<string, string> getOutputData(string responseData) {
        if (string.isblank(responsedata)) {
            throw new sapInvoiceDetailException('Response null for sapInvoiceDetail request.');
        }

        map<string, string> m = new map<string, string>();

        JSONParser jresponse = JSON.createParser(responsedata);
        jresponse.nextValue();

        boolean hasOutput = false;
        string[] errors = null;
        string[] backendErrorMessages = null;
        while (jresponse.nextValue() != JSONToken.END_OBJECT && jresponse.getCurrentToken() != null) {
            if (jresponse.getCurrentName() == 'output') {
                jresponse.skipChildren();
                hasOutput = true;
                continue;
            }
            if (jresponse.getCurrentName() == 'backendMessage') {
                m.put('backendMessage', (string)jresponse.readValueAs(string.class));
                continue;
            }
            if (jresponse.getCurrentName() == 'error') {
                errors = (string[])jresponse.readValueAs(list<string>.class);
                jresponse.skipChildren();
                continue;
            }
            if (jresponse.getCurrentName() == 'backendErrorMessages') {
                backendErrorMessages = (string[])jresponse.readValueAs(list<string>.class);
                jresponse.skipChildren();
                continue;
            }
        }
        if (errors != null) {
            sapInvoiceDetailException ex = new sapInvoiceDetailException(string.join(errors, ';'));
            ex.setMessages(errors);
            ex.setBackendMessages(backendErrorMessages == null ? new List<String>() : backendErrorMessages);
            throw ex;
        }
        if (!hasOutput) {
            throw new sapInvoiceDetailException('Malformed response for sapInvoiceDetail request.');
        }
        integer start = responsedata.indexOf(':') + 1;
        integer lastIndex = m.get('backendMessage') == null
            ? responsedata.length() - 2
            : responsedata.lastIndexOf('backendMessage');
        integer finish = responsedata.lastIndexOf('}', lastIndex) + 1;
        m.put('output', responseData.substring(start, finish));
        return m;
    }


    public transient string testResponse;
    private transient string outputData;
    private transient string backendMessage;

    private transient map<string, overcast.TypeInfo> metadata;
    private transient map<string, object> dynamicBody;

    global void loadAsyncResponse(string responseBody) {
        if (overcast.Globals.IsOCF) {
            if (string.isblank(responseBody)) {
                throw new sapInvoiceDetailException('Response null for sapInvoiceDetail request.');
            }
            map<string, object> responseObj = (map<string, object>)JSON.deserializeUntyped(responseBody);
            if (responseObj.containsKey('error')) {
                throw new sapInvoiceDetailException((List<object>)responseObj.get('error'), (List<object>)responseObj.get('backendErrorMessages'));
            }
            backendMessage = (string)responseObj.get('backendMessage');
            dynamicBody = (map<string, object>)responseObj.get('output');
            return;
        }

        map<string, string> m = getOutputData(responseBody);
        outputData = m.get('output');
        backendMessage = m.get('backendMessage');
        
        if (outputData != null) {
            dynamicBody = (map<string, object>)JSON.deserializeUntyped(outputData);
        }
    }

    global string getTopTypeName() {
        return 'BAPI_WEBINVOICE_GETDETAIL';
    }

    global void set(string typeName, object records) {
        if (typeName == '@testResponse') {
            dynamicBody = (map<string, object>)records;
            return;
        }
        if (dynamicBody == null) {
            dynamicBody = new map<string, object>();
        }
        
        dynamicBody.put(typeName, records);
    }
    
    global object get(string typeName) {
        if (dynamicBody == null && outputData != null) {
            dynamicBody = (map<string, object>)JSON.deserializeUntyped(outputData);
        }
        if (dynamicBody == null) { 
            return null;
        }
        return dynamicBody.get(typeName);
    }

    global map<string, overcast.TypeInfo> getMetadata() {
        if (metadata == null) {
            metadata = new Map<String, overcast.TypeInfo>();
            metadata.putAll(sapInvoiceDetailMeta0.metadata);
        }
        return metadata;
    }

}