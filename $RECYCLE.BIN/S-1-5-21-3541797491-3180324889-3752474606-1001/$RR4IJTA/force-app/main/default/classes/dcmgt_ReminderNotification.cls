public class dcmgt_ReminderNotification {
@InvocableMethod
public static void sendEmailReminder(List<Id> recordId) {
EmailTemplate template = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'dcmgt_Submit_For_Reminder'];
    try{
    Map<String,List<String>> changeRequestAndRecordsWithApproverIds = new Map<String,List<String>>();
    Map<String, String> mapOfCurrentOwnersAndStewards = new Map<String, String>();
    //list<dcmgt_Change_Request__c> changeRequestList=[select id,dcmgt_Request_Type__r.Name,dcmgt_Approvers__c from dcmgt_Change_Request__c where dcmgt_Status__c = 'Submitted'];
    list<dcmgt_Alation_Article__c> alationArticleList =[select id,CreatedDate,dcmgt_DataStewards__c,dcmgt_Data_Owners__c,
                                                            dcmgt_Change_Request__r.Name,dcmgt_Change_Request__r.dcmgt_Approvers__c,
                                                            dcmgt_Change_Request__r.CreatedById,dcmgt_Change_Request__r.CreatedBy.Name,
                                                            dcmgt_Change_Request__c from dcmgt_Alation_Article__c where dcmgt_Status__c='Submitted' 
                                                            and dcmgt_Change_Request__c in :recordId]; 
    list<dcmgt_Data_Assets__c> dataAssetList =[select id,CreatedDate,dcmgt_Data_Stewards__c,dcmgt_Service_Owners__c,
                                                    dcmgt_Change_Request__r.CreatedById,dcmgt_Change_Request__r.CreatedBy.Name,
                                                    dcmgt_Change_Request__r.Name,dcmgt_Change_Request__r.dcmgt_Approvers__c,dcmgt_Change_Request__c
                                                    from dcmgt_Data_Assets__c where dcmgt_Status__c='Submitted' and dcmgt_Change_Request__c in :recordId];// and CreatedDate = LAST_N_DAYS:3
    for(dcmgt_Alation_Article__c article : alationArticleList) {
        if(changeRequestAndRecordsWithApproverIds.get(article.dcmgt_Change_Request__c)!= null && String.isNotBlank(article.dcmgt_Change_Request__r.dcmgt_Approvers__c)){
            Set<String> allApproverIdsSet = new Set<String>(); 
            List<String> allApproverIdsList = changeRequestAndRecordsWithApproverIds.get(article.dcmgt_Change_Request__c);
            allApproverIdsSet.addAll(allApproverIdsList);
           // system.debug('alationarticle--16--'+String.valueOf(article.dcmgt_Change_Request__r.dcmgt_Approvers__c));
             Map<String,String> toMap = (Map<String,String>) JSON.deserialize(String.valueOf(article.get(article.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim())).replace('&quot;','"'), Map<String,String>.class);                                                                                             
             allApproverIdsSet.addAll(toMap.keySet());
             allApproverIdsList.addAll(allApproverIdsSet);
             changeRequestAndRecordsWithApproverIds.put(article.dcmgt_Change_Request__c,allApproverIdsList); 
          }
        else if(changeRequestAndRecordsWithApproverIds.get(article.dcmgt_Change_Request__c)==null && String.isNotBlank(article.dcmgt_Change_Request__r.dcmgt_Approvers__c)){
            Set<String> allApproverIdsSet = new Set<String>(); 
            List<String> allApproverIdsList = new List<String>();
            Map<String,String> toMap = (Map<String,String>) JSON.deserialize(String.valueOf(article.get(article.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim())).replace('&quot;','"'), Map<String,String>.class);                                                                                             
             allApproverIdsSet.addAll(toMap.keySet());
             allApproverIdsList.addAll(allApproverIdsSet);
             changeRequestAndRecordsWithApproverIds.put(article.dcmgt_Change_Request__c,allApproverIdsList); 
        }
        if(String.valueOf(article.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim()) == 'dcmgt_Data_Owners__c'){
            if(String.isNotBlank(article.dcmgt_DataStewards__c)){           
                Map<String, String> mapOfStewards = (Map<String,String>) JSON.deserialize(String.valueOf(article.dcmgt_DataStewards__c).replace('&quot;','"'), Map<String,String>.class);
                mapOfCurrentOwnersAndStewards.putAll(mapOfStewards);
                mapOfCurrentOwnersAndStewards.put(string.valueOf(article.dcmgt_Change_Request__r.CreatedById), article.dcmgt_Change_Request__r.CreatedBy.Name);
            }
        }
        if(String.valueOf(article.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim()) == 'dcmgt_DataStewards__c'){
            if(String.isNotBlank(article.dcmgt_Data_Owners__c)){
                Map<String, String> mapOfOwners = (Map<String,String>) JSON.deserialize(String.valueOf(article.dcmgt_Data_Owners__c).replace('&quot;','"'), Map<String,String>.class);
                mapOfCurrentOwnersAndStewards.putAll(mapOfOwners);
                mapOfCurrentOwnersAndStewards.put(string.valueOf(article.dcmgt_Change_Request__r.CreatedById), article.dcmgt_Change_Request__r.CreatedBy.Name);
            }
        }
    }
     for(dcmgt_Data_Assets__c dataAsset : dataAssetList) {
         if(changeRequestAndRecordsWithApproverIds.get(dataAsset.dcmgt_Change_Request__c)!= null && String.isNotBlank(dataAsset.dcmgt_Change_Request__r.dcmgt_Approvers__c)){
            Set<String> allApproverIdsSet = new Set<String>(); 
            List<String> allApproverIdsList = changeRequestAndRecordsWithApproverIds.get(dataAsset.dcmgt_Change_Request__c);
            allApproverIdsSet.addAll(allApproverIdsList);
           //  system.debug('dataAsset--37--'+String.valueOf(dataAsset.dcmgt_Change_Request__r.dcmgt_Approvers__c));
            Map<String,String> toMap = (Map<String,String>) JSON.deserialize(String.valueOf(dataAsset.get(dataAsset.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim())).replace('&quot;','"'), Map<String,String>.class);                                                                                             
             allApproverIdsSet.addAll(toMap.keySet());
             allApproverIdsList.addAll(allApproverIdsSet);
            changeRequestAndRecordsWithApproverIds.put(dataAsset.dcmgt_Change_Request__c,allApproverIdsList);
          }
        else if(changeRequestAndRecordsWithApproverIds.get(dataAsset.dcmgt_Change_Request__c)!= null && String.isNotBlank(dataAsset.dcmgt_Change_Request__r.dcmgt_Approvers__c)){
            Set<String> allApproverIdsSet = new Set<String>(); 
            List<String> allApproverIdsList = new List<String>();
           // system.debug('dataAsset--46--'+String.valueOf(dataAsset.dcmgt_Change_Request__r.dcmgt_Approvers__c));
            Map<String,String> toMap = (Map<String,String>) JSON.deserialize(String.valueOf(dataAsset.get(dataAsset.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim())).replace('&quot;','"'), Map<String,String>.class);                                                                                             
             allApproverIdsSet.addAll(toMap.keySet());
             allApproverIdsList.addAll(allApproverIdsSet);
            changeRequestAndRecordsWithApproverIds.put(dataAsset.dcmgt_Change_Request__c,allApproverIdsList); 
        }
        if(String.valueOf(dataAsset.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim()) == 'dcmgt_Service_Owners__c'){
            if(String.isNotBlank(dataAsset.dcmgt_Data_Stewards__c)){
            
                Map<String, String> mapOfStewards = (Map<String,String>) JSON.deserialize(String.valueOf(dataAsset.dcmgt_Data_Stewards__c).replace('&quot;','"'), Map<String,String>.class);
                
                mapOfCurrentOwnersAndStewards.putAll(mapOfStewards);
                mapOfCurrentOwnersAndStewards.put(string.valueOf(dataAsset.dcmgt_Change_Request__r.CreatedById), dataAsset.dcmgt_Change_Request__r.CreatedBy.Name);
            }
        }
        if(String.valueOf(dataAsset.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim()) == 'dcmgt_Data_Stewards__c'){
            if(String.isNotBlank(dataAsset.dcmgt_Service_Owners__c)){
        
                Map<String, String> mapOfServiceOwners = (Map<String,String>) JSON.deserialize(String.valueOf(dataAsset.dcmgt_Service_Owners__c).replace('&quot;','"'), Map<String,String>.class);
                system.debug('==mapOfServiceOwners=='+mapOfServiceOwners);
                mapOfCurrentOwnersAndStewards.putAll(mapOfServiceOwners);
                mapOfCurrentOwnersAndStewards.put(string.valueOf(dataAsset.dcmgt_Change_Request__r.CreatedById), dataAsset.dcmgt_Change_Request__r.CreatedBy.Name);
            }
        }
     }
     
     Set<String> currentUsersEmails = new Set<String>();       
      map<Id,user> mapUsers=new map<id,user>([select Email from User where id in:mapOfCurrentOwnersAndStewards.KeySet() limit 10000]);
      for(Id userId:mapUsers.keySet()){
         currentUsersEmails.add(mapUsers.get(userId).email); 
      }
     
     List<String> ccAddresses = new List<String>();
     if(!currentUsersEmails.IsEmpty()){
         ccAddresses.addAll(currentUsersEmails);
      }
        
     List<String> toUsers = new List<String>();
     List<String> a =new List<String>();
        
      list<Messaging.SingleEmailMessage> emailList= new list<Messaging.SingleEmailMessage>();
    for(String changeRequestId:changeRequestAndRecordsWithApproverIds.keySet()){
        if(changeRequestAndRecordsWithApproverIds.get(changeRequestId).Size()>0){
           Integer i=0;
        	if(i !=0){
                toUsers.add(mapUsers.get(changeRequestId).Email); 
            }else{
                toUsers.add(changeRequestId);  
            }
            i++;
            
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setToAddresses(toUsers);
            message.setTargetObjectId(changeRequestAndRecordsWithApproverIds.get(changeRequestId)[0]); 
            //message.setSenderDisplayName('Contract Management'); 
            message.setToAddresses(changeRequestAndRecordsWithApproverIds.get(changeRequestId)); 
             
            message.setReplyTo('bt-office-of-data-aaaaekw6z27okyszuum7bkcgpa@salesforce.org.slack.com');
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false); 
            message.setTemplateID(template.Id); 
            message.setccAddresses(ccAddresses);
            message.setWhatId(changeRequestId);
            
            
            emailList.add(message); 
            
        }
        //break;
    }
    
      system.debug('-'+emailList);
      Messaging.sendEmail(emailList);
    }catch(Exception e){
        System.debug(e.getMessage());
         System.debug('=='+e.getlinenumber());
    }
    
}
    
    
    
    
/*public void execute(SchedulableContext SC) {
 EmailTemplate template = [SELECT id FROM EmailTemplate WHERE DeveloperName = 'dcmgt_Submitted_For_Approval_Template'];

list<dcmgt_Alation_Article__c> articleList=new list<dcmgt_Alation_Article__c>([select id,dcmgt_Change_Request__r.dcmgt_Approvers__c,dcmgt_Change_Request__r.Name,
                                                                               dcmgt_Change_Request__c,dcmgt_DataStewards__c,dcmgt_Data_Owners__c,CreatedById 
                                                                               from dcmgt_Alation_Article__c where dcmgt_Change_Request__r.dcmgt_Status__c ='Submitted'
                                                                               AND (dcmgt_NextApproverRequired__c = true AND dcmgt_isSecondApproverNotified__c= false AND dcmgt_Status__c='In Review')]);
    List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        
         for(dcmgt_Alation_Article__c a : articleList)
    {   
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(a.dcmgt_Change_Request__r.dcmgt_Approvers__c);
            mail.setTemplateId(template.Id);
            mail.saveAsActivity = false;
            mailsToSend.add(mail);
            
       }
    //Send Emai
    if(mailsToSend.size() > 0)
    {
        Messaging.sendEmail(mailsToSend);       
    }
    }
    
   global class scheduledBatchable implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchable b = new batchable(); 
      database.executebatch(b);
   }
}*/
                                                                               

}