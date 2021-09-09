@isTest
public class dcmgt_MultiLookUpControllerTest {
   
    @isTest
    public static void getResultsTest(){
        Account a = new Account();
        a.Name ='Test';
        insert a;
        
        dcmgt_MultiLookUpController m = new dcmgt_MultiLookUpController();
        dcmgt_MultiLookUpController.getResults('Account','Name','Te',null,false,'Name','Test');
         dcmgt_MultiLookUpController.getResults('Account','Name','Te',null,true,'Name','Test');
    }
   
    
   



}