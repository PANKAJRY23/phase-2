@isTest
public class dcmgt_ApprovalReqDetailsControllerTest {
 @isTest
    public static void getContactList()
    {
        dcmgt_ApprovalReqDetailsController approvalDetails = new dcmgt_ApprovalReqDetailsController();
         approvalDetails.getContactList();
        ProcessInstanceWorkitem pI = new ProcessInstanceWorkitem();
        pI.Id = pI.ProcessInstanceId;
        insert pI;
        
       
    }

}