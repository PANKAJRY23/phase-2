@isTest
public class dcmgt_alation_dataAsset_batchUpdateTest {
   @isTest
        public static void testRunAs(){     
        String filter='DataAsset123456';
        Test.startTest();
        dcmgt_alation_dataAsset_batchUpdate DA =new dcmgt_alation_dataAsset_batchUpdate();
        dcmgt_Data_Assets__c dataAsset=new dcmgt_Data_Assets__c(name='DataAsset123456');
        insert dataAsset;
 		User u=[Select name From User where Id='0057d000004rKVQ'];
        system.runAs(u){}
        DataBase.executeBatch(DA,200); 
        Test.stopTest();             
       }
    
    @isTest
    public static void getErrorMessageTest()
    {
        Test.startTest();
        Object result1=dcmgt_alation_dataAsset_batchUpdate.getErrorMessage(500);
        Object result2=dcmgt_alation_dataAsset_batchUpdate.getErrorMessage(503);
        Object result3=dcmgt_alation_dataAsset_batchUpdate.getErrorMessage(400);
        Test.stopTest();
       System.assert(((String)result1).startsWith('Error'));
       System.assert(((String)result2).startsWith('Error'));
       System.assert(((String)result3).startsWith('Error'));
    }
    
    /*@isTest    
   static void invokeGetRestAPITest()
    {
        Test.startTest();
        dcmgt_alation_dataAsset_batchUpdate.invokeGetRestAPI('http://34.199.204.90/integration/v1/custom_template/?title=Business%20Glossary','GXLsNpChkv6GW3FIv2fhH8UGIi2BKTu1zxmEVXXU_M4');
		Test.stopTest();
    }*/     

}