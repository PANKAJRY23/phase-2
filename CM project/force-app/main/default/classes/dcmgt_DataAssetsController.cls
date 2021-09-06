public with sharing class dcmgt_DataAssetsController {
    
    @AuraEnabled
    public static list<dcmgt_Data_Assets__c> getDataAssetsMethod(){
        return [select id, dcmgt_Alation_Id__c, dcmgt_Approval_date__c, 
                    dcmgt_Business_Rules__c, dcmgt_Change_Request__c, 
                    dcmgt_Data_Assets__c, dcmgt_Data_Assets_Name__c, dcmgt_Data_category__c, 
                    dcmgt_Data_Consumer__c, dcmgt_Data_Dictionary_Field__c, dcmgt_Data_Steward__c, 
                    dcmgt_Data_Stewards__c, dcmgt_Derived_logic_Business_Calculation__c, dcmgt_Description__c, 
                    dcmgt_Dimensions__c, dcmgt_External_Id__c, dcmgt_Full_name__c, dcmgt_Indication_Metric__c, 
                    dcmgt_IsActive__c, dcmgt_IsApproved__c, Name from dcmgt_Data_Assets__c 
                    WITH SECURITY_ENFORCED limit 10000];
    }

    @AuraEnabled
    public static void upsertDataSubscriptionRecord(string Ids){
        try {
            System.debug('--Ids--'+Ids);
            if(string.isNotBlank(Ids)){
                List<String> lstOfDataAssetsId = Ids.split(',');
                list<dcmgt_Data_Assets__c> selectedDataAssets = [select id, Name from dcmgt_Data_Assets__c where id in: lstOfDataAssetsId];

                list<dcmgt_Data_Sub_Request__c> listOfDataSubForDelete = [select id from dcmgt_Data_Sub_Request__c 
                                                                            where dcmgt_Requestor__c= :UserInfo.getUserId() and dcmgt_Status__c = 'Draft'];
                if(!listOfDataSubForDelete.IsEmpty()){
                    delete listOfDataSubForDelete;
                }     
                
                dcmgt_Data_Sub_Request__c dataRequestRec = new dcmgt_Data_Sub_Request__c();
                dataRequestRec.dcmgt_Requestor__c = UserInfo.getUserId();

                insert dataRequestRec;

                if(!selectedDataAssets.IsEmpty()){
                    list<dcmgt_Data_Asset_Sub_Request__c> dataAssetsRecordListToBeInserted = new list<dcmgt_Data_Asset_Sub_Request__c>();
                    for(dcmgt_Data_Assets__c dataAssetsRec : selectedDataAssets){
                        dcmgt_Data_Asset_Sub_Request__c subDataAssetRec = new dcmgt_Data_Asset_Sub_Request__c();
                        subDataAssetRec.dcmgt_Data_Subscription_Request__c = dataRequestRec.id;
                        subDataAssetRec.dcmgt_Data_Asset_USC_ID__c = dataAssetsRec.Id;
                        subDataAssetRec.dcmgt_Data_Asset_Name__c = dataAssetsRec.Name;
                        dataAssetsRecordListToBeInserted.add(subDataAssetRec);
                    }

                    if(!dataAssetsRecordListToBeInserted.IsEmpty()){
                        insert dataAssetsRecordListToBeInserted;
                    }
                    
                }

                
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}