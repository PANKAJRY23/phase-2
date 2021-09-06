public class dcmgt_highlightPanelController {

    public class UserWrapper{
       @AuraEnabled  
        public String submitter {get;set;}  
        
         @AuraEnabled  
        public String actualApprover {get;set;}  
        
         @AuraEnabled  
        public String assignedTo {get;set;}  
        
        @AuraEnabled  
        public String createdDate {get;set;} 
        
        
         @AuraEnabled  
        public String objectLabel {get;set;} 
        
    }
    public class ReturnWrapper{
        @AuraEnabled  
        public boolean success {get;set;}
         @AuraEnabled  
        public Id instanceWorkItemId {get;set;}
        
    }
    
    
    @AuraEnabled(cacheable=true) 
    public static UserWrapper getProcessInstanceWorkitem(String workItemId){
        
        List<ProcessInstanceWorkitem> workitem = [Select Id, ProcessInstanceId, ProcessInstance.Status, ProcessInstance.TargetObjectId, ActorId, OriginalActorId, CreatedById, CreatedDate from ProcessInstanceWorkitem  where id=:workItemId];
        set<Id> setUserIds=new set<Id>{userinfo.getUserId(),workitem[0].OriginalActorId,workitem[0].ActorId};
        List<User> allUsersList = [select Id,name from User where id in :setUserIds];
        Map<Id,String> usersMap = new Map<Id,String>();
        for(User user:allUsersList){
           usersMap.put(user.id, user.name); 
        }
        
        
        List<sObject> recordItem = Database.query('select CreatedDate, CreatedById from ' +workitem[0].ProcessInstance.TargetObjectId.getSObjectType()+ ' where Id =\''+workitem[0].ProcessInstance.TargetObjectId+'\'');
        UserWrapper uWrapper = new UserWrapper();
        uWrapper.submitter = usersMap.get(String.valueOf(recordItem[0].get('CreatedById')));
        if(workitem[0].ProcessInstance.Status != 'Pending')
        	uWrapper.actualApprover = usersMap.get(workitem[0].ActorId);
         uWrapper.assignedTo = usersMap.get(workitem[0].OriginalActorId); 
          //uWrapper.createdDate = String.valueOf(recordItem[0].get('CreatedDate')).subString(0,10);
          Date tempeffectiveDate = Date.valueOf(String.valueOf(recordItem[0].get('CreatedDate')).subString(0,10));
         Datetime effectiveDateTime = datetime.newInstance(tempeffectiveDate.year(), tempeffectiveDate.month(),tempeffectiveDate.day());
         uWrapper.createdDate = effectiveDateTime.format('MM/dd/yyyy');
        uWrapper.objectLabel = workitem[0].ProcessInstance.TargetObjectId.getSobjectType().getDescribe().getLabel();
        return uWrapper;
        
    }
    
    @AuraEnabled
    public static String processStep(String recordId,String comments,String action,String effectiveDate){
     List<Approval.ProcessWorkitemRequest> listOfItems = new List<Approval.ProcessWorkitemRequest>();
     ProcessInstanceWorkitem p =  [select ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where id=:recordId];
        sObject s = p.ProcessInstance.TargetObjectId.getSObjectType().newSObject(p.ProcessInstance.TargetObjectId);
        if(String.isNotBlank(effectiveDate)) {
            s.put('dcmgt_Approval_date__c', Date.valueOf(effectiveDate));
        }
             s.put('id', p.ProcessInstance.TargetObjectId);
             update s;
     List<ProcessInstanceWorkitem> workitems = [Select Id from ProcessInstanceWorkitem  where id !=:recordId and ProcessInstance.TargetObjectId =:p.ProcessInstance.TargetObjectId ];    
         listOfItems.add(createProcessWorkItemRequest(recordId, null, action, comments));
       for(ProcessInstanceWorkitem workitem:workitems){
        listOfItems.add(createProcessWorkItemRequest(workitem.id, null, action, comments));       
        } 
        ReturnWrapper objReturnWrapper=new ReturnWrapper();
        system.debug('***listOfItems**'+listOfItems);
        List<Approval.ProcessResult> result = Approval.process(listOfItems); 
        objReturnWrapper.success=result.get(0).success;
        List<ProcessInstanceStep > returnWorkItems = [Select Id,ProcessInstanceId from ProcessInstanceStep   where ProcessInstance.TargetObjectId =:p.ProcessInstance.TargetObjectId order by CREATEDDATE desc];    
        objReturnWrapper.instanceWorkItemId=returnWorkItems[0].Id;
        return JSON.serialize(objReturnWrapper);
    }

    public static String processStep2(String recordId, String comments,String action,String effectiveDate){
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :recordId 
        ];
        System.debug('workItems:- '+workItems);
        if(!workItems.isEmpty()) {
            return processStep(workItems[0].Id,'Auto Approved',action,effectiveDate);
        }
        return '';
        
        // approvalEffectiveDate = effectiveDate;
        // Boolean isCurrentUserSystemAdmin = dcmgt_ApprovalHistoryUtil.isCurrentUserSystemAdmin(recordId);
        //      sObject s = Id.valueOf(recordId).getSObjectType().newSObject(recordId);
        //      s.put('dcmgt_Approval_date__c', Date.valueOf(effectiveDate));
        //      s.put('id', recordId);
        //     //  if(isCurrentUserSystemAdmin) {
        //     //     s.put('dcmgt_NextApproverRequired__c', false);
        //     //  }
        //      update s;
    //    return dcmgt_ApprovalHistoryUtil.processStep(workItems,comments,  action);
    }
    
    @AuraEnabled
    public static string setApproversForStep2(String recordId,String comments,String action, String effectiveDate){
    Set<Id> userIds;    
    ProcessInstanceWorkitem p =  [select ProcessInstance.TargetObjectId from ProcessInstanceWorkitem where id=:recordId];
    List<ProcessInstanceWorkitem> workitems = [Select Id from ProcessInstanceWorkitem  where id !=:recordId and ProcessInstance.TargetObjectId =:p.ProcessInstance.TargetObjectId ];    
    List<Approval.ProcessWorkitemRequest> listOfItems = new List<Approval.ProcessWorkitemRequest>();
        if(p.ProcessInstance.TargetObjectId.getSobjectType().getDescribe().getName() == 'dcmgt_Alation_Article__c'){
         dcmgt_Approval_Configuration__c approvalConfig = [select dcmgt_Approver_Role_For_step_2__c from dcmgt_Approval_Configuration__c where RecordType.Name = 'Article Approval Process Configurations' and dcmgt_Status__c='Active' order by createdDate desc limit 1]; 
                if(approvalConfig.dcmgt_Approver_Role_For_step_2__c == 'Data Steward'){
                   userIds =  dcmgt_ApprovalHistoryUtil.getApproversSet(p.ProcessInstance.TargetObjectId,'dcmgt_DataStewards__c');
                }else{
                   userIds =  dcmgt_ApprovalHistoryUtil.getApproversSet(p.ProcessInstance.TargetObjectId,'dcmgt_Data_Owners__c');  
                }    
        } else{
            dcmgt_Approval_Configuration__c approvalConfig = [select dcmgt_Approver_Role_For_step_2__c from dcmgt_Approval_Configuration__c where RecordType.Name = 'Data Asset Approval Configurations' and dcmgt_Status__c='Active' order by createdDate desc limit 1];
                if(approvalConfig.dcmgt_Approver_Role_For_step_2__c == 'Data Steward'){
                  userIds =  dcmgt_ApprovalHistoryUtil.getApproversSet(p.ProcessInstance.TargetObjectId,'dcmgt_Data_Stewards__c');  
                }else{
                  userIds =  dcmgt_ApprovalHistoryUtil.getApproversSet(p.ProcessInstance.TargetObjectId,'dcmgt_Service_Owners__c');     
                }
        }
        
        for(Id user:userIds){
       listOfItems.add(createProcessWorkItemRequest(recordId, user, action, comments));     
        }
        for(ProcessInstanceWorkitem workitem:workitems){
       listOfItems.add(createProcessWorkItemRequest(workitem.id, null, 'Removed', comments));     
        }
         List<Approval.ProcessResult> result = Approval.process(listOfItems);
        
        ReturnWrapper objReturnWrapper=new ReturnWrapper();
        objReturnWrapper.success=result.get(0).success;
        List<ProcessInstanceStep > returnWorkItems = [Select Id,ProcessInstanceId from ProcessInstanceStep   where ProcessInstance.TargetObjectId =:p.ProcessInstance.TargetObjectId order by CREATEDDATE desc];    
        objReturnWrapper.instanceWorkItemId=returnWorkItems[0].Id;
        Boolean isCurrentUserSystemAdmin = dcmgt_ApprovalHistoryUtil.isCurrentUserSystemAdmin(recordId);
        if(isCurrentUserSystemAdmin) {
            processStep2(p.ProcessInstance.TargetObjectId, comments, action, effectiveDate);
        }
        return JSON.serialize(objReturnWrapper);
    }
    
    private static Approval.ProcessWorkitemRequest createProcessWorkItemRequest(Id approvalStepId, Id approverId, String approvalAction, String commentFromApprover){
    Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
    // if(commentFromApprover != 'Auto Approved'){
    //     String replaceTarget = commentFromApprover.right(10);
    //     Date tempeffectiveDate = Date.valueOf(replaceTarget);
    //     Datetime effectiveDateTime = datetime.newInstance(tempeffectiveDate.year(), tempeffectiveDate.month(),tempeffectiveDate.day());
    //     String replaceReplacement = effectiveDateTime.format('MM/dd/yyyy');
    //     commentFromApprover = commentFromApprover.replace(replaceTarget,replaceReplacement);
    // }
    result.setComments(commentFromApprover);
    result.setAction(approvalAction);
    result.setWorkitemId(approvalStepId);
    if (approverId != null) {
        result.setNextApproverIds(new List<Id>{approverId});
    }
    return result;
}
    
}