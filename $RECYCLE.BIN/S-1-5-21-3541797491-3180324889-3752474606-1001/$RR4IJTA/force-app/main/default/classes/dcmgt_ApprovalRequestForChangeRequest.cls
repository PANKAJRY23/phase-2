public class dcmgt_ApprovalRequestForChangeRequest {
     public static void submitForApproval(dcmgt_Change_Request__c opp){        
            // Create an approval request for  Opportunity        
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();          
            req.setComments('Submitting approval request using Trigger');        
            req.setObjectId(opp.id);
            // Submit the approval request for the Opportunity        
            Approval.ProcessResult result = Approval.process(req);        
        }     

    }