@isTest
public class dcmgt_alationCrudOperationsTest {
    @isTest
        public static void testRunAs(){       
        String filter='Article123456';
        Test.startTest();
        dcmgt_alationCrudOperations AC=new dcmgt_alationCrudOperations();
        dcmgt_Alation_Article__c a=new dcmgt_Alation_Article__c(name='Article123456');
        insert a;
            
 		User u=[Select name From User where Id='0057d000004rKVQ'];
        system.runAs(u){}
        DataBase.executeBatch(AC,200);  
        Test.stopTest();             
       }
    
    @isTest
    public static void getErrorMessageTest()
    {
        Test.startTest();
        Object result1=dcmgt_alationCrudOperations.getErrorMessage(500);
        Object result2=dcmgt_alationCrudOperations.getErrorMessage(503);
        Object result3=dcmgt_alationCrudOperations.getErrorMessage(400);
        Test.stopTest();
       System.assert(((String)result1).startsWith('Error'));
       System.assert(((String)result2).startsWith('Error'));
       System.assert(((String)result3).startsWith('Error'));
    }
}