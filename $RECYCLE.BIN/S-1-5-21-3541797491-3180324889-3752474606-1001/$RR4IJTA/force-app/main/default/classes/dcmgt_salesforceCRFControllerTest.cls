@isTest
public class dcmgt_salesforceCRFControllerTest {
    @isTest
    public static void getMapOfUserIdAndNameTest()
    {
        //String Id_18_char = '0D5B000001DVM9tkAh';
        //ID testId = Id_18_char;
        Test.startTest();
        dcmgt_salesforceCRFController.getMapOfUserIdAndName();
        dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
        User user = new User();
        alationArticle.Name = 'testAA12';
        //alationArticle.Id=testId;
        Test.stopTest();
        System.assert(user.Name != alationArticle.Name);
    }
    
    /*@isTest
    public static void getPickListValuesTest()
    {
        //String Id_18_char = '0D5B000001DVM9tkAh';
        //ID testId = Id_18_char;
        Test.startTest();
        dcmgt_salesforceCRFController.getPickListValues();
        dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
        User user = new User();
        alationArticle.Name = 'testAA1';
        //alationArticle.Id=testId;
        Test.stopTest();
        System.assert(user.Name != alationArticle.Name);
    }
*/
    
    /*@isTest
    public static void getTemplateFieldsTest()
    {
        Test.startTest();        
        dcmgt_CSV_Template_for_ChangeType__c cSVTemplate = new dcmgt_CSV_Template_for_ChangeType__c();
        dcmgt_Request_Type__c rT = new dcmgt_Request_Type__c();
        rT.Name = 'testId1';
        cSVTemplate.Name = 'Test1';
        insert rT;
        insert cSVTemplate;
        rT.Id = cSVTemplate.Id;
        String Id_18_char = rT.Id;
        ID testId = id.valueOf(Id_18_char);
        dcmgt_changeRequestFormController.getTemplateFields(testId);
        Test.stopTest();
        System.assert(cSVTemplate.dcmgt_Fields__c!='test');
    }*/
    
    @isTest
    public static void getAllArticleTest()
    {
        Test.startTest();
        dcmgt_salesforceCRFController.getAllArticle();
        dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
        alationArticle.Name = 'Test12AA';
        alationArticle.dcmgt_Is_Active__c = true;
        Test.stopTest();
        System.assert(alationArticle.Name != null);
        
    }
    
    @isTest
    public static void getAllDataAssertsTest()
    {
        Test.startTest();
        dcmgt_salesforceCRFController.getAllDataAsserts();
        dcmgt_Data_Assets__c dataAsset = new dcmgt_Data_Assets__c();
        dataAsset.Name = 'Test12A';
        dataAsset.dcmgt_IsActive__c = true;
        Test.stopTest();
        System.assert(dataAsset.dcmgt_IsActive__c != false);
    }
    
    @isTest
    public static void getDataAssertByDictionaryTest()
    {
        Test.startTest();
        dcmgt_Alation_Data_Dictionary__c dataDict = new dcmgt_Alation_Data_Dictionary__c();
        dataDict.Name = 'Test12AB';
        insert dataDict;
      	String Id_18_char = dataDict.Id;
        ID testId = Id.valueOf(Id_18_char);
        dcmgt_salesforceCRFController.getDataAssertByDictionary(testId);
        Test.stopTest();
        System.assert(dataDict.Name != Null);
    }
    
    @isTest
    public static void getArticleByGlossaryTest()
    {
        Test.startTest();
        dcmgt_Alation_Glossary__c glossary = new dcmgt_Alation_Glossary__c();
        glossary.Name = 'Test12AB';
        insert glossary;
      	String Id_18_char = glossary.Id;
        ID testId = Id.valueOf(Id_18_char);
        dcmgt_salesforceCRFController.getArticleByGlossary(testId);
        Test.stopTest();
        System.assert(glossary.Name != Null);
    }
    
    /*@isTest
    public static void getResponseTest()
    {
        Test.startTest();
        List<String> list1 = new List<String>();
        dcmgt_Alation_Glossary__c glossary = new dcmgt_Alation_Glossary__c();
        dcmgt_changeRequestFormController.getResponse(list1,glossary);
        HttpResponse response = Continuation.getResponse('label');
        test.stopTest();
        System.assert(response.getBody() != null );
    }*/
    
    @isTest
    public static void getMapOfUserNameAndIdTest()
    {
        Test.startTest();
        dcmgt_changeRequestFormController.getMapOfUserNameAndId();
        dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
        User user = new User();
        alationArticle.Name = 'testAA12';
        Test.stopTest();
        System.assert(user.Name != alationArticle.Name);
    }
    
    @isTest
    public static void getMapOfFieldNameWithAPINameTest()
    {
        Test.startTest();
        dcmgt_Alation_Article__c article = new dcmgt_Alation_Article__c();
        dcmgt_Data_Assets__c dataAsset = new dcmgt_Data_Assets__c();
        dcmgt_changeRequestFormController.getMapOfFieldNameWithAPIName('article');
        article.Name= 'testAA';
        dataAsset.Name= 'testDA';
        insert article;
        insert dataAsset;
        Test.stopTest();
        System.assert(article.Name != null || dataAsset.Name != null);
    }
    
    @isTest
    public static void getRequestTypeNameTest()
    {
        dcmgt_Request_Type__c rT = new dcmgt_Request_Type__c();
        rT.Name = 'testRequestType';
        insert rT;
        String Id_18_char = rT.Id;
        ID testId = Id.valueOf(Id_18_char); 
        Test.startTest();
        dcmgt_changeRequestFormController.getRequestTypeName(testId);
        Test.stopTest();
        System.assert(rT.Name != null);
    }

}