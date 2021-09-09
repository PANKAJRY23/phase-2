public class dcmgt_secondApproverEmailsBatchArticle implements Database.Batchable<dcmgt_Alation_Article__c>, Database.Stateful,Iterable<dcmgt_Alation_Article__c>, Iterator<dcmgt_Alation_Article__c>{

    public integer i;
    List<dcmgt_Alation_Article__c> sObjectsList = new List<dcmgt_Alation_Article__c>();
    Map<String,Map<String,Set<String>>> changeRequestandApproversMap = new  Map<String,Map<String,Set<String>>>();
    Map<String,Map<String,Set<String>>> changeRequestAndListofIdsProcessed = new  Map<String,Map<String,Set<String>>>();
    Set<String> allUserSet = new Set<String>();
    public Set<String> oldApproversEmails = new Set<String>();
    public dcmgt_secondApproverEmailsBatchArticle() {  
    String query ='select id,dcmgt_Change_Request__r.dcmgt_Approvers__c,dcmgt_Change_Request__r.Name,dcmgt_Change_Request__c,dcmgt_DataStewards__c,dcmgt_Data_Owners__c,CreatedById,dcmgt_Updates_Fields__c from dcmgt_Alation_Article__c where dcmgt_Change_Request__r.dcmgt_Status__c =\'Submitted\' AND (dcmgt_NextApproverRequired__c = true AND dcmgt_isSecondApproverNotified__c= false AND dcmgt_Status__c=\'In Review\')';
    sObjectsList = Database.query(query) ;
    i = 0;
     }
    
  public Iterator<dcmgt_Alation_Article__c> iterator() {
    return this;
  }
    
  public boolean hasNext() {
    if(sObjectsList.size() <= i) 
      return false;
    else
      return true;
  }
  public dcmgt_Alation_Article__c next() {
    i++;
    return sObjectsList[i-1];
  }
    public Iterable<dcmgt_Alation_Article__c> start(Database.BatchableContext BC){
      return new dcmgt_secondApproverEmailsBatchArticle();  
    }
      
    public void execute(Database.BatchableContext BC, List<dcmgt_Alation_Article__c> scope){
        for(dcmgt_Alation_Article__c itemInBatch:scope){
            if(itemInBatch.dcmgt_Change_Request__r.dcmgt_Approvers__c !=null && itemInBatch.dcmgt_DataStewards__c !=null && itemInBatch.dcmgt_Data_Owners__c  !=null ){
                if(changeRequestandApproversMap.get(itemInBatch.dcmgt_Change_Request__r.Name) !=null && changeRequestAndListofIdsProcessed.get(itemInBatch.dcmgt_Change_Request__r.Name) !=null){
                Set<String> processedIds = (changeRequestAndListofIdsProcessed.get(itemInBatch.dcmgt_Change_Request__r.Name)).get(itemInBatch.dcmgt_Change_Request__c);
                processedIds.add(itemInBatch.Id);
                Map<String,Set<String>> processedIdsAndChangeRequestIdMap = new Map<String,Set<String>>();
                processedIdsAndChangeRequestIdMap.put(itemInBatch.dcmgt_Change_Request__c,processedIds);
                changeRequestAndListofIdsProcessed.put(itemInBatch.dcmgt_Change_Request__r.Name, processedIdsAndChangeRequestIdMap);    
                Set<String> toAddresses = (changeRequestandApproversMap.get(itemInBatch.dcmgt_Change_Request__r.Name)).get('toAddresses');
                Set<String> ccAddresses = (changeRequestandApproversMap.get(itemInBatch.dcmgt_Change_Request__r.Name)).get('ccAddresses');  
                Map<String,String> toMap = (Map<String,String>) JSON.deserialize(String.valueOf(itemInBatch.get(itemInBatch.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[1].trim())).replace('&quot;','"'), Map<String,String>.class);  
                Map<String,String> ccMap = (Map<String,String>) JSON.deserialize(String.valueOf(itemInBatch.get(itemInBatch.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim())).replace('&quot;','"'), Map<String,String>.class);     
                toAddresses.addAll(toMap.keySet());
                ccAddresses.addAll(ccMap.keySet());
                ccAddresses.add(itemInBatch.CreatedById);
                allUserSet.addAll(toAddresses);
                allUserSet.addAll(ccAddresses);      
                Map<String,Set<String>> toAndCCAdressesMap = new Map<String,Set<String>>();
                toAndCCAdressesMap.put('toAddresses', toAddresses); 
                toAndCCAdressesMap.put('ccAddresses', ccAddresses);    
                changeRequestandApproversMap.put(itemInBatch.dcmgt_Change_Request__r.Name, toAndCCAdressesMap);
                Set<String> oldApprovers = checkForOldApproversAndReturn(itemInBatch.dcmgt_Updates_Fields__c);
                oldApproversEmails.addAll(oldApprovers);    
                }else{
                Set<String> processedIds = new Set<String>();
                processedIds.add(itemInBatch.Id);
                Map<String,Set<String>> processedIdsAndChangeRequestIdMap = new Map<String,Set<String>>();
                processedIdsAndChangeRequestIdMap.put(itemInBatch.dcmgt_Change_Request__c,processedIds);
                changeRequestAndListofIdsProcessed.put(itemInBatch.dcmgt_Change_Request__r.Name, processedIdsAndChangeRequestIdMap);      
                Set<String> toAddresses = new Set<String>();
                Set<String> ccAddresses = new Set<String>();
                Map<String,String> toMap = (Map<String,String>) JSON.deserialize(String.valueOf(itemInBatch.get(itemInBatch.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[1].trim())).replace('&quot;','"'), Map<String,String>.class);  
                Map<String,String> ccMap = (Map<String,String>) JSON.deserialize(String.valueOf(itemInBatch.get(itemInBatch.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim())).replace('&quot;','"'), Map<String,String>.class);     
                toAddresses.addAll(toMap.keySet());
                ccAddresses.addAll(ccMap.keySet());
                ccAddresses.add(itemInBatch.CreatedById);
                allUserSet.addAll(toAddresses);
                allUserSet.addAll(ccAddresses);      
                Map<String,Set<String>> toAndCCAdressesMap = new Map<String,Set<String>>();
                toAndCCAdressesMap.put('toAddresses', toAddresses); 
                toAndCCAdressesMap.put('ccAddresses', ccAddresses);    
                changeRequestandApproversMap.put(itemInBatch.dcmgt_Change_Request__r.Name, toAndCCAdressesMap); 
                Set<String> oldApprovers = checkForOldApproversAndReturn(itemInBatch.dcmgt_Updates_Fields__c);
                oldApproversEmails.addAll(oldApprovers);     
                }
            }  
        }      
    }
    
    
    public static Set<String> checkForOldApproversAndReturn(String updatedFields){
        List<String> userFieldsLabelStoredInOldAndNewValuesMap = new List<String>{'Data Steward','Service Owner','Data Owner'};
        Set<String> olduserNames = new Set<String>();
        Set<String> newuserNames = new Set<String>();
        Set<String> usersThatAreChanged = new Set<String>();
        Set<String> oldEmails = new Set<String>();       
       
            Map<String,String> oldAndNewValues = (Map<String,String>) JSON.deserialize(updatedFields.replace('&quot;','"'), Map<String,String>.class);
            for(String value:oldAndNewValues.keySet()){
                if(userFieldsLabelStoredInOldAndNewValuesMap.contains(value)){
                olduserNames.addAll(oldAndNewValues.get(value).subString(0,oldAndNewValues.get(value).indexOf('---')).split(';'));
                newuserNames.addAll(oldAndNewValues.get(value).subString(oldAndNewValues.get(value).indexOf('---')+3,oldAndNewValues.get(value).length()).split(';'));
                olduserNames.removeAll(newuserNames); 
                usersThatAreChanged.addAll(olduserNames);    
                }
            }
        map<Id,user> mapUsers=new map<id,user>([select Email from User where Name in:usersThatAreChanged]);
        for(Id userId:mapUsers.keySet()){
           oldEmails.add(mapUsers.get(userId).email); 
        }
        System.debug(oldEmails);
        return oldEmails;  
    }
    
    
    
    public void finish(Database.BatchableContext BC){
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where developername = 'dcmgt_Submit_For_Approvers_2'];
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
          
          List<OrgWideEmailAddress> lstEmailAddress;
          if(string.IsNotBlank(fromAddress)){
              lstEmailAddress = [select Id from OrgWideEmailAddress WHERE Address=: fromAddress];
          }
        System.debug(changeRequestandApproversMap); 
        System.debug(changeRequestAndListofIdsProcessed); 
        map<Id,user> mapUsers=new map<id,user>([select Email from User where id in:allUserSet ]);
        List<String> processedIds = new List<Id>();
        List<dcmgt_Alation_Article__c> updatedAlationArticlesList = new List<dcmgt_Alation_Article__c>();    
        for(String changeRequestName:changeRequestandApproversMap.keySet()){
        System.debug(changeRequestName);    
        List<String> toUsers = new List<String>();
        List<String> ccUsers = new List<String>();
        Integer i =0;    
        for(String a:changeRequestandApproversMap.get(changeRequestName).get('toAddresses')){
            if(i !=0){
                toUsers.add(mapUsers.get(a).Email); 
            }else{
                toUsers.add(a);  
            }
            i++;
        }
            System.debug(toUsers);
        for(String b:changeRequestandApproversMap.get(changeRequestName).get('ccAddresses')){
         ccUsers.add(mapUsers.get(b).Email);
        }
        ccUsers.addAll(oldApproversEmails);    
        Map<String,Set<String>> changeRequestAndProcessedRecords =  changeRequestAndListofIdsProcessed.get(changeRequestName);
        List<String> a =new List<String>();  
        List<String> b =new List<String>();   
        a.addAll(changeRequestAndProcessedRecords.keySet());
        b.addAll(changeRequestAndProcessedRecords.get(a[0]));
        processedIds.addAll(changeRequestAndProcessedRecords.get(a[0]));    
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage(); 
        if(string.IsNotBlank(replyTo)){  
            message.setTargetObjectId(toUsers[0]); 
            if(!lstEmailAddress.IsEmpty()){
                message.setOrgWideEmailAddressId(lstEmailAddress[0].Id); 
            }
            toUsers.remove(0);    
            message.setToAddresses(toUsers); 
            message.setReplyTo(replyTo);
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false);  
            message.setccAddresses(ccUsers);
            message.setTemplateID(emailTemplate.Id); 
            message.setWhatId(a[0]);
            messages.add(message);
        }    
        }
       try {
                Messaging.sendEmail(messages,false);
           for(String c:processedIds){
            dcmgt_Alation_Article__c alationArticle = new dcmgt_Alation_Article__c();
            alationArticle.dcmgt_isSecondApproverNotified__c = true;
            alationArticle.Id = c;
            updatedAlationArticlesList.add(alationArticle);
        }
         update updatedAlationArticlesList;
                } catch (Exception e) {
                    System.debug(e.getMessage());
                } 
    }

}