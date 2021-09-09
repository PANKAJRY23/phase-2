trigger dcmgt_SubmitForApproval on dcmgt_Change_Request__c (after insert, before insert, after update, after delete) {
    
    public static final String articleApprovalConfigurationName = 'Article Approval Process Configurations';
    public static final String dataAssetApprovalConfigurationName = 'Data Asset Approval Configurations';
    
    
    if(Trigger.isInsert && Trigger.isBefore){
        dcmgt_ChangeRequestHandler.updateRequestEffectiveDateAndApprovers(Trigger.New);
    }
   
    // if(Trigger.isUpdate){
    //         UpdateRecord.submitForUpdate(Trigger.newMap,Trigger.oldMap);
    // } 

    
        // for(Change_Request__c opp:trigger.New){       
        //     try{
                
        //         if(Trigger.isInsert && Trigger.isAfter){
        //             ApprovalRequestForChangeRequest.submitForApproval(opp);
        //         }   
        //     }
        //     catch(Exception e){
        //         opp.addError(e.getMessage());
        //     }
        // }
     }