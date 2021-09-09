/*
        Name            :     dcmgt_BatchToUpdateNotificationFields 
        Date            :     16 Aug 2021
        Author          :     IA
        Description     :     We are creating this class for updating checkbox which helps to pervent to send duplicate Emails.
*/
public class dcmgt_BatchToUpdateNotificationFields implements Database.Batchable<sObject>, Database.Stateful {
    
    public set<Id> RecordId;
    public string methodType;
    
    public dcmgt_BatchToUpdateNotificationFields(set<Id> RecordId,String methodType){
        this.RecordId = RecordId;
        this.methodType = methodType;
        
    }
     public Database.QueryLocator start(Database.BatchableContext BC){
       
       return Database.getQueryLocator([select id,dcgmt_EmailBeforeImpSent__c, dcmgt_ImplementationEmailSent__c, dcmgt_RejectedMailSent__c
                                            from dcmgt_Data_Assets__c where id in :RecordId]);
       
       
   }
   
    public void execute(Database.BatchableContext BC, List<dcmgt_Data_Assets__c> scope){
    
        list<dcmgt_Data_Assets__c> listOfDataAssetsNeedToUpdate= new list<dcmgt_Data_Assets__c>();
        for(dcmgt_Data_Assets__c assets: scope){
            if(methodType == 'After'){
                assets.dcmgt_ImplementationEmailSent__c = true;
                assets.dcgmt_EmailBeforeImpSent__c = true;
            }
            if(methodType == 'Before'){
                assets.dcgmt_EmailBeforeImpSent__c = true;
            }
            if(methodType == 'Rejected'){
                assets.dcmgt_RejectedMailSent__c = true;
            }
             
             listOfDataAssetsNeedToUpdate.add(assets);
        }
        system.debug('==listOfDataAssetsNeedToUpdate=='+listOfDataAssetsNeedToUpdate);
        update listOfDataAssetsNeedToUpdate;
        
        
    }
    
    public void finish(Database.BatchableContext BC){
    
    }
    
}