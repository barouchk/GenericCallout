public with sharing class GenericRequest {
    private final static EnvSettings__c envSettings = EnvSettings__c.getInstance('Main');
    private final static OutboundService service = OutboundService.getInstance();
    private final static Outbound_Utils outUtils = new Outbound_Utils();
    private final static Set<Integer> successStatusCodes = new Set<Integer> {200, 201};
    private final static String LOG_TO_SYSTEM = 'Destenation System';
    

    private static User user = [SELECT Id, FederationIdentifier
                                FROM User 
                                WHERE Id = :UserInfo.getUserId() 
                                LIMIT 1];

    public class RequestHeader {
        public String AppID, ServiceName, EnvCode, TransactionID;
        public Integer Timeout;

        public RequestHeader(String serviceName, String transactionId) {
            Service_Endpoint__mdt serviceEndpointInstance = Service_Endpoint__mdt.getInstance(serviceName);

            String salesforce = 'SalesForce';
            this.AppID = salesforce;
            this.ServiceName = getServiceNameFromMetadataEndpoint(serviceEndpointInstance);
            EnvCode = salesforce + '_' + envSettings.Env__c;
            Timeout = Integer.valueOf(envSettings.Timeout__c);
            this.TransactionID = transactionId;
        }
    }

    private static String getServiceNameFromMetadataEndpoint(Service_Endpoint__mdt se) {
        List<String> endpointParts = se.Service_Endpoint__c.split('/');
        return endpointParts.get(endpointParts.size() - 1);
    }

    public class RequestObject {
        Object InParams;

        public RequestObject(String serviceName, Object inParams, String transactionId) {
            this.InParams = inParams;
        }
    }

    public class Request {
        GeneralRequestHeader RequestHeader;
        RequestObject Request;

        Request(String serviceName, Object inParams) {
            String transactionId = outUtils.generateUUID();
            RequestHeader = new GeneralRequestHeader(transactionId, 'Outbound', null);
            Request = new RequestObject(serviceName, inParams, transactionId);
        }
    }

    public class GeneralRequestHeader {
        public String FromSystem = 'Salesforce';
        public final String UserIdentifier = user.FederationIdentifier;
        public String ToSystem, token, TransactionId;

        public GeneralRequestHeader(String transactionId, String toSystem, String token) {
            this.TransactionId = transactionId;
            this.ToSystem = toSystem;
            this.token = token;
        }
    }

    public class ResponseHeader {
        public ResponseHeader() {}

        public ResponseHeader(String errorCode, String errorDesc) {
            Application_Status = errorCode;
            Error = new ResponseHeaderError(errorCode, errorDesc);
        }

        @AuraEnabled public String ServiceName, TransactionID, Application_Status;
        @AuraEnabled public ResponseHeaderError Error;
    }

    public class ResponseHeaderError {
        public ResponseHeaderError() {}
        public ResponseHeaderError(String errorCode, String errorDesc) {
            ErrCode = errorCode;
            ErrDesc = errorDesc;
        }

        @AuraEnabled public String ErrCode, ErrDesc, StackTrace;
    }

    public virtual class Response {
        @AuraEnabled public ResponseHeader ResponseHeader;
    }

    private static Object makeCalloutHelper(String serviceName, Object request, Type responseClass) {
        System.debug('request: ' + JSON.serializePretty(request));
        HttpResponse response = service.send(serviceName, JSON.serialize(request));
        String body = response.getBody();
        Integer statusCode = response.getStatusCode();
        System.debug('response: ' + JSON.serializePretty(body));
        Map<String, Object> responseMap;
        if(successStatusCodes.contains(statusCode)) {
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(body);
        } else {
            responseMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(new OutboundService.ResponseWrapper(String.valueOf(statusCode), body)));
        }

        Map<String, Object> res = responseMap.containsKey('Response') ? (Map<String, Object>)responseMap.get('Response') : responseMap;
        System.debug('result: ' + JSON.serializePretty(responseClass == null ? res : JSON.deserialize(JSON.serialize(res), responseClass)));
        return responseClass == null ? res : JSON.deserialize(JSON.serialize(res), responseClass);
    }

    public static Object makeCallout(String serviceName, Object inParams, Type responseClass) {
        Request request = new Request(serviceName, inParams);
        return makeCalloutHelper(serviceName, request, responseClass);
    }
}