public with sharing class dcmgt_ServiceDetailsController {
    @AuraEnabled(Cacheable = true)
    public static List<dcmgt_Service__c> getServiceBySelectedTeam(){
        try {
            return [SELECT Id, Name, dcmgt_Data_Classification__c, 
                    dcmgt_Service_Description__c, 
                    dcmgt_Service_Owner__c, dcmgt_System_Account__c , 
                    dcmgt_Service_Owner__r.dcmgt_Team_Owner__r.Email
                    FROM dcmgt_Service__c 
                    WHERE dcmgt_Service_Owner__c = 'a0J5g0000002PQtEAM'];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<dcmgt_Service__c> getServiceByTeamId(Id teamId){
        try {
            return [SELECT Id, Name, dcmgt_Data_Classification__c, 
                    dcmgt_Service_Description__c, 
                    dcmgt_Service_Owner__c, dcmgt_System_Account__c , 
                    dcmgt_Service_Owner__r.dcmgt_Team_Owner__r.Email
                    FROM dcmgt_Service__c 
                    WHERE dcmgt_Service_Owner__c = :teamId];
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
                upsert service;
            }
            return [SELECT Id, Name, dcmgt_Data_Classification__c, 
                    dcmgt_Service_Description__c, 
                    dcmgt_Service_Owner__c, dcmgt_System_Account__c , 
                    dcmgt_Service_Owner__r.dcmgt_Team_Owner__r.Email
                    FROM dcmgt_Service__c 
                    WHERE Id = :serviceId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}