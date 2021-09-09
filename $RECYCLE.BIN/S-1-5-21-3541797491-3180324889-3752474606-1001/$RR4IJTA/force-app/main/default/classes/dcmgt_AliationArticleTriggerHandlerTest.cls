@isTest
public class dcmgt_AliationArticleTriggerHandlerTest {
@isTest
 public static void approveChangeRequestTest()
    {
       dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
       alationArticle.Name = 'Testclass';
        insert alationArticle;
        dcmgt_Alation_Article__c alationArticle1 = new dcmgt_Alation_Article__c();
       alationArticle1.Name = 'Testclass2';
        alationArticle1.Id = alationArticle.Id;
        update alationArticle1 ;
       
    }
@isTest
 public static void checkDuplicateArticleUpdateRequestTest()
	{
     dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
       alationArticle.Name = 'Duplicate1';
        insert alationArticle;
       List<dcmgt_Alation_Article__c> alationArticleList= [select Id from dcmgt_Alation_Article__c];
       dcmgt_AliationArticleTriggerHandler.checkDuplicateArticleUpdateRequest(alationArticleList);
	}
}