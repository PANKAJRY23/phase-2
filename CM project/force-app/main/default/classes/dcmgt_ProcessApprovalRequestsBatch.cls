public class dcmgt_ProcessApprovalRequestsBatch implements Database.Batchable<sObject>, Database.Stateful {
    public final String changeRequestId;
    public final String objectAPIName;
    public List<String> resultsForItemsThatAreSubmittedForApproval = new List<String>();
    public Map<Id,Set<Id>> approvers1WithRecordMap = new Map<Id,Set<Id>>();
    public Map<Id,Set<Id>> approvers2WithRecordMap = new Map<Id,Set<Id>>();
    public Set<String> oldApproversEmails = new Set<String>();
    public final String approver1APIName;
    public final String approver2APIName;
    public final String oldAndNewValuesFieldApiName;
    public dcmgt_ProcessApprovalRequestsBatch(String c,String o,String a1,String a2,String u){
      oldAndNewValuesFieldApiName=u;
      changeRequestId=c;
      objectAPIName = o;
      approver1APIName=a1;
      approver2APIName=a2; 
   }

   public Database.QueryLocator start(Database.BatchableContext BC){
       System.debug(objectAPIName);
       System.debug(changeRequestId);
       String query ='select id from '+objectAPIName+' where dcmgt_Change_Request__c=:changeRequestId';
       System.debug(query);
       return Database.getQueryLocator(query);
   }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        List<Approval.ProcessSubmitRequest> listOfItemsBeingSubmittedForApproval = new List<Approval.ProcessSubmitRequest>();
        List<String> allRecordIdsInBatch = new List<String>();
        Map<Id, Set<Id>> recordsAndLevel1ApproversMap;
        Map<Id, Set<Id>> recordsAndLevel2ApproversMap;
        
        for(sObject singleRecordInBatch:scope){
         allRecordIdsInBatch.add(String.valueOf(singleRecordInBatch.get('Id')));   
        }
        
        recordsAndLevel1ApproversMap = getApproversMapWithRecordID(allRecordIdsInBatch,approver1APIName);
        approvers1WithRecordMap.putAll(recordsAndLevel1ApproversMap);
        if(String.isNotBlank(approver2APIName)){
        recordsAndLevel2ApproversMap = getApproversMapWithRecordID(allRecordIdsInBatch,approver2APIName);
        approvers2WithRecordMap.putAll(recordsAndLevel2ApproversMap);    
        }
        
        if(recordsAndLevel1ApproversMap !=null){
            for(Id recordId:recordsAndLevel1ApproversMap.keySet()){
                for(Id userId:recordsAndLevel1ApproversMap.get(recordId)){
                    Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                    approvalRequest.setComments('Submitting request for approval.');
                    approvalRequest.setObjectId(recordId);
                    approvalRequest.setNextApproverIds(new List<Id>{userId}); 
                    listOfItemsBeingSubmittedForApproval.add(approvalRequest);    
                }
            }
        }   
         
        if(listOfItemsBeingSubmittedForApproval.size() >0){
         List<Approval.ProcessResult> results =  Approval.process(listOfItemsBeingSubmittedForApproval);
            for(Approval.ProcessResult result:results){
            if(result.isSuccess()){
               resultsForItemsThatAreSubmittedForApproval.add(result.getEntityId());
                } 
            }
        }
        
        if(checkForOldApproversAndReturn(allRecordIdsInBatch,oldAndNewValuesFieldApiName) !=null){
          oldApproversEmails.addAll(checkForOldApproversAndReturn(allRecordIdsInBatch,oldAndNewValuesFieldApiName));  
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
    
    public static Map<Id, Set<Id>> getApproversMapWithRecordID(List<Id> recordIds,String fieldName){
        Map<Id, Set<Id>> userMap = new Map<Id, Set<Id>>();
        List<sObject> returnValues=Database.query('select id,'+fieldName+' from ' + Id.valueOf(recordIds.get(0)).getSObjectType()+ ' where Id in :recordIds');
        for(sObject s:returnValues){
            Map<Id,String> recordMap=(Map<Id,String>) JSON.deserialize(String.valueOf(s.get(fieldName)).replace('&quot;','"'), Map<Id,String>.class);
            userMap.put(String.valueOf(s.get('Id')),recordMap.keySet());
        }  
        return userMap;   
    }
    
    public void finish(Database.BatchableContext BC){

       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
      TotalJobItems, CreatedBy.Email
      FROM AsyncApexJob WHERE Id =
      :BC.getJobId()];
        Set<Id> allUsersSet = new Set<Id>();
        Set<Id> toAddressesSet = new Set<Id>();
        Set<Id> ccAddressesSet = new Set<Id>();
        List<String> bccAddresses = new List<String>();
        bccAddresses.addAll(oldApproversEmails);
        List<Id> toAddressesSetConvertedToList = new List<Id>();
        List<Id> ccAddressesSetConvertedToList = new List<Id>();
        List<String> toAddressesList = new List<String>();
        List<String> ccAddressesList = new List<String>();
        List<Approval.ProcessWorkitemRequest> listOfItemsBeingSubmittedForAutoApproval1 = new List<Approval.ProcessWorkitemRequest>();
        List<Approval.ProcessWorkitemRequest> listOfItemsBeingSubmittedForAutoApproval2 = new List<Approval.ProcessWorkitemRequest>();
        Map<Id,Id> mapOfIdVsWorkItems= new map<Id,Id>();
        list<sobject> listOfRecordToUpdate1 = new list<sobject>();
        list<sobject> listOfRecordToUpdate2 = new list<sobject>();
        EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where developername = 'dcmgt_Submit_For_Approval_Change_Request'];
        
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
        
        
        for(String result:resultsForItemsThatAreSubmittedForApproval){
              toAddressesSet.addAll(approvers1WithRecordMap.get(result));
              allUsersSet.addAll(approvers1WithRecordMap.get(result));
                if(String.isNotBlank(approver2APIName)){
                 ccAddressesSet.addAll(approvers2WithRecordMap.get(result));
                 allUsersSet.addAll(approvers2WithRecordMap.get(result));   
                } 
        }
        toAddressesSetConvertedToList.addAll(toAddressesSet);
        map<Id,user> mapUsers=new map<id,user>([select Email from User where id in:allUsersSet]);
        if(String.isNotBlank(approver2APIName)){
         ccAddressesSetConvertedToList.addAll(ccAddressesSet);
         for(Integer i=0;i<ccAddressesSetConvertedToList.size();i++){  
             ccAddressesList.add(mapUsers.get(ccAddressesSetConvertedToList[i]).Email);      
        }   
        }
        for(Integer i=0;i<toAddressesSetConvertedToList.size();i++){
            if(i==0){
             toAddressesList.add(String.valueOf(toAddressesSetConvertedToList[i]));   
            }else{
             toAddressesList.add(mapUsers.get(toAddressesSetConvertedToList[i]).Email);      
            }
        }
       ccAddressesList.add(a.CreatedBy.Email);
       ccAddressesList.addAll(bccAddresses); 
        if(string.IsNotBlank(replyTo)){
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(toAddressesList[0]);
            if(toAddressesList.size()>1)
            {
             toAddressesList.remove(0);  
             message.setToAddresses(toAddressesList); 
            }
            message.setReplyTo(replyTo);
            message.setUseSignature(false); 
            message.setBccSender(false); 
            message.setSaveAsActivity(false); 
            message.setTemplateID(emailTemplate.Id); 
            message.setccAddresses(ccAddressesList);
            message.setWhatId(changeRequestId);
            if(!lstEmailAddress.IsEmpty()){
                message.setOrgWideEmailAddressId(lstEmailAddress[0].Id); 
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { message });
        }
        String comments = 'Auto Approved\n';
        Date todayDate = system.today();
        Datetime effectiveDateTime = datetime.newInstance(todayDate.year(), todayDate.month(),todayDate.day());
        comments = comments+effectiveDateTime.format('MM/dd/yyyy');
        Boolean isFirstApproverAutoApproved = false;
        //Auto approve for Approver 1
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstanceId,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :approvers1WithRecordMap.keySet()];
        if(workItems.size() > 0){
            for(ProcessInstanceWorkitem workItem: workItems){
                mapOfIdVsWorkItems.put(workItem.ProcessInstance.TargetObjectId,workItem.Id);
            }
        }
        system.debug('@@approvers1WithRecordMap::'+approvers1WithRecordMap);
        system.debug('@@approvers2WithRecordMap::'+approvers2WithRecordMap);
        Map<Id,Boolean> mapOfRecordWithIsFirstApproverAutoApproved = new Map<Id,Boolean>();
        for(Id recordId:approvers1WithRecordMap.keySet()){
            for(Id userId:approvers1WithRecordMap.get(recordId)){
                if(userId == UserInfo.getUserId() && mapOfIdVsWorkItems.size() > 0){
                    Id targetWorkItemId = mapOfIdVsWorkItems.get(recordId);
                    Approval.ProcessWorkitemRequest autoApprovalRequest = new Approval.ProcessWorkitemRequest();
                    autoApprovalRequest.setComments(comments);
                    autoApprovalRequest.setAction('Approve');
                    autoApprovalRequest.setNextApproverIds(new List<Id>{userId});
                    autoApprovalRequest.setWorkitemId(targetWorkItemId);
                    listOfItemsBeingSubmittedForAutoApproval1.add(autoApprovalRequest);
                    mapOfRecordWithIsFirstApproverAutoApproved.put(recordId, true);
                    sObject s = Id.valueOf(recordId).getSObjectType().newSObject(recordId);
                    s.put('dcmgt_Approval_date__c', System.today());
                    listOfRecordToUpdate1.add(s);
                }
            }
        }
        if(listOfItemsBeingSubmittedForAutoApproval1.size() > 0){
            List<Approval.ProcessResult> results =  Approval.process(listOfItemsBeingSubmittedForAutoApproval1);
            update listOfRecordToUpdate1;
            isFirstApproverAutoApproved = true;
        }

        //Auto Approve for Approver 2
        List<ProcessInstanceWorkitem> workItems2 = [SELECT Id, ProcessInstanceId,ProcessInstance.TargetObjectId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId IN :approvers2WithRecordMap.keySet()];
        if(workItems.size() > 0){
            for(ProcessInstanceWorkitem workItem: workItems2){
                mapOfIdVsWorkItems.put(workItem.ProcessInstance.TargetObjectId,workItem.Id);
            }
        }
        for(Id recordId:approvers2WithRecordMap.keySet()){
            for(Id userId:approvers2WithRecordMap.get(recordId)){
                if(userId == UserInfo.getUserId() && mapOfIdVsWorkItems.size() > 0 &&
                    mapOfRecordWithIsFirstApproverAutoApproved.containsKey(recordId) &&
                    mapOfRecordWithIsFirstApproverAutoApproved.get(recordId)){
                    Id targetWorkItemId = mapOfIdVsWorkItems.get(recordId);
                    Approval.ProcessWorkitemRequest autoApprovalRequest = new Approval.ProcessWorkitemRequest();
                    autoApprovalRequest.setComments(comments);

                    autoApprovalRequest.setAction('Approve');
                    autoApprovalRequest.setNextApproverIds(new List<Id>{userId});
                    autoApprovalRequest.setWorkitemId(targetWorkItemId);
                    listOfItemsBeingSubmittedForAutoApproval2.add(autoApprovalRequest);
                    sObject s = Id.valueOf(recordId).getSObjectType().newSObject(recordId);
                    s.put('dcmgt_Approval_date__c', System.today());
                    listOfRecordToUpdate2.add(s);
                }
            }
        }
        if(listOfItemsBeingSubmittedForAutoApproval2.size() > 0 && isFirstApproverAutoApproved){
            List<Approval.ProcessResult> results =  Approval.process(listOfItemsBeingSubmittedForAutoApproval2);
            update listOfRecordToUpdate2;
        }
   }
    
}