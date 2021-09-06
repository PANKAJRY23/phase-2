@isTest
public class dcmgt_ApprovalHistoryUtilTest {
	@isTest
    public static void isCurrentUserSystemAdminTest()
    {
        Test.startTest();
        String Id_18_char ='0057d000004rKVQ';
        ID testId = Id_18_char;
        dcmgt_ApprovalHistoryUtil.isCurrentUserSystemAdmin(testId);
        Test.stopTest();
    }
    
    @isTest
    public static void populateApprovalHistoryStepsTest()	
    {
        dcmgt_Alation_Article__c article = new dcmgt_Alation_Article__c();
        article.Name = 'Test1AA';
        insert article;
        String Id_18_char =article.Id;
        ID testId = Id_18_char;
        Test.startTest();
        List<ProcessInstance> piList = [Select p.TargetObjectId, p.Status From ProcessInstance p where TargetObjectId = :testId];
        dcmgt_ApprovalHistoryUtil.populateApprovalHistorySteps(piList, testId);
        Test.stopTest();
    }
    
    @isTest
    public static void processStepTest()	
    {
        dcmgt_Alation_Article__c article = new dcmgt_Alation_Article__c();
        article.Name = 'Test1AA';
        insert article;
        String Id_18_char =article.Id;
        ID testId = Id_18_char;
        Test.startTest();
       List<ProcessInstanceWorkitem> wis = [
            SELECT Id, ProcessInstance.TargetObjectId 
            FROM   ProcessInstanceWorkitem
            WHERE  ProcessInstance.Status = 'Pending'
            AND    ActorId = :testId
        ];
        Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();
        pwr.setAction('Removed');
        pwr.setComments('Quote submitted with updated discounts');
        pwr.setWorkitemId(testId);

        dcmgt_ApprovalHistoryUtil.processStep(wis, 'Approved' ,'Removed');
        Test.stopTest();
    }
    
    	
 /*@isTest
    public static void initApprovalProcessTest()	
    {
        dcmgt_Alation_Article__c article = new dcmgt_Alation_Article__c();
        article.Name = 'Test1AA';
        insert article;
        String Id_18_char =article.Id;
        ID testId = Id_18_char;
        Test.startTest();
        List<id> listaToTrue=new List<id>();
		for(dcmgt_Alation_Article__c a : [select id from dcmgt_Alation_Article__c where Name = '']){
            listaToTrue.add(a.id);
        }
        
        Map<String, list<id>> mapForId = new Map<String, list<id>>();
        mapForId.put('name',listaToTrue);
        dcmgt_ApprovalHistoryUtil.initApprovalProcess(mapForId);
        Test.stopTest();
      }*/
}