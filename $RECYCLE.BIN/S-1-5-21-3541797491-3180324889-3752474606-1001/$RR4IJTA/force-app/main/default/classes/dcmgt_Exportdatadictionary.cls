public inherited sharing class dcmgt_Exportdatadictionary {
    @AuraEnabled(Cacheable = true)
   public static List<dcmgt_Data_Assets__c> getDictionary(){
     return [select	Name, dcmgt_Full_name__c, dcmgt_Type__c, dcmgt_Description__c, dcmgt_Data_Assets__c, dcmgt_Business_Process__c, dcmgt_Business_Rules__c, dcmgt_Data_category__c, dcmgt_Data_Consumer__c, dcmgt_Data_Dictionary_Field__c, dcmgt_Data_Steward__c, dcmgt_Derived_logic_Business_Calculation__c, dcmgt_Dimensions__c, dcmgt_Indication_Metric__c, dcmgt_Refresh_Frequency__c, dcmgt_Schema__c, dcmgt_Service_Owner__c, dcmgt_Subject_Area__c, dcmgt_Tenant__c, dcmgt_Value_Update__c  from dcmgt_Data_Assets__c];
   }
       
   }