@isTest
public class dcmgt_CurrentSubscriptionControllerTest {
    @testSetup static void testSetupMethod() {
    
        dcmgt_Team__c teamRec = new dcmgt_Team__c();
        teamRec.Name ='Test';
        teamRec.dcmgt_Team_Description__c = 'Testing Record';
        
        insert teamRec;
        
        dcmgt_Service__c serviceRec = new dcmgt_Service__c();
        serviceRec.Name = 'Test';
        serviceRec.dcmgt_Service_Owner__c = teamRec.id;
        insert serviceRec;
    
        dcmgt_Data_Sub_Request__c subRequest= new dcmgt_Data_Sub_Request__c();
        subRequest.dcmgt_Status__c = 'Approved' ;
        subRequest.dcmgt_Requestor__c = UserInfo.getUserId();
        subRequest.dcmgt_Tenant__c = teamRec.Id;
        subRequest.dcmgt_Service__c = serviceRec.id;
        
        insert subRequest;
        
        dcmgt_Data_Asset_Sub_Request__c dataAssetSubRec= new dcmgt_Data_Asset_Sub_Request__c();
       // dataAssetSubRec.dcmgt_Expiration_Date__c = System.today() ;
        dataAssetSubRec.dcmgt_Data_Subscription_Request__c = subRequest.id;
        
        insert dataAssetSubRec;
        
    }
    
    static list<dcmgt_Data_Asset_Sub_Request__c> getSubRequest() {
        return [select id, dcmgt_Data_Subscription_Request__r.dcmgt_Alation_Data_Dictionary__r.Name, 
                        dcmgt_Data_Subscription_Request__r.dcmgt_Alation_Data_Dictionary__c,
                        dcmgt_Data_Asset_Name__c, dcmgt_Expiration_Date__c from dcmgt_Data_Asset_Sub_Request__c 
                        where dcmgt_Data_Subscription_Request__r.dcmgt_Status__c = 'Approved' LIMIT 1];
        
    }
    
    @isTest
    static void UnitTestMethod1() {
        list<dcmgt_Data_Asset_Sub_Request__c> dataAssetList = getSubRequest();
        Test.startTest();
            dcmgt_CurrentSubscriptionController.getAllCurrentSubscriptionRec();
            string Ids = dataAssetList[0].Id;
            dcmgt_CurrentSubscriptionController.extendApprovedSubscriptionRec(Ids, 'Test', '3');    
        Test.stopTest();
    }
   
    
}