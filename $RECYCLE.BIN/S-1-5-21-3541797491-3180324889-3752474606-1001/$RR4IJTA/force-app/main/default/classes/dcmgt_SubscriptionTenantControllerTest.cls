@isTest
public class dcmgt_SubscriptionTenantControllerTest
{
    
    @testSetup static void checkSubRequest()
    {
        dcmgt_Team__c teamRec = new dcmgt_Team__c();
        teamRec.Name ='Test';
        teamRec.dcmgt_Team_Description__c = 'Testing Record';
        
        insert teamRec;
        
        dcmgt_Service__c serviceRec = new dcmgt_Service__c();
        serviceRec.Name = 'Test';
        serviceRec.dcmgt_Service_Owner__c = teamRec.id;
        
        insert serviceRec;
        
        dcmgt_Team_Member__c teamMember = new dcmgt_Team_Member__c();
         teamMember.dcmgt_Role__c = 'Other';
         teamMember.dcmgt_Team__c = teamRec.Id;
         teamMember.dcmgt_Team_Member_Name__c = UserInfo.getUserId();
        
        insert teamMember;
        
        dcmgt_Data_Sub_Request__c  dataSubRequest = new dcmgt_Data_Sub_Request__c();
        dataSubRequest.dcmgt_Requestor__c= UserInfo.getUserId();
        dataSubRequest.dcmgt_Status__c = 'Draft' ;
        dataSubRequest.dcmgt_Tenant__c = teamRec.Id;
        dataSubRequest.dcmgt_Service__c = null;
        dataSubRequest.dcmgt_Alation_Data_Dictionary__c = null;
        
        insert dataSubRequest;
    }
    
    static list<dcmgt_Data_Sub_Request__c> getDataSubReq() 
    {
        return [select id  from dcmgt_Data_Sub_Request__c ];       
    }
    
     static list<dcmgt_Team__c> getTenantId() 
    {
         return [select id from dcmgt_Team__c limit 1];     
    }
     @isTest
    static void unitTestMethod()
    {
        list<dcmgt_Data_Sub_Request__c> dataSubReqList = getDataSubReq();
        list<dcmgt_Team__c> tenantIdList = getTenantId();
        Test.startTest();
        dcmgt_SubscriptionTenantController.getTenantsByCurrentUser();
        dcmgt_SubscriptionTenantController.getSubRequest();
        string Ids = dataSubReqList[0].id;
        dcmgt_SubscriptionTenantController.getSubScriptionRequest(Ids);
        string Ids1 = tenantIdList[0].id;
        dcmgt_SubscriptionTenantController.updateDataSubRequestRecMethod(Ids1);
        Id IdOfTenant = tenantIdList[0].id;
        dcmgt_SubscriptionTenantController.createTeamMenberForTenant(IdOfTenant);
        Test.stopTest();
     }

}