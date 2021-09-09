@isTest
public class dcmgt_alation_http_requests_mockTest {
 @isTest
    public static void dcmgt_alation_http_requests_mock_Test()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new dcmgt_alation_http_requests_mock('accessToken',201));  
        Object result=dcmgt_alation_token_management.createAPIAccessToken();
        Test.stopTest();
        System.debug((String)result);
        System.assert(result!=null);       
    }     
}