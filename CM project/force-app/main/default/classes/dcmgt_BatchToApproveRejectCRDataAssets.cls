global class dcmgt_BatchToApproveRejectCRDataAssets implements Database.Batchable<sObject>, Database.Stateful{

        global list<Id> recordIds = new list<Id>();
        global String comments = '';
        global String action = '';
        global String effectiveDate = '';
        global Schema.SObjectType getSobjectType;
        global Id sobjectRcordId;
        Boolean isExecuteTwice;
        public dcmgt_BatchToApproveRejectCRDataAssets(list<Id> recordIds, String comments,String action,String effectiveDate, Boolean isExecuteTwice){
            this.recordIds = recordIds ;
            this.comments = comments;
            this.action = action;
            this.effectiveDate = effectiveDate;
            this.sobjectRcordId = recordIds[0];
            this.isExecuteTwice = isExecuteTwice;
            getSobjectType = sobjectRcordId.getSobjectType();
           // system.de
        }

        global Database.QueryLocator start(Database.BatchableContext BC){
            String query = 'SELECT Id,dcmgt_Approval_date__c,dcmgt_Change_Request__c,dcmgt_Change_Request__r.dcmgt_Approvers__c, dcmgt_Data_Stewards__c, dcmgt_Data_Assets__c FROM dcmgt_Data_Assets__c WHERE Id IN :recordIds';
            return Database.getQueryLocator(query);
        }

        global void execute(Database.BatchableContext BC, List<sObject> scope) {
            set<Id> userIds;
            list<Id> listOfApproverIds = new list<Id>();
            list<sobject> listOfRecordsToUpdate = new list<sobject>();
            for(sObject objectRec : scope){
                String fieldValue = '';
                list<String> listOfFields = new list<String>();
                Map<Id, String> userMap = new Map<Id, String>();
                if(String.valueOf(getSobjectType) == 'dcmgt_Alation_Article__c'){
                    dcmgt_Alation_Article__c record = (dcmgt_Alation_Article__c)objectRec;
                    fieldValue = record.dcmgt_Change_Request__r.dcmgt_Approvers__c;
                    listOfFields = fieldValue.split(';');
                    for(String s : listOfFields){
                        if(s == 'dcmgt_Data_Owners__c'){
                            userMap=(Map<Id,String>) JSON.deserialize(String.valueOf(record.dcmgt_Data_Owners__c).replace('&quot;','"'),Map<Id,String>.class);
                        }
                        else if(s == 'dcmgt_DataStewards__c'){
                            userMap=(Map<Id,String>) JSON.deserialize(String.valueOf(record.dcmgt_DataStewards__c).replace('&quot;','"'),Map<Id,String>.class);
                        }
                        //userMap=(Map<Id,String>) JSON.deserialize(String.valueOf(record.get(s)).replace('&quot;','"'),Map<Id,String>.class);
                        userIds = userMap.keySet();
                    }
                }
                else{
                    dcmgt_Data_Assets__c record = (dcmgt_Data_Assets__c)objectRec;
                    fieldValue = record.dcmgt_Change_Request__r.dcmgt_Approvers__c;
                    listOfFields = fieldValue.split(';');
                    for(String s : listOfFields){
                        if(s == 'dcmgt_Data_Stewards__c'){
                            userMap=(Map<Id,String>) JSON.deserialize(String.valueOf(record.dcmgt_Data_Stewards__c).replace('&quot;','"'),Map<Id,String>.class);
                        }
                        else if(s == 'dcmgt_Service_Owners__c'){
                            userMap=(Map<Id,String>) JSON.deserialize(String.valueOf(record.dcmgt_Service_Owners__c).replace('&quot;','"'),Map<Id,String>.class);
                        }
                       // userMap=(Map<Id,String>) JSON.deserialize(String.valueOf(record.get(s)).replace('&quot;','"'),Map<Id,String>.class);
                        userIds = userMap.keySet();
                    }
                }
                system.debug('@@fieldValue::'+fieldValue);
                system.debug('@@listOfFields::'+listOfFields);
                system.debug('@@userIds::'+userIds);
                listOfApproverIds.addAll(userIds);
                if(effectiveDate != ''){
                    objectRec.put('dcmgt_Approval_date__c',Date.valueOf(effectiveDate));
                }
                listOfRecordsToUpdate.add(objectRec);
            }
            try{
                update listOfRecordsToUpdate;
            }
            catch(Exception ex){
                system.debug('@@In Exception::'+ex.getMessage());
            }

            List<Approval.ProcessWorkitemRequest> approvalRequestList = new List<Approval.ProcessWorkitemRequest>();
            List<ProcessInstanceWorkitem> listOfWorkItems = [
                    SELECT Id, ProcessInstanceId
                    FROM ProcessInstanceWorkitem
                    WHERE ProcessInstance.TargetObjectId IN :recordIds
                ];
            for(ProcessInstanceWorkitem workItem:listOfWorkItems){
                    Approval.ProcessWorkitemRequest result = new Approval.ProcessWorkitemRequest();
                    // if(comments != 'Auto Approved'){
                    //     String replaceTarget = comments.right(10);
                    //     Date tempeffectiveDate = Date.valueOf(replaceTarget);
                    //     Datetime effectiveDateTime = datetime.newInstance(tempeffectiveDate.year(), tempeffectiveDate.month(),tempeffectiveDate.day());
                    //     String replaceReplacement = effectiveDateTime.format('MM/dd/yyyy');
                    //     comments = comments.replace(replaceTarget,replaceReplacement);
                    // }
                    result.setComments(comments);
                    result.setAction(action);
                    result.setWorkitemId(workItem.Id);
                    result.setNextApproverIds(new List<Id>{listOfApproverIds[0]});
                    approvalRequestList.add(result);
            }
            List<Approval.ProcessResult> result = Approval.process(approvalRequestList);
        }

        global void finish(Database.BatchableContext BC) {
            // if(!recordIds.isEmpty()) {
            //     Boolean isCurrentUserSystemAdmin = dcmgt_ApprovalHistoryUtil.isCurrentUserSystemAdmin(recordIds[0]);
            //     if(isCurrentUserSystemAdmin) {
            //         DataBase.executeBatch(new dcmgt_BatchToApproveRejectCRDataAssets(recordIds,'Auto Approved' , action, effectiveDate),200);
            //     }
            // }
            if(!isExecuteTwice) {
                system.debug('---100--'+sobjectRcordId );
                Id changeRequestId = [Select id,dcmgt_Change_Request__c from dcmgt_Data_Assets__c where id=:sobjectRcordId limit 1].dcmgt_Change_Request__c;
                dcmgt_Change_Request__c changeRequest = [Select id, dcmgt_Batch_Job_Id__c from dcmgt_Change_Request__c where Id=:changeRequestId limit 1];

                AsyncApexJob async = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors FROM AsyncApexJob WHERE ID =: BC.getJobId() limit 1];

                if(async.Status == 'Completed'){
                    changeRequest.dcmgt_Batch_Job_Id__c = null;
                }
                // changeRequest.dcmgt_Batch_Job_Id__c = null;
                if(changeRequest!= null){
                update changeRequest;
                }
            }
        }
    }