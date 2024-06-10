@IsTest
private class CustomComponentTest {

    private static final String WRAPPER_NAME = 'Products_Table';

    static void generateDataModel(){
        
        DC_Wrapper__mdt wrapper = new DC_Wrapper__mdt(

            Label = 'מוצרים', 
            DeveloperName = WRAPPER_NAME,
            Icon__c = 'standard:account', 
            Display_Type__c = 'Table', 
            Card_Header_Style__c = 'Page Header',
            Illustration__c = 'No Events', 
            Illustration_Size__c = 'large', 
            No_Data_Message__c = '', 
            Max_Row_Selection__c = 10, 
            Show_Row_Number__c = true
        );

        // insert wrapper;

        DC_Field__mdt field1 = new DC_Field__mdt(
            Label = 'שם פרטי',
            DeveloperName = 'First_Name',
            Field_API_Name__c = 'firstName',
            Wrapper__c = wrapper.Id,
            Type__c = 'Text',
            Source__c = 'Service',
            Order__c = 1
        );
        
        DC_Field__mdt field2 = new DC_Field__mdt(
            Label = 'שם משפחה',
            DeveloperName = 'Last_Name',
            Field_API_Name__c = 'lastName',
            Wrapper__c = wrapper.Id,
            Type__c = 'Text',
            Source__c = 'Service',
            Order__c = 1
        );

        List<DC_Field__mdt> fields = new List<DC_Field__mdt>{ field1, field2 };

        // insert fields;
    } 
    
    @IsTest
    private static void generateDynamicComponent (){
        Test.startTest();
        CustomComponent.wireGetWrapperModel(WRAPPER_NAME);
        Test.stopTest();
    }
}