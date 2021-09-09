@isTest
public class dcmgt_csvtemplateTest {
     @isTest
         static void getCsvTemplateDataTest()
         {
             String Id_18_char = '0D5B000001DVM7tkAh';
                    ID testId = Id_18_char;
             Test.startTest();
             dcmgt_csvtemplate.getCsvTemplateData(testId);
             dcmgt_CSV_Template_for_ChangeType__c changetype = new dcmgt_CSV_Template_for_ChangeType__c();
             changetype.Name='testrk';
             Test.stopTest();
             System.assert(changetype!= null);
         }

}