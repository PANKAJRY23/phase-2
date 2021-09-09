@isTest
public class dcmgt_LWCExampleControllerTest {
 @isTest
    public static void getGlossaryTest()
    {
        Test.startTest();
        dcmgt_LWCExampleController.getGlossary();
        dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
        alationArticle.Name='testAA1';
        alationArticle.dcmgt_Acronynm_Synonym__c = 'new';
        insert alationArticle;
        Test.stopTest();
        System.assert(alationArticle!= null);
    }
}