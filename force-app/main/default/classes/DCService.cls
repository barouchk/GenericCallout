public interface DCService {
    
    Map<String, Object> retrive(String recordId, String serviceEndpoint, Map<String, Object> calloutParams);
}