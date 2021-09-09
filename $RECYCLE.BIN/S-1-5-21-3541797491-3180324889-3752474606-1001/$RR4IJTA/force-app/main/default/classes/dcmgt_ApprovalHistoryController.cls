public without sharing class dcmgt_ApprovalHistoryController {

    public class ApprovalHistoryStep{
        @AuraEnabled  
        public String stepName {get;set;}  
        @AuraEnabled  
        public String stepUrl {get;set;}
        @AuraEnabled  
        public DateTime createdDate {get;set;}   
        @AuraEnabled  
        public String stepStatus {get;set;}  
        @AuraEnabled  
        public String assignedTo {get;set;}   
        @AuraEnabled  
        public String assignedToUrl {get;set;}
        @AuraEnabled
        public String comments {get;set;}
        @AuraEnabled
        public String effectiveDate {get;set;}
        
        public ApprovalHistoryStep(
            String stepName,
            String stepId,
            DateTime createdDate, 
            String stepStatus,
            String assignedTo,
            String assignedToId,
            String comments )  
        { 
            this.stepName = stepName;
            this.stepUrl = '/' + stepId;
            this.createdDate = createdDate;
            this.assignedTo = assignedTo;  
            this.assignedToUrl = '/'+assignedToId;
            system.debug('comments'+comments);
            this.comments = string.isNotBlank(comments)?
                comments.substringBefore('\n'):comments;
            this.effectiveDate = string.isNotBlank(comments)?
                comments.substringAfterLast('\n'):'';

            if(stepStatus == dcmgt_ApprovalHistoryUtil.STATUS_STARTED){
                this.stepStatus = dcmgt_ApprovalHistoryUtil.STATUS_SUBMITTED;
            }else if(stepStatus == dcmgt_ApprovalHistoryUtil.STATUS_REMOVED){
                this.stepStatus = dcmgt_ApprovalHistoryUtil.STATUS_RECALLED;
            }else{
                this.stepStatus = stepStatus;
            }
            
        } 
    }
    
    
    public class ApprovalHistory{
        @AuraEnabled
        public List<ApprovalHistoryStep> approvalSteps;
        @AuraEnabled
        public String approvalStepsSize;
        @AuraEnabled 
        public boolean isCurrentUserApprover; 
        @AuraEnabled 
        public boolean showRecall;  //Modify All Data" permission or "Modify All" on the object level
                                    // system admin and submitter(if it says so on the approval process)
                                        //SELECT Name FROM Profile WHERE PermissionsModifyAllData = true
                                    //query permission sets with modify all or modify all for object and see if curr user has them

        @AuraEnabled 
        public boolean showSubmitForApproval; 

        @AuraEnabled
        public String objectApiName;
        
        
        public ApprovalHistory(List<ApprovalHistoryStep> approvalSteps, boolean isCurrentUserApprover, boolean isSubmitForApproval, boolean showRecall){
            this.approvalSteps = approvalSteps;
            this.isCurrentUserApprover = isCurrentUserApprover; 
            //this.approvalStepsSize = moreThan6Steps ? '6+' : string.valueOf(approvalSteps.size());
            this.showSubmitForApproval = isSubmitForApproval;
            this.showRecall = showRecall;
        }
    }
    
    
   
     @AuraEnabled (cacheable=true)
    public static ApprovalHistory getApprovalHistory(String recordId){
        System.debug('1');
      List<ProcessInstance> processInstances = [SELECT Id,SubmittedById, ProcessDefinition.Name , (SELECT ID, ProcessNodeId,  
                                                            StepStatus,Comments,TargetObjectId,ActorId,CreatedById,IsDeleted,IsPending  
                                                            ,OriginalActorId,ProcessInstanceId,RemindersSent,CreatedDate, Actor.Name,  
                                                            OriginalActor.Name , ProcessNode.Name FROM StepsAndWorkitems order by IsPending DESC, CreatedDate DESC )   
                                                    FROM ProcessInstance where TargetObjectId =:recordId order by CreatedDate DESC]; 
          
          return dcmgt_ApprovalHistoryUtil.populateApprovalHistorySteps(processInstances, recordId); 
    }
    
    @AuraEnabled
    public static String processStepInBulk(list<Id> recordIds, String comments,String action,String effectiveDate){
         Id sobjectRcordId = recordIds[0];
         system.debug('--recordIds--'+recordIds);
         Schema.SObjectType getSobjectType = sobjectRcordId.getSobjectType();
         dcmgt_Change_Request__c changeRequestRec = new dcmgt_Change_Request__c();
         Id jobId ;
         Boolean isCurrentUserSystemAdmin = dcmgt_ApprovalHistoryUtil.isCurrentUserSystemAdmin(recordIds[0]);
         if(String.valueOf(getSobjectType) == 'dcmgt_Alation_Article__c'){
            jobId = DataBase.executeBatch(new dcmgt_BatchToApproveRejectChangeRequest(recordIds,comments,action,effectiveDate, isCurrentUserSystemAdmin),200);
            if(isCurrentUserSystemAdmin) {
                jobId = DataBase.executeBatch(new dcmgt_BatchToApproveRejectChangeRequest(recordIds,comments,action,effectiveDate, false),200);
            }
            changeRequestRec.Id = [Select id,dcmgt_Change_Request__c from dcmgt_Alation_Article__c where id=:recordIds[0] limit 1].dcmgt_Change_Request__c; 
         }else{
            jobId = DataBase.executeBatch(new dcmgt_BatchToApproveRejectCRDataAssets(recordIds,comments,action,effectiveDate, isCurrentUserSystemAdmin),200);
            changeRequestRec.Id = [Select id,dcmgt_Change_Request__c from dcmgt_Data_Assets__c where id=:recordIds[0] limit 1].dcmgt_Change_Request__c; 
            if(isCurrentUserSystemAdmin) {
                jobId = DataBase.executeBatch(new dcmgt_BatchToApproveRejectCRDataAssets(recordIds,comments,action,effectiveDate, false),200);
            }
         }
         system.debug('--jobId--'+jobId);
         
            
            
         changeRequestRec.dcmgt_Batch_Job_Id__c = jobId;
            
         upsert changeRequestRec;
        return null;
    }
    
    @AuraEnabled
    public static String methodForCheckingJobId(string recordId){
    
        dcmgt_Change_Request__c changeRequest = [Select id, dcmgt_Batch_Job_Id__c from dcmgt_Change_Request__c where Id=:recordId limit 1];
        
        if(string.IsnotBlank(changeRequest.dcmgt_Batch_Job_Id__c)){
            return 'true';
        }else{
            return 'false';
        }
           

        
    }
    
    private Static String approvalEffectiveDate;
    @AuraEnabled
    public static String processStep(String recordId, String comments,String action,String effectiveDate){
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :recordId 
        ];
        approvalEffectiveDate = effectiveDate;
        Boolean isCurrentUserSystemAdmin = dcmgt_ApprovalHistoryUtil.isCurrentUserSystemAdmin(recordId);
             sObject s = Id.valueOf(recordId).getSObjectType().newSObject(recordId);
             if(effectiveDate != ''){
                s.put('dcmgt_Approval_date__c', Date.valueOf(effectiveDate));
             }
             s.put('id', recordId);
            //  if(isCurrentUserSystemAdmin) {
            //     s.put('dcmgt_NextApproverRequired__c', false);
            //  }
             update s;
       return dcmgt_ApprovalHistoryUtil.processStep(workItems,comments,  action);
    }

    @AuraEnabled
    public static String publicRequestStep(String recordId, String comments,String action){
        List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :recordId 
        ];
     return dcmgt_ApprovalHistoryUtil.processStep(workItems,comments,action);
    }
    
    @AuraEnabled
    public static void setApproversForStep2(String recordId, String comments,String action){
      List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :recordId 
        ];
        System.debug('workitemss:'+workItems ) ;
        System.debug(' comments:'+comments ) ;
        System.debug('actionsss:'+action );
        System.debug('recordid:'+recordId);
     dcmgt_ApprovalHistoryUtil.setApproversForStep2(workItems,comments,action,recordId);   
    }

    @AuraEnabled
    public static void setApproversForStep2(String recordId, String comments,String action, String effectiveDate){
      List<ProcessInstanceWorkitem> workItems = [
            SELECT Id, ProcessInstanceId 
            FROM ProcessInstanceWorkitem 
            WHERE ProcessInstance.TargetObjectId = :recordId 
        ];
        System.debug('workitemss:'+workItems ) ;
        System.debug(' comments:'+comments ) ;
        System.debug('actionsss:'+action );
        System.debug('recordid:'+recordId);
     dcmgt_ApprovalHistoryUtil.setApproversForStep2(workItems,comments,action,recordId);   
     Boolean isCurrentUserSystemAdmin = dcmgt_ApprovalHistoryUtil.isCurrentUserSystemAdmin(recordId);
     if(isCurrentUserSystemAdmin) {
        processStep(recordId,'Auto Approved' , action, effectiveDate);
     }
    }
    
    @AuraEnabled(Cacheable=true)
    public static List<dcmgt_LookupSearchResult> searchUsers(String searchTerm) {
        // Prepare query paramters
        searchTerm += '*';

        // Execute search query
        List<List<SObject>> searchResults = [
            FIND :searchTerm
            IN ALL FIELDS
            RETURNING
                User(Id, FirstName, LastName)
            LIMIT :dcmgt_ApprovalHistoryUtil.MAX_RESULTS 
        ];

        // Prepare results
        List<dcmgt_LookupSearchResult> results = new List<dcmgt_LookupSearchResult>();

        // Extract Accounts & convert them into LookupSearchResult
        String userIcon = 'standard:user';
        User[] users = (List<User>) searchResults[0];
        for (User currUser : users) {
            results.add(
                new dcmgt_LookupSearchResult(
                    currUser.Id,
                    'User',
                    userIcon,
                    currUser.FirstName + ' ' + currUser.LastName,
                    ''
                )
            );
        }

        // Optionnaly sort all results on title
        results.sort();

        return results;
    }
    
}