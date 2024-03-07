@IsTest
private with sharing class InvocableJSONParserTest {
    @IsTest
    private static void testParser() {
        List<InvocableJSONParser.Output> outputs = InvocableJSONParser.invoke(new List<InvocableJSONParser.Input>{getInvocableJsonParserInput()});
        System.debug('outputs: ' + JSON.serializePretty(outputs));
        System.assertEquals(1, outputs.size());
        for(InvocableJSONParser.Output output : outputs) {
            assertOutputs(output.outputs);
            for(List<ParsedJsonOutput> parsedOutputsList : new List<List<ParsedJsonOutput>>{output.collectionOutputs1, output.collectionOutputs2}) {
                System.assertNotEquals(0, parsedOutputsList.size());
                for(ParsedJsonOutput parsedOutputs : parsedOutputsList) {
                    assertOutputs(parsedOutputs);
                }
            }
        }
    }

    private static InvocableJSONParser.Input getInvocableJsonParserInput() {
        InvocableJSONParser.Input input = new InvocableJSONParser.Input();
        input.jsonStr = (String)JSON.serialize(new Map<String, Object>{'wrapper' => new List<Object>{assembleOutputs()}});
        /* object will be: {
            "wrapper": [
                {
                    "key1": "value1",
                    "key2": "value2",
                    ...
                }
            ]
        }*/
        input.path1 = 'wrapper[0].key1';
        input.path2 = 'wrapper[0].key2';
        input.path3 = 'wrapper[0].key3';
        input.path4 = 'wrapper[0].key4';
        input.path5 = 'wrapper[0].key5';
        input.path6 = 'wrapper[0].key6';
        input.path7 = 'wrapper[0].key7';
        input.path8 = 'wrapper[0].key8';
        input.path9 = 'wrapper[0].key9';
        input.path10 = 'wrapper[0].key10';
        input.path11 = 'wrapper[0].key11';
        input.path12 = 'wrapper[0].key12';
        input.path13 = 'wrapper[0].key13';
        input.path14 = 'wrapper[0].key14';
        input.path15 = 'wrapper[0].key15';
        input.collectionPath1 = 'wrapper[0].collection1';
        input.collectionPath2 = 'wrapper[0].collection2';
        List<String> keysList = new List<String>();
        for(Integer i = 1; i < 16; i++) {
            keysList.add('key' + i);
        }
        String keysStr = String.join(keysList, ';');
        input.collectionKeys1 = keysStr;
        input.collectionKeys2 = keysStr;

        System.debug('input: ' + JSON.serializePretty(input));

        return input;
    }

    private static Map<String, Object> populateStringOutputs(Map<String, Object> outputs) {
        for(Integer i = 1; i < 16; i++) {
            outputs.put('key' + i, 'value' + i);
        }

        return outputs;
    }

    private static Map<String, Object> assembleOutputs() {
        Map<String, Object> outputs = new Map<String, Object>();
        populateStringOutputs(outputs);

        for(Integer i = 1; i < 3; i++) {
            outputs.put('collection' + i, new List<Object>{populateStringOutputs(new Map<String, Object>())});
        }

        return outputs;
    }

    private static void assertOutputs(ParsedJsonOutput parsedOutput) {
        Integer index = 1;
        for(String outputValue : new List<String>{
                parsedOutput.output1, parsedOutput.output2, parsedOutput.output3, parsedOutput.output4, parsedOutput.output5,
                parsedOutput.output6, parsedOutput.output7, parsedOutput.output8, parsedOutput.output9, parsedOutput.output10,
                parsedOutput.output11, parsedOutput.output12, parsedOutput.output13, parsedOutput.output14, parsedOutput.output15
        }) {
            System.assertEquals('value' + index++, outputValue);
        }
    }
}