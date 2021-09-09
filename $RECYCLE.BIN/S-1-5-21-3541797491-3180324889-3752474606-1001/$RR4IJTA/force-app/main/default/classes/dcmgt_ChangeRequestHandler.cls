public with sharing class dcmgt_ChangeRequestHandler {
    public static void updateRequestEffectiveDate(List<dcmgt_Change_Request__c> listOfChangeRequest) {
        for(dcmgt_Change_Request__c changeRequest : listOfChangeRequest) {
            changeRequest.dcmgt_Request_Effective_Date__c = System.Today();
            changeRequest.dcmgt_Status__c = 'Submitted';
        }
    }
    
    public static void updateRequestEffectiveDateAndApprovers(List<dcmgt_Change_Request__c> listOfChangeRequest) {
        List<dcmgt_Request_Type__c> requestTypes = [select id,Name from dcmgt_Request_Type__c Limit 1000];
        Map<String,String> requestTypeIdAndNameMap = new Map<String,String>();
        for(dcmgt_Request_Type__c requestType:requestTypes){
        requestTypeIdAndNameMap.put(requestType.id, requestType.Name);    
        }
        for(dcmgt_Change_Request__c changeRequest : listOfChangeRequest) {
            String approvers ='';
             System.Debug(changeRequest.dcmgt_Request_Type__c);
            if(requestTypeIdAndNameMap.get(changeRequest.dcmgt_Request_Type__c) == 'Business Glossary'){                
            dcmgt_Approval_Configuration__c approvalConfig = [select dcmgt_Approver_Role_For_step_1__c,dcmgt_Approver_Role_For_step_2__c from dcmgt_Approval_Configuration__c where RecordType.Name = 'Article Approval Process Configurations' and dcmgt_Status__c='Active' order by createdDate desc limit 1]; 
            if(approvalConfig.dcmgt_Approver_Role_For_step_1__c == 'Data Steward'){
                approvers = 'dcmgt_DataStewards__c; ';
                if(approvalConfig.dcmgt_Approver_Role_For_step_2__c == 'Data Owner'){
                approvers +='dcmgt_Data_Owners__c';
                }
            }else{  
                approvers = 'dcmgt_Data_Owners__c; ';
               if(approvalConfig.dcmgt_Approver_Role_For_step_2__c == 'Data Steward'){
                approvers +='dcmgt_DataStewards__c';
                }
            }    
            }else if(requestTypeIdAndNameMap.get(changeRequest.dcmgt_Request_Type__c) == 'Data Dictionary'){
             dcmgt_Approval_Configuration__c approvalConfig = [select dcmgt_Approver_Role_For_step_1__c,dcmgt_Approver_Role_For_step_2__c from dcmgt_Approval_Configuration__c where RecordType.Name = 'Data Asset Approval Configurations' and dcmgt_Status__c='Active' order by createdDate desc limit 1];                      
            if(approvalConfig.dcmgt_Approver_Role_For_step_1__c == 'Data Steward'){
                approvers =  'dcmgt_Data_Stewards__c; ';
                if(approvalConfig.dcmgt_Approver_Role_For_step_2__c == 'Service Owner'){
                     approvers +='dcmgt_Service_Owners__c';
                }
            }else{
               approvers =  'dcmgt_Service_Owners__c; ';
                if(approvalConfig.dcmgt_Approver_Role_For_step_2__c == 'Data Steward'){
                   approvers +='dcmgt_Data_Stewards__c';
                }
            }     
            }
            System.Debug(approvers);
            changeRequest.dcmgt_Approvers__c = approvers;
            changeRequest.dcmgt_Request_Effective_Date__c = System.Today();
            changeRequest.dcmgt_Status__c = 'Submitted';
        }
    }
}