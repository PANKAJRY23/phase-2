@isTest
public class dcmgt_alation_article_managementTest {
    
@isTest
    static void fetchAlationArticlesTest()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new dcmgt_alation_http_requests_mock('article',200));  
        Object result=dcmgt_alation_article_management.getArticles('Business%20Glossary');
        Test.stopTest();
        System.debug((String)result);
        System.assert(result!=null);        
    }
    
  @isTest
    static void getCustomFieldsValueSetTest()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new dcmgt_alation_http_requests_mock('customFeildValueSet',200));  
        Object result=dcmgt_alation_article_management.getCustomFieldsValueSet();
        Test.stopTest();
        System.assert(result!=null);
    
    }
    
    @isTest
    static void getAlationUsersTest()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new dcmgt_alation_http_requests_mock('users',200));  
        Object result=dcmgt_alation_article_management.getAlationUsers();
        Test.stopTest();
        System.assert(result!=null);
    
    }
    @isTest
    static void fetchAlationArticlesExceptionTest()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new dcmgt_alation_http_requests_mock('article',400));  
        Object result=dcmgt_alation_article_management.getArticles('');
        Test.stopTest();
        System.assert(result!=null);
    
    }
    @isTest
    static void fetchAlationArticlesServiceUnavailableExceptionTest()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new dcmgt_alation_http_requests_mock('article',503));  
        Object result=dcmgt_alation_article_management.getArticles('');
        Test.stopTest();
        System.assert(result!=null);
    
    }
    
    
  @isTest
  static void getErrorMessageTest()
    {
        Test.startTest();
        Object result=dcmgt_alation_article_management.getErrorMessage(500);
        Test.stopTest();
       System.assert(((String)result).startsWith('Error'));       
    }
   
}