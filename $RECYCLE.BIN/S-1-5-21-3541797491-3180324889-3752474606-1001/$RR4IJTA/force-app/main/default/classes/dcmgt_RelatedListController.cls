public with sharing class dcmgt_RelatedListController {
    private static Set<String> setOfApprovedRejectStatus = new Set<String> {
        'Approved', 'Rejected', 'Completed', 'Under Processing'
    };
    @AuraEnabled(Cacheable = true)
    public static List<RelatedListWrapper> getArticleByChangeRequestId(Id changeRequestId){
        try {
            Id currentUserId = UserInfo.getUserId();
            List<RelatedListWrapper> listOfArticleRelatedList = new List<RelatedListWrapper>();
            dcmgt_Change_Request__c changeRequest = [
                SELECT id, Name, dcmgt_Request_Type__r.Name 
                FROM dcmgt_Change_Request__c where id = : changeRequestId
            ];
            Map<Id, sObject> mapOfImpectedDataAssetById;
            Boolean isGlossary = false, isDictionary = false;
            if('Business Glossary'.equalsIgnoreCase(changeRequest.dcmgt_Request_Type__r.Name)) {
                mapOfImpectedDataAssetById = new Map<Id, sObject>(
                    [
                    SELECT Id, Name, dcmgt_Updates_Fields__c, dcmgt_DataStewards__c,
                        dcmgt_Data_Owners__c, dcmgt_Status__c, dcmgt_Approval_date__c, dcmgt_Change_Request__r.OwnerId
                    FROM dcmgt_Alation_Article__c
                    WHERE dcmgt_Change_Request__c = :changeRequestId
                ]);
                isGlossary = true;
            } else if('Data Dictionary'.equalsIgnoreCase(changeRequest.dcmgt_Request_Type__r.Name)) {
                mapOfImpectedDataAssetById = new Map<Id, sObject>(
                    [
                        SELECT Id, Name, dcmgt_Updated_Fields__c, dcmgt_Data_Stewards__c,
                            dcmgt_Service_Owners__c, dcmgt_Status__c, dcmgt_Approval_date__c, dcmgt_Change_Request__r.OwnerId
                        FROM dcmgt_Data_Assets__c
                        WHERE dcmgt_Change_Request__c = :changeRequestId
                ]);
                isDictionary = true;
            }
            Boolean isCurrentUserSystemAdmin;
            for(String key : mapOfImpectedDataAssetById.keySet()) {
                RelatedListWrapper wrapper;
                if(isGlossary) {
                    dcmgt_Alation_Article__c record = (dcmgt_Alation_Article__c)mapOfImpectedDataAssetById.get(key);
                    if(isCurrentUserSystemAdmin == null) {
                        isCurrentUserSystemAdmin = 
                            dcmgt_ApprovalHistoryUtil.isCurrentUserSystemAdmin(record.Id);
                    }
                    if( isCurrentUserSystemAdmin || currentUserId == record.dcmgt_Change_Request__r.OwnerId
                        ||record.dcmgt_DataStewards__c.contains(currentUserId) ||
                        record.dcmgt_Data_Owners__c.contains(currentUserId)) {

                        wrapper = fillWrapperForArticle(record, currentUserId, isCurrentUserSystemAdmin);
                        listOfArticleRelatedList.add(wrapper);
                    }
                } else if(isDictionary) {
                    dcmgt_Data_Assets__c record = (dcmgt_Data_Assets__c)mapOfImpectedDataAssetById.get(key);
                    if(isCurrentUserSystemAdmin == null) {
                        isCurrentUserSystemAdmin = 
                            dcmgt_ApprovalHistoryUtil.isCurrentUserSystemAdmin(record.Id);
                    }
                    if(isCurrentUserSystemAdmin || currentUserId == record.dcmgt_Change_Request__r.OwnerId
                        ||record.dcmgt_Data_Stewards__c.contains(currentUserId) ||
                        record.dcmgt_Service_Owners__c.contains(currentUserId)) {
                        
                        wrapper = fillWrapperForDataAsset(record, currentUserId, isCurrentUserSystemAdmin);
                        listOfArticleRelatedList.add(wrapper);
                    }
                }
            }
            return listOfArticleRelatedList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static RelatedListWrapper fillWrapperForArticle(dcmgt_Alation_Article__c record, Id currentUserId,
        Boolean isCurrentUserSystemAdmin) {

        RelatedListWrapper relatedRecord = new RelatedListWrapper(record.Name, record.Id, '/'+record.Id);
        if(record.dcmgt_Updates_Fields__c != null) {
            Map<String,String> oldAndNewValues = (Map<String,String>) JSON.deserialize(record.dcmgt_Updates_Fields__c.replace('&quot;','"'), Map<String,String>.class);
            relatedRecord = fillWrapperDetails(oldAndNewValues,relatedRecord);
        }
        relatedRecord.isDataSteward = false;
        relatedRecord.isDataOrServiceOwner = false;
        relatedRecord.isApproveOrRejectBtnDisabled = !isCurrentUserSystemAdmin;
        if(record.dcmgt_DataStewards__c.contains(currentUserId)) {
            relatedRecord.isDataSteward = true;
            if('Submitted'.equalsIgnoreCase(record.dcmgt_Status__c)) {
                relatedRecord.isApproveOrRejectBtnDisabled = false;
            }
        }
        if(record.dcmgt_Data_Owners__c.contains(currentUserId)) {
            relatedRecord.isDataOrServiceOwner = true;
            if('In Review'.equalsIgnoreCase(record.dcmgt_Status__c)) {
                relatedRecord.isApproveOrRejectBtnDisabled = false;
            }
        }
        if(setOfApprovedRejectStatus.contains(record.dcmgt_Status__c) ||
            String.isBlank(record.dcmgt_Status__c)) {

            relatedRecord.isApproveOrRejectBtnDisabled = true;
        }
        relatedRecord.recordStatus = record.dcmgt_Status__c;
        //relatedRecord.approvalEffectiveDate = record.dcmgt_Approval_date__c;
        if(record.dcmgt_Approval_date__c != null){
            Date tempeffectiveDate = record.dcmgt_Approval_date__c;
            Datetime effectiveDateTime = datetime.newInstance(tempeffectiveDate.year(), tempeffectiveDate.month(),tempeffectiveDate.day());
            relatedRecord.approvalEffectiveDate = effectiveDateTime.format('MM/dd/yyyy');
        }
        return relatedRecord;
    }

    private static RelatedListWrapper fillWrapperForDataAsset(dcmgt_Data_Assets__c record, Id currentUserId,
        Boolean isCurrentUserSystemAdmin) {

        RelatedListWrapper relatedRecord = new RelatedListWrapper(record.Name, record.Id, '/'+record.Id);
        if(record.dcmgt_Updated_Fields__c != null) {
            Map<String,String> oldAndNewValues = (Map<String,String>) JSON.deserialize(record.dcmgt_Updated_Fields__c.replace('&quot;','"'), Map<String,String>.class);
            relatedRecord = fillWrapperDetails(oldAndNewValues,relatedRecord);
        }
        relatedRecord.isDataSteward = false;
        relatedRecord.isDataOrServiceOwner = false;
        relatedRecord.isApproveOrRejectBtnDisabled = !isCurrentUserSystemAdmin;
        if(record.dcmgt_Data_Stewards__c.contains(currentUserId)) {
            relatedRecord.isDataSteward = true;
            if('Submitted'.equalsIgnoreCase(record.dcmgt_Status__c)) {
                relatedRecord.isApproveOrRejectBtnDisabled = false;
            }
        }
        if(record.dcmgt_Service_Owners__c.contains(currentUserId)) {
            relatedRecord.isDataOrServiceOwner = true;
            if('In Review'.equalsIgnoreCase(record.dcmgt_Status__c)) {
                relatedRecord.isApproveOrRejectBtnDisabled = false;
            }
        }
        if(setOfApprovedRejectStatus.contains(record.dcmgt_Status__c) ||
            String.isBlank(record.dcmgt_Status__c)) {

            relatedRecord.isApproveOrRejectBtnDisabled = true;
        }
        relatedRecord.recordStatus = record.dcmgt_Status__c;
        //relatedRecord.approvalEffectiveDate = record.dcmgt_Approval_date__c;
        if(record.dcmgt_Approval_date__c != null){
            Date tempeffectiveDate = record.dcmgt_Approval_date__c;
            Datetime effectiveDateTime = datetime.newInstance(tempeffectiveDate.year(), tempeffectiveDate.month(),tempeffectiveDate.day());
            relatedRecord.approvalEffectiveDate = effectiveDateTime.format('MM/dd/yyyy');
        }
        return relatedRecord;
    }

    private static RelatedListWrapper fillWrapperDetails(Map<String,String> oldAndNewValues,RelatedListWrapper relatedRecord) {
            
        List<String> updatedFields = new List<String>();
        List<String> Oldvalue = new List<String>();
        List<String> Newvalue = new List<String>();
        List<ApprovalRecordWrapper> listOfWrapper = new List<ApprovalRecordWrapper>();
        ApprovalRecordWrapper wrapper;
        for(String value:oldAndNewValues.keySet()){
            wrapper = new ApprovalRecordWrapper();
            if(oldAndNewValues.get(value).subString(0,3) == '---'){
                wrapper.fieldName = value;
                wrapper.newvalue = oldAndNewValues.get(value).subString(3,oldAndNewValues.get(value).length());
                wrapper.oldvalue = '';
                listOfWrapper.add(wrapper);
            }else{
                wrapper.fieldName = value;
                wrapper.newvalue = oldAndNewValues.get(value).subString(oldAndNewValues.get(value).indexOf('---')+3,oldAndNewValues.get(value).length());
                wrapper.oldvalue = oldAndNewValues.get(value).subString(0,oldAndNewValues.get(value).indexOf('---'));
                listOfWrapper.add(wrapper);
            }  
        }
        System.debug('listOfWrapper'+listOfWrapper);
        relatedRecord.approvalRecordWrapper = listOfWrapper;
        relatedRecord.rowSpan = String.valueOf(listOfWrapper.size() + 1);
        return relatedRecord;
    }
    
    public class ApprovalRecordWrapper {
        @AuraEnabled public String oldvalue {get;set;} 
        @AuraEnabled public String newvalue {get;set;} 
        @AuraEnabled public String fieldName {get;set;} 
    }

    public Class RelatedListWrapper{
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String approvalLink;
        @AuraEnabled
        public String recordLink;
        @AuraEnabled
        public List<ApprovalRecordWrapper> approvalRecordWrapper;
        @AuraEnabled
        public String rowSpan;
        @AuraEnabled
        public Boolean isDataSteward;
        @AuraEnabled
        public Boolean isDataOrServiceOwner;
        @AuraEnabled
        public String recordStatus;
        @AuraEnabled
        public String approvalEffectiveDate;
        @AuraEnabled
        public Boolean isApproveOrRejectBtnDisabled;
        public RelatedListWrapper(String name, String Id, String recordLink) {
            this.name = name;
            this.Id = Id;
            this.recordLink = recordLink;
        }
    }
    
}