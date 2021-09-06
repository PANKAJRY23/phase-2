@isTest
public class dcmgt_ApprovalRequestDetailsCtrlTest {
    @isTest
    public static void getApprovalRequestDetailsTest()
    {
        dcmgt_Approval_Configuration__c aC = new dcmgt_Approval_Configuration__c();
        aC.RecordTypeId = Schema.SObjectType.dcmgt_Approval_Configuration__c.getRecordTypeInfosByName().get('Article Approval Process Configurations').getRecordTypeId();
        aC.dcmgt_Approver_Role_For_Step_1__c = 'Data Steward';
        aC.dcmgt_Approver_Role_For_step_2__c = 'Data Owner';
        aC.dcmgt_Status__c = 'Active';
        insert aC;
        User user = new User();
        dcmgt_Alation_Article__c article = new dcmgt_Alation_Article__c();
        article.Name = 'TestA1';
        article.dcmgt_Data_Owners__c = '{&quot;0055e0000044RchAAE&quot;:&quot;Bhelcy Nadar&quot;}' ;
        article.dcmgt_DataStewards__c = '{&quot;0055e0000044RchAAE&quot;:&quot;Bhelcy Nadar&quot;}';
        insert article;
        List<ProcessInstance> processInstances = [SELECT Id FROM ProcessInstance where TargetObjectId =:article.Id order by CreatedDate DESC];
        System.debug('process'+processInstances[0].id);
        dcmgt_ApprovalRequestDetailsCtrl.getApprovalRequestDetails(processInstances[0].id);                                         
    }

}