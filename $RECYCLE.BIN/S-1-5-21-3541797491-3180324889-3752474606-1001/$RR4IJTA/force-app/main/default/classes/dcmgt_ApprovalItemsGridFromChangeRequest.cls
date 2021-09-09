public class dcmgt_ApprovalItemsGridFromChangeRequest {

      public Id recordId {get;set;}
      public String roleName {get;set;}
      public String changeRequestURL{get;set;}
      public Boolean isAttachement {get;set;}
      public Boolean isArticle {get;set;}
    public class RecordNameAndApprovalRecordWrapper{
       
        public String stagedRecordName {get;set;}
        public String RecordType {get;set;} 
        public List<ApprovalRecordWrapper> approvalRecordWrapper {get;set;} 
        public String rowSpan {get;set;}
        public String Requester {get;set;} 
        public String approver {get;set;} 
        public String LastModifiedBy {get;set;}
        public String RequestedDate {get;set;}
        public String Status {get;set;}
        public String approvalRequestLink {get;set;}
        public String rejectReqestLink {get;set;}
    }
    
      public class ApprovalRecordWrapper {
          
        public String Oldvalue {get;set;} 
    
        public String Newvalue {get;set;} 
    
        public String fieldName {get;set;} 
    
}
    public List<RecordNameAndApprovalRecordWrapper> getApprovalRequestDetails()
    {
        List<RecordNameAndApprovalRecordWrapper> listToReturn = new List<RecordNameAndApprovalRecordWrapper>();
         Map<String,String> getApproverRolesBasedOnAPIName = getroleAPINameAndActualNameMap(); 
        Integer index = 0;
        if(string.IsNotBlank(recordId)){
          changeRequestURL =System.Url.getOrgDomainUrl().toExternalForm()+'/'+recordId;   
          dcmgt_Change_Request__c changeRequest = [select dcmgt_Request_Type__r.Name,dcmgt_Approvers__c from dcmgt_Change_Request__c where id=:recordId];
            
          String query ='';
            
          if(changeRequest.dcmgt_Request_Type__r.Name == 'Business Glossary'){
          isArticle = true;    
          List<dcmgt_Alation_Article__c> stageRecords;
          Map<String,String> recordIdWithProcessInstanceId = new Map<String,String>();
          query = 'Select dcmgt_Change_Request__r.CreatedBy.Name,dcmgt_Data_Steward__c,dcmgt_DataStewards__c,dcmgt_Data_Owners__c,dcmgt_Data_Owner__c, dcmgt_Change_Request__r.CreatedBy.UserRole.Name, dcmgt_Change_Request__r.dcmgt_Status__c, LastModifiedBy.Name, dcmgt_Change_Request__r.Name, dcmgt_Change_Request__r.CreatedDate,dcmgt_Updates_Fields__c,Name,Id,dcmgt_Term_Type__c FROM dcmgt_Alation_Article__c where dcmgt_Change_Request__c=:recordId'; 
          stageRecords = Database.query(query);
          List<Id> allArticlesIdsInChangeRequest = new List<Id>();
              for(dcmgt_Alation_Article__c stagedRecord:stageRecords){
              allArticlesIdsInChangeRequest.add(stagedRecord.Id);    
              }    
          List<ProcessInstanceWorkitem> articlesApprovalRequestIds = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId,OriginalActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId in:allArticlesIdsInChangeRequest];
              for(ProcessInstanceWorkitem articlesApprovalRequestId:articlesApprovalRequestIds){
                  if(recordIdWithProcessInstanceId.get(articlesApprovalRequestId.ProcessInstance.TargetObjectId) == null){
                     recordIdWithProcessInstanceId.put(articlesApprovalRequestId.ProcessInstance.TargetObjectId,articlesApprovalRequestId.Id); 
                  }
              }    
            for(dcmgt_Alation_Article__c stagedRecord:stageRecords){
                if((recordIdWithProcessInstanceId.get(stagedRecord.Id) !=null && index <10) || isAttachement){
                 RecordNameAndApprovalRecordWrapper singleArticleWrapper = new RecordNameAndApprovalRecordWrapper();
                List<String> updatedFields = new List<String>();
                List<String> Oldvalue = new List<String>();
                List<String> Newvalue = new List<String>();
                Map<String,String> oldAndNewValues = (Map<String,String>) JSON.deserialize(String.valueOf(stagedRecord.get('dcmgt_Updates_Fields__c')).replace('&quot;','"'), Map<String,String>.class);
                for(String value:oldAndNewValues.keySet()){
                if(oldAndNewValues.get(value).subString(0,3) == '---'){
                    updatedFields.add(value);    
                    Oldvalue.add('');
                    Newvalue.add(oldAndNewValues.get(value).subString(3,oldAndNewValues.get(value).length()));
                }else{
                    updatedFields.add(value);
                    Oldvalue.add(oldAndNewValues.get(value).subString(0,oldAndNewValues.get(value).indexOf('---')));
                    Newvalue.add(oldAndNewValues.get(value).subString(oldAndNewValues.get(value).indexOf('---')+3,oldAndNewValues.get(value).length()));
                } 
              }
                List<ApprovalRecordWrapper> approvalRecordWrapper = new List<ApprovalRecordWrapper>();
                    for(Integer i=0;i<updatedFields.size();i++){
                ApprovalRecordWrapper a = new ApprovalRecordWrapper();
                a.fieldName=updatedFields.get(i);
                a.Oldvalue=Oldvalue.get(i);
                a.Newvalue=Newvalue.get(i);
                approvalRecordWrapper.add(a);
                index++;
        }   
                singleArticleWrapper.stagedRecordName = stagedRecord.Name;
                singleArticleWrapper.approvalRecordWrapper = approvalRecordWrapper;
                singleArticleWrapper.rowSpan = String.valueOf(updatedFields.size()+1);
                singleArticleWrapper.RecordType = stagedRecord.dcmgt_Term_Type__c;
                singleArticleWrapper.Requester=stagedRecord.dcmgt_Change_Request__r.CreatedBy.Name;
                roleName = getApproverRolesBasedOnAPIName.get(String.valueOf(changeRequest.dcmgt_Approvers__c.split(';')[0].trim()));    
                singleArticleWrapper.approver=getApproversSeperatedBySemiColon(String.valueOf(stagedRecord.get(String.valueOf(changeRequest.dcmgt_Approvers__c.split(';')[0].trim()))));
                singleArticleWrapper.LastModifiedBy= stagedRecord.LastModifiedBy.Name;
                DateTime requestedDate=stagedRecord.dcmgt_Change_Request__r.CreatedDate;
                singleArticleWrapper.RequestedDate=requestedDate.month()+ '/' +requestedDate.day()+ '/' +requestedDate.year();
                singleArticleWrapper.Status=stagedRecord.dcmgt_Change_Request__r.dcmgt_Status__c;
                singleArticleWrapper.approvalRequestLink = System.Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/ProcessInstanceWorkitem/'+recordIdWithProcessInstanceId.get(stagedRecord.Id)+'/view?c__approve=true';
                singleArticleWrapper.rejectReqestLink = System.Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/ProcessInstanceWorkitem/'+recordIdWithProcessInstanceId.get(stagedRecord.Id)+'/view?c__approve=false';
                listToReturn.add(singleArticleWrapper);    
                }else if(recordIdWithProcessInstanceId.get(stagedRecord.Id) !=null && index >= 10){
                 return listToReturn;   
                }
                }    
            }else if(changeRequest.dcmgt_Request_Type__r.Name == 'Data Dictionary'){
           isArticle = false;      
          List<dcmgt_Data_Assets__c> stageRecords;
          Map<String,String> recordIdWithProcessInstanceId = new Map<String,String>();
          query = 'Select Name,Id,dcmgt_Type__c,dcmgt_Service_Owners__c,dcmgt_Data_Stewards__c,dcmgt_Change_Request__r.CreatedBy.UserRole.Name,LastModifiedBy.Name, dcmgt_Change_Request__r.CreatedBy.Name, dcmgt_Change_Request__r.dcmgt_Status__c, dcmgt_Change_Request__r.CreatedDate,dcmgt_Updated_Fields__c,dcmgt_Change_Request__r.Name,dcmgt_Change_Request__c FROM dcmgt_Data_Assets__c where dcmgt_Change_Request__c=:recordId';     
          stageRecords = Database.query(query);
          List<Id> alldataAssetIdsInChangeRequest = new List<Id>();
              for(dcmgt_Data_Assets__c stagedRecord:stageRecords){
              alldataAssetIdsInChangeRequest.add(stagedRecord.Id);    
              }    
          List<ProcessInstanceWorkitem> articlesApprovalRequestIds = [SELECT Id, ProcessInstanceId, ProcessInstance.TargetObjectId,OriginalActorId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId in:alldataAssetIdsInChangeRequest ALL ROWS];
              for(ProcessInstanceWorkitem articlesApprovalRequestId:articlesApprovalRequestIds){
                  if(recordIdWithProcessInstanceId.get(articlesApprovalRequestId.ProcessInstance.TargetObjectId) == null){
                     recordIdWithProcessInstanceId.put(articlesApprovalRequestId.ProcessInstance.TargetObjectId,articlesApprovalRequestId.Id); 
                  }
              }
              for(dcmgt_Data_Assets__c stagedRecord:stageRecords){
                if((recordIdWithProcessInstanceId.get(stagedRecord.Id) !=null && index <10) || isAttachement){
                RecordNameAndApprovalRecordWrapper singleArticleWrapper = new RecordNameAndApprovalRecordWrapper();
                List<String> updatedFields = new List<String>();
                List<String> Oldvalue = new List<String>();
                List<String> Newvalue = new List<String>();
                Map<String,String> oldAndNewValues = (Map<String,String>) JSON.deserialize(String.valueOf(stagedRecord.get('dcmgt_Updated_Fields__c')).replace('&quot;','"'), Map<String,String>.class);
                for(String value:oldAndNewValues.keySet()){
                if(oldAndNewValues.get(value).subString(0,3) == '---'){
                    updatedFields.add(value);    
                    Oldvalue.add('');
                    Newvalue.add(oldAndNewValues.get(value).subString(3,oldAndNewValues.get(value).length()));
                }else{
                    updatedFields.add(value);
                    Oldvalue.add(oldAndNewValues.get(value).subString(0,oldAndNewValues.get(value).indexOf('---')));
                    Newvalue.add(oldAndNewValues.get(value).subString(oldAndNewValues.get(value).indexOf('---')+3,oldAndNewValues.get(value).length()));
                } 
              }
                List<ApprovalRecordWrapper> approvalRecordWrapper = new List<ApprovalRecordWrapper>();
                    for(Integer i=0;i<updatedFields.size();i++){
                ApprovalRecordWrapper a = new ApprovalRecordWrapper();
                a.fieldName=updatedFields.get(i);
                a.Oldvalue=Oldvalue.get(i);
                a.Newvalue=Newvalue.get(i);
                approvalRecordWrapper.add(a);
                index++;
        }   
                singleArticleWrapper.stagedRecordName = stagedRecord.Name;
                singleArticleWrapper.approvalRecordWrapper = approvalRecordWrapper;
                singleArticleWrapper.rowSpan = String.valueOf(updatedFields.size()+1);
                singleArticleWrapper.RecordType = stagedRecord.dcmgt_Type__c;
                singleArticleWrapper.Requester=stagedRecord.dcmgt_Change_Request__r.CreatedBy.Name;
                roleName = getApproverRolesBasedOnAPIName.get(String.valueOf(changeRequest.dcmgt_Approvers__c.split(';')[0].trim()));    
                singleArticleWrapper.approver=getApproversSeperatedBySemiColon(String.valueOf(stagedRecord.get(String.valueOf(changeRequest.dcmgt_Approvers__c.split(';')[0].trim()))));
                singleArticleWrapper.LastModifiedBy= stagedRecord.LastModifiedBy.Name;
                DateTime requestedDate=stagedRecord.dcmgt_Change_Request__r.CreatedDate;
                singleArticleWrapper.RequestedDate=requestedDate.month()+ '/' +requestedDate.day()+ '/' +requestedDate.year();
                singleArticleWrapper.Status=stagedRecord.dcmgt_Change_Request__r.dcmgt_Status__c;
                singleArticleWrapper.approvalRequestLink = System.Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/ProcessInstanceWorkitem/'+recordIdWithProcessInstanceId.get(stagedRecord.Id)+'/view?c__approve=true';
                singleArticleWrapper.rejectReqestLink = System.Url.getOrgDomainUrl().toExternalForm()+'/lightning/r/ProcessInstanceWorkitem/'+recordIdWithProcessInstanceId.get(stagedRecord.Id)+'/view?c__approve=false';
                listToReturn.add(singleArticleWrapper);    
                }else if(recordIdWithProcessInstanceId.get(stagedRecord.Id) !=null && index >= 10){
                 return listToReturn;   
                }
                }   
            }
      
            
            
        }
        return listToReturn;
    }
    
      private static String getApproversSeperatedBySemiColon(String approversJsonData){
      String approversSeperatedBySemiColon = '';    
      Map<Id,String> userMap=(Map<Id,String>) JSON.deserialize(approversJsonData.replace('&quot;','"'), Map<Id,String>.class);                     
          for(Id user:userMap.keySet()){
              if(String.isEmpty(approversSeperatedBySemiColon)) {
              approversSeperatedBySemiColon = userMap.get(user)+';';    
              }else{
              approversSeperatedBySemiColon += userMap.get(user)+';';    
              }
          }  
        return approversSeperatedBySemiColon.substring(0, approversSeperatedBySemiColon.length()-1);   
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