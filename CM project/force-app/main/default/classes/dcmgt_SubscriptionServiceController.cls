public with sharing class dcmgt_SubscriptionServiceController {
    
    @AuraEnabled(Cacheable = true)
    public static List<dcmgt_Service__c> getServiceByTeamId(Id teamId){
        try {
        
             list<dcmgt_Service__c> listOfServiceAll= new list<dcmgt_Service__c>();
            
            list<dcmgt_Data_Sub_Request__c> listOfDataSub = getSubRequest();
            Set<Id> SerivceIdSet = new Set<Id>(); 
            if(!listOfDataSub.IsEmpty()){  
                                                                           
                for(dcmgt_Data_Sub_Request__c request: listOfDataSub){
                    if(request.dcmgt_Tenant__c == teamId && request.dcmgt_Service__c != null){
                        SerivceIdSet.add(request.dcmgt_Service__c);
                    }
                }
                if(!SerivceIdSet.IsEmpty()){
                        list<dcmgt_Service__c> listOfSerivce = [SELECT Id, Name, dcmgt_Data_Classification__c, 
                                                            dcmgt_Service_Description__c, 
                                                            dcmgt_Service_Owner__c, dcmgt_System_Account__c , 
                                                            dcmgt_Service_Owner__r.dcmgt_Team_Owner__r.Email
                                                            FROM dcmgt_Service__c 
                                                            WHERE id in:SerivceIdSet WITH SECURITY_ENFORCED limit 10000]; 
                        listOfServiceAll.addall(listOfSerivce);  
                }
            }                         
        
        
            list<dcmgt_Service__c> listOfSerivceMain = [SELECT Id, Name, dcmgt_Data_Classification__c, 
                                                        dcmgt_Service_Description__c, 
                                                        dcmgt_Service_Owner__c, dcmgt_System_Account__c , 
                                                        dcmgt_Service_Owner__r.dcmgt_Team_Owner__r.Email
                                                        FROM dcmgt_Service__c 
                                                        WHERE dcmgt_Service_Owner__c = :teamId and Id not in :SerivceIdSet 
                                                        WITH SECURITY_ENFORCED limit 10000];
        
        
            listOfServiceAll.addall(listOfSerivceMain);  
        
        
            return listOfServiceAll;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static list<dcmgt_Data_Sub_Request__c> getSubRequest(){
        return [select id, dcmgt_Service__c, dcmgt_Tenant__c from dcmgt_Data_Sub_Request__c 
                    where dcmgt_Requestor__c= :UserInfo.getUserId()and dcmgt_Status__c = 'Draft' 
                    WITH SECURITY_ENFORCED limit 1];
    }
    
    @AuraEnabled
    public static void updateDataSubRequestRecMethod(string serviceId){
        try {
            list<dcmgt_Data_Sub_Request__c> listOfDataSub = getSubRequest();
            if(!listOfDataSub.IsEmpty() && string.isNotBlank(serviceId)){                                                                
                for(dcmgt_Data_Sub_Request__c request: listOfDataSub){
                    request.dcmgt_Service__c = serviceId;
                }     
            }  
           if(Schema.sObjectType.dcmgt_Data_Sub_Request__c.isUpdateable()){
                update listOfDataSub;
           }
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static dcmgt_Service__c getServiceById(Id serviceId, String tenantId){
        try {
            if(!String.isBlank(tenantId)) {
                dcmgt_Service__c service = new dcmgt_Service__c(
                    Id = serviceId,
                    dcmgt_Service_Owner__c = tenantId
                );
                if(Schema.sObjectType.dcmgt_Service__c.isUpdateable() || Schema.sObjectType.dcmgt_Service__c.isCreateable() ){
                    upsert service;
                }
            }
            return [SELECT Id, Name, dcmgt_Data_Classification__c, 
                    dcmgt_Service_Description__c, 
                    dcmgt_Service_Owner__c, dcmgt_System_Account__c , 
                    dcmgt_Service_Owner__r.dcmgt_Team_Owner__r.Email
                    FROM dcmgt_Service__c 
                    WHERE Id = :serviceId WITH SECURITY_ENFORCED limit 10000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}