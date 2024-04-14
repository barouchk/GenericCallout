public interface DCService {
    
    Map<String, Object> retrieve(String recordId, String serviceEndpoint, Map<String, Object> calloutParams);
}