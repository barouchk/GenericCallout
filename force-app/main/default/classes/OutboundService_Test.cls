/**
 * Created by ilana.brodsky on 10/08/2020.
    * @modifiedBy     
    * @version        
    * @created        10/08/2020
    * @modified      
 */
@IsTest
private with sharing class OutboundService_Test {

    @isTest
    private static void sendTest() {
        Test.startTest();
        OutboundService serviceTest = OutboundService.getInstance();
        Test.setMock(HttpCalloutMock.class, new ApiGWServiceMock());
        String payload = '{"RequestHeader":{"TransactionID":"fc1ef3e4-5353-8420-9976-dd7214989609","Timeout":50,"ServiceName":"BPM-CreateLead","EnvCode":"SalesForce_DEV","Destinations":{"Yes":"N","Pelephone":"Y","BBL":"N"},"AppID":"SalesForce"},"InParams":{"Phone":"0524972554","LastName":"חברה בעמ","ID_Type":"TZ1","Id_Number":null,"Id":"00Q3H000002Phh6UAC","Handling_Queue":null,"Given_Offer":null,"FirstName":null,"Email":null,"Customer_Type":"PRV","Customer_Number":null,"Create_User":null,"Convert_User":null,"Company":"PEL","City":null,"Additional_Phone":null}}';
        HTTPResponse response = serviceTest.send('ApiGateway', 'CreateLead', payload);
        Test.stopTest();

        System.assertEquals(ApiGWServiceMock.RESPONSE_BODY, response.getBody(), 'Incorrect Body');
        System.assertEquals('success', response.getStatus(), 'Incorrect Status');
        System.assertEquals('application/json;charset=utf-8', response.getHeader('Content-Type'), 'Incorrect Header Content-Type');
        System.assertEquals(200, response.getStatusCode(), 'Incorrect Status Code');
    }
}