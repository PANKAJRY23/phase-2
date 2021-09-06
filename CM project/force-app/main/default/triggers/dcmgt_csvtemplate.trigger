trigger dcmgt_csvtemplate on dcmgt_CSV_Template_for_ChangeType__c (before insert, before update) {
    if(Trigger.isInsert && Trigger.isBefore){
            for(dcmgt_CSV_Template_for_ChangeType__c csv:Trigger.new){
                if(csv.dcmgt_Unique_Field__c !=null){  
                     dcmgt_CSV_Template_for_ChangeType__c csvconfig;
                    try {
                 csvconfig = [select Name,dcmgt_Unique_Field__c from dcmgt_CSV_Template_for_ChangeType__c  where dcmgt_Unique_Field__c=:csv.dcmgt_Unique_Field__c limit 1];    
                    } catch(Exception e){
                        return ;
                    } 
                    system.debug('csv configgggg:'+csvconfig);
                    if(csvconfig != null) {
                      if(csvconfig.dcmgt_Unique_Field__c != null ){
                    csv.addError('Record exists with same Request Type');
                         } 
                    }                       
                   }
            }              
    }
}