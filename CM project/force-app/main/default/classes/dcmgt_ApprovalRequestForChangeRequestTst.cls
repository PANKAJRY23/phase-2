@isTest
public class dcmgt_ApprovalRequestForChangeRequestTst{
    @isTest 
    public static void submitForApprovalTest()
     {
         Test.startTest();
         Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
         dcmgt_Change_Request__c cR = new dcmgt_Change_Request__c();
         dcmgt_ApprovalRequestForChangeRequest.submitForApproval(cR);
         Test.stopTest();
         System.assert(req.getComments() == 'Approved');
         
         
     }  
     
}