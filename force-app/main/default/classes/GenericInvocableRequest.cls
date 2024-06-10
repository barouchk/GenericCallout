global with sharing class GenericInvocableRequest implements DCService  {
    global virtual class Request {
        @InvocableVariable(label='Service Endpoint Developer Name' description='Service_Endpoint__mdt DeveloperName' required=true)
        global String serviceEndpoint;

        @InvocableVariable(label='Request Parameters' Description='InParams' required=true)
        global String paramsJson;

        @InvocableVariable(label='Status Code Path' description='which response field will return in Status Code output field' required=false)
        global String statusCodePath;

        @InvocableVariable(label='Status Description Path' description='which response field will return in Status Description output field' required=false)
        global String statusDescPath;

        @InvocableVariable(label='Output1 Path' description='JSON path for output value' required=false)
        global String output1Path;

        @InvocableVariable(label='Output2 Path' description='JSON path for output value' required=false)
        global String output2Path;

        @InvocableVariable(label='Output3 Path' description='JSON path for output value' required=false)
        global String output3Path;

        @InvocableVariable(label='Output4 Path' description='JSON path for output value' required=false)
        global String output4Path;

        @InvocableVariable(label='Output5 Path' description='JSON path for output value' required=false)
        global String output5Path;

        @InvocableVariable(label='Output6 Path' description='JSON path for output value' required=false)
        global String output6Path;

        @InvocableVariable(label='Output7 Path' description='JSON path for output value' required=false)
        global String output7Path;

        @InvocableVariable(label='Output8 Path' description='JSON path for output value' required=false)
        global String output8Path;

        @InvocableVariable(label='Output9 Path' description='JSON path for output value' required=false)
        global String output9Path;

        @InvocableVariable(label='Output10 Path' description='JSON path for output value' required=false)
        global String output10Path;

        @InvocableVariable(label='Output11 Path' description='JSON path for output value' required=false)
        global String output11Path;

        @InvocableVariable(label='Output12 Path' description='JSON path for output value' required=false)
        global String output12Path;

        @InvocableVariable(label='Output13 Path' description='JSON path for output value' required=false)
        global String output13Path;

        @InvocableVariable(label='OutputCollection1 Path' description='JSON path for output collection value - returns array' required=false)
        global String outputCollection1Path;

        @InvocableVariable(label='OutputCollection2 Path' description='JSON path for output collection value - returns array' required=false)
        global String outputCollection2Path;

        @InvocableVariable(label='OutputCollection1 Keys' description='Collections key to retrieve values by' required=false)
        global String outputCollection1Keys;

        @InvocableVariable(label='OutputCollection2 Keys' description='Collections key to retrieve values by' required=false)
        global String outputCollection2Keys;

        @InvocableVariable(label='Collection 1 Path' description='JSON path for output collection value - returns object' required=false)
        global String collection1Path;

        @InvocableVariable(label='Collection 2 Path' description='JSON path for output collection value - returns object' required=false)
        global String collection2Path;

        public List<String> getListOfOutputPaths() {
            return new List<String>{statusCodePath, statusDescPath, output1Path, output2Path, output3Path, output4Path,
                                    output5Path, output6Path, output7Path, output8Path, output9Path, output10Path,
                                    output11Path, output12Path, output13Path};
        }
    }

    global class Response {
        @InvocableVariable(label='Response Status Code')
        global String statusCode;

        @InvocableVariable(label='Response Status Description')
        global String statusDesc;

        @InvocableVariable(label='Output1')
        global String output1;

        @InvocableVariable(label='Output2')
        global String output2;

        @InvocableVariable(label='Output3')
        global String output3;

        @InvocableVariable(label='Output4')
        global String output4;

        @InvocableVariable(label='Output5')
        global String output5;

        @InvocableVariable(label='Output6')
        global String output6;

        @InvocableVariable(label='Output7')
        global String output7;

        @InvocableVariable(label='Output8')
        global String output8;

        @InvocableVariable(label='Output9')
        global String output9;

        @InvocableVariable(label='Output10')
        global String output10;

        @InvocableVariable(label='Output11')
        global String output11;

        @InvocableVariable(label='Output12')
        global String output12;

        @InvocableVariable(label='Output13')
        global String output13;

        @InvocableVariable(label='Collection 1')
        global List<ParsedJsonOutput> collection1;

        @InvocableVariable(label='Collection 2')
        global List<ParsedJsonOutput> collection2;

        @InvocableVariable(label='Response Json')
        global String responseJson;

        // allow access to this input for error handling
        @InvocableVariable(label='Service Endpoint Developer Name' description='Service_Endpoint__mdt DeveloperName')
        global String serviceEndpoint;

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

    @InvocableMethod (label='Make Callout' callout=true category='Invocable Callouts' configurationEditor='dynamic_comp-generic-invocable-request-configuration-editor')
    global static List<Response> invoke(List<Request> requests) {
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

    public Map<String, Object> retrieve(String recordId, String serviceEndpoint, Map<String, Object> calloutParams){
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