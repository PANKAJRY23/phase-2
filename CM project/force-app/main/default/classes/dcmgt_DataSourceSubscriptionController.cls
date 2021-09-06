public with sharing class dcmgt_DataSourceSubscriptionController {
    
    @AuraEnabled
    public static list<DataAssetSubRequestWrapper> getAllCurrentSubscriptionRec(Id tenantId){
        list<DataAssetSubRequestWrapper> wrapperClassList=new list<DataAssetSubRequestWrapper>();
        map<id,dcmgt_Data_Assets__c> mapOfIdVsAssets= new map<id,dcmgt_Data_Assets__c>();
       // for(dcmgt_Data_Assets__c assets : [select id, dcmgt_Refresh_Frequency__c, Name from dcmgt_Data_Assets__c]){
         //   mapOfIdVsAssets.put(assets.id, assets);
        //}
    
       list<dcmgt_Data_Asset_Sub_Request__c> subRequestList = [select id, dcmgt_Data_Subscription_Request__r.dcmgt_Alation_Data_Dictionary__r.Name, 
                                                                    dcmgt_Data_Source__c, dcmgt_Data_Source__r.Name, dcmgt_Data_Classification__c,
                                                                    dcmgt_Data_Asset_Name__c, dcmgt_Data_Load__c, dcmgt_Access_Layer__c, dcmgt_Refresh_Frequency__c, 
                                                                    dcmgt_SLA__c, dcmgt_Expiration_Date__c, dcmgt_Comunication_Email_Chatter__c, dcmgt_Data_Asset_USC_ID__c
                                                                    from dcmgt_Data_Asset_Sub_Request__c 
                                                                    where dcmgt_Data_Subscription_Request__r.dcmgt_Status__c = 'Draft' 
                                                                    and dcmgt_Data_Subscription_Request__r.dcmgt_Requestor__c= :UserInfo.getUserId()
                                                                    and dcmgt_Data_Subscription_Request__r.dcmgt_Tenant__c =: tenantId
                                                                    WITH SECURITY_ENFORCED limit 10000];
        
        
       for(dcmgt_Data_Asset_Sub_Request__c subRequest: subRequestList){
          //if(mapOfIdVsAssets!= null && mapOfIdVsAssets.containsKey(subRequest.dcmgt_Data_Asset_USC_ID__c)){
               wrapperClassList.add(new DataAssetSubRequestWrapper(subRequest.Id,subRequest.dcmgt_Data_Asset_Name__c, subRequest.dcmgt_Data_Source__r.Name, 
                                                                   subRequest.dcmgt_Data_Classification__c, subRequest.dcmgt_Data_Load__c, subRequest.dcmgt_Access_Layer__c, 
                                                                   subRequest.dcmgt_Refresh_Frequency__c, subRequest.dcmgt_SLA__c, subRequest.dcmgt_Comunication_Email_Chatter__c, 
                                                                   subRequest.dcmgt_Expiration_Date__c));
         // }
       } 
        
        
        return wrapperClassList;
    
    }
    
    @AuraEnabled
    public static dcmgt_Data_Sub_Request__c getSubRequest(Id tenantId){
        if(string.isNotBlank(tenantId)){
            return [select id, dcmgt_Service__c, dcmgt_Tenant__c, dcmgt_Business_Justification__c from dcmgt_Data_Sub_Request__c 
                        where dcmgt_Requestor__c= :UserInfo.getUserId()and dcmgt_Status__c = 'Draft' 
                        and dcmgt_Tenant__c =: tenantId WITH SECURITY_ENFORCED limit 1];
        }else{
            return Null;
        }
    }
    
    public class DataAssetSubRequestWrapper{
        @AuraEnabled public string Id;
        @AuraEnabled public string DataSource;
        @AuraEnabled public string DataAsset;
        @AuraEnabled public string DataClassification;
        @AuraEnabled public string DataLoad;
        @AuraEnabled public string AccessLayer;
        @AuraEnabled public string RefershFrequency;
        @AuraEnabled public string SLA;
        @AuraEnabled public string Communication;
        @AuraEnabled public date Expiration;
        
        public DataAssetSubRequestWrapper(string Id, string DataSource, string DataAsset, string DataClassification, string DataLoad, string AccessLayer, string RefershFrequency, string SLA, string Communication, date Expiration){
            this.Id = Id;
            this.DataSource = DataSource;
            this.DataAsset = DataAsset;
            this.DataClassification = DataClassification;
            this.DataLoad = DataLoad;
            this.AccessLayer = AccessLayer;
            this.RefershFrequency = RefershFrequency;
            this.SLA = SLA;
            this.Communication = Communication;
            this.Expiration = Expiration;
        }
    
    }
    
    @AuraEnabled
    public static string upsertDataAssetSubRequestList(string value, String RecordId, string FieldName){
        try {            
            if(!String.isBlank(FieldName) ){
                

                dcmgt_Data_Asset_Sub_Request__c RequestObj = new dcmgt_Data_Asset_Sub_Request__c();
                RequestObj.Id = RecordId;
                Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('dcmgt_Data_Asset_Sub_Request__c').getDescribe().SObjectType.getDescribe().fields.getMap();

                
                for(Schema.SObjectField field : fields.values()){      
                    if(FieldName == 'dcmgt_Expiration_Date__c' ){
                        RequestObj.put(FieldName,date.valueof(value));   
                    }else{              
                        RequestObj.put(FieldName,value);  
                    }                  
                }
                if(Schema.sObjectType.dcmgt_Data_Asset_Sub_Request__c.isUpdateable() || Schema.sObjectType.dcmgt_Data_Asset_Sub_Request__c.isCreateable() ){
                    upsert RequestObj Id;
                }
                

                
            }

            return 'Success';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static string upsertDataSubRequestList(string value, String RecordId, string FieldName){
        try {            
            if(!String.isBlank(FieldName) ){
                

                dcmgt_Data_Sub_Request__c RequestObj = new dcmgt_Data_Sub_Request__c();
                RequestObj.Id = RecordId;
                Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('dcmgt_Data_Sub_Request__c').getDescribe().SObjectType.getDescribe().fields.getMap();

                
                for(Schema.SObjectField field : fields.values()){  
                    
                    RequestObj.put(FieldName,value);   
                                   
                                     
                }
                if(Schema.sObjectType.dcmgt_Data_Sub_Request__c.isUpdateable() || Schema.sObjectType.dcmgt_Data_Sub_Request__c.isCreateable() ){
                    upsert RequestObj Id;
                }
                

                
            }

            return 'Success';

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
}