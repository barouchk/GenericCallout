public with sharing class CustomDCClass implements DCService{

    public Map<String, Object> retrieve(String recordId, String serviceEndpoint, Map<String, Object> calloutParams){

        Map<String, Object> result = new Map<String, Object>();
        if(String.isNotBlank(serviceEndpoint)){
            Map<String, Object> serviceResult = GenericInvocableRequest.makeCallout(serviceEndpoint, calloutParams);
            if(!serviceResult.isEmpty()){
                result.putAll(serviceResult);
            }
        }

        Opportunity opp = [SELECT Name FROM Opportunity WHERE Id =: recordId LIMIT 1];

        result.put('oppName', opp.Name);

        return result;
    }
}