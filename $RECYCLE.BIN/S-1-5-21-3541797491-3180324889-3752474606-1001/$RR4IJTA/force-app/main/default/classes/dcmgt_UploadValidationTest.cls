@isTest
public class dcmgt_UploadValidationTest {
    @isTest
     static void uploadDataTest()
    {
        dcmgt_Alation_Article__c article = new dcmgt_Alation_Article__c();
        article.Name = 'Article1test';
        insert article;
        Test.startTest();
        dcmgt_UploadValidation.uploadData(article.Name, 'Business Glossary');
        Test.stopTest();
        System.assertEquals('Business Glossary', 'Data Dictionary');
    }
    @isTest
       static void uploadDataForArticles()
       {
           
       }
    

}