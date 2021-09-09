@isTest
public class dcmgt_uptest {
    @isTest
     static void uploadDataTest()
    {
        Test.startTest();
         string filecontent = 'Name,Description,Acronynm/Synonym,Term Type,Life Cycle Status,Subject Area,Classification,Data Owners,Data Stewards,Alation Article,Alation Data Dictionary,Governed Flag\nrk1,ramtest,,Metric,,,,Jatin Bhoir,Jatin Bhoir,,,';
        dcmgt_Alation_Article__c article = new dcmgt_Alation_Article__c();
        dcmgt_UploadValidation.uploadData('filecontent', 'Business Glossary');
        Test.stopTest();
        System.assertEquals('Business Glossary', 'Data Dictionary');
    }
    

}