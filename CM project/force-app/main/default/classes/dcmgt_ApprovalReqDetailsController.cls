public class dcmgt_ApprovalReqDetailsController {
    
    public Id recordId {get;set;}
    Public String URL {get;set;}
    
    public class ApprovalRecordWrapper {

    public String changeRequestName {get;set;} 
       
        public String LastModifiedBy {get;set;} 
      
        public String RecordType {get;set;} 
       
        public String Requester {get;set;} 
       
        public String RequestedDate {get;set;} 
       
        public String changeRequestUrl {get;set;} 
       
        public String stagedRecordName {get;set;} 
      
        public String stagedRecordUrl {get;set;} 

        public String approver {get;set;} 
       
        public String Status {get;set;} 
      
        public String updatedFields {get;set;} 
      
        public String Oldvalue {get;set;} 
    
        public String Newvalue {get;set;} 
    
        public String fieldName {get;set;} 
    
}
     
    
    public List<ApprovalRecordWrapper> getContactList()
    {
        System.debug('11');
        List<ApprovalRecordWrapper> conList  = new List<ApprovalRecordWrapper>();
        if(string.IsNotBlank(recordId)){
        List<ProcessInstanceWorkitem> approvalProcess = [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :recordId];
        String URLL = 'https://' + System.Url.getOrgDomainUrl();    
        System.debug('urll :'+URLL);
       String[] url1 = URLL.split('=');       
       String[] url2 = url1[1].split(']');
       System.debug('2nd url:'+url2);
           String finalurl = string.join(url2,',');
       System.debug('finalurl:'+finalurl);
         URL = finalurl+'/lightning/r/ProcessInstanceWorkitem/'+approvalProcess[0].Id+'/view';
        dcmgt_ApprovalRequestDetailsCtrl.ApprovalRecordWrapper results = dcmgt_ApprovalRequestDetailsCtrl.getApprovalRequestDetails(approvalProcess.get(0).id);
        for(Integer i=0;i<results.updatedFields.size();i++){
        ApprovalRecordWrapper a = new ApprovalRecordWrapper();
            a.changeRequestUrl = results.changeRequestUrl;
            a.stagedRecordUrl= results.stagedRecordUrl;
            a.changeRequestName=results.changeRequestName;
            a.stagedRecordName=results.stagedRecordName;
            a.RecordType=results.RecordType;
            a.Requester=results.Requester;
            a.approver=results.approver;
            a.LastModifiedBy= results.LastModifiedBy;
            a.RequestedDate=String.valueOf(results.RequestedDate);
            a.Status=results.Status;
            a.fieldName=results.updatedFields.get(i);
            a.Oldvalue=results.Oldvalue.get(i);
            a.Newvalue=results.Newvalue.get(i);
            conList.add(a);
        }
            return conList;
        }else{
            return null;
        }
    }
    
    public static void main(String recordId){
        Map<String,String> oldAndNewValues = new Map<String,String>();
        
        List<ApprovalRecordWrapper> aWrapperList = new List<ApprovalRecordWrapper>();
        if('dcmgt_Alation_Article__c'.equalsIgnoreCase(String.valueOf(Id.valueOf(recordId).getSobjectType()))) {
         list<dcmgt_Alation_Article__c> article = [select dcmgt_Change_Request__r.Name,Name,LastModifiedBy.Name,dcmgt_Term_Type__c,Owner.Name, 
                                                                    CreatedDate,dcmgt_Status__c,dcmgt_Updates_Fields__c from 
                                                                    dcmgt_Alation_Article__c where id=:recordId limit 1];  
            if(!article.IsEmpty()){                                         
                oldAndNewValues = (Map<String,String>) JSON.deserialize(article[0].dcmgt_Updates_Fields__c, Map<String,String>.class);
                for(String value:oldAndNewValues.keySet()){
                    ApprovalRecordWrapper aWrapper = new ApprovalRecordWrapper();
                    aWrapper.changeRequestName = article[0].dcmgt_Change_Request__r.Name;
                    aWrapper.stagedRecordName = article[0].Name;
                    aWrapper.RecordType = article[0].dcmgt_Term_Type__c; 
                    aWrapper.Requester= article[0].Owner.Name;
                    aWrapper.LastModifiedBy= article[0].LastModifiedBy.Name;
                    aWrapper.RequestedDate= String.valueOf(article[0].CreatedDate);
                    aWrapper.Status= article[0].dcmgt_Status__c;
                    if(oldAndNewValues.get(value).subString(0,3) == '---'){
                        aWrapper.fieldName= value;
                        aWrapper.Oldvalue= '';
                        aWrapper.Newvalue  = oldAndNewValues.get(value).subString(3,oldAndNewValues.get(value).length());
                    }else{
                        aWrapper.fieldName= value;
                        aWrapper.Oldvalue= oldAndNewValues.get(value).subString(0,oldAndNewValues.get(value).indexOf('---'));
                        aWrapper.Newvalue  = oldAndNewValues.get(value).subString(oldAndNewValues.get(value).indexOf('---')+3,oldAndNewValues.get(value).length());
                    }
                   aWrapperList.add(aWrapper);   
                }
            }
        }else if('dcmgt_Data_Assets__c'.equalsIgnoreCase(String.valueOf(Id.valueOf(recordId).getSobjectType()))) {
            
        }
            System.debug(aWrapperList);
        
    }
}