public with sharing class InvocableJSONParser {
    @InvocableMethod (label='Parse JSON' category='String Utilities')
    public static List<Output> invoke(List<Input> requests) {
        List<Output> results = new List<Output>();
        for(Input request : requests) {
            results.add(parseJson(request));
        }

        return results;
    }

    public static Output parseJson(Input request) {
        Output output = new Output();
        Map<String, Object> parsedMap = (Map<String, Object>)JSON.deserializeUntyped(request.jsonStr);
        populateParsedJsonOutputs(output.outputs, request, parsedMap);
        populateParsedCollections(output, request, parsedMap);

        return output;
    }

    private static void populateParsedJsonOutputs(ParsedJsonOutput parsedJsonOutputs, Input request, Map<String, Object> parsedMap) {
        parsedJsonOutputs.output1 = extractStringFromParsedMap(request.path1, parsedMap);
        parsedJsonOutputs.output2 = extractStringFromParsedMap(request.path2, parsedMap);
        parsedJsonOutputs.output3 = extractStringFromParsedMap(request.path3, parsedMap);
        parsedJsonOutputs.output4 = extractStringFromParsedMap(request.path4, parsedMap);
        parsedJsonOutputs.output5 = extractStringFromParsedMap(request.path5, parsedMap);
        parsedJsonOutputs.output6 = extractStringFromParsedMap(request.path6, parsedMap);
        parsedJsonOutputs.output7 = extractStringFromParsedMap(request.path7, parsedMap);
        parsedJsonOutputs.output8 = extractStringFromParsedMap(request.path8, parsedMap);
        parsedJsonOutputs.output9 = extractStringFromParsedMap(request.path9, parsedMap);
        parsedJsonOutputs.output10 = extractStringFromParsedMap(request.path10, parsedMap);
        parsedJsonOutputs.output11 = extractStringFromParsedMap(request.path11, parsedMap);
        parsedJsonOutputs.output12 = extractStringFromParsedMap(request.path12, parsedMap);
        parsedJsonOutputs.output13 = extractStringFromParsedMap(request.path13, parsedMap);
        parsedJsonOutputs.output14 = extractStringFromParsedMap(request.path14, parsedMap);
        parsedJsonOutputs.output15 = extractStringFromParsedMap(request.path15, parsedMap);
    }

    private static void populateParsedCollections(Output output, Input request, Map<String, Object> parsedMap) {
        output.collectionOutputs1 = extractCollectionElementFromResponse(request.collectionPath1, request.collectionKeys1, parsedMap);
        output.collectionOutputs2 = extractCollectionElementFromResponse(request.collectionPath2, request.collectionKeys2, parsedMap);
    }

    public static Object extractObjectFromResponse(String keyPath, Map<String, Object> responseMap) {
        if(String.isEmpty(keyPath)) {
            return null;
        }

        Object currentPathValue = responseMap;
        List<String> pathKeys = keyPath.split('\\.');
        for(String key : pathKeys) {
            try {
                if(key.endsWith(']')) {
                    Integer indexOfStartingBracket = key.indexOf('[');
                    String keyWithoutBrackets = key.left(indexOfStartingBracket);
                    List<Object> objectList = (List<Object>)((Map<String, Object>)currentPathValue).get(keyWithoutBrackets);
                    Integer index = Integer.valueOf(key.substring(keyWithoutBrackets.length() + 1, key.length() - 1));
                    currentPathValue = index < objectList.size() ? objectList.get(index) : null;
                } else {
                    currentPathValue = ((Map<String, Object>)currentPathValue).get(key);
                }

                if(currentPathValue == null) {
                    return null;
                }
            } catch(Exception ex) {
                System.debug('exception parsing path key ' + key + '\nkeyPath: ' + keyPath + '\n' + ex + '\nstack: ' + ex.getStackTraceString());
                return null;
            }
        }

        return currentPathValue;
    }

    public static String extractStringFromParsedMap(String keyPath, Map<String, Object> responseMap) {
        Object currentPathValue = extractObjectFromResponse(keyPath, responseMap);
        return currentPathValue == null ? null : String.valueOf(currentPathValue);
    }

    private static ParsedJsonOutput getParsedJsonOutputFromKeys(List<String> keys, Object obj) {
        Map<String, Object> parsedJsonMap = new Map<String, Object>();
        Integer keysSize = keys.size();
        String outputPrefix = 'output';
        for(Integer keyIndex = 0; keyIndex < keysSize; keyIndex++) {
            parsedJsonMap.put(outputPrefix + (keyIndex + 1), extractStringFromParsedMap(keys[keyIndex], (Map<String, Object>)obj));
        }

        return (ParsedJsonOutput)JSON.deserialize(JSON.serialize(parsedJsonMap), ParsedJsonOutput.class);
    }

    private static ParsedJsonOutput parseJsonOutput(Object obj, List<String> keys) {
        ParsedJsonOutput parsedJsonOutput;
        if(keys == null) {
            parsedJsonOutput = new ParsedJsonOutput();
            parsedJsonOutput.output1 = (String)obj;
        } else {
            parsedJsonOutput = getParsedJsonOutputFromKeys(keys, obj);
        }

        return parsedJsonOutput;
    }

    private static List<ParsedJsonOutput> extractCollectionElementFromResponse(String keyPath, String collectionKeys, Map<String, Object> responseMap) {
        if(String.isEmpty(keyPath)) {
            return null;
        }

        List<ParsedJsonOutput> parsedJsonOutputs = new List<ParsedJsonOutput>();
        String collectionJSON = JSON.serialize(InvocableJSONParser.extractObjectFromResponse(keyPath, responseMap));
        List<String> keys = collectionKeys?.split(';');
        List<Object> collectionObjects = (List<Object>)JSON.deserializeUntyped(collectionJSON);
        if(collectionObjects != null) {
            for (Object obj : collectionObjects) {
                parsedJsonOutputs.add(parseJsonOutput(obj, keys));
            }
        }

        return parsedJsonOutputs.isEmpty() ? null : parsedJsonOutputs;
    }

    public class Input {
        @InvocableVariable(label='JSON String' required=true)
        public String jsonStr;

        @InvocableVariable(label='Path 1' description='JSON path for output value' required=false)
        public String path1;

        @InvocableVariable(label='Path 2' description='JSON path for output value' required=false)
        public String path2;

        @InvocableVariable(label='Path 3' description='JSON path for output value' required=false)
        public String path3;

        @InvocableVariable(label='Path 4' description='JSON path for output value' required=false)
        public String path4;

        @InvocableVariable(label='Path 5' description='JSON path for output value' required=false)
        public String path5;

        @InvocableVariable(label='Path 6' description='JSON path for output value' required=false)
        public String path6;

        @InvocableVariable(label='Path 7' description='JSON path for output value' required=false)
        public String path7;

        @InvocableVariable(label='Path 8' description='JSON path for output value' required=false)
        public String path8;

        @InvocableVariable(label='Path 9' description='JSON path for output value' required=false)
        public String path9;

        @InvocableVariable(label='Path 10' description='JSON path for output value' required=false)
        public String path10;

        @InvocableVariable(label='Path 11' description='JSON path for output value' required=false)
        public String path11;

        @InvocableVariable(label='Path 12' description='JSON path for output value' required=false)
        public String path12;

        @InvocableVariable(label='Path 13' description='JSON path for output value' required=false)
        public String path13;

        @InvocableVariable(label='Path 14' description='JSON path for output value' required=false)
        public String path14;

        @InvocableVariable(label='Path 15' description='JSON path for output value' required=false)
        public String path15;

        @InvocableVariable(label='Collection Path 1' description='JSON path for collection output value' required=false)
        public String collectionPath1;

        @InvocableVariable(label='Collection Path 2' description='JSON path for collection output value' required=false)
        public String collectionPath2;

        @InvocableVariable(label='Collection Keys 1' description='Collection Keys For object in collection' required=false)
        public String collectionKeys1;

        @InvocableVariable(label='Collection Keys 2' description='Collection Keys For object in collection' required=false)
        public String collectionKeys2;
    }

    public class Output {
        @InvocableVariable(label='Outputs')
        public ParsedJsonOutput outputs = new ParsedJsonOutput();

        @InvocableVariable(label='Collection Outputs 1')
        public List<ParsedJsonOutput> collectionOutputs1;

        @InvocableVariable(label='Collection Outputs 2')
        public List<ParsedJsonOutput> collectionOutputs2;
    }
}