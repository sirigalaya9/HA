global class ovcSAPBDSGetDocument extends overcast.Realtime.ScenarioExtension implements overcast.Realtime.Runnable {
/* 
 * Generated by Overcast UTC 2024-03-18 07:45:19Z.
 * This class belongs to the ovcSAPBDSGetDocument Real-time Integration Scenario.
 * Changes to this class may cause incorrect behavior and will be lost if the scenario is re-activated.
 */
     global class ovcSAPBDSGetDocumentException extends overcast.Realtime.ScenarioException {
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

        public ovcSAPBDSGetDocumentException(List<object> messages, List<object> backendMessages) {
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
    global ovcSAPBDSGetDocument() {
        this.BDS_DOCUMENT_GET_TABLE = new ovcSAPBDSGetDocument.BDS_DOCUMENT_GET_TABLE();
        this.SIGNATURE = new list<ovcSAPBDSGetDocument.SIGNATURE>();
        this.COMPONENTS = new list<ovcSAPBDSGetDocument.COMPONENTS>();
        this.CONTENT = new list<ovcSAPBDSGetDocument.CONTENT>();
        this.ASCII_CONTENT = new list<ovcSAPBDSGetDocument.ASCII_CONTENT>();
    }

    public class BDS_DOCUMENT_GET_TABLE {
        @AuraEnabled public String CLIENT { get; set; }
        @AuraEnabled public String DOC_ID { get; set; }
        @AuraEnabled public String BINARY_FLAG { get; set; }

        public BDS_DOCUMENT_GET_TABLE() {}
    }

    public class SIGNATURE {
        @AuraEnabled public String DOC_COUNT { get; set; }
        @AuraEnabled public String DOC_ID { get; set; }
        @AuraEnabled public String DOC_VER_NO { get; set; }
        @AuraEnabled public String DOC_VAR_ID { get; set; }
        @AuraEnabled public String DOC_VAR_TG { get; set; }
        @AuraEnabled public String COMP_COUNT { get; set; }
        @AuraEnabled public String PROP_NAME { get; set; }
        @AuraEnabled public String PROP_VALUE { get; set; }

        public SIGNATURE() {}
    }

    public class COMPONENTS {
        @AuraEnabled public String DOC_COUNT { get; set; }
        @AuraEnabled public String COMP_COUNT { get; set; }
        @AuraEnabled public String COMP_ID { get; set; }
        @AuraEnabled public String MIMETYPE { get; set; }
        @AuraEnabled public String COMP_SIZE { get; set; }

        public COMPONENTS() {}
    }

    public class CONTENT {
        @AuraEnabled public Blob LINE { get; set; }

        public CONTENT() {}
    }

    public class ASCII_CONTENT {
        @AuraEnabled public String LINE { get; set; }

        public ASCII_CONTENT() {}
    }

    @AuraEnabled public ovcSAPBDSGetDocument.BDS_DOCUMENT_GET_TABLE BDS_DOCUMENT_GET_TABLE { get; set; }
    @AuraEnabled public list<ovcSAPBDSGetDocument.SIGNATURE> SIGNATURE { get; set; }
    @AuraEnabled public list<ovcSAPBDSGetDocument.COMPONENTS> COMPONENTS { get; set; }
    @AuraEnabled public list<ovcSAPBDSGetDocument.CONTENT> CONTENT { get; set; }
    @AuraEnabled public list<ovcSAPBDSGetDocument.ASCII_CONTENT> ASCII_CONTENT { get; set; }

    public string inputSetName { get; set; }

    public ovcSAPBDSGetDocument run() {
        overcast.Logger logger1 = createLogger();
        try {
            ovcSAPBDSGetDocument response = this.run(logger1, null);
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
    
    public ovcSAPBDSGetDocument run(overcast.Logger logger, string namedCredential) {
        overcast.SynchronousHandler sh = setup(logger, namedCredential);

        if (Test.isRunningTest()) {
            if (this.dynamicBody != null) {
                return this;
            }
            return ovcSAPBDSGetDocument.deserialize(this.testResponse);
        }
        overcast.EpgwController.ExecuteScenarioSynchronously(sh, logger);
        
        return ovcSAPBDSGetDocument.deserialize(sh.Response);
    }

    public string runAsync(overcast.Logger logger, string namedCredential, Continuation con) {
        overcast.SynchronousHandler sh = setup(logger, namedCredential);

        sh.ContinuationWebRequest = new HttpRequest();
        overcast.EpgwController.ExecuteScenarioSynchronously(sh, logger);

        return con.addHttpRequest(sh.ContinuationWebRequest);
    }

    public static ovcSAPBDSGetDocument handleAsyncResponse(HttpResponse resp) {
        return ovcSAPBDSGetDocument.deserialize(resp.getBody());
    }

    public static ovcSAPBDSGetDocument getAsyncResponse(String requestLabel) {
        HttpResponse response = Continuation.getResponse(requestLabel);
        return handleAsyncResponse(response);
    }

    private overcast.SynchronousHandler setup(overcast.Logger logger, string namedCredential) {
        overcast.SynchronousHandler sh = overcast.SynchronousHandler.CreateFromName('ovcSAPBDSGetDocument');

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
        return new overcast.Logger('ovcSAPBDSGetDocument');
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
        public ovcSAPBDSGetDocument output { get; set; }
    }

    private static ovcSAPBDSGetDocument.BodyContents getBodyContents(string responseData) {
        if (string.isblank(responseData)) {
            throw new ovcSAPBDSGetDocumentException('Response null for ovcSAPBDSGetDocument request.');
        }

        ovcSAPBDSGetDocument.BodyContents contents = (ovcSAPBDSGetDocument.BodyContents) JSON.deserialize(responseData, ovcSAPBDSGetDocument.BodyContents.class);
        if (contents.error != null) {
            ovcSAPBDSGetDocumentException ex = new ovcSAPBDSGetDocumentException(string.join(contents.error, ';'));
            ex.setMessages(contents.error);
            ex.setBackendMessages(contents.backendErrorMessages == null ? new List<String>() : contents.backendErrorMessages);
            throw ex;
        }
        return contents;
    }

    public static ovcSAPBDSGetDocument deserialize(string responsedata) {
        if (overcast.Globals.IsOCF) {
            ovcSAPBDSGetDocument obj = new ovcSAPBDSGetDocument();
            obj.loadAsyncResponse(responsedata);
            return obj;
        }
        ovcSAPBDSGetDocument.BodyContents contents = getBodyContents(responsedata);
        contents.output.backendMessage = contents.backendMessage;

        return contents.output;
    }

    private static map<string, string> getOutputData(string responseData) {
        if (string.isblank(responsedata)) {
            throw new ovcSAPBDSGetDocumentException('Response null for ovcSAPBDSGetDocument request.');
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
            ovcSAPBDSGetDocumentException ex = new ovcSAPBDSGetDocumentException(string.join(errors, ';'));
            ex.setMessages(errors);
            ex.setBackendMessages(backendErrorMessages == null ? new List<String>() : backendErrorMessages);
            throw ex;
        }
        if (!hasOutput) {
            throw new ovcSAPBDSGetDocumentException('Malformed response for ovcSAPBDSGetDocument request.');
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
                throw new ovcSAPBDSGetDocumentException('Response null for ovcSAPBDSGetDocument request.');
            }
            map<string, object> responseObj = (map<string, object>)JSON.deserializeUntyped(responseBody);
            if (responseObj.containsKey('error')) {
                throw new ovcSAPBDSGetDocumentException((List<object>)responseObj.get('error'), (List<object>)responseObj.get('backendErrorMessages'));
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
        return 'BDS_DOCUMENT_GET_TABLE';
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
            metadata.putAll(ovcSAPBDSGetDocumentMeta0.metadata);
        }
        return metadata;
    }

}