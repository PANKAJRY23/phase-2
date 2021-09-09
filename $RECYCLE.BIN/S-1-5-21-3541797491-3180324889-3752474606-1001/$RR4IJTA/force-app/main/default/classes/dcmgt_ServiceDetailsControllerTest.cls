@isTest
public class dcmgt_ServiceDetailsControllerTest {
 @isTest
 static void getServiceBySelectedTeamTest()
 {
     Test.startTest();
     List<dcmgt_Service__c> serviceList=dcmgt_ServiceDetailsController.getServiceBySelectedTeam();
     Test.stopTest();
     System.assert(serviceList.size()>0);
 }
 
 @isTest
 static void getServiceByTeamIdTest()
 {
     String Id_char = 'a0J5g0000002PQtEAM';
     ID testId = Id_char;
     Test.startTest();
     List<dcmgt_Service__c> serviceList=dcmgt_ServiceDetailsController.getServiceByTeamId(testId);
     Test.stopTest();
     System.assert(serviceList.size()>0);
 }
 
 @isTest
 static void getServiceByIdTest()
 {
     String Id_char = 'a0J5g0000002PQtEAM';
     ID testId = Id_char;
     Test.startTest();
     dcmgt_Service__c service=dcmgt_ServiceDetailsController.getServiceById(testId,'');
     Test.stopTest();
     System.assert(service!=null);
 }
 @isTest
 static void getServiceByIdTestWithTenantId()
 {
     String Id_char = 'a0J5g0000002PQtEAM';
     ID testId = Id_char;
     Test.startTest();
     dcmgt_Service__c service=dcmgt_ServiceDetailsController.getServiceById(testId,'a0J5g0000002PQtEAM');
     Test.stopTest();
     System.assert(service!=null);
 }
    
}