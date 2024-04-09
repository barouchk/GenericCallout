global with sharing class OutboundService {
    private static final String ORG_NAME_SERVICE_DELIMITER = '_';

    private static EnvSettings__c envSettings = EnvSettings__c.getInstance('Main');
    private String destination = 'APIGATEWAY';
    private String transactionId;
    private String federationId = '';

    private static OutboundService OutboundServiceObj;
    private static final Set<Integer> successCodes = new Set<Integer>{200, 201};

    private OutboundService() {}

    // Singelton Pattern
    global static OutboundService getInstance() {
        if (OutboundServiceObj == null) {
            OutboundServiceObj = new OutboundService();
        }

        return OutboundServiceObj;
    }

    private String generateUUID() {
        Blob b = Crypto.GenerateAESKey(128);
        String convertedToHex = EncodingUtil.ConvertTohex(b);
        String guid = convertedToHex.SubString(0, 8) + '-' + convertedToHex.SubString(8, 12)
                + '-' + convertedToHex.SubString(12, 16) + '-'
                + convertedToHex.SubString(16, 20) + '-' + convertedToHex.substring(20);
        return guid;
    }

    private Map<String, String> populateHeaders(String stringHeaders) {
        Map<String, Object> jsonMap = new Map<String, Object>();
        Map<String, String> headersMap = new Map<String, String>();

        if(!String.isEmpty(stringHeaders)) {
            jsonMap = (Map<String, Object>) JSON.deserializeUntyped(stringHeaders);
            for (String key : jsonMap.keySet()) {
                if (!String.isEmpty(key) && jsonMap.get(key) != null) {
                    headersMap.put(key, String.valueOf(jsonMap.get(key)));
                } else {
                    throw new OutboundServiceException('Headers problem');
                }
            }
        } else {
            throw new OutboundServiceException('Headers problem');
        }

        return headersMap;
    }

    private String generateGetEndpointWithParams(String endpoint, String requestJson){
        Map<String, Object> requestObjectsMap = (Map<String, Object>) JSON.deserializeUntyped(requestJson);
        Map<String, Object> requestMap = (Map<String, Object>) requestObjectsMap.get('Request');
        Map<String, Object> inParamsMap = (Map<String, Object>) requestMap.get('InParams');

        for(String key : inParamsMap.keySet()){
            String replaceParamKey = '{'+ key +'}';
            if(endpoint.contains(key)){
                endpoint = endpoint.replace(replaceParamKey, (String)inParamsMap.get(key));
                inParamsMap.remove(key);
            }
        }
        return endpoint;
    }

    private void findRequestHeaderParams(String requestJson) {
        Map<String, Object> requestObjectsMap = (Map<String, Object>) JSON.deserializeUntyped(requestJson);
        Map<String, Object> requestHeaderMap = (Map<String, Object>) requestObjectsMap.get('RequestHeader');
        if (requestHeaderMap?.isEmpty() == false) {
            String TransactionID = (String) requestHeaderMap.get('TransactionId');
            this.transactionId = TransactionID != null ? TransactionID : generateUUID();
            if ((String)requestHeaderMap.get('ToSystem') != null) {
                this.destination = (String) requestHeaderMap.get('ToSystem');
            }

            if ((String)requestHeaderMap.get('UserIdentifier') != null) {
                this.federationId = (String) requestHeaderMap.get('UserIdentifier');
            }
        } else {
            this.transactionId = generateUUID();
        }
    }

    private static String getEndpoint(Service_Endpoint__mdt serviceEndpoint) {
        String endpoint = 'callout:' + envSettings.Env__c + ORG_NAME_SERVICE_DELIMITER + serviceEndpoint.Service_Name__c + serviceEndpoint.Service_Endpoint__c;

        return endpoint;
    }

    global HTTPResponse send(Service_Endpoint__mdt serviceEndpoint, String body) {
        findRequestHeaderParams(body);
        Datetime startDate = Datetime.now();
        if (body == null) {
            throw new OutboundServiceException('body is null exception');
        }

        HttpRequest req = new HttpRequest();
        req.setMethod(serviceEndpoint.Method_Type__c);
        if (serviceEndpoint.Method_Type__c == 'GET') {
            String endpoint = getEndpoint(serviceEndpoint);
            endpoint = generateGetEndpointWithParams(endPoint, body);
            req.setEndpoint(endpoint); //ENDPOINT FOR GET - No body
        } else {
            req.setEndpoint(getEndpoint(serviceEndpoint)); //ENDPOINT FOR POST
            req.setBody(body);
        }

        //SET HEADERS
        req.setHeader('Content-Type', serviceEndpoint.Content_Type__c);
        req.setHeader('Accept', serviceEndpoint.Accept__c);

        //Additional Headers:
        req.setHeader('Env', envSettings.Env__c);
        req.setHeader('TransactionID', this.transactionId);
        req.setHeader('UserNt', this.federationId);

        if(String.isNotEmpty(serviceEndpoint.Accept_Encoding__c)) {
            req.setHeader('Accept-Encoding', serviceEndpoint.Accept_Encoding__c);
        }

        //CUSTOM HEADERS
        if (serviceEndpoint.Headers__c != null) {
            Map<String, String> headersMap = populateHeaders(serviceEndpoint.Headers__c);
            for (String key : headersMap.keySet()) {
                req.setHeader(key, headersMap.get(key));
            }
        }

        //Set timeout
        Integer timeout = Integer.valueOf(envSettings.Timeout__c);
        if (timeout > 10) {
            req.setTimeout(timeout * 1000); //In miliseconds
        }

        // Create a new http object to send the request object
        Http http = new Http();
        HttpResponse res = http.send(req);
        String responseBody = res.getBody();
        Integer statusCode = res.getStatusCode();
        ResponseWrapper response;
        if(successCodes.contains(statusCode)) {
            response = String.isBlank(responseBody) ? null : (ResponseWrapper)JSON.deserialize(responseBody, ResponseWrapper.class);
        } else {
            response = new ResponseWrapper(String.valueOf(statusCode), responseBody);
        }

        return res;
    }

    /**
     * Callout to service by name, method and body -*** The global main method that will be called ***
     *
     * @param {String}			: Service name field from the relevant endpoint in the Meta Data- example : ApiGateway
     * @param {String}			: Service method name field - the relevant name of the endpoint that will be do the callout
     * @param {String}			: Payload - serialized mapping
     * @return {HTTPResponse}	: Response
     */

    global HTTPResponse send(String methodName, String body) {
        Service_Endpoint__mdt serviceEndpoint = Service_Endpoint__mdt.getInstance(methodName);
        if (serviceEndpoint == null) {
            throw new OutboundServiceException('Service_Endpoint__mdt "' + methodName + '" does not exists');
        }

        return send(serviceEndpoint, body);
    }

    global class OutboundServiceException extends Exception {}

    public class Response extends GenericRequest.Response {
        public Response() {}
        public Response(String errorCode, String errorMessage) {
            ResponseHeader = new GenericRequest.ResponseHeader(errorCode, errorMessage);
        }
    }

    public class ResponseWrapper {
        public Response Response;

        public ResponseWrapper() {}
        public ResponseWrapper(String errorCode, String errorMessage) {
            Response = new Response(errorCode, errorMessage);
        }
    }
}