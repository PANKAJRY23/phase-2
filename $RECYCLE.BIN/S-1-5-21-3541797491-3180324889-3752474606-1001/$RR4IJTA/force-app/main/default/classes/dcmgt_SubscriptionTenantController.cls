public with sharing class dcmgt_SubscriptionTenantController {
    @AuraEnabled
    public static List<dcmgt_Team__c> getTenantsByCurrentUser(){
        try {
            Set<Id> setOfTenantId = new Set<Id>();
            Id currentUserId = UserInfo.getUserId();
            list<dcmgt_Team__c> listOfTeamAll= new list<dcmgt_Team__c>();
             Set<Id> TenantIdSet = new Set<Id>();   
            list<dcmgt_Data_Sub_Request__c> listOfDataSub = getSubRequest();
            if(!listOfDataSub.IsEmpty()){  
                                                                        
                for(dcmgt_Data_Sub_Request__c request: listOfDataSub){
                    if(request.dcmgt_Tenant__c != null){
                        TenantIdSet.add(request.dcmgt_Tenant__c);
                    }
                }
                if(!TenantIdSet.IsEmpty()){
                        list<dcmgt_Team__c> listOfTeam = [SELECT Id, Name, dcmgt_Team_Description__c, 
                                dcmgt_Team_Owner__c, dcmgt_Team_Owner__r.Email 
                            FROM dcmgt_Team__c 
                            WHERE (Id IN :TenantIdSet) WITH SECURITY_ENFORCED limit 10000]; 
                        listOfTeamAll.addall(listOfTeam);  
                }
            }                                                   
            
            
            List<dcmgt_Team_Member__c> listOfTeamMember = [SELECT dcmgt_Team__c 
                FROM dcmgt_Team_Member__c  
                WHERE dcmgt_Team_Member_Name__c = :currentUserId WITH SECURITY_ENFORCED limit 10000];
            for(dcmgt_Team_Member__c teamMember: listOfTeamMember) {
                setOfTenantId.add(teamMember.dcmgt_Team__c);
            }
            
            list<dcmgt_Team__c> listOfMainTeam = [SELECT Id, Name, dcmgt_Team_Description__c, 
                    dcmgt_Team_Owner__c, dcmgt_Team_Owner__r.Email 
                    FROM dcmgt_Team__c 
                    WHERE (Id IN :setOfTenantId or dcmgt_Team_Owner__c = :currentUserId ) and id not in :TenantIdSet WITH SECURITY_ENFORCED limit 10000];
            
            listOfTeamAll.addall(listOfMainTeam);
            
            return listOfTeamAll;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static list<dcmgt_Data_Sub_Request__c> getSubRequest(){
        return [select id, dcmgt_Tenant__c, dcmgt_Service__c, dcmgt_Alation_Data_Dictionary__c
                    from dcmgt_Data_Sub_Request__c 
                    where dcmgt_Requestor__c= :UserInfo.getUserId() and dcmgt_Status__c = 'Draft' 
                    WITH SECURITY_ENFORCED limit 1];
    }
    
    @AuraEnabled
    public static list<dcmgt_Data_Sub_Request__c> getSubScriptionRequest(string Ids){
        return [select id, dcmgt_Tenant__c, dcmgt_Service__c, dcmgt_Alation_Data_Dictionary__c
                    from dcmgt_Data_Sub_Request__c 
                    where id =: Ids
                    WITH SECURITY_ENFORCED limit 1];
    }
    
    @AuraEnabled
    public static void updateDataSubRequestRecMethod(string tenantId){
        try {
            list<dcmgt_Data_Sub_Request__c> listOfDataSub = getSubRequest();
            if(!listOfDataSub.IsEmpty() && string.isNotBlank(tenantId)){                                                                
                for(dcmgt_Data_Sub_Request__c request: listOfDataSub){
                    request.dcmgt_Tenant__c = tenantId;
                    request.dcmgt_Service__c = null;
                    request.dcmgt_Alation_Data_Dictionary__c = null;
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
    public static dcmgt_Team__c createTeamMenberForTenant(Id tenantId){
        try {
            dcmgt_Team_Member__c teamMember = new dcmgt_Team_Member__c(
                dcmgt_Role__c = 'Other',
                dcmgt_Team__c = tenantId,
                dcmgt_Team_Member_Name__c = UserInfo.getUserId()
            );
            if(Schema.sObjectType.dcmgt_Team_Member__c.isCreateable()){
                insert teamMember;
            }
            return [SELECT Id, Name, dcmgt_Team_Description__c, 
                        dcmgt_Team_Owner__c, dcmgt_Team_Owner__r.Email 
                    FROM dcmgt_Team__c 
                    WHERE Id = :tenantId WITH SECURITY_ENFORCED limit 10000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}