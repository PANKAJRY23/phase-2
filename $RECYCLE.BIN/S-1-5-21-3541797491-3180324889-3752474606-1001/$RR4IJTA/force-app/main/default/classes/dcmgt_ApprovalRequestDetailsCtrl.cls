public with sharing class dcmgt_ApprovalRequestDetailsCtrl {

    static Set<String> setOfFieldsToBeIgnore = new Set<String>{
        'dcmgt_Alation_Id__c', 'CreatedById', 'dcmgt_External_Id__c',
        'dcmgt_IsApproved__c', 'dcmgt_Locked_Fields__c', 'dcmgt_Staged_Data_Assets__c',
         'dcmgt_Change_Request__c', 'dcmgt_Approver_1__c', 'dcmgt_Data_Steward__c', 'dcmgt_Approver_2__c', 'dcmgt_Status__c', 'dcmgt_Staged_Alation_Article__c',
        'Id', 'CreatedDate', 'LastModifiedDate', 'dcmgt_Multi_Subject_Area__c', 'SystemModstamp', 'LastViewedDate', 'LastReferencedDate',
        'dcmgt_Updates_Fields__c','dcmgt_DataStewards__c','dcmgt_Data_Owners__c','dcmgt_Data_Stewards__c','dcmgt_Service_Owners__c'
    };

    @AuraEnabled(Cacheable=true)
    public static ApprovalRecordWrapper getApprovalRequestDetails(Id approvalRequestId){
        try {
            sObject approvalProcess;
            ApprovalRecordWrapper approvalWrapper = new ApprovalRecordWrapper();
            ProcessInstanceWorkitem processInstanceWorkitemObj;
            ProcessInstanceStep processInstanceStepObj;
            try{
                processInstanceWorkitemObj = [SELECT Id, 
                ProcessInstance.TargetObjectId, Actor.Name,Actor.UserRole.Name , Actor.Id
                FROM ProcessInstanceWorkitem WHERE Id = :approvalRequestId];
            } catch(Exception ex) {
                processInstanceStepObj = [SELECT Id, 
                ProcessInstance.TargetObjectId, Actor.Name,Actor.UserRole.Name , Actor.Id
                FROM ProcessInstanceStep WHERE Id = :approvalRequestId];
            }
            // ProcessInstanceStep approvalProcess = [SELECT Id, 
            //     ProcessInstance.TargetObjectId, Actor.Name,Actor.UserRole.Name , Actor.Id
            //     FROM ProcessInstanceStep WHERE Id = :approvalRequestId];
            
            String targetObjectApiName;
            if(processInstanceWorkitemObj != null) {
                targetObjectApiName = String.valueOf(
                    processInstanceWorkitemObj.ProcessInstance.TargetObjectId.getSobjectType());
            } else if(processInstanceStepObj != null) {
                targetObjectApiName = String.valueOf(
                    processInstanceStepObj.ProcessInstance.TargetObjectId.getSobjectType());
            }
            dcmgt_Alation_Article__c stageArticle;
            dcmgt_Alation_Article__c orignalArticle;
            dcmgt_Data_Assets__c stageDataAssert;
            dcmgt_Data_Assets__c orignalDataAssert;
            Map<String, String> mapOfNameAndAPIName;
            if('dcmgt_Alation_Article__c'.equalsIgnoreCase(targetObjectApiName)) {
                mapOfNameAndAPIName = dcmgt_changeRequestFormController.getMapOfFieldNameWithAPIName('dcmgt_Alation_Article__c');
                //setOfFields = getAllFieldsByObject('dcmgt_Alation_Article__c');
                String tempQuery = 'Select dcmgt_Change_Request__r.CreatedBy.Name,dcmgt_Data_Steward__c,dcmgt_DataStewards__c,dcmgt_Data_Owners__c,dcmgt_Data_Owner__c, dcmgt_Change_Request__r.CreatedBy.UserRole.Name, dcmgt_Change_Request__r.dcmgt_Status__c, LastModifiedBy.Name, dcmgt_Change_Request__r.Name, dcmgt_Change_Request__r.CreatedDate,dcmgt_Updates_Fields__c,Name,Id,dcmgt_Term_Type__c '+
                    ' FROM dcmgt_Alation_Article__c WHERE Id = \'';
                String query;
                if(processInstanceWorkitemObj != null) {
                    query = tempQuery +
                        processInstanceWorkitemObj.ProcessInstance.TargetObjectId+'\'';
                } else if(processInstanceStepObj != null) {
                    query = tempQuery +
                        processInstanceStepObj.ProcessInstance.TargetObjectId+'\'';
                }
                
                System.debug(query);
                stageArticle = Database.query(query);
                //query = tempQuery + stageArticle.dcmgt_Staged_Alation_Article__c + '\'';
                //orignalArticle = Database.query(query);
                Map<String,String> oldAndNewValues = (Map<String,String>) JSON.deserialize(stageArticle.dcmgt_Updates_Fields__c.replace('&quot;','"'), Map<String,String>.class);
                approvalWrapper = fillApprovalRequestDetails(oldAndNewValues,approvalWrapper,'Article');
                approvalWrapper.changeRequestName = stageArticle.dcmgt_Change_Request__r.Name;
                approvalWrapper.changeRequestUrl = '/'+stageArticle.dcmgt_Change_Request__c;
                approvalWrapper.stagedRecordName = stageArticle.Name;
                approvalWrapper.stagedRecordUrl = '/'+stageArticle.Id;
                //approvalWrapper.orignalRecordName = orignalArticle.Name;
                //approvalWrapper.orignalRecordUrl = '/'+orignalArticle.Id;
                //approvalWrapper.approver = stageArticle.dcmgt_Data_Steward__r.Name;
                //approvalWrapper.dataOwner = stageArticle.dcmgt_Data_Owner__r.Name;
                //approvalWrapper.RequestedDate = stageArticle.dcmgt_Change_Request__r.dcmgt_Request_Effective_Date__c;
                dcmgt_Change_Request__c changeRequest=stageArticle.dcmgt_Change_Request__r;
                DateTime requestedDate=changeRequest.CreatedDate;
                approvalWrapper.RequestedDate= requestedDate.month()+ '/' +requestedDate.day()+ '/' +requestedDate.year() ;
                approvalWrapper.Status = stageArticle.dcmgt_Change_Request__r.dcmgt_Status__c;
                approvalWrapper.LastModifiedBy = stageArticle.LastModifiedBy.Name;
                approvalWrapper.RecordType = stageArticle.dcmgt_Term_Type__c;
                approvalWrapper.Requester = stageArticle.dcmgt_Change_Request__r.CreatedBy.Name;
                approvalWrapper.Requesttype=stageArticle.dcmgt_Change_Request__r.CreatedBy.UserRole.Name;
                if(processInstanceWorkitemObj != null) {
                    approvalWrapper.approver = processInstanceWorkitemObj.Actor.Name;
                } else if(processInstanceStepObj != null) {
                    approvalWrapper.approver = processInstanceStepObj.Actor.Name;
                }
                
                Map<String,String> m = (Map<String,String>)JSON.deserialize(stageArticle.dcmgt_DataStewards__c.replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                Map<String,String> n = (Map<String,String>)JSON.deserialize(stageArticle.dcmgt_Data_Owners__c.replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);

                Boolean isDataSteward = false;
                Boolean isDataOwner = false; 
                Id actorId;
                if(processInstanceWorkitemObj != null) {
                    actorId = processInstanceWorkitemObj.Actor.Id;
                } else if(processInstanceStepObj != null) {
                    actorId = processInstanceStepObj.Actor.Id;
                }
                if(m.keySet().contains(actorId)){

                    isDataSteward = true;
                   
                }
                if(n.keySet().contains(actorId)){
                    isDataOwner = true;
                    
                    // approvalWrapper.approvertype = 'Data Owner';
                }
                if(isDataOwner && isDataSteward)
                {
                    approvalWrapper.approvertype = 'Data Owner & Data Steward';

                }else if(isDataOwner)
                {
                    approvalWrapper.approvertype = 'Data Owner';
                }
                else if(isDataSteward)
                {
                    approvalWrapper.approvertype = 'Data Steward';
                } else {
                    approvalWrapper.approvertype = 'System Administrator';
                }
                

            } else if('dcmgt_Data_Assets__c'.equalsIgnoreCase(targetObjectApiName)) {
               mapOfNameAndAPIName = dcmgt_changeRequestFormController.getMapOfFieldNameWithAPIName('dcmgt_Data_Assets__c');
                //setOfFields = getAllFieldsByObject('dcmgt_Data_Assets__c');
                String tempQuery = 'Select Name,Id,dcmgt_Type__c,dcmgt_Service_Owner__r.Name,dcmgt_Service_Owners__c,dcmgt_Data_Stewards__c, dcmgt_Service_Owner__c,dcmgt_Change_Request__r.CreatedBy.UserRole.Name,LastModifiedBy.Name, dcmgt_Change_Request__r.CreatedBy.Name, dcmgt_Change_Request__r.dcmgt_Status__c, dcmgt_Data_Steward__r.Name, dcmgt_Change_Request__r.CreatedDate,dcmgt_Updated_Fields__c,dcmgt_Change_Request__r.Name,dcmgt_Change_Request__c'+
                    ' FROM dcmgt_Data_Assets__c WHERE Id = \'';
                String query;
                if(processInstanceWorkitemObj != null) {
                    query = tempQuery +
                        processInstanceWorkitemObj.ProcessInstance.TargetObjectId+'\'';
                } else if(processInstanceStepObj != null) {
                    query = tempQuery +
                        processInstanceStepObj.ProcessInstance.TargetObjectId+'\'';
                }
                stageDataAssert = Database.query(query);
                //query = tempQuery + stageDataAssert.dcmgt_Staged_Data_Assets__c + '\'';
                //orignalDataAssert = Database.query(query);
               Map<String,String> oldAndNewValues = (Map<String,String>) JSON.deserialize(stageDataAssert.dcmgt_Updated_Fields__c.replace('&quot;','"'), Map<String,String>.class);
                approvalWrapper = fillApprovalRequestDetails(oldAndNewValues,approvalWrapper,'Data Asset');
                approvalWrapper.changeRequestName = stageDataAssert.dcmgt_Change_Request__r.Name;
                approvalWrapper.changeRequestUrl = '/'+stageDataAssert.dcmgt_Change_Request__c;
                approvalWrapper.stagedRecordName = stageDataAssert.Name;
                approvalWrapper.stagedRecordUrl = '/'+stageDataAssert.Id;
                //approvalWrapper.orignalRecordName = orignalDataAssert.Name;
                //approvalWrapper.orignalRecordUrl = '/'+orignalDataAssert.Id;
                //approvalWrapper.approver = stageDataAssert.dcmgt_Data_Steward__r.Name;
                //approvalWrapper.dataOwner = stageDataAssert.dcmgt_Service_Owner__r.Name;
                approvalWrapper.Status = stageDataAssert.dcmgt_Change_Request__r.dcmgt_Status__c;
                approvalWrapper.LastModifiedBy = stageDataAssert.LastModifiedBy.Name;
                //start 07/27 modified by rk to test vf email error
                // dcmgt_Change_Request__c changeRequest=stageArticle.dcmgt_Change_Request__r;
                dcmgt_Change_Request__c changeRequest=stageDataAssert.dcmgt_Change_Request__r;
                //end 07/27 modified by rk to test vf email error
                
                
                DateTime requestedDate=changeRequest.CreatedDate;
                approvalWrapper.RequestedDate= requestedDate.month()+ '/' +requestedDate.day()+ '/' +requestedDate.year() ;
                approvalWrapper.RecordType = stageDataAssert.dcmgt_Type__c;
                approvalWrapper.Requester = stageDataAssert.dcmgt_Change_Request__r.CreatedBy.Name; 
                approvalWrapper.Requesttype=stageDataAssert.dcmgt_Change_Request__r.CreatedBy.UserRole.Name;
                if(processInstanceWorkitemObj != null) {
                    approvalWrapper.approver = processInstanceWorkitemObj.Actor.Name;
                } else if(processInstanceStepObj != null) {
                    approvalWrapper.approver = processInstanceStepObj.Actor.Name;
                }
                

                Map<String,String> m = (Map<String,String>)JSON.deserialize(stageDataAssert.dcmgt_Data_Stewards__c.replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                Map<String,String> n = (Map<String,String>)JSON.deserialize(stageDataAssert.dcmgt_Service_Owners__c.replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);


                Boolean isDataSteward = false;
                Boolean isServiceOwner = false;
                Id actorId;
                if(processInstanceWorkitemObj != null) {
                    actorId = processInstanceWorkitemObj.Actor.Id;
                } else if(processInstanceStepObj != null) {
                    actorId = processInstanceStepObj.Actor.Id;
                }
                System.debug(n.keySet().contains(actorId));
                
                if(m.keySet().contains(actorId)){
    
                    isDataSteward = true;
                   
                }
                if(n.keySet().contains(actorId)){
                    isServiceOwner = true;
                    // approvalWrapper.approvertype = 'Data Owner';
                }
                if(isServiceOwner && isDataSteward){

                    approvalWrapper.approvertype = 'Data Steward & Data Owner';
                }
                else if(isDataSteward)
                {
                    approvalWrapper.approvertype = 'Data Steward';
                }
                else if(isServiceOwner)
                {
                    approvalWrapper.approvertype = 'Data Owner';
                } else {
                    approvalWrapper.approvertype = 'System Administrator';
                }
            }
            System.debug('Approval type role'+approvalWrapper.approvertype);
            return approvalWrapper;
        } catch (Exception e) {
            system.debug('===linenumber=='+e.getLineNumber());
            system.debug('===linenumber=='+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Set<String> getAllFieldsByObject(String ObjectName) {
        return new Set<String>(Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().keySet());
    }

    private static ApprovalRecordWrapper fillApprovalRequestDetails(Map<String,String> oldAndNewValues,ApprovalRecordWrapper approvalWrapper,String objectName) {
            
        List<String> updatedFields = new List<String>();
        List<String> Oldvalue = new List<String>();
        List<String> Newvalue = new List<String>();
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
        
        approvalWrapper.updatedFields = updatedFields;
        approvalWrapper.Oldvalue = Oldvalue;
        approvalWrapper.Newvalue = Newvalue;
        return approvalWrapper;
    }

   public class ApprovalRecordWrapper{
        @AuraEnabled
        public String changeRequestName;
        @AuraEnabled
        public String LastModifiedBy;
        @AuraEnabled
        public String RecordType;
        @AuraEnabled
        public String Requester;
        @AuraEnabled
        public String Requesttype;
        @AuraEnabled
        public String RequestedDate;
        @AuraEnabled
        public String changeRequestUrl;
        @AuraEnabled
        public String stagedRecordName;
        @AuraEnabled
        public String stagedRecordUrl;
        @AuraEnabled
        public String orignalRecordName;
        @AuraEnabled
        public String orignalRecordUrl;
        @AuraEnabled
        public String dataSteward;
        @AuraEnabled
        public String dataOwner;       
        @AuraEnabled
        public String approver;
        @AuraEnabled
        public String approvertype;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public List<String> updatedFields;
        @AuraEnabled
        public List<String> Oldvalue;
        @AuraEnabled
        public List<String> Newvalue;
    }
}



/*

public with sharing class dcmgt_ApprovalRequestDetailsCtrl {

    static Set<String> setOfFieldsToBeIgnore = new Set<String>{
        'dcmgt_Alation_Id__c', 'CreatedById', 'dcmgt_External_Id__c',
        'dcmgt_IsApproved__c', 'dcmgt_Locked_Fields__c', 'dcmgt_Staged_Data_Assets__c',
         'dcmgt_Change_Request__c', 'dcmgt_Approver_1__c', 'dcmgt_Data_Steward__c', 'dcmgt_Approver_2__c', 'dcmgt_Status__c', 'dcmgt_Staged_Alation_Article__c',
        'Id', 'CreatedDate', 'LastModifiedDate', 'dcmgt_Multi_Subject_Area__c', 'SystemModstamp', 'LastViewedDate', 'LastReferencedDate',
        'dcmgt_Updates_Fields__c', 'dcmgt_NextApproverRequired__c', 'dcmgt_DataStewards__c','dcmgt_Data_Owners__c','dcmgt_Data_Stewards__c','dcmgt_Service_Owners__c'
    };

    @AuraEnabled(Cacheable=true)
    public static ApprovalRecordWrapper getApprovalRequestDetails(Id approvalRequestId){
        try {
            ApprovalRecordWrapper approvalWrapper = new ApprovalRecordWrapper();
            ProcessInstanceWorkitem approvalProcess = [SELECT Id, 
                ProcessInstance.TargetObjectId, Actor.Name 
                FROM ProcessInstanceWorkitem WHERE Id = :approvalRequestId];

            
            String targetObjectApiName = String.valueOf(
                approvalProcess.ProcessInstance.TargetObjectId.getSobjectType());
            dcmgt_Alation_Article__c stageArticle;
            dcmgt_Alation_Article__c orignalArticle;
            dcmgt_Data_Assets__c stageDataAssert;
            dcmgt_Data_Assets__c orignalDataAssert;
            Map<String, String> mapOfNameAndAPIName;
            if('dcmgt_Alation_Article__c'.equalsIgnoreCase(targetObjectApiName)) {
                mapOfNameAndAPIName = dcmgt_salesforceCRFController.getMapOfFieldNameWithAPIName('dcmgt_Alation_Article__c');
                //setOfFields = getAllFieldsByObject('dcmgt_Alation_Article__c');
                String tempQuery = 'Select '+String.join(new List<String>(mapOfNameAndAPIName.values()), ',')+
                    ', dcmgt_Data_Owner__r.Name, dcmgt_Data_Steward__r.Name, dcmgt_Change_Request__r.CreatedBy.Name, dcmgt_Change_Request__r.dcmgt_Status__c,'+
                    ' LastModifiedBy.Name, dcmgt_Change_Request__r.Name, dcmgt_Change_Request__r.dcmgt_Request_Effective_Date__c, '+
                    ' dcmgt_Change_Request__r.dcmgt_Change_Type__c '+
                    ' FROM dcmgt_Alation_Article__c WHERE Id = \'';
                String query = tempQuery +
                    approvalProcess.ProcessInstance.TargetObjectId+'\'';
                stageArticle = Database.query(query);
                if(stageArticle.dcmgt_Staged_Alation_Article__c != null) {
                    query = tempQuery + stageArticle.dcmgt_Staged_Alation_Article__c + '\'';
                    orignalArticle = Database.query(query);
                    approvalWrapper = fillApprovalRequestDetails(approvalWrapper, stageArticle, 
                        orignalArticle, mapOfNameAndAPIName);
                    approvalWrapper.orignalRecordName = orignalArticle.Name;
                    approvalWrapper.orignalRecordUrl = '/'+orignalArticle.Id;
                }
                
                approvalWrapper.changeRequestName = stageArticle.dcmgt_Change_Request__r.Name;
                approvalWrapper.changeRequestUrl = '/'+stageArticle.dcmgt_Change_Request__c;
                approvalWrapper.stagedRecordName = stageArticle.Name;
                approvalWrapper.stagedRecordUrl = '/'+stageArticle.Id;
                
                approvalWrapper.approver = stageArticle.dcmgt_Data_Steward__r.Name;
                approvalWrapper.dataOwner = stageArticle.dcmgt_Data_Owner__r.Name;
                approvalWrapper.RequestedDate = stageArticle.dcmgt_Change_Request__r.dcmgt_Request_Effective_Date__c;
                approvalWrapper.Status = stageArticle.dcmgt_Change_Request__r.dcmgt_Status__c;
                approvalWrapper.LastModifiedBy = stageArticle.LastModifiedBy.Name;
                approvalWrapper.RecordType = stageArticle.dcmgt_Term_Type__c;
                approvalWrapper.Requester = stageArticle.dcmgt_Change_Request__r.CreatedBy.Name;
            } else if('dcmgt_Data_Assets__c'.equalsIgnoreCase(targetObjectApiName)) {
                mapOfNameAndAPIName = dcmgt_salesforceCRFController.getMapOfFieldNameWithAPIName('dcmgt_Alation_Article__c');
                //setOfFields = getAllFieldsByObject('dcmgt_Data_Assets__c');
                String tempQuery = 'Select '+String.join(new List<String>(mapOfNameAndAPIName.values()), ',')+
                    ', dcmgt_Service_Owner__r.Name, LastModifiedBy.Name, dcmgt_Change_Request__r.CreatedBy.Name, dcmgt_Change_Request__r.dcmgt_Status__c, dcmgt_Data_Steward__r.Name, dcmgt_Change_Request__r.dcmgt_Request_Effective_Date__c'+
                    ' FROM dcmgt_Data_Assets__c WHERE Id = \'';
                String query = tempQuery +
                    approvalProcess.ProcessInstance.TargetObjectId+'\'';
                stageDataAssert = Database.query(query);
                if(stageDataAssert.dcmgt_Staged_Data_Assets__c != null) {
                    query = tempQuery + stageDataAssert.dcmgt_Staged_Data_Assets__c + '\'';
                    orignalDataAssert = Database.query(query);
                    approvalWrapper = fillApprovalRequestDetails(approvalWrapper, stageDataAssert,
                        orignalDataAssert, mapOfNameAndAPIName);
                    approvalWrapper.orignalRecordName = orignalDataAssert.Name;
                    approvalWrapper.orignalRecordUrl = '/'+orignalDataAssert.Id;
                }
                approvalWrapper.changeRequestName = stageDataAssert.dcmgt_Change_Request__r.Name;
                approvalWrapper.changeRequestUrl = '/'+stageDataAssert.dcmgt_Change_Request__c;
                approvalWrapper.stagedRecordName = stageDataAssert.Name;
                approvalWrapper.stagedRecordUrl = '/'+stageDataAssert.Id;
                
                approvalWrapper.approver = stageDataAssert.dcmgt_Data_Steward__r.Name;
                approvalWrapper.dataOwner = stageDataAssert.dcmgt_Service_Owner__r.Name;
                approvalWrapper.Status = stageDataAssert.dcmgt_Change_Request__r.dcmgt_Status__c;
                approvalWrapper.LastModifiedBy = stageDataAssert.LastModifiedBy.Name;
                approvalWrapper.RequestedDate = stageDataAssert.dcmgt_Change_Request__r.dcmgt_Request_Effective_Date__c;
                approvalWrapper.RecordType = stageDataAssert.dcmgt_Type__c;
                approvalWrapper.Requester = stageDataAssert.dcmgt_Change_Request__r.CreatedBy.Name;
            }
            approvalWrapper.approver = approvalProcess.Actor.Name;
            return approvalWrapper;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static Set<String> getAllFieldsByObject(String ObjectName) {
        return new Set<String>(Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap().keySet());
    }

    private static ApprovalRecordWrapper fillApprovalRequestDetails(
        ApprovalRecordWrapper approvalWrapper, sObject stageObj, sObject orignalObj,
        Map<String, String> mapOfFieldNameAndAPIName ) {
            
        List<String> updatedFields = new List<String>();
        List<String> Oldvalue = new List<String>();
        List<String> Newvalue = new List<String>();
        for(String key : mapOfFieldNameAndAPIName.keySet()) {
            String fieldValue = mapOfFieldNameAndAPIName.get(key);
            if((!setOfFieldsToBeIgnore.contains(fieldValue)) &&
                stageObj.get(fieldValue) != orignalObj.get(fieldValue)) {

                System.debug(fieldValue);
                updatedFields.add(key);
                if('Data Owners'.equalsIgnoreCase(key) || 'Service Owners'.equalsIgnoreCase(key) ||
                    'Data Stewards'.equalsIgnoreCase(key)) {

                    string users = ''+stageObj.get(fieldValue);
                    users = users.replaceAll('&quot;', '"');
                    Map<String, Object> mapOfUserNameById = (Map<String, Object>)JSON.deserializeUntyped(users);
                    Newvalue.add(String.join(mapOfUserNameById.values(), ','));
                    users = ''+orignalObj.get(fieldValue);
                    users = users.replaceAll('&quot;', '"');
                    mapOfUserNameById = (Map<String, Object>)JSON.deserializeUntyped(users);
                    Oldvalue.add(String.join(mapOfUserNameById.values(), ','));
                } else {
                    Newvalue.add(''+stageObj.get(fieldValue));
                    Oldvalue.add(''+orignalObj.get(fieldValue));
                }
            }
        }
        
        approvalWrapper.updatedFields = updatedFields;
        approvalWrapper.Oldvalue = Oldvalue;
        approvalWrapper.Newvalue = Newvalue;
        return approvalWrapper;
    }

    public class ApprovalRecordWrapper{
        @AuraEnabled
        public String changeRequestName;
        @AuraEnabled
        public String LastModifiedBy;
        @AuraEnabled
        public String RecordType;
        @AuraEnabled
        public String Requester;
        @AuraEnabled
        public Date RequestedDate;
        @AuraEnabled
        public String changeRequestUrl;
        @AuraEnabled
        public String stagedRecordName;
        @AuraEnabled
        public String stagedRecordUrl;
        @AuraEnabled
        public String orignalRecordName;
        @AuraEnabled
        public String orignalRecordUrl;
        @AuraEnabled
        public String dataSteward;
        @AuraEnabled
        public String dataOwner;
        @AuraEnabled
        public String approver;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public List<String> updatedFields;
        @AuraEnabled
        public List<String> Oldvalue;
        @AuraEnabled
        public List<String> Newvalue;
    }
} */