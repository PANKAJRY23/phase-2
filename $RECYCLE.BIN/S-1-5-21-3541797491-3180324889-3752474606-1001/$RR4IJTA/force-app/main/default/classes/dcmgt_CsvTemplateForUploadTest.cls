@isTest
public class dcmgt_CsvTemplateForUploadTest {
    @isTest
    public static void updateCsvTemplateDataTest()
    {
       	dcmgt_Request_Type__c rT = new dcmgt_Request_Type__c();
        rT.Name = 'Test12';
        insert rT;
        String Id_18_char = rT.Id;
        ID testId = Id_18_char;
        Test.startTest();
        dcmgt_CsvTemplateForUpload.updateCsvTemplateData(testId, 'fieldNames');
        Test.stopTest();
        System.assert(rT.Name != null);
    }

}