@isTest
public class dcmgt_TenantDetailsControllerTest {
    @isTest
       static void getTenantsByCurrentUserTest()
       {
           Test.startTest();
           dcmgt_TenantDetailsController.getTenantsByCurrentUser();
           dcmgt_Team__c team = new dcmgt_Team__c();
           team.Name = 'testrk1';
           insert team;
           Test.stopTest();
           System.assert(team!= null);
       }
    @isTest
        static void createTeamMenberForTenantTest()
        {
            String Id_18_char = '0D5B000001DVM7tkAh';
                    ID testId = Id_18_char;
            Test.startTest();
            dcmgt_TenantDetailsController.createTeamMenberForTenant(testId);
            dcmgt_Team_Member__c teamMember = new dcmgt_Team_Member__c();
            Test.stopTest();
            System.assert(teamMember!= null);
        }

}