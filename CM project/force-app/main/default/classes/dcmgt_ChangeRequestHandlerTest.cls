@isTest
public class dcmgt_ChangeRequestHandlerTest {
@isTest
    public static void updateRequestEffectiveDateTest()
    {
        dcmgt_Change_Request__c changeRequest= new dcmgt_Change_Request__c();
        changeRequest.dcmgt_Request_Effective_Date__c = Date.newInstance(2016, 07, 30);
        insert changeRequest;
        List<dcmgt_Change_Request__c> listOfChangeRequest = [select Id from dcmgt_Change_Request__c] ;
        dcmgt_ChangeRequestHandler.updateRequestEffectiveDate(listOfChangeRequest);
    }
}