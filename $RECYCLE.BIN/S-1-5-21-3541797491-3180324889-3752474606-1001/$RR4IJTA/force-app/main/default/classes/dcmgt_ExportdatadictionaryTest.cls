@isTest
public class dcmgt_ExportdatadictionaryTest {
 @isTest
 public static void getDictionaryTest()
 	{
        Test.startTest();
        dcmgt_Exportdatadictionary.getDictionary();
        dcmgt_Data_Assets__c dataAsset = new dcmgt_Data_Assets__c();
        dataAsset.Name='testDA1';
        dataAsset.dcmgt_Business_Process__c = 'new';
        insert dataAsset;
        Test.stopTest();
        System.assert(dataAsset!= null,'Record is inserted');
 	}

}