@isTest
public class dcmgt_DataAssertTriggerHandlerTest {
@isTest
 static void approveChangeRequestTest()
    {
       dcmgt_Data_Assets__c dataAsset = new dcmgt_Data_Assets__c();
       dataAsset.Name = 'Testclass';
        insert dataAsset;
        dcmgt_Data_Assets__c dataAsset1 = new dcmgt_Data_Assets__c();
       dataAsset1.Name = 'Testclass2';
        dataAsset1.Id = dataAsset.Id;
        update dataAsset1 ;
       
    }
@isTest
 public static void checkDuplicateArticleUpdateRequestTest()
	{
     dcmgt_Data_Assets__c dataAsset = new dcmgt_Data_Assets__c();
       dataAsset.Name = 'Duplicate1';
        insert dataAsset;
       List<dcmgt_Data_Assets__c> dataAssetList= [select Id from dcmgt_Data_Assets__c];
       dcmgt_DataAssertTriggerHandler.checkDuplicateArticleUpdateRequest(dataAssetList);
	}
}