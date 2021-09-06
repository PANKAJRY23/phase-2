/*
        Name            :     dcmgt_BatchToUpdateArticleNotifinFlds 
        Date            :     16 Aug 2021
        Author          :     IA
        Description     :     We are creating this class for updating checkbox which helps to pervent to send duplicate Emails.
*/
public class dcmgt_BatchToUpdateArticleNotifinFlds implements Database.Batchable<sObject>, Database.Stateful {
    
    public set<Id> RecordId;
    public string methodType;
    
    public dcmgt_BatchToUpdateArticleNotifinFlds(set<Id> RecordId,String methodType){
        this.RecordId = RecordId;
        this.methodType = methodType;
        
    }
     public Database.QueryLocator start(Database.BatchableContext BC){
       
       return Database.getQueryLocator([select id,dcgmt_EmailBeforeImpSent__c, dcmgt_ImplementationEmailSent__c, dcmgt_RejectedMailSent__c 
                                           from dcmgt_Alation_Article__c where id in :RecordId]);
       
       
   }
   
    public void execute(Database.BatchableContext BC, List<dcmgt_Alation_Article__c> scope){
    
        list<dcmgt_Alation_Article__c> listOfArticlesNeedToUpdate= new list<dcmgt_Alation_Article__c>();
        for(dcmgt_Alation_Article__c article: scope){
            if(methodType == 'After'){
                article.dcmgt_ImplementationEmailSent__c = true;
                article.dcgmt_EmailBeforeImpSent__c = true;
            }
            if(methodType == 'Before'){
             article.dcgmt_EmailBeforeImpSent__c = true;
            }
            if(methodType == 'Rejected'){
             article.dcmgt_RejectedMailSent__c = true;
            }
             listOfArticlesNeedToUpdate.add(article);
        }
        system.debug('==listOfArticlesNeedToUpdate=='+listOfArticlesNeedToUpdate);
        update listOfArticlesNeedToUpdate;
        
        
    }
    
    public void finish(Database.BatchableContext BC){
    
    }
    
}