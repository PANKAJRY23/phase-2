@isTest
public class dcmgt_alation_token_managementTest {
@isTest    
   static void createAPIAccessTokenTest()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new dcmgt_alation_http_requests_mock('accessToken',201));  
        Object result=dcmgt_alation_token_management.createAPIAccessToken();
        Test.stopTest();
        System.debug((String)result);
        System.assert(result!=null);       
    }     
@isTest
  static void createAPIAccessTokenInternernalExceptionTest()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new dcmgt_alation_http_requests_mock('accessToken',400));  
        Object result=dcmgt_alation_token_management.createAPIAccessToken();
        Test.stopTest();
       System.assert(((String)result).startsWith('Error'));       
    }
  @isTest
  static void createAPIAccessTokenServiceUnAvailableExceptionTest()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new dcmgt_alation_http_requests_mock('accessToken',503));  
        Object result=dcmgt_alation_token_management.createAPIAccessToken();
        Test.stopTest();
       System.assert(((String)result).startsWith('Error'));       
    }
 @isTest
  static void getErrorMessageTest()
    {
        Test.startTest();
        Object result=dcmgt_alation_token_management.getErrorMessage(500);
        Test.stopTest();
       System.assert(((String)result).startsWith('Error'));       
    }
}