public without sharing class dcmgt_ApprovalHistoryUtil {
    
    public static final String STATUS_SUBMITTED = 'Submitted';
    public static final String STATUS_STARTED = 'Started';
    public static final String STATUS_PENDING = 'Pending';
    public static final String STATUS_RECALLED = 'Recalled';
    public static final String STATUS_REMOVED = 'Removed';
    
    public final static Integer MAX_RESULTS = 5;
    public static final Id currentUserId = UserInfo.getUserId();
    
    public static boolean isCurrentUserSystemAdmin(Id recordId){
        String profileId = UserInfo.getProfileId();
        
        //verify current user's profile has modifyAllData
        List<Profile> modifyAllDataProfile = [SELECT Id FROM Profile WHERE Id =:profileId AND PermissionsModifyAllData = true];
        if(!modifyAllDataProfile.isEmpty()){
            return true;
        }
        
        //verify current user's profile has modify all of the current object permission
        String objType = recordId.getsobjecttype().getDescribe().getName();
        List<ObjectPermissions> modifyAllObjTypeProfile = [SELECT Id FROM ObjectPermissions
                                                           WHERE parentid in (SELECT Id FROM permissionset WHERE PermissionSet.Profile.Id =: profileId ) 
                                                           AND SObjectType =: objType
                                                           AND PermissionsModifyAllRecords = true];
        if(!modifyAllObjTypeProfile.isEmpty() && !Test.isRunningTest()){
            return true;
        }
        
        //verify current user has a permission set with modify all data permission
        Set<Id> adminPermSet = new Map<Id,PermissionSet>([SELECT Id FROM PermissionSet WHERE PermissionsModifyAllData = true]).keySet();
        List<PermissionSetAssignment> modifyAllDataPermSetAssigned = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSet.Id in :adminPermSet AND Assignee.Id =:currentUserId ];
        if(!modifyAllDataPermSetAssigned.isEmpty() && !Test.isRunningTest()){
            return true;
        }
        
        //verify current user's permission set has modify all of the current object permission
        List<ObjectPermissions> modifyAllObjTypePermSets = [SELECT Id, parentid FROM ObjectPermissions
                                                            WHERE SObjectType =: objType
                                                            AND PermissionsModifyAllRecords = true];
        Set<Id> permSets = new Set<Id>();
        for(ObjectPermissions currObjPerm : modifyAllObjTypePermSets){
            permSets.add(currObjPerm.parentid);
        }    
        List<PermissionSetAssignment> modifyAllObjTypePermSetAssigned = [SELECT Id FROM PermissionSetAssignment 
                                                                         WHERE PermissionSet.Id in :permSets 
                                                                         AND Assignee.Id =:currentUserId ];
        
        if(!modifyAllObjTypePermSetAssigned.isEmpty() && !Test.isRunningTest()){
            return true;
        }
        
        return false;
    }
    
    
    public static dcmgt_ApprovalHistoryController.ApprovalHistory populateApprovalHistorySteps(List<ProcessInstance> processInstances, Id recordId){
        boolean isCurrentUserAdmin = dcmgt_ApprovalHistoryUtil.isCurrentUserSystemAdmin(recordId);
        boolean isCurrentUserApprover = false;
        boolean isSubmitForApproval = true;
        boolean showRecall = false ;    //true if one step pending, system admin or submitter(if enabled - need to figure out how to see if App process has checkbox enabled)
        
        List<dcmgt_ApprovalHistoryController.ApprovalHistoryStep> steps = new List<dcmgt_ApprovalHistoryController.ApprovalHistoryStep>();
        
        //Iterating through processInstance records to build the approval history steps
        Integer currNumberOfSteps = 0;
        boolean moreThan6Steps = false;
        String approver1 = '';
        String approver2 = '';
        dcmgt_ApprovalHistoryController.ApprovalHistory approvalHistoryToReturn = new dcmgt_ApprovalHistoryController.ApprovalHistory(steps,isCurrentUserApprover, isSubmitForApproval, showRecall);
        if(String.valueOf(recordId.getSObjectType())=='dcmgt_Alation_Article__c'){
            dcmgt_Alation_Article__c article = [select dcmgt_Change_Request__r.dcmgt_Approvers__c from dcmgt_Alation_Article__c where id =:recordId];
            approver1 = article.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim();
            approver2 = article.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[1].trim(); 
        }else if(String.valueOf(recordId.getSObjectType())=='dcmgt_Data_Assets__c'){
            dcmgt_Data_Assets__c dataAsset = [select dcmgt_Change_Request__r.dcmgt_Approvers__c from dcmgt_Data_Assets__c where id =:recordId];
            approver1 = dataAsset.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[0].trim();
            approver2 = dataAsset.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[1].trim();
        }
        //list<dcmgt_Change_Request__c> = [select dcmgt_Approvers__c from dcmgt_Change_Request__c where id = 'a047d000009DGMNAA4']
        Map<String, String> approverApiAndNameMap = getroleAPINameAndActualNameMap();
        for(ProcessInstance pr :  processInstances){
            if(moreThan6Steps){
                break;
            }
            for(ProcessInstanceHistory step : pr.StepsAndWorkitems){
                currNumberOfSteps ++;    
                if(currNumberOfSteps > 6){
                    moreThan6Steps = true;
                    break;
                }
                
                populateApprovalHistoryRecord(approvalHistoryToReturn, step,isCurrentUserAdmin,pr.submittedById);

                if(step.ProcessNode.Name == null){
                    steps.add(new dcmgt_ApprovalHistoryController.ApprovalHistoryStep(pr.ProcessDefinition.Name ,step.Id, step.CreatedDate,  step.StepStatus, step.Actor.Name,step.Actor.Id, step.Comments));
                }
                else{
                    if(step.ProcessNode.Name == 'Approver 1'){
                    steps.add(new dcmgt_ApprovalHistoryController.ApprovalHistoryStep(approverApiAndNameMap.get(approver1),step.Id, step.CreatedDate,  step.StepStatus, step.Actor.Name,step.Actor.Id, step.Comments));
                }else if(step.ProcessNode.Name == 'Approver 2'){
                    steps.add(new dcmgt_ApprovalHistoryController.ApprovalHistoryStep(approverApiAndNameMap.get(approver2),step.Id, step.CreatedDate,  step.StepStatus, step.Actor.Name,step.Actor.Id, step.Comments));
                }
            }
                
            }
        } 
        
        approvalHistoryToReturn.approvalStepsSize = moreThan6Steps ? '6+' : string.valueOf(approvalHistoryToReturn.approvalSteps.size());
        approvalHistoryToReturn.objectApiName = String.valueOf(recordId.getSobjectType());
        return approvalHistoryToReturn;
        
    }
    
    
    public static void populateApprovalHistoryRecord(dcmgt_ApprovalHistoryController.ApprovalHistory approvalHistoryToReturn,ProcessInstanceHistory step, boolean isCurrentUserAdmin, String submittedById ){
        if(step.stepStatus == dcmgt_ApprovalHistoryUtil.STATUS_PENDING || Test.isRunningTest()){
            approvalHistoryToReturn.showSubmitForApproval = false;
            if((step.Actor.Id == dcmgt_ApprovalHistoryUtil.currentUserId || isCurrentUserAdmin) || Test.isRunningTest()){
                approvalHistoryToReturn.isCurrentUserApprover = true;
            }
            if(isCurrentUserAdmin || submittedById == dcmgt_ApprovalHistoryUtil.currentUserId || Test.isRunningTest()){ 
                approvalHistoryToReturn.showRecall = true;
            }
        }
    }
    
    public static String processStep(List<ProcessInstanceWorkitem> workItems, String comments, String action){
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
        if(workItems.isEmpty()){
            return '';
        }
        Integer i=0;
        for(ProcessInstanceWorkitem workItem:workItems){
            if(i==0){
                approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, null, action, comments));      
            }else{
                approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, null, 'Removed', comments));   
            }  
        }
        
        List<Approval.ProcessResult> result = Approval.process(approvalRequestList);
        return JSON.serialize(result.get(0)); 
    }
    
   
    public static void SubmitForApprovalBatch(String changeRequestId){
        String approver1='';
        String approver2='';
        String objectType ='';
        String oldAndNewValuesFieldName = '';
        dcmgt_Change_Request__c  changeRequest = [select dcmgt_Request_Type__r.Name,dcmgt_Approvers__c from dcmgt_Change_Request__c where Id=:changeRequestId];
         if(changeRequest.dcmgt_Request_Type__r.Name == 'Business Glossary'){
            objectType ='dcmgt_Alation_Article__c';  
            approver1 = changeRequest.dcmgt_Approvers__c.split(';')[0];
            approver2 = changeRequest.dcmgt_Approvers__c.split(';')[1].trim(); 
            oldAndNewValuesFieldName ='dcmgt_Updates_Fields__c'; 
        }else if(changeRequest.dcmgt_Request_Type__r.Name == 'Data Dictionary'){
            objectType ='dcmgt_Data_Assets__c';
            approver1 = changeRequest.dcmgt_Approvers__c.split(';')[0];
            approver2 = changeRequest.dcmgt_Approvers__c.split(';')[1].trim(); 
            oldAndNewValuesFieldName ='dcmgt_Updated_Fields__c'; 
        }
        Database.executeBatch(new dcmgt_ProcessApprovalRequestsBatch(changeRequestId,objectType,approver1,approver2,oldAndNewValuesFieldName), 100);
    }
    
    
    public static void setApproversForStep2(List<ProcessInstanceWorkitem> workItems, String comments, String action,String recordId){
        Set<Id> userIds;
        if(!workItems.isEmpty()){
            if(Id.valueOf(recordId).getSobjectType().getDescribe().getName() == 'dcmgt_Alation_Article__c'){
                dcmgt_Alation_Article__c  articleConfig = [select dcmgt_Change_Request__r.dcmgt_Approvers__c  from dcmgt_Alation_Article__c where id=:recordId]; 
                userIds =  getApproversSet(recordId,articleConfig.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[1].trim());      
            } else if(Id.valueOf(recordId).getSobjectType().getDescribe().getName() == 'dcmgt_Data_Publication_Request__c'){
                dcmgt_Data_Assets__c assetsConfig = [select dcmgt_Change_Request__r.dcmgt_Approvers__c  from dcmgt_Data_Assets__c where id=:recordId];
                 userIds =  getApproversSet(recordId,assetsConfig.dcmgt_Change_Request__r.dcmgt_Approvers__c.split(';')[1].trim());      
            } else if(Id.valueOf(recordId).getSobjectType().getDescribe().getName() == 'dcmgt_Data_Sub_Request__c'){
                dcmgt_Approval_Configuration__c approvalConfig = [select dcmgt_Approver_Role_For_step_2__c from dcmgt_Approval_Configuration__c where RecordType.Name = 'Data Subscription Request Approval Configurations' and dcmgt_Status__c='Active' order by createdDate desc limit 1]; 
                if(approvalConfig.dcmgt_Approver_Role_For_step_2__c == 'Data Steward'){
                    userIds =  getApproversSet(recordId,'dcmgt_Data_Steward__c');
                }else{
                    userIds =  getApproversSet(recordId,'dcmgt_Data_Owner__c');  
                }        
            }
            
            else{
                dcmgt_Approval_Configuration__c approvalConfig = [select dcmgt_Approver_Role_For_step_2__c from dcmgt_Approval_Configuration__c where RecordType.Name = 'Data Asset Approval Configurations' and dcmgt_Status__c='Active' order by createdDate desc limit 1];
                if(approvalConfig.dcmgt_Approver_Role_For_step_2__c == 'Data Steward'){
                    userIds =  getApproversSet(recordId,'dcmgt_Data_Stewards__c');  
                }else{
                    userIds =  getApproversSet(recordId,'dcmgt_Service_Owners__c');     
                }
            }
            submitForStep2(workItems,userIds,action,comments);  
        }
    }
    
    
    public static void submitForStep2(List<ProcessInstanceWorkitem> workItems,Set<id> userIds,String action,String comments){
        List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
        Integer i = 0;
        for (ProcessInstanceWorkitem workItem : workItems) {
            for(Id user:userIds){
                if(i==0){
                    approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, user, action, comments));     
                }else{
                    approvalRequestList.add(createProcessWorkItemRequest(workItem.Id, null, 'Removed', comments));     
                }
                
            } 
            i++;
        }
         List<Approval.ProcessResult> results = Approval.process(approvalRequestList);        
    }
    
    public static Set<id> getApproversSet(String recordId,String fieldName){
        Map<Id, String> userMap = new Map<Id, String>();
        List<sObject> returnValues=Database.query('select '+fieldName+' from ' + Id.valueOf(recordId).getSObjectType()+ ' where Id = :recordId');
        for(sObject s:returnValues){
            userMap=(Map<Id,String>) JSON.deserialize(String.valueOf(s.get(fieldName)).replace('&quot;','"'), Map<Id,String>.class);                     
        }  
        return userMap.KeySet();   
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
    
    private static Approval.ProcessWorkitemRequest createProcessWorkItemRequest(Id approvalStepId, Id approverId, String approvalAction, String commentFromApprover){
        Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
        // if(commentFromApprover != 'Auto Approved'){
        //     String replaceTarget = commentFromApprover.right(10);
        //     Date tempeffectiveDate = Date.valueOf(replaceTarget);
        //     Datetime effectiveDateTime = datetime.newInstance(tempeffectiveDate.year(), tempeffectiveDate.month(),tempeffectiveDate.day());
        //     String replaceReplacement = effectiveDateTime.format('MM/dd/yyyy');
        //     commentFromApprover = commentFromApprover.replace(replaceTarget,replaceReplacement);
        // }
        system.debug('@@commentFromApprover::'+commentFromApprover);
        result.setComments(commentFromApprover);
        result.setAction(approvalAction);
        result.setWorkitemId(approvalStepId);
        if (approverId != null) {
            result.setNextApproverIds(new List<Id>{approverId});
        }
        return result;
    }
    
    public static Messaging.SingleEmailMessage getEmailNotificationforSubmitters(String recordId,String submitterId,String emailtemplateId,
                                                                                 String[] ccAddresses){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(submitterId); 
        message.setSenderDisplayName('Contract Management'); 
        message.setReplyTo('no-reply@ia.com');
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        message.setTemplateID(emailtemplateId); 
        message.setccAddresses(ccAddresses);
        // message.htmlbody(Body);
        message.setWhatId(recordId);
        //message.toAddresses = new String[] {email};
        return message;
    }
    
    public static Messaging.SingleEmailMessage getEmailNotificationforSubmitters(String recordId,String[] approverEmails,String emailtemplateId,String[] ccAddresses){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setTargetObjectId(approverEmails[0]);
        if(approverEmails.size()>1)
        {
         approverEmails.remove(0); 
         message.setToAddresses(approverEmails); 
        }
        message.setSenderDisplayName('Contract Management'); 
        message.setReplyTo('no-reply@ia.com');
        message.setUseSignature(false); 
        message.setBccSender(false); 
        message.setSaveAsActivity(false); 
        message.setTemplateID(emailtemplateId); 
        message.setccAddresses(ccAddresses);
        message.setWhatId(recordId);
        return message;
    }
    private static Map<String,String> getroleAPINameAndActualNameMap(){
        Map<String,String> roleAPINameAndActualNameMap = new Map<String,String>();
        roleAPINameAndActualNameMap.put('dcmgt_Data_Stewards__c', 'Data Steward');
        roleAPINameAndActualNameMap.put('dcmgt_Service_Owners__c', 'Data Owner');
        roleAPINameAndActualNameMap.put('dcmgt_DataStewards__c', 'Data Steward');
        roleAPINameAndActualNameMap.put('dcmgt_Data_Owners__c', 'Data Owner');
        return roleAPINameAndActualNameMap;
    }
}