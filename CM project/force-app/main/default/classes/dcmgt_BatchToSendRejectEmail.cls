/*
        Name            :     dcmgt_BatchToSendRejectEmail 
        Date            :     17 Aug 2021
        Author          :     IA
        Description     :     We are creating this class to Send Email notification where Status is Rejected.
*/

public class dcmgt_BatchToSendRejectEmail implements Database.Batchable<sObject>, Database.Stateful {
     public set<Id> setOfArticleId= new set<Id>();
     public set<Id> setOfDataAssetsId= new set<Id>();
     public Database.QueryLocator start(Database.BatchableContext BC){
       String query = 'SELECT Id FROM dcmgt_Change_Request__c where dcmgt_Status__c = \'Approved\' or dcmgt_Status__c = \'Submitted\' or dcmgt_Status__c = \'Completed\'';
        return Database.getQueryLocator( query );
     }
     public void execute(Database.BatchableContext BC, List<sObject> scope){
         date currentdate = system.today();
         list<dcmgt_Change_Request__c> changeRequestList = [select id, CreatedBy.Email,CreatedById,
                                                         (Select Id, dcmgt_RejectedMailSent__c, 
                                                         dcmgt_Data_Owners__c, dcmgt_DataStewards__c, dcmgt_Updates_Fields__c
                                                         FROM dcmgt_Alation_Article__r
                                                         where  
                                                         dcmgt_RejectedMailSent__c = false and 
                                                         dcmgt_Status__c = 'Rejected'),
                                                         (Select id, dcmgt_RejectedMailSent__c, 
                                                         dcmgt_Data_Stewards__c, dcmgt_Service_Owners__c, dcmgt_Updated_Fields__c
                                                         from dcmgt_Data_Assets__r where 
                                                         dcmgt_RejectedMailSent__c = false and 
                                                         dcmgt_Status__c = 'Rejected')
                                                          from dcmgt_Change_Request__c where id in: scope];
         
         // dcmgt_Status__c = \'Approved\' or dcmgt_Status__c = \'Submitted\' or dcmgt_Status__c = \'Completed\'  id = \'a047d000009DDZgAAO\'
         
         
          EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where developername = 'dcmgt_Email_Notifications_Reject'];
         list<Messaging.SingleEmailMessage> emailList= new list<Messaging.SingleEmailMessage>();
         
         list<string> setOfIdForOldAlrticleUser = new list<string>();
         list<string> setOfIdForOldDataAssetsUser = new list<string>();
         Map<String, String> mapOfCurrentOwnersAndStewards = new Map<String, String>();
          for(dcmgt_Change_Request__c changeReqRec: changeRequestList ){
                if(!changeReqRec.dcmgt_Alation_Article__r.IsEmpty()){
                    for(dcmgt_Alation_Article__c article: changeReqRec.dcmgt_Alation_Article__r){
                        if(string.isNotBlank(article.dcmgt_Updates_Fields__c)){
                            setOfIdForOldAlrticleUser.add(article.Id);
                        }
                        if(String.isNotBlank(article.dcmgt_DataStewards__c)){
        
                            Map<String, String> mapOfStewards = (Map<String,String>) JSON.deserialize(String.valueOf(article.dcmgt_DataStewards__c).replace('&quot;','"'), Map<String,String>.class);
                            mapOfCurrentOwnersAndStewards.putAll(mapOfStewards);
                        }
                        if(String.isNotBlank(article.dcmgt_Data_Owners__c)){
        
                            Map<String, String> mapOfOwners = (Map<String,String>) JSON.deserialize(String.valueOf(article.dcmgt_Data_Owners__c).replace('&quot;','"'), Map<String,String>.class);
                            mapOfCurrentOwnersAndStewards.putAll(mapOfOwners);
                        }
                    }
                }
                
                if(!changeReqRec.dcmgt_Data_Assets__r.IsEmpty()){
                    for(dcmgt_Data_Assets__c dataAssets: changeReqRec.dcmgt_Data_Assets__r){
                        if(string.isNotBlank(dataAssets.dcmgt_Updated_Fields__c)){
                            setOfIdForOldDataAssetsUser.add(dataAssets.Id);
                        }
                        if(String.isNotBlank(dataAssets.dcmgt_Data_Stewards__c)){
        
                            Map<String, String> mapOfStewards = (Map<String,String>) JSON.deserialize(String.valueOf(dataAssets.dcmgt_Data_Stewards__c).replace('&quot;','"'), Map<String,String>.class);
                            system.debug('==mapOfStewards=='+mapOfStewards);
                            mapOfCurrentOwnersAndStewards.putAll(mapOfStewards);
                            system.debug('==6363=='+mapOfCurrentOwnersAndStewards);
                        }
                        if(String.isNotBlank(dataAssets.dcmgt_Service_Owners__c)){
        
                            Map<String, String> mapOfServiceOwners = (Map<String,String>) JSON.deserialize(String.valueOf(dataAssets.dcmgt_Service_Owners__c).replace('&quot;','"'), Map<String,String>.class);
                            system.debug('==mapOfServiceOwners=='+mapOfServiceOwners);
                            mapOfCurrentOwnersAndStewards.putAll(mapOfServiceOwners);
                            system.debug('==7070=='+mapOfCurrentOwnersAndStewards);
                        }
                    }
                }
                
          }
          Set<String> oldUsersEmails = new Set<String>();
          if(!setOfIdForOldDataAssetsUser.IsEmpty()){
              oldUsersEmails = checkForOldApproversAndReturn(setOfIdForOldDataAssetsUser, 'dcmgt_Updated_Fields__c');
          }
          
