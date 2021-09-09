@isTest
public class dcmgt_LookupSearchResultTest {
 @isTest
    public static void getIdTest()
    {
        dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
        alationArticle.Name = 'Test1';
        insert alationArticle;
        String Id_18_char = alationArticle.Id;
        ID testId = Id_18_char;
        test.startTest();
		dcmgt_LookupSearchResult lookupSearch = new dcmgt_LookupSearchResult(testId,'dcmgt_Alation_Article__c','new','object','object info');
        lookupSearch.getId();
        test.stopTest();
        System.assert(alationArticle.Name != null);     
    }
    
   @isTest
    public static void getSObjectTypeTest()
    {
        dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
        alationArticle.Name = 'Test1';
        insert alationArticle;
        String Id_18_char = alationArticle.Id;
        ID testId = Id_18_char;
        String sobj ='dcmgt_Alation_Article__c'; 
        test.startTest();
		dcmgt_LookupSearchResult lookupSearch = new dcmgt_LookupSearchResult(testId,sobj,'new','object','object info');
        lookupSearch.getSObjectType();
        test.stopTest();
        System.assert(sobj!= alationArticle.Name);     
    }
    
    @isTest
    public static void getIconTest()
    {
       dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
        alationArticle.Name = 'Test1';
        insert alationArticle;
        String Id_18_char = alationArticle.Id;
        ID testId = Id_18_char;
        String sobj ='dcmgt_Alation_Article__c';
        String icon = 'objecticon';
        test.startTest();
		dcmgt_LookupSearchResult lookupSearch = new dcmgt_LookupSearchResult(testId,sobj,icon,'object','object info');
        lookupSearch.getIcon();
        test.stopTest();
        System.assert(icon!= alationArticle.Name);     
    }
    
    @isTest
    public static void getTitleTest()
    {
        dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
        alationArticle.Name = 'Test1';
        insert alationArticle;
        String Id_18_char = alationArticle.Id;
        ID testId = Id_18_char;
        String sobj ='dcmgt_Alation_Article__c';
        String icon = 'objecticon';
        String getTitle = 'object';
        test.startTest();
		dcmgt_LookupSearchResult lookupSearch = new dcmgt_LookupSearchResult(testId,sobj,icon,getTitle,'object info');
        lookupSearch.getTitle();
        test.stopTest();
        System.assert(getTitle!= alationArticle.Name);     
    }
    
    @isTest
    public static void getSubtitleTest()
    {
       dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
        alationArticle.Name = 'Test1';
        insert alationArticle;
        String Id_18_char = alationArticle.Id;
        ID testId = Id_18_char;
        String sobj ='dcmgt_Alation_Article__c';
        String icon = 'objecticon';
        String getTitle = 'object';
        String getSubtitle = 'object info';
        test.startTest();
		dcmgt_LookupSearchResult lookupSearch = new dcmgt_LookupSearchResult(testId,sobj,icon,getTitle,getSubtitle);
        lookupSearch.getSubtitle();
        test.stopTest();
        System.assert(getSubtitle!= alationArticle.Name);     
    }
    
    @isTest
    public static void compareToTest(){
       dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
        alationArticle.Name = 'Test1';
        insert alationArticle;
        String Id_18_char = alationArticle.Id;
        ID testId = Id_18_char;
        String sobj ='dcmgt_Alation_Article__c';
        String icon = 'objecticon';
        String getTitle = 'object';
        String getSubtitle = 'object info';
        test.startTest();
		dcmgt_LookupSearchResult lookupSearch = new dcmgt_LookupSearchResult(testId,sobj,icon,getTitle,getSubtitle);
        lookupSearch.compareTo(lookupSearch);
        test.stopTest();
        System.assert(getTitle != alationArticle.Name);     
    }    
}