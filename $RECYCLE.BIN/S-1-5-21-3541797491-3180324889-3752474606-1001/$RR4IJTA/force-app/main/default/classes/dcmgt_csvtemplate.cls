public class dcmgt_csvtemplate {
  @AuraEnabled(Cacheable = true)
 public static List<dcmgt_CSV_Template_for_ChangeType__c> getCsvTemplateData(Id recordId) {
     String sObjectType=String.valueOf(recordId.getSobjectType());   
 List<dcmgt_CSV_Template_for_ChangeType__c> listData = [select dcmgt_Request_Type__r.Name from dcmgt_CSV_Template_for_ChangeType__c where Id =:recordId];
     return   listData;
     }
}