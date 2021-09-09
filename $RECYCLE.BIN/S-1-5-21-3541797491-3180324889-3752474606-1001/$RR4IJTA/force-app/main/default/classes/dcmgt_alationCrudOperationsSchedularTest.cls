@isTest
public class dcmgt_alationCrudOperationsSchedularTest {
    @istest
	public static void testschedule() {
		Test.startTest();
        dcmgt_Alation_Article__c en=new dcmgt_Alation_Article__c();
        en.dcmgt_Approval_date__c =System.Date.Today()-1;
        insert en;
        String CRON_EXP = '0 0 0 3 9 ? 2022';
       String jobId = System.schedule('dcmgt_alationCrudOperationsSchedular', CRON_EXP, new dcmgt_alationCrudOperationsSchedular());     
       CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];          
      System.assertEquals(0, ct.TimesTriggered); 
      System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));   
      Test.stopTest();        
	}
}