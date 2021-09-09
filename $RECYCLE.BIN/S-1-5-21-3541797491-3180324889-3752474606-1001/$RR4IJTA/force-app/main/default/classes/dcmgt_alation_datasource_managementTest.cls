@isTest
public class dcmgt_alation_datasource_managementTest {
     @isTest
    static void getCustomFieldsValueSetTest()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new dcmgt_alation_http_requests_mock('customFeildValueSet',500));  
        Object result=dcmgt_alation_datasource_management.getCustomFieldsValueSet();
        Test.stopTest();
        System.assert(result!=null);
    
    }
    
	@isTest
    public static void getDatasourceHierarchyTest()
    {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new dcmgt_alation_http_requests_mock('article',200));  
        Object result=dcmgt_alation_datasource_management.getDatasourceHierarchy('Business%20Glossary');
        Test.stopTest();
        System.debug((String)result);
        System.assert(result!=null);        
    }
    
    @isTest
    public static void isEmptyTest()
    {
        Test.startTest();
        dcmgt_Data_Assets__c dataAsset = new dcmgt_Data_Assets__c();
        object result = dcmgt_alation_datasource_management.isEmpty(dataAsset);
        Test.stopTest();
        System.assert(result!=null); 
    }
   
    @isTest
   public static void getErrorMessageTest()
    {
        Test.startTest();
        Object result=dcmgt_alation_datasource_management.getErrorMessage(500);
        Test.stopTest();
       System.assert(((String)result).startsWith('Error'));       
    }
 

}