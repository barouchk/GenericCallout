public with sharing class GenericInvocableRequest implements DCService  {
    public virtual class Request {
        @InvocableVariable(label='Service Endpoint Developer Name' description='Service_Endpoint__mdt DeveloperName' required=true)
        public String serviceEndpoint;

        @InvocableVariable(label='Request Parameters' Description='InParams' required=true)
        public String paramsJson;

        @InvocableVariable(label='Status Code Path' description='which response field will return in Status Code output field' required=false)
        public String statusCodePath;

        @InvocableVariable(label='Status Description Path' description='which response field will return in Status Description output field' required=false)
        public String statusDescPath;

        @InvocableVariable(label='Output1 Path' description='JSON path for output value' required=false)
        public String output1Path;

        @InvocableVariable(label='Output2 Path' description='JSON path for output value' required=false)
        public String output2Path;

        @InvocableVariable(label='Output3 Path' description='JSON path for output value' required=false)
        public String output3Path;

        @InvocableVariable(label='Output4 Path' description='JSON path for output value' required=false)
        public String output4Path;

        @InvocableVariable(label='Output5 Path' description='JSON path for output value' required=false)
        public String output5Path;

        @InvocableVariable(label='Output6 Path' description='JSON path for output value' required=false)
        public String output6Path;

        @InvocableVariable(label='Output7 Path' description='JSON path for output value' required=false)
        public String output7Path;

        @InvocableVariable(label='Output8 Path' description='JSON path for output value' required=false)
        public String output8Path;

        @InvocableVariable(label='Output9 Path' description='JSON path for output value' required=false)
        public String output9Path;

        @InvocableVariable(label='Output10 Path' description='JSON path for output value' required=false)
        public String output10Path;

        @InvocableVariable(label='Output11 Path' description='JSON path for output value' required=false)
        public String output11Path;

        @InvocableVariable(label='Output12 Path' description='JSON path for output value' required=false)
        public String output12Path;

        @InvocableVariable(label='Output13 Path' description='JSON path for output value' required=false)
        public String output13Path;

        @InvocableVariable(label='OutputCollection1 Path' description='JSON path for output collection value - returns array' required=false)
        public String outputCollection1Path;

        @InvocableVariable(label='OutputCollection2 Path' description='JSON path for output collection value - returns array' required=false)
        public String outputCollection2Path;

        @InvocableVariable(label='OutputCollection1 Keys' description='Collections key to retrieve values by' required=false)
        public String outputCollection1Keys;

        @InvocableVariable(label='OutputCollection2 Keys' description='Collections key to retrieve values by' required=false)
        public String outputCollection2Keys;

        @InvocableVariable(label='Collection 1 Path' description='JSON path for output collection value - returns object' required=false)
        public String collection1Path;

        @InvocableVariable(label='Collection 2 Path' description='JSON path for output collection value - returns object' required=false)
        public String collection2Path;

        public List<String> getListOfOutputPaths() {
            return new List<String>{statusCodePath, statusDescPath, output1Path, output2Path, output3Path, output4Path,
                                    output5Path, output6Path, output7Path, output8Path, output9Path, output10Path,
                                    output11Path, output12Path, output13Path};
        }
    }

    public class Response {
        @InvocableVariable(label='Response Status Code')
        public String statusCode;

        @InvocableVariable(label='Response Status Description')
        public String statusDesc;

        @InvocableVariable(label='Output1')
        public String output1;

        @InvocableVariable(label='Output2')
        public String output2;

        @InvocableVariable(label='Output3')
        public String output3;

        @InvocableVariable(label='Output4')
        public String output4;

        @InvocableVariable(label='Output5')
        public String output5;

        @InvocableVariable(label='Output6')
        public String output6;

        @InvocableVariable(label='Output7')
        public String output7;

        @InvocableVariable(label='Output8')
        public String output8;

        @InvocableVariable(label='Output9')
        public String output9;

        @InvocableVariable(label='Output10')
        public String output10;

        @InvocableVariable(label='Output11')
        public String output11;

        @InvocableVariable(label='Output12')
        public String output12;

        @InvocableVariable(label='Output13')
        public String output13;

        @InvocableVariable(label='Collection 1')
        public List<ParsedJsonOutput> collection1;

        @InvocableVariable(label='Collection 2')
        public List<ParsedJsonOutput> collection2;

        @InvocableVariable(label='Response Json')
        public String responseJson;

        // allow access to this input for error handling
        @InvocableVariable(label='Service Endpoint Developer Name' description='Service_Endpoint__mdt DeveloperName')
        public String serviceEndpoint;

        public Response(String statusCode, String statusDesc) {
            this.statusCode = statusCode;
            this.statusDesc = statusDesc;
        }

        public Response(Request request, Map<String, Object> response) {
            InvocableJSONParser.Output parsedJson = parseResponse(request, response);
            parseStringOutputs(parsedJson.outputs);
            parseCollectionOutputs(request, response, parsedJson);
            responseJson = JSON.serialize(response);
            serviceEndpoint = request.serviceEndpoint;
        }

        private InvocableJSONParser.Output parseResponse(Request request, Map<String, Object> response) {
            Map<String, Object> inputMap = new Map<String, Object>{
                    'jsonStr' => JSON.serialize(response),
                    'collectionPath1' => request.collection1Path,
                    'collectionPath2' => request.collection2Path,
                    'collectionKeys1' => request.outputCollection1Keys,
                    'collectionKeys2' => request.outputCollection2Keys
            };

            Integer index = 1;
            for(String path : request.getListOfOutputPaths()) {
                inputMap.put('path' + index++, path);
            }

            return InvocableJSONParser.parseJson((InvocableJSONParser.Input)JSON.deserialize(JSON.serialize(inputMap), InvocableJSONParser.Input.class));
        }

        private void parseStringOutputs(ParsedJsonOutput parsedJsonOutput) {
            statusCode = parsedJsonOutput.output1;
            statusDesc = parsedJsonOutput.output2;
            output1 = parsedJsonOutput.output3;
            output2 = parsedJsonOutput.output4;
            output3 = parsedJsonOutput.output5;
            output4 = parsedJsonOutput.output6;
            output5 = parsedJsonOutput.output7;
            output6 = parsedJsonOutput.output8;
            output7 = parsedJsonOutput.output9;
            output8 = parsedJsonOutput.output10;
            output9 = parsedJsonOutput.output11;
            output10 = parsedJsonOutput.output12;
            output11 = parsedJsonOutput.output13;
            output12 = parsedJsonOutput.output14;
            output13 = parsedJsonOutput.output15;
        }

        private void parseCollectionOutputs(Request request, Map<String, Object> response, InvocableJSONParser.Output parsedResponse) {
            collection1 = parsedResponse.collectionOutputs1;
            collection2 = parsedResponse.collectionOutputs2;
        }
    }

    @InvocableMethod (label='Make Callout' callout=true category='Invocable Callouts' configurationEditor='c-generic-invocable-request-configuration-editor')
    public static List<Response> invoke(List<Request> requests) {
        List<Response> responses = new List<Response>();
        for(Request request: requests) {
            try {
                responses.add(new Response(request, makeCallout(
                        request.serviceEndpoint,
                        parseJson(request.paramsJson)
                )));
            } catch(Exception ex) {
                String msg = 'exception occurred: ' + ex + '\nstack: ' + ex.getStackTraceString();
                System.debug(msg + '\nrequest: ' + request.paramsJson);
                DateTime now = DateTime.now();
                responses.add(new Response('95',  'missing response body \n' + ex.getMessage()));
            }
        }
        return responses;
    }

    @AuraEnabled(Cacheable=false)
    public static Map<String, Object> makeCallout(String serviceEndpoint, Map<String, Object> params) {

        Map<String, Object> response;
        if(Service_Endpoint__mdt.getInstance(serviceEndpoint) != null) {
            // Make callout to endpoint
            response = (Map<String, Object>)GenericRequest.makeCallout(serviceEndpoint, params, null);
        }

        return response;
    }

    public Map<String, Object> retrive(String recordId, String serviceEndpoint, Map<String, Object> calloutParams){
        return makeCallout(serviceEndpoint, calloutParams);
    }

    private static String extractStringFromResponse(String keyPath, Map<String, Object> responseMap) {
        Object currentPathValue = InvocableJSONParser.extractObjectFromResponse(keyPath, responseMap);
        return currentPathValue == null ? null : String.valueOf(currentPathValue);
    }

    private static Map<String, Object> parseJson(String paramsJson) {
        Map<String, Object> parsed;
        try {
            parsed = (Map<String, Object>)JSON.deserializeUntyped(paramsJson);
        } catch(Exception ex) {
            System.debug('ex:' + ex + ', paramsJson: ' + paramsJson);
            parsed = (Map<String, Object>)JSON.deserializeUntyped(paramsJson.replace('\\', '\\\\'));
        }

        return parsed;
    }
}