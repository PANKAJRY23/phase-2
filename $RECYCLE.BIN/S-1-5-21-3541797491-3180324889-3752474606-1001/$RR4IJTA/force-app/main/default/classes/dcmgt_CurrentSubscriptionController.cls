public with sharing class dcmgt_CurrentSubscriptionController {
    
    @AuraEnabled
    public static list<dcmgt_Data_Asset_Sub_Request__c> getAllCurrentSubscriptionRec(){
        try {
            return [select id, dcmgt_Data_Subscription_Request__r.dcmgt_Alation_Data_Dictionary__r.Name, 
                        dcmgt_Data_Subscription_Request__r.dcmgt_Alation_Data_Dictionary__c,
                        dcmgt_Data_Asset_Name__c, dcmgt_Expiration_Date__c from dcmgt_Data_Asset_Sub_Request__c 
                        where dcmgt_Data_Subscription_Request__r.dcmgt_Status__c = 'Approved' 
                        WITH SECURITY_ENFORCED limit 50000];
                    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string extendApprovedSubscriptionRec(string ids, string extendComment, string extendedTime){
        try {
            if(string.isNotBlank(Ids)){
                 List<String> lstOfDataAssetsId = ids.split(',');
                 
                 
                 list<dcmgt_Data_Asset_Sub_Request__c> listOfSubRequest = [select id, dcmgt_Data_Subscription_Request__r.dcmgt_Alation_Data_Dictionary__r.Name, 
                                                                                dcmgt_Data_Asset_Name__c, dcmgt_Expiration_Date__c, dcmgt_Access_Layer__c,
                                                                                dcmgt_Comunication_Email_Chatter__c, dcmgt_Data_Asset_Type__c, 
                                                                                dcmgt_Data_Asset_USC_ID__c, dcmgt_Data_Load__c, 
                                                                                dcmgt_Refresh_Frequency__c, dcmgt_SLA__c, 
                                                                                dcmgt_Data_Subscription_Request__c from 
                                                                                dcmgt_Data_Asset_Sub_Request__c where id in : lstOfDataAssetsId 
                                                                                WITH SECURITY_ENFORCED limit 10000];
                 set<id> parentIdSet = new set<id>();                                                             
                 for(dcmgt_Data_Asset_Sub_Request__c subRequestRec: listOfSubRequest){
                     parentIdSet.add(subRequestRec.dcmgt_Data_Subscription_Request__c);
                 }
                 
                 if(parentIdSet.Size()>1){
                     return 'error';
                 }else if(parentIdSet.Size() == 1){
                    dcmgt_Data_Sub_Request__c parentRecordList = [select dcmgt_Requestor__c, dcmgt_Service__c, dcmgt_Tenant__c, 
                                                                         dcmgt_Business_Justification__c, dcmgt_Access_Layer__c, 
                                                                         dcmgt_Alation_Data_Dictionary__c, dcmgt_Consumption_Preference__c, 
                                                                         dcmgt_Data_Owner__c, dcmgt_Data_Retention_Policy__c, dcmgt_Data_Steward__c, 
                                                                         dcmgt_Desired_Data_SLA__c, dcmgt_Desired_Refresh_Frequency__c, 
                                                                         dcmgt_On_Call_Information__c, dcmgt_Preferred_Duration__c, 
                                                                         dcmgt_SLA_Expectations__c, dcmgt_System_Account__c, dcmgt_Total_Data_Contract__c
                                                                         from dcmgt_Data_Sub_Request__c where id in :parentIdSet 
                                                                         WITH SECURITY_ENFORCED limit 1];
                                                                         
                     dcmgt_Data_Contract__c dataContractRec = new dcmgt_Data_Contract__c();
                     dataContractRec.dcmgt_Version__c = parentRecordList.dcmgt_Total_Data_Contract__c + 1;
                     dataContractRec.dcmgt_Data_Subscription_Request__c = parentRecordList.Id;
                     if(Schema.sObjectType.dcmgt_Data_Contract__c.isCreateable()){
                         insert dataContractRec;
                     }
                     
                     system.debug('==dataContractRec=='+dataContractRec);
                     
                     parentRecordList.dcmgt_Comment__c = extendComment;
                     if(Schema.sObjectType.dcmgt_Data_Sub_Request__c.isUpdateable()){
                         update parentRecordList;
                     }
                                                                         
                     
                     for(dcmgt_Data_Asset_Sub_Request__c subRequestRec: listOfSubRequest){
                         if(subRequestRec.dcmgt_Expiration_Date__c != null){
                             subRequestRec.dcmgt_Expiration_Date__c = subRequestRec.dcmgt_Expiration_Date__c.addMonths(integer.valueof(extendedTime));
                         }else{
                             subRequestRec.dcmgt_Expiration_Date__c = system.today().addMonths(integer.valueof(extendedTime));
                         }
                     }
                     if(Schema.sObjectType.dcmgt_Data_Asset_Sub_Request__c.isUpdateable()){
                         update listOfSubRequest;
                         return 'success';
                     }else{
                         return 'error';
                     }
                     
                 }
            }
            
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}