          if(!setOfIdForOldAlrticleUser.IsEmpty()){
              oldUsersEmails = checkForOldApproversAndReturn(setOfIdForOldAlrticleUser, 'dcmgt_Updates_Fields__c');
          }
          
          system.debug('==mapOfCurrentOwnersAndStewards=='+mapOfCurrentOwnersAndStewards.KeySet());
          Set<String> currentUsersEmails = new Set<String>();       
          map<Id,user> mapUsers=new map<id,user>([select Email from User where id in:mapOfCurrentOwnersAndStewards.KeySet() limit 10000]);
          for(Id userId:mapUsers.keySet()){
             currentUsersEmails.add(mapUsers.get(userId).email); 
          }
          
          
          List<String> ccAddresses = new List<String>();
          if(!oldUsersEmails.IsEmpty()){
             ccAddresses.addAll(oldUsersEmails);
          }
          if(!currentUsersEmails.IsEmpty()){
             ccAddresses.addAll(currentUsersEmails);
          }
          
          system.debug('--ccAddresses--'+ccAddresses);    
          list<dcmgt_Approval_Configuration__c> approvalCongList = [select id, dcmgt_ReplyTo__c, dcmgt_FromAddress__c
                                                                          from dcmgt_Approval_Configuration__c order By createddate desc limit 1];
                                                                          
          string fromAddress;
          string replyTo;
          if(!approvalCongList.IsEmpty()){
              if(string.isnotBlank(approvalCongList[0].dcmgt_ReplyTo__c)){
                  replyTo = approvalCongList[0].dcmgt_ReplyTo__c;
              }
              if(string.isnotBlank(approvalCongList[0].dcmgt_FromAddress__c)){
                  fromAddress = approvalCongList[0].dcmgt_FromAddress__c;
              }
          }
          
