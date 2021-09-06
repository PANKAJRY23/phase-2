public class dcmgt_UsersSelectionController {
   public static Map<String,String> alationUsers=dcmgt_alation_article_management.getAlationUsers();
    public class UserWrapper{
        @AuraEnabled 
       public  String label;
        @AuraEnabled 
       public String value;
    }
    
    
 @AuraEnabled 
    public static List<UserWrapper>  getAllUsers(){
        
        List<User> users = [SELECT Id, Name, Email FROM User WHERE IsActive = true and Email in:alationUsers.KeySet()];
        List<UserWrapper> options = new List<UserWrapper>();
        for(User user:users){
           UserWrapper u = new UserWrapper();
                u.label = user.Name;
                u.value = user.Id;
                options.add(u);
        }
        System.debug(options);
        return options;
    }   
    
 @AuraEnabled 
    public static List<String> getSelectedUsers(Id recordID,String fieldName){
        List<String> users = new List<String>();
        String query = 'select '+fieldName+' from '+recordID.getSobjectType()+' where id=:recordID';
        System.debug('Id'+recordId+'fieldName'+fieldName);
        sObject sObj = Database.query(query);
        System.debug(sObj.get(fieldName).toString().replaceAll('&quot;','"').replaceAll(';',','));
        Map<String,String> m = (Map<String,String>)JSON.deserialize(sObj.get(fieldName).toString().replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
        users.addAll(m.keyset());
        return users;   
    }	
    
    @AuraEnabled
    public static Map<String,String> getUsers() {
       Map<String,String> availableUsersMap = new Map<String,String>();
       
       for (User u : [SELECT Id, Name, Email FROM User WHERE IsActive = true and Email in:alationUsers.KeySet()]) {
            availableUsersMap.put(u.Id, u.Name);
          }
        return availableUsersMap;
    }
    @AuraEnabled(Cacheable = true)
   public static Map<String, String> getUserDetails(){
       try {
           // return [SELECT Id, Name, Email FROM User WHERE IsActive = true];
           Map<String, String> mapOfUserEmailAndName = new Map<String, String>();
           List<User> listOfUser = [SELECT Id, Name, Email FROM User WHERE IsActive = true and Email in:alationUsers.KeySet()];
           for(User userObj : listOfUser) {
              mapOfUserEmailAndName.put(userObj.Id, userObj.Name);
            }
           return mapOfUserEmailAndName;
       } catch (Exception e) {
           throw new AuraHandledException(e.getMessage());
       }
   }

    
    @AuraEnabled
    public static void saveRecord(Id recordID,List<String> userIds,String objectName,String fieldName){
       sObject sObj = Schema.getGlobalDescribe().get(objectName).newSObject();  
        Map<String,String> availableUsersMap = getUsers();
         String jsonString;
         for(String user:userIds){
             if(String.isEmpty(jsonString)){
                 jsonString='{"'+String.valueOf(user)+'" : "' + String.valueOf(availableUsersMap.get(user)+'"') ;
             }else{
                  jsonString+=',"'+String.valueOf(user)+'" : "' + String.valueOf(availableUsersMap.get(user)+'"') ;
             }
         }
         jsonString+='}';
         sObj.put(fieldName, jsonString);
         sObj.put('Id', recordID);
         update sObj;  
    }

    @AuraEnabled(Cacheable = true)
   static public Boolean checkIfUserHasAssignedPermissionSet() {
          System.debug(UserInfo.getUserId());
          list<string> permissionSetName= new list<string>{'dcmgt_user'};
          List<PermissionSetAssignment> psas = [ select Id from PermissionSetAssignment where PermissionSetId IN ( select Id from PermissionSet where Name = :permissionSetName) and AssigneeId = : UserInfo.getUserId() ];
          System.debug('pas'+psas);
          if(psas.size() > 0){
              return true;
          }
          else{
              return false;
          }
         
       }
    
  /*  public static void test(Id recordId,String fieldName,String objectName){
       sObject ob = Schema.getGlobalDescribe().get(objectName).newSObject() ;
        //ob.getSObject(fieldName) = 'test';
        ob.put(fieldName, 'test');
        ob.put('Id', recordId);
        update ob;
    }
    
        public static List<String> getSelectedUsers1(Id recordID){
        List<String> dataStewards = new List<String>();
        dcmgt_Alation_Article__c article = [select dcmgt_DataStewards__c from dcmgt_Alation_Article__c where id=:recordID];
        Map<String,String> m = (Map<String,String>)JSON.deserialize(article.dcmgt_DataStewards__c.replaceAll('&quot;','"'), Map<String,String>.class);
        dataStewards.addAll(m.keyset());
        return dataStewards;
       }	      
  
*/
    
}