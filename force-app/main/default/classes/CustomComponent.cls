public with sharing class CustomComponent {

    @AuraEnabled(cacheable=true)
    public static WrapperInfo wireGetWrapperModel(String developerName) {
        DC_Wrapper__mdt wrapper = CustomComponent.getWrapperModel(developerName);
        return fillWrapperInfo(wrapper);
    }

    @AuraEnabled(cacheable=false)
    public static Object getClassResult(String apexClass, String recordId, String serviceEndpoint, Map<String,Object> calloutParams) {

        DCService service = (DCService) Type.forName(apexClass).newInstance();
        Map<String, Object> result = service.retrieve(recordId, serviceEndpoint, calloutParams);

        if (result != null && !result.IsEmpty()) {
            return result;
        }

        return null;
    }

    public static DC_Wrapper__mdt getWrapperModel(String developerName) {

        List<DC_Wrapper__mdt> wrappers = [
            SELECT Id, Label, Icon__c, Display_Type__c, Apex_Class__c,
            Is_Nested_Card__c, Hide_Card_Header__c, Card_Header_Style__c,
            Illustration__c, Illustration_Size__c, No_Data_Message__c, 
            Max_Row_Selection__c, Show_Row_Number__c,
            Service_Endpoint__r.DeveloperName, Data_Path__c,
            (SELECT Id, Label, Source__c, Order__c, Field_API_Name__c,Type__c,
            Is_Hidden_When_Empty__c, toLabel__c,
            DC_Section__c, DC_Section__r.DeveloperName, DC_Section__r.Label, 
            DC_Section__r.Order__c, DC_Section__r.Default_Open__c
            FROM dc_fields__r WHERE Active__c = true ORDER BY Order__c),
            (SELECT Id, Label, DeveloperName, Type__c, Flow_Name__c, Order__c 
            FROM DC_Actions__r WHERE Active__c = true ORDER BY Order__c)
        FROM  DC_Wrapper__mdt
        WHERE DeveloperName =: developerName LIMIT 1];

        if(!wrappers.isEmpty()){
            return wrappers[0];
        }
        
        return null;
    }

    public static WrapperInfo fillWrapperInfo(DC_Wrapper__mdt wrapper) {

        WrapperInfo wrapperInfo = null;

        if(wrapper != null){
            wrapperInfo = new WrapperInfo();
            wrapperInfo.title = wrapper.Label;
            wrapperInfo.icon = wrapper.Icon__c;
            wrapperInfo.type = wrapper.Display_Type__c;
            wrapperInfo.serviceEndpoint = wrapper.Service_Endpoint__r.DeveloperName;
            wrapperInfo.dataPath = wrapper.Data_Path__c;
            wrapperInfo.maxRowSelection = wrapper.Max_Row_Selection__c;
            wrapperInfo.showRowNumber = wrapper.Show_Row_Number__c;
            wrapperInfo.apexClass = wrapper.Apex_Class__c;
            wrapperInfo.isNestedCard = wrapper.Is_Nested_Card__c;
            wrapperInfo.hideHeader = wrapper.Hide_Card_Header__c;
            wrapperInfo.headerStyle = wrapper.Card_Header_Style__c;
            wrapperInfo.illustration = wrapper.Illustration__c;
            wrapperInfo.illustrationSize = wrapper.Illustration_Size__c;
            wrapperInfo.noDataMessage = wrapper.No_Data_Message__c;

            wrapperInfo.columns = getColumns(wrapper.Display_Type__c, wrapper.dc_fields__r);
            wrapperInfo.actions = getActions(wrapper.DC_Actions__r);
        }

        return wrapperInfo;
    }

    public static List<FieldInfo> getColumns(String wrapperType, List<DC_Field__mdt> fieldList) {
        List<FieldInfo> fieldInfoResult = new List<FieldInfo>();
        for (DC_Field__mdt oneField : fieldList) {

            String fieldType = oneField.Type__c;
            String formatter = '';

            if(wrapperType != 'Table' && (fieldType == 'currency' || fieldType == 'percent')){
                    formatter = fieldType;
                    fieldType = 'number';
            }

            FieldInfo fieldInfo = new fieldInfo(
                oneField.Field_API_Name__c, 
                oneField.Label,
                fieldType, 
                formatter,
                oneField.Source__c, 
                oneField.Is_Hidden_When_Empty__c);

            if(String.isNotBlank(oneField.DC_Section__c)){
                fieldInfo.section = new SectionInfo(
                    oneField.DC_Section__r.DeveloperName,
                    oneField.DC_Section__r.Label,
                    oneField.DC_Section__r.Order__c,
                    oneField.DC_Section__r.Default_Open__c                   
                );
            }

            fieldInfoResult.add(fieldInfo);
        }

        return fieldInfoResult;
    }

    public static List<ActionInfo> getActions(List<DC_Action__mdt> actionList){
        List<ActionInfo> actions = new List<ActionInfo>();
        for(DC_Action__mdt action : actionList){
            actions.add(new ActionInfo(
                action.Label,
                action.DeveloperName,
                action.Flow_Name__c,
                action.Type__c,
                action.Order__c 
            ));
        }
        return actions;
    }

    public class WrapperInfo {

        @AuraEnabled
        public String title {get;set;}

        @AuraEnabled
        public String icon {get;set;}

        @AuraEnabled
        public String type {get;set;}

        @AuraEnabled
        public String serviceEndpoint {get;set;}
        
        @AuraEnabled
        public String dataPath {get;set;}

        @AuraEnabled
        public Decimal maxRowSelection {get;set;}

        @AuraEnabled
        public Boolean showRowNumber {get;set;}

        @AuraEnabled
        public String apexClass {get;set;}

        @AuraEnabled
        public List<FieldInfo> columns {get;set;}

        @AuraEnabled
        public Boolean isNestedCard {get;set;}

        @AuraEnabled
        public Boolean hideHeader {get;set;}

        @AuraEnabled
        public String headerStyle {get;set;}

        @AuraEnabled
        public String illustration {get;set;}

        @AuraEnabled
        public String illustrationSize {get;set;}

        @AuraEnabled
        public String noDataMessage {get;set;}

        @AuraEnabled
        public List<ActionInfo> actions {get;set;}
    }

    public class SectionInfo {
        @AuraEnabled
        public String id {get;set;}  

        @AuraEnabled
        public String title {get;set;}  

        @AuraEnabled
        public Decimal order {get;set;}  

        @AuraEnabled
        public Boolean isDefaultOpen {get;set;} 

        public SectionInfo(){

        }

        public SectionInfo(String id, String title, Decimal Order, Boolean isDefaultOpen){
            this.id = id;
            this.title = title;
            this.order = order;
            this.isDefaultOpen = isDefaultOpen;
        }
    }

    public class FieldInfo {
        @AuraEnabled
        public String fieldName {get;set;}

        @AuraEnabled
        public String label {get;set;} 
        
        @AuraEnabled
        public String type {get;set;} 

        @AuraEnabled
        public String formatter {get;set;} 

        @AuraEnabled
        public String source {get;set;} 

        @AuraEnabled
        public Boolean isHiddenWhenEmpty {get;set;} 

        @AuraEnabled
        public SectionInfo section {get;set;} 

        public FieldInfo(){

        }

        public FieldInfo(String fieldName, String label, String type,String formatter, String source, Boolean isHiddenWhenEmpty){
            this.fieldName = fieldName;
            this.label = label;
            this.type = type;
            this.formatter = formatter;
            this.source = source;
            this.isHiddenWhenEmpty = isHiddenWhenEmpty;
        }
    }

    public class ActionInfo {
        @AuraEnabled
        public String label {get;set;}

        @AuraEnabled
        public String name {get;set;}

        @AuraEnabled
        public String flowName {get;set;}

        @AuraEnabled
        public String type {get;set;}

        @AuraEnabled
        public Decimal order {get;set;}

        public ActionInfo(){

        }

        public ActionInfo(String label, String name, String flowName, String type, Decimal order){
            this.label = label;
            this.name = name;
            this.flowName = flowName;
            this.type = type;
            this.order = order;
        }
    }
}