          List<OrgWideEmailAddress> lstEmailAddress=new List<OrgWideEmailAddress>();
          if(string.IsNotBlank(fromAddress)){
              lstEmailAddress = [select Id from OrgWideEmailAddress WHERE Address=: fromAddress];
          }
          
          
          
          
          for(dcmgt_Change_Request__c changeReqRec: changeRequestList ){
                if(!changeReqRec.dcmgt_Alation_Article__r.IsEmpty() && string.IsNotBlank(replyTo)){
                
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(changeReqRec.CreatedById);
                    
                    message.setReplyTo(replyTo);
                    message.setUseSignature(false); 
                    message.setBccSender(false); 
                    message.setSaveAsActivity(false); 
                    message.setTemplateID(emailTemplate.Id); 
                    message.setccAddresses(ccAddresses);
                    message.setWhatId(changeReqRec.Id);
                    if(!lstEmailAddress.IsEmpty()){
                        message.setOrgWideEmailAddressId(lstEmailAddress[0].Id); 
                    }
                    emailList.add(message);
                    
                    for(dcmgt_Alation_Article__c article: changeReqRec.dcmgt_Alation_Article__r){                        
                        setOfArticleId.add(article.Id);
                    }
                    
                 }
                 if(!changeReqRec.dcmgt_Data_Assets__r.IsEmpty() && string.IsNotBlank(replyTo)){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    message.setTargetObjectId(changeReqRec.CreatedById);                    
                    
                    message.setReplyTo(replyTo);
                    message.setUseSignature(false); 
                    message.setBccSender(false); 
                    message.setSaveAsActivity(false); 
                    message.setTemplateID(emailTemplate.Id); 
                    message.setccAddresses(ccAddresses);
                    message.setWhatId(changeReqRec.Id);
                    //if(!lstEmailAddress.IsEmpty()){
                   //     message.setOrgWideEmailAddressId(lstEmailAddress[0].Id); 
                    //}
                    emailList.add(message);
                                        
                    for(dcmgt_Data_Assets__c dataAssets: changeReqRec.dcmgt_Data_Assets__r){                        
                        setOfDataAssetsId.add(dataAssets.Id);
                    }
                 }
                
          
          }
                   
         try{
             system.debug('--emailList--'+emailList);
             Messaging.sendEmail( emailList);  
             
             
              
         }catch(exception ee){
             system.debug('=='+ee.getMessage());
             system.debug('=='+ee.getlinenumber());
         }                
                   
     } 
     
     public void finish(Database.BatchableContext BC){
         if(!setOfArticleId.IsEmpty()){         
            Database.executeBatch(new dcmgt_BatchToUpdateArticleNotifinFlds(setOfArticleId, 'Rejected'), 200);
         }
         If(!setOfDataAssetsId.IsEmpty()){
            Database.executeBatch(new dcmgt_BatchToUpdateNotificationFields(setOfDataAssetsId, 'Rejected'), 200);
         }
            
     }
     
     public static Set<String> checkForOldApproversAndReturn(List<Id> recordIds,String fieldName){
        List<String> userFieldsLabelStoredInOldAndNewValuesMap = new List<String>{'Data Steward','Service Owner','Data Owner'};
        Set<String> olduserNames = new Set<String>();
        Set<String> newuserNames = new Set<String>();
        Set<String> usersThatAreChanged = new Set<String>();
        Set<String> oldEmails = new Set<String>();       
        List<sObject> returnValues=Database.query('select id,'+fieldName+' from ' + Id.valueOf(recordIds.get(0)).getSObjectType()+ ' where Id in :recordIds');
        for(sObject s:returnValues){
            Map<String,String> oldAndNewValues = (Map<String,String>) JSON.deserialize(String.valueOf(s.get(fieldName)).replace('&quot;','"'), Map<String,String>.class);
            for(String value:oldAndNewValues.keySet()){
                if(userFieldsLabelStoredInOldAndNewValuesMap.contains(value)){
                olduserNames.addAll(oldAndNewValues.get(value).subString(0,oldAndNewValues.get(value).indexOf('---')).split(';'));
                newuserNames.addAll(oldAndNewValues.get(value).subString(oldAndNewValues.get(value).indexOf('---')+3,oldAndNewValues.get(value).length()).split(';'));
                olduserNames.removeAll(newuserNames); 
                usersThatAreChanged.addAll(olduserNames);    
                }
            }
        } 
        map<Id,user> mapUsers=new map<id,user>([select Email from User where Name in:usersThatAreChanged]);
        for(Id userId:mapUsers.keySet()){
           oldEmails.add(mapUsers.get(userId).email); 
        }
        System.debug(oldEmails);
        return oldEmails;  
    }
}