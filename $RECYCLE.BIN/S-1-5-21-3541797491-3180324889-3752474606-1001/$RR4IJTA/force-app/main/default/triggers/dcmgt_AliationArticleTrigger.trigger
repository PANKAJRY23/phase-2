trigger dcmgt_AliationArticleTrigger on dcmgt_Alation_Article__c (before insert, after insert, before update, after update) {
    if(Trigger.isUpdate && Trigger.isAfter) {
        //dcmgt_AliationArticleTriggerHandler.approveChangeRequest(Trigger.newMap, Trigger.oldMap);
        dcmgt_AliationArticleTriggerHandler.rejectChangeRequest(Trigger.newMap, Trigger.oldMap);
    }
    
    if(Trigger.isInsert && Trigger.isBefore){
        dcmgt_Approval_Configuration__c approvalConfig;
        try {
            approvalConfig = [select dcmgt_Approver_Role_For_step_2__c from dcmgt_Approval_Configuration__c where RecordType.Name = 'Article Approval Process Configurations' and dcmgt_Status__c='Active' order by createdDate desc limit 1]; 
            dcmgt_AliationArticleTriggerHandler.checkDuplicateArticleUpdateRequest(Trigger.new);
          } catch(Exception e){
             return ;
          }  
      if(approvalConfig.dcmgt_Approver_Role_For_step_2__c != null){
            for(dcmgt_Alation_Article__c article:Trigger.new){
              article.dcmgt_NextApproverRequired__c = true;  
            }   
        }   
    }
}