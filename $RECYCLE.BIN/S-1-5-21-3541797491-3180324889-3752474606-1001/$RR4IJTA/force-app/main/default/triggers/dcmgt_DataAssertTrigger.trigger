trigger dcmgt_DataAssertTrigger on dcmgt_Data_Assets__c (before insert, after insert, before update, after update) {
    if(Trigger.isUpdate && Trigger.isAfter) {
        dcmgt_DataAssertTriggerHandler.approveChangeRequest(Trigger.newMap, Trigger.oldMap);
        //dcmgt_DataAssertTriggerHandler.rejectChangeRequest(Trigger.newMap, Trigger.oldMap);
    }
    
    if(Trigger.isInsert && Trigger.isBefore){
        dcmgt_Approval_Configuration__c approvalConfig;
        try {
  			approvalConfig = [select dcmgt_Approver_Role_For_step_2__c from dcmgt_Approval_Configuration__c where RecordType.Name = 'Data Asset Approval Configurations' and dcmgt_Status__c='Active' order by createdDate desc limit 1]; 
            dcmgt_DataAssertTriggerHandler.checkDuplicateDataAssetUpdateRequest(Trigger.New);
         } catch(Exception e){
         return ;
     }       
  if(approvalConfig.dcmgt_Approver_Role_For_step_2__c != null){
            for(dcmgt_Data_Assets__c dataAsset:Trigger.new){
              dataAsset.dcmgt_NextApproverRequired__c = true;  
            }   
        }   
    }
    
}