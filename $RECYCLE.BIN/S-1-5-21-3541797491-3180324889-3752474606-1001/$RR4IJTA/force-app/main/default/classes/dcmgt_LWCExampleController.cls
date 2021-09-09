public inherited sharing class dcmgt_LWCExampleController {
     @AuraEnabled(Cacheable = true)
    public static List<dcmgt_Alation_Article__c> getGlossary(){
    
      return [select  Name, dcmgt_Description__c, dcmgt_Acronynm_Synonym__c, dcmgt_Approval_date__c, dcmgt_Classification__c, dcmgt_Data_Owner__r.Name, dcmgt_Data_Steward__r.Name, dcmgt_Governed_Flag__c, dcmgt_Last_Review_Date__c, dcmgt_Life_Cycle_Status__c, dcmgt_Alation_Article__r.Name, dcmgt_Alation_Data_Dictionary__r.Name, dcmgt_Term_Type__c from dcmgt_Alation_Article__c];
    }
    }