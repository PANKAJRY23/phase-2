public class dcmgt_CsvTemplateForUpload {
 @AuraEnabled
 public static List<dcmgt_CSV_Template_for_ChangeType__c> updateCsvTemplateData(Id recordId, String fieldNames) { 
       // String sObjectType=String.valueOf(recordId.getSobjectType()); 
        System.debug('entered:   record ID:'+recordId + '    fieldnamesssssssss :'+ fieldNames);
        fieldNames = fieldNames.removeEnd(',');
        List<dcmgt_CSV_Template_for_ChangeType__c> listData = [select Name,dcmgt_Fields__c from dcmgt_CSV_Template_for_ChangeType__c where Id =:recordId];
        if (!listData.isEmpty()) {
        dcmgt_CSV_Template_for_ChangeType__c csv=listData[0];
         csv.dcmgt_Fields__c = fieldNames;
         update csv; 
        }
        return listData;
      
}
}