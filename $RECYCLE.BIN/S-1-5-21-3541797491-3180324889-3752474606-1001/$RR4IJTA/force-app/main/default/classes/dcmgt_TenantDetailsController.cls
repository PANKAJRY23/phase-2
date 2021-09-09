public with sharing class dcmgt_TenantDetailsController {
    @AuraEnabled(Cacheable = true)
    public static List<dcmgt_Team__c> getTenantsByCurrentUser(){
        try {
            return [SELECT Id, Name, dcmgt_Team_Description__c, 
                        dcmgt_Team_Owner__c, dcmgt_Team_Owner__r.Email 
                    FROM dcmgt_Team__c 
                    WHERE Id IN (
                        SELECT dcmgt_Team__c 
                        FROM dcmgt_Team_Member__c  
                        WHERE dcmgt_Team_Member_Name__c = :UserInfo.getUserId())];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static dcmgt_Team__c createTeamMenberForTenant(Id tenantId){
        try {
            dcmgt_Team_Member__c teamMember = new dcmgt_Team_Member__c(
                dcmgt_Role__c = 'Other',
                dcmgt_Team__c = tenantId,
                dcmgt_Team_Member_Name__c = UserInfo.getUserId()
            );
            insert teamMember;
            return [SELECT Id, Name, dcmgt_Team_Description__c, 
                        dcmgt_Team_Owner__c, dcmgt_Team_Owner__r.Email 
                    FROM dcmgt_Team__c 
                    WHERE Id = :tenantId];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}