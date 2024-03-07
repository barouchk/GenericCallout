@IsTest
private with sharing class GenericInvocableRequestTest {

    private static String getBuildingPairJSON ( String id, String description){
        return '{"Description":"'+ description +'","BuildingId":"' + id + '"}';
    }

    private static GenericInvocableRequest.Request createGenericRequest(String serviceEndpoint, String output5Path) {
        GenericInvocableRequest.Request genericRequest = new GenericInvocableRequest.Request();
        genericRequest.serviceEndpoint = serviceEndpoint;
        genericRequest.paramsJson = '{"BuildingType":"BIL","ChosenBuildingId":"283801","City":"מזכרת בתיה","EmployeeCode":"YMQ","Entrance":"NO_ENTRANCE","Street":"שד בגין מנחם","StreetNumber":"22","UnitNumber":"451"}';
        genericRequest.statusCodePath = 'OutParams.Result.messageCode';
        genericRequest.statusDescPath = 'OutParams.Result.message';
        genericRequest.output1Path = 'OutParams.workOrderNumber';
        genericRequest.output2Path = 'OutParams.DwellingDescr';
        genericRequest.output3Path = 'OutParams.DropDescr';
        genericRequest.output4Path = 'OutParams.SupplAddrLineList.BuildingIdPair[0].BuildingId';
        genericRequest.output5Path = output5Path;
        genericRequest.outputCollection1Keys= 'BuildingId;Description';
        genericRequest.outputCollection1Path = 'OutParams.SupplAddrLineList.BuildingIdPair';

        return genericRequest;
    }

    private static void assertResponse(
            GenericInvocableRequest.Response response, String expectedStatusCode, String expectedStatusDesc, String expectedOutput1,
            String expectedOutput2, String expectedOutput3, String expectedOutput4, String expectedOutput5, String expectedResponseJson) {
        System.assertEquals(expectedStatusCode, response.statusCode);
        System.assertEquals(expectedStatusDesc, response.statusDesc);
        System.assertEquals(expectedOutput1, response.output1);
        System.assertEquals(expectedOutput2, response.output2);
        System.assertEquals(expectedOutput3, response.output3);
        System.assertEquals(expectedOutput4, response.output4);
        System.assertEquals(expectedOutput5, response.output5);
        System.assertEquals(JSON.serialize(JSON.deserializeUntyped(expectedResponseJson)), response.responseJson);
    }
}