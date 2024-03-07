public with sharing class GenericRequestConfigurationController {
    @AuraEnabled
    public static List<Service_Endpoint__mdt> getCustomMetadata(){
        try {
            return [SELECT Id,DeveloperName FROM Service_Endpoint__mdt];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}