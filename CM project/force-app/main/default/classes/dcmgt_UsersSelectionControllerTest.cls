@isTest
public class dcmgt_UsersSelectionControllerTest {
 @isTest
 static void getAllUsersTest()
    {
        Test.startTest();
        Map<String,String> alationUsers=dcmgt_alation_article_management.getAlationUsers();
        List<dcmgt_UsersSelectionController.UserWrapper> usersList=dcmgt_UsersSelectionController.getAllUsers();
        Test.stopTest();
        System.assert(usersList!=null);
    }
  @isTest
  static void getSelectedUsersTest()
    {
        String Id_18_char = '0D5B000001DVM9tkAh';
        ID testId = Id_18_char;
        Test.startTest();
        List<String> selectedUsersList=dcmgt_UsersSelectionController.getSelectedUsers(testId,'');
        Test.stopTest();
        System.assert(selectedUsersList.size()>0);
    }
   @isTest
   static void getUsersTest()
    {
        Test.startTest();
        Map<String,String> usersMap=dcmgt_UsersSelectionController.getUsers();
        Test.stopTest();
        System.assert(usersMap.keyset().size()>0);
    }
    
   @isTest
   static void getUserDetailsTest()
    {
        Test.startTest();
        Map<String,String> usersMap=dcmgt_UsersSelectionController.getUserDetails();
        Test.stopTest();
        System.assert(usersMap.keyset().size()>0);
    }
    @isTest
   static void saveRecordTest()
    {
        String Id_18_char = '0D5B000001DVM7tkAh';
        ID testId = Id_18_char;
        Test.startTest();
        dcmgt_UsersSelectionController.saveRecord(testId,null,'dcmgt_Alation_Article__c','dcmgt_Data_Owners__c');
        Test.stopTest();
        //System.assert(usersMap.keyset().size()>0);
    }
}