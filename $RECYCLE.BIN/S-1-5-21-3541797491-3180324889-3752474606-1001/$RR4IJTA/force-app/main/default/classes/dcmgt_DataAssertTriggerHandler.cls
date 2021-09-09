public with sharing class dcmgt_DataAssertTriggerHandler {
    public static void approveChangeRequest(Map<Id, dcmgt_Data_Assets__c> newMapOfDataAssert,
        Map<Id, dcmgt_Data_Assets__c> oldMapOfDataAssert) {

        Set<Id> setOfChageRequestId = new Set<Id>();
        for(String key : newMapOfDataAssert.keySet()) {
            if(newMapOfDataAssert.get(key).dcmgt_Status__c == 'Rejected' || newMapOfDataAssert.get(key).dcmgt_IsApproved__c == true) {

                setOfChageRequestId.add(newMapOfDataAssert.get(key).dcmgt_Change_Request__c);
            }
        }

        List<dcmgt_Change_Request__c> lsitOfChangeRequest = [ 
            SELECT Id, dcmgt_Status__c, 
                (SELECT Id FROM dcmgt_Data_Assets__r) 
            FROM dcmgt_Change_Request__c WHERE Id IN :setOfChageRequestId
        ];
        List<dcmgt_Change_Request__c> lsitOfChangeRequestToBeUpdate = 
            new List<dcmgt_Change_Request__c>();
        for(dcmgt_Change_Request__c changeRequest : lsitOfChangeRequest) {
           
        Integer completedStatus = 0;
        Integer submittedStatus = 0;
        Integer inReviewStatus = 0;
        Integer approvedStatus = 0;
        Integer rejectedStatus = 0;
        Integer underProcessingStatus = 0;
        Integer completedRejectedStatus = 0;
        for(dcmgt_Data_Assets__c dataAssets : changeRequest.dcmgt_Data_Assets__r )
        {
            if(dataAssets.dcmgt_Status__c== 'Completed')
            {
                completedStatus++;
            }
            else if(dataAssets.dcmgt_Status__c== 'Submitted')
            {
                submittedStatus++;
            }
            else if(dataAssets.dcmgt_Status__c== 'In Review')
            {
                inReviewStatus++;
            }
            else if(dataAssets.dcmgt_Status__c== 'Approved')
            {
                approvedStatus++;
            }
            else if(dataAssets.dcmgt_Status__c== 'Rejected')
            {
                rejectedStatus++;
            }
            else if(dataAssets.dcmgt_Status__c== 'Under Processing')
            {
                underProcessingStatus++;
            }
        
        }
            if(changeRequest.dcmgt_Data_Assets__r.size() == submittedStatus )
            {
                changeRequest.dcmgt_Status__c = 'Submitted';
                lsitOfChangeRequestToBeUpdate.add(changeRequest);
            }
            if(changeRequest.dcmgt_Data_Assets__r.size() == completedStatus )
            {
                changeRequest.dcmgt_Status__c = 'Implemented';
                lsitOfChangeRequestToBeUpdate.add(changeRequest);
            }else if((changeRequest.dcmgt_Data_Assets__r.size() == approvedStatus)||(changeRequest.dcmgt_Data_Assets__r.size() == rejectedStatus))
            {
                 changeRequest.dcmgt_Status__c = 'Completed';
                lsitOfChangeRequestToBeUpdate.add(changeRequest);
            }else if(changeRequest.dcmgt_Data_Assets__r.size() == (completedStatus+rejectedStatus))
            {
                changeRequest.dcmgt_Status__c = 'Implemented';
                lsitOfChangeRequestToBeUpdate.add(changeRequest);
            }
        	else if(changeRequest.dcmgt_Data_Assets__r.size() == (approvedStatus+rejectedStatus))
            {
                changeRequest.dcmgt_Status__c = 'Completed';
                lsitOfChangeRequestToBeUpdate.add(changeRequest);
            }
        }
        if(!lsitOfChangeRequestToBeUpdate.isEmpty()) {
            Database.update(lsitOfChangeRequestToBeUpdate, false);
        }
    }
     	
    public static void checkDuplicateDataAssetUpdateRequest(List<dcmgt_Data_Assets__c> listOfDataAsset) {	
        Set<Decimal> setOfAliationId = new Set<Decimal>();	
        for(dcmgt_Data_Assets__c dataAsset : listOfDataAsset) {	
            if(dataAsset.dcmgt_Alation_Id__c != null) {
                setOfAliationId.add(dataAsset.dcmgt_Alation_Id__c);	
            }
        }	
        Set<String> setOfStatus = new Set<String>{
            'Rejected' , 'Approved'
        };
        List<dcmgt_Data_Assets__c> listOfExistingDataAsset = [SELECT Id, dcmgt_Alation_Id__c,dcmgt_Type__c 	
                                                                FROM dcmgt_Data_Assets__c 	
                                                                WHERE dcmgt_Alation_Id__c IN :setOfAliationId 	
                                                                	AND  dcmgt_Status__c Not IN :setOfStatus ];	
        Set<String> setOfExistingAliationId = new Set<String>();	
        for(dcmgt_Data_Assets__c dataAsset : listOfExistingDataAsset) {	
            setOfExistingAliationId.add(dataAsset.dcmgt_Alation_Id__c+'-'+dataAsset.dcmgt_Type__c);	
        }	
        List<Id> listOfChangeRequestIds = new List<Id>();	
        for(dcmgt_Data_Assets__c dataAsset : listOfDataAsset) {	
            if(setOfExistingAliationId.contains(dataAsset.dcmgt_Alation_Id__c+'-'+dataAsset.dcmgt_Type__c)) {	
                listOfChangeRequestIds.add(dataAsset.dcmgt_Change_Request__c);	
                //delete [SELECT Id FROM dcmgt_Change_Request__c WHERE Id = :dataAsset.dcmgt_Change_Request__c];	
                dataAsset.addError('Duplicate DataAsset request ---'+dataAsset.Name);	
            }	
        }	
    }
}