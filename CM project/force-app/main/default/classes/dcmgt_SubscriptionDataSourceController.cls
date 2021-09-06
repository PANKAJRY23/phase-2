public with sharing class dcmgt_SubscriptionDataSourceController {
    
    @AuraEnabled
    public static dcmgt_Data_Sub_Request__c getDataSubRequestByTeamId(Id teamId){
      try{  
        list<dcmgt_Data_Sub_Request__c> selectDataSub = getSubRequest(teamId);
        if(!selectDataSub.IsEmpty()){
            return selectDataSub[0];
        }else{
            return null;
        }    
       } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
       }                                            
    }
    
    public static list<dcmgt_Data_Sub_Request__c> getSubRequest(Id teamId){
        return [select id, dcmgt_Tenant__c, dcmgt_Alation_Data_Dictionary__c, dcmgt_Service__c, dcmgt_Status__c from dcmgt_Data_Sub_Request__c 
                    where dcmgt_Requestor__c= :UserInfo.getUserId()and dcmgt_Status__c = 'Draft' 
                    and dcmgt_Tenant__c =:teamId WITH SECURITY_ENFORCED limit 1];
    }
    
    @AuraEnabled
    public static void updateSubscriptionRec(Id dataSourceId, Id teamId){
        try{
            list<dcmgt_Data_Sub_Request__c> selectDataSub= getSubRequest(teamId);
            system.debug('==dataSourceId=='+dataSourceId);
            system.debug('--teamId--'+teamId);
            for(dcmgt_Data_Sub_Request__c requestRec:selectDataSub){
                requestRec.dcmgt_Alation_Data_Dictionary__c = dataSourceId;
            }
            if(Schema.sObjectType.dcmgt_Data_Sub_Request__c.isUpdateable()){
                update selectDataSub;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }    
    
    @AuraEnabled
    public static dcmgt_Data_Sub_Request__c methodForUpdateSubTeamId(Id teamId){
        try{
            list<dcmgt_Data_Sub_Request__c> selectDataSub = getSubRequest(teamId);
            if(!selectDataSub.IsEmpty()){
                for(dcmgt_Data_Sub_Request__c requestRec:selectDataSub){
                    if(requestRec.dcmgt_Tenant__c != null && requestRec.dcmgt_Alation_Data_Dictionary__c != null && requestRec.dcmgt_Service__c != null){
                        requestRec.dcmgt_Status__c = 'Pending Approval';
                    }
                }
                if(Schema.sObjectType.dcmgt_Data_Sub_Request__c.isUpdateable()){
                    update selectDataSub;
                }
                return selectDataSub[0];
            }else{
                return null;
            }  
        
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }  
                                                   
    }
    
}