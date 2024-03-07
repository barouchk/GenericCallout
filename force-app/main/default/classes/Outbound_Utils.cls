/**
 * Created by ilana.brodsky on 30/08/2020.
    * @modifiedBy     
    * @version        
    * @created        30/08/2020
    * @modified      
 */

public without sharing class Outbound_Utils {
    private static  EnvSettings__c envSettings = EnvSettings__c.getInstance('Main');
    final static String SALESFORCE = 'SalesForce';
    public String generateUUID(){
        Blob b = Crypto.GenerateAESKey(128);
        String convertedToHex = EncodingUtil.ConvertTohex(b);
        String guid = convertedToHex.SubString(0,8)+ '-' + convertedToHex.SubString(8,12)
                + '-' + convertedToHex.SubString(12,16) + '-'
                + convertedToHex.SubString(16,20) + '-' + convertedToHex.substring(20);
        return guid;
    }
    /**
     * Generate Log Header For MDM CallOuts
     */
    public  Map<String,Object> generateLogHeader(){

        User currentUser = [
                SELECT FederationIdentifier 
                  FROM User 
                 WHERE Id = :UserInfo.getUserId()
                ]; 

       return new Map<String,Object>{
            'RequestHeader'  => new Map<String,Object>{
                                    'FromSystem'     => 'Salesforce',
                                    'ToSystem'       => 'K2VIEW',
                                    'TransactionId'  => generateUUID(),
                                    'UserIdentifier' => currentUser.FederationIdentifier,
                                    'token'          => getTokenFromEnvSetting()
                                    }
            };
    }

    public static String getEnvCode(){
        EnvSettings__c envSettings = EnvSettings__c.getInstance('Main');
        return  SALESFORCE + '_' + envSettings.Env__c;
    }
    public String getTokenFromEnvSetting(){
        return envSettings.EndPoint_Token__c.substringAfter('=');

    }

}