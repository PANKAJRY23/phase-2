public with sharing class dcmgt_UploadValidation {
    private static final Integer Name = 0;
    private static final Integer Description = 1;
    private static final Integer Acronynm =2;
    private static final Integer Term_Type = 3;
    private static final Integer Life_Cycle_Status = 4;
    private static final Integer Subject_Area = 5;
    private static final Integer Classification = 6;
    private static final Integer Data_Owner =7;
    private static final Integer Data_Steward = 8;
    private static final Integer Alation_Article =9;
    private static final Integer Alation_Data_Dictionary =10;
    private static final Integer Governed_Flag =11;
    private static final Integer Schema = 1;
    private static final Integer Full_Name = 2;
    private static final Integer Type = 3;

    private static final Integer DataseetDescription = 4;
    // private static final Integer Description = 15;
    private static final Integer Data_Assets = 5;
    private static final Integer Business_Process= 6;
    private static final Integer Business_Rules = 7;
    private static final Integer Data_Category = 8;
    private static final Integer Data_Consumer = 9;
    private static final Integer Data_Dictionary_Field = 10;
    private static final Integer DataassetData_Steward = 11;
    private static final Integer  Derived_logic_or_Business_Calculation = 12;
    private static final Integer  Dimensions = 13;
    private static final Integer Indication_Metric = 14;
    private static final Integer Refresh_Frequency = 15;
    private static final Integer Service_Owner = 16;
    private static final Integer DataassetSubject_Area = 17;
    private static final Integer Tenant = 18; 	
    private static final Integer Value_Update = 19;
   
    
    

 public  dcmgt_UploadValidation(){
    }
public static string removeCommas(string csvLine){
Integer startIndex;
Integer endIndex;
while(csvLine.indexOf('"') > -1){
    
    if(startIndex == null){
        startIndex = csvLine.indexOf('"');
        csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
    }else{
        if(endIndex == null){
            endIndex = csvLine.indexOf('"');
            csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
        }
    }
    
    if(startIndex != null && endIndex != null){
        String sub = csvLine.substring(startIndex, endIndex);
        sub = sub.replaceAll(',', ':comma:');
        csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
        startIndex = null;
        endIndex = null;
    }
}
return csvLine;
}
    @AuraEnabled
    public static List<String> uploadData(String filesContent,String requestType){
        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'+filesContent);
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+requestType);
        List<String> errors= new List<String>();
        if('Business Glossary'.equalsIgnoreCase(requestType)){
           errors = uploadDataForArticles(filesContent);
        }
        else if('Data Dictionary'.equalsIgnoreCase(requestType)){
            errors =  uploadDataForDataasset(filesContent);
        }
        return errors;
    
    }
    private static List<String> uploadDataForArticles(String filesContent){
        Map<String,Set<String>> mapOfFieldWithOptions = 
            getPickListOptions(dcmgt_alation_article_management.getCustomFieldsValueSet());
        String data = JSON.deserializeUntyped(filesContent).toString();
        System.debug('*********************'+data);
        List<String> csvFileLines = data.split('\n');
        System.debug(csvFileLines.size());
        System.debug('csvFileLines'+csvFileLines);
        List<String> errors= new List<String>();
        List<String> csvRecordcolumn = csvFileLines.get(0).split(',');
        Map<String,Integer> mapofcolumnnamewithindex = new Map<String,Integer>();
        
        for(Integer column=0;column<csvRecordcolumn.size();column++) {
            mapofcolumnnamewithindex.put(csvRecordcolumn.get(column).trim(),column);
        }
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+mapofcolumnnamewithindex);
        Set<String> setOfUsersName = new Set<String>();
        for(Integer i=0;i<csvFileLines.size()-1;i++) {  
            string csvLine=removeCommas(csvFileLines.get(i+1))+' ';
            List<String> csvRecordData = csvLine.split(',');
            for(String recordData : csvRecordData){
                recordData = recordData.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            }
            String dataOwner, dataSteward;
            if(mapofcolumnnamewithindex.containsKey('Data Owner')){
                dataOwner  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Owner')).trim();
            }
            if(mapofcolumnnamewithindex.containsKey('Data Steward')){
                dataSteward  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Steward')).trim();
            }
            if(String.isNotBlank(dataOwner)) {
                List<String> StewardAreacolumn = dataSteward.split(';');
                setOfUsersName.addAll(StewardAreacolumn);
            }
            if(String.isNotBlank(dataOwner)) {
                List<String> ownerAreacolumn = dataOwner.split(';');
                setOfUsersName.addAll(ownerAreacolumn);
            }
        }
        System.debug('setOfUsersName'+setOfUsersName);
        List<User> listOfUser= [SELECT Name FROM User WHERE Name IN :setOfUsersName LIMIT 49000];
        for(Integer i=0;i<csvFileLines.size()-1;i++) {  
            System.debug('row:::'+csvFileLines.get(i+1));
            string csvLine=removeCommas(csvFileLines.get(i+1))+' ';
           
            List<String> csvRecordData = csvLine.split(',');
            for(String recordData : csvRecordData){
                recordData = recordData.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            }
            for(Integer x=0;x<csvRecordcolumn.size();x++) {
                System.debug('csvRecordcolumn'+csvRecordcolumn.get(x));
                mapofcolumnnamewithindex.put(csvRecordcolumn.get(x).trim(),x);
            }
            System.debug('csvRecordData'+csvRecordData);
            System.debug('mapofcolumnnamewithindex'+mapofcolumnnamewithindex);
            String name;
            if(mapofcolumnnamewithindex.containsKey('Business Term Name')){
                System.debug('***csvRecordcolumnz88'+csvRecordcolumn);
                name  = csvRecordData.get(mapofcolumnnamewithindex.get('Business Term Name')).trim();
            }
            String DataOwner;
            if(mapofcolumnnamewithindex.containsKey('Data Owner')){
                DataOwner  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Owner')).trim();
            }
            String DataSteward;
            if(mapofcolumnnamewithindex.containsKey('Data Steward')){
                DataSteward  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Steward')).trim();
            }
            String TermType;
            if(mapofcolumnnamewithindex.containsKey('Term Type')){
                TermType  = csvRecordData.get(mapofcolumnnamewithindex.get('Term Type')).trim();
            }
            String Classification;
            if(mapofcolumnnamewithindex.containsKey('Data Classification')){
                Classification  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Classification')).trim();
            }
            String LifeCycleStatus;
            if(mapofcolumnnamewithindex.containsKey('Lifecycle Status')){
                LifeCycleStatus  = csvRecordData.get(mapofcolumnnamewithindex.get('Lifecycle Status')).trim();
            }
            String SubjectArea;
            if(mapofcolumnnamewithindex.containsKey('Data Subject Area')){
                SubjectArea  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Subject Area')).trim();
            }
            String GovernedFlag;
            if(mapofcolumnnamewithindex.containsKey('Governed Flag')){
                GovernedFlag  = csvRecordData.get(mapofcolumnnamewithindex.get('Governed Flag')).trim();
            }
            String Description;
            if(mapofcolumnnamewithindex.containsKey('Business Term Definition')){
                Description  = csvRecordData.get(mapofcolumnnamewithindex.get('Business Term Definition')).trim();
            }
            String acronynmSynonym;
            if(mapofcolumnnamewithindex.containsKey('Acronym/Synonym')){
                acronynmSynonym  = csvRecordData.get(mapofcolumnnamewithindex.get('Acronym/Synonym')).trim();
            }
            String alationArticle;
            if(mapofcolumnnamewithindex.containsKey('Alation Article')){
                alationArticle  = csvRecordData.get(mapofcolumnnamewithindex.get('Alation Article')).trim();
            }
            String datadictionary;
            if(mapofcolumnnamewithindex.containsKey('Children/Data Dictionary Reference')){
                datadictionary  = csvRecordData.get(mapofcolumnnamewithindex.get('Children/Data Dictionary Reference')).trim();
            }
            String approvedOn;
            if(mapofcolumnnamewithindex.containsKey('Approved On')){
                approvedOn  = csvRecordData.get(mapofcolumnnamewithindex.get('Approved On')).trim();
            }
            String lastReviewDate;
            if(mapofcolumnnamewithindex.containsKey('Last Review Date')){
                lastReviewDate  = csvRecordData.get(mapofcolumnnamewithindex.get('Last Review Date')).trim();
            }
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%####'+name);
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%####'+Description);
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%####'+DataOwner);
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%####'+mapofcolumnnamewithindex.get('Data Stewards'));
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%####'+DataSteward);
            System.debug('##########################'+TermType);
            System.debug('#@@@@@@@@@@@@@@@@@@@##'+Classification);
            System.debug('#$$$$$$$$$$$$$$$$$$$$$$$$###'+LifeCycleStatus);
            System.debug('&&&&&&&&&&&&&&&&&&&&&&##########'+SubjectArea);
            System.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%####'+GovernedFlag);
            System.debug('%%%%lastReviewDate%%####'+mapofcolumnnamewithindex.get('Last Review Date'));
            System.debug('%%%%lastReviewDate%%####'+mapofcolumnnamewithindex.containsKey('Last Review Date'));
        
            if(String.isNotBlank(name)) {
                 if(name.length() > 80) {
                     errors.add('\n'+System.now()+'  "Name" in row number '+(i+1)+' is too long(Max length:80 character)');
                 }
            } else {
                errors.add('\n'+System.now()+'  "Name" in row number '+(i+1)+' is null');
            }
            Set<String> termTypeValues = new Set<String>();
            if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Term Type')) {
                termTypeValues = mapOfFieldWithOptions.get('Term Type');
            } else {
                Schema.DescribeFieldResult termTypePicklist = dcmgt_Alation_Article__c.dcmgt_Term_Type__c.getDescribe();        
                List<Schema.PicklistEntry> termTypeValue = termTypePicklist.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : termTypeValue){
                    termTypeValues.add(pickListVal.getLabel());
                }  
            }
            System.debug('TermType value is:'+TermType);
            if(!(termTypeValues.contains(TermType))){
                System.debug('Term Type not found');
                    errors.add('\n'+System.now()+'  "Term Type" in row number '+(i+1)+' please provide correct one');
            }
            Set<String> lifeCycleValues=new Set<String>();
            if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Life Cycle Status')) {
                lifeCycleValues = mapOfFieldWithOptions.get('Life Cycle Status');
            } else {
                Schema.DescribeFieldResult lifeCyclePicklist = dcmgt_Alation_Article__c.dcmgt_Life_Cycle_Status__c.getDescribe();
                List<Schema.PicklistEntry> lifeCycleValue = lifeCyclePicklist.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : lifeCycleValue){
                    lifeCycleValues.add(pickListVal.getLabel());
                }  
            }
            if(!String.isBlank(LifeCycleStatus)){
                if(!(lifeCycleValues.contains(LifeCycleStatus))){
                    errors.add('\n'+System.now()+'  "Lifecycle Status" in row number '+(i+1)+' please provide correct one');
                }
            }
            if(SubjectArea != null) {
                Set<String> SubjectArea1= new Set<String>();
                if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Subject Area')) {
                    SubjectArea1 = mapOfFieldWithOptions.get('Subject Area');
                } else {
                    Schema.DescribeFieldResult fieldResult = dcmgt_Alation_Article__c.dcmgt_Multi_Subject_Area__c.getDescribe();
                    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
                    for( Schema.PicklistEntry pickListVal : ple){
                        SubjectArea1.add(pickListVal.getLabel());
                    }     
                }
                List<String> SubjectAreacolumn = SubjectArea.split(';');
                System.debug('Fetched Subject Areas:'+SubjectArea1);
                System.debug(SubjectArea+'###@@@@@@@@@@@@@@@@@@@@@@@@@#####################'+SubjectAreacolumn);
                for(Integer k=0;k<SubjectAreacolumn.size();k++){
                    System.debug('*************************************#'+SubjectAreacolumn.get(k));
                    if(!String.isBlank(SubjectAreacolumn.get(k))) {
                        System.debug('SubjectArea is not blank');
                    if((!SubjectArea1.contains(SubjectAreacolumn.get(k)))){
                        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*#'+SubjectAreacolumn.get(k));
                        errors.add('\n'+System.now()+'  "Data Subject Area" in row number '+(i+1)+' please provide correct one');
                        break;
                    }
                    }
                }
            }
            Set<String> classificationValues = new Set<String>();
            if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Classification')) {
                classificationValues = mapOfFieldWithOptions.get('Classification');
            } else {
                Schema.DescribeFieldResult classificationPicklist = dcmgt_Alation_Article__c.dcmgt_Classification__c.getDescribe();
                List<Schema.PicklistEntry> classValue = classificationPicklist.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : classValue){
                    classificationValues.add(pickListVal.getLabel());
                }
            }
            if(!String.isBlank(Classification)){
                if(!(classificationValues.contains(Classification))){
                    errors.add('\n'+System.now()+'  "Data Classification" in row number '+(i+1)+' please provide correct one');
                }
            }
            if(String.isNotBlank(DataSteward)) {
                List<String> StewardAreacolumn = DataSteward.split(';');
                for(Integer m=0;m<StewardAreacolumn.size();m++){
                        System.debug('*************************************#'+StewardAreacolumn.get(m));
                        Set<String> usersOwnerList= new Set<String>();
                        // List<User> ownerList= [select name from User where name=:StewardAreacolumn.get(m)];
                        for (User user: listOfUser){
                                usersOwnerList.add(user.name);
                        }
                        if(!usersOwnerList.contains(StewardAreacolumn.get(m))){
                            System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*#'+StewardAreacolumn.get(m));

                            errors.add('\n'+System.now()+'  "Data Steward" in row number '+(i+1)+' is invalid or null');
                            break;
                        }

                    }
            } else {
                errors.add('\n'+System.now()+'  "Data Steward" in row number '+(i+1)+' is null');
            }
            if(String.isNotBlank(DataOwner)) {
                List<String> UserAreacolumn = DataOwner.split(';');
                System.debug(DataOwner+'###@@@@@@@@@@@@@@@@@@@@@@@@@#####################'+UserAreacolumn);
                    for(Integer l=0;l<UserAreacolumn.size();l++){
                        System.debug('*************************************#'+UserAreacolumn.get(l));
                        Set<String> usersStewardList= new Set<String>();
                        // List<User> stewardList= [select name from User where name=:UserAreacolumn.get(l)];
                        for (User user: listOfUser){
                                System.debug('User Exists:'+user.name);
                                usersStewardList.add(user.name);
                        }
                        if(!usersStewardList.contains(UserAreacolumn.get(l))){
                            
                            System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*#'+UserAreacolumn.get(l));

                            errors.add('\n'+System.now()+'  "Data Owner" in row number '+(i+1)+' is invalid or null');
                            break;
                        }

                    }
            } else {
                errors.add('\n'+System.now()+'  "Data Owner" in row number '+(i+1)+' is null');
            }
            System.debug('##############################################################'+GovernedFlag);
            if(String.isNotBlank(GovernedFlag)) {
                if(!('FALSE'.equalsIgnoreCase(GovernedFlag) || 'TRUE'.equalsIgnoreCase(GovernedFlag))) {
                    errors.add('\n'+System.now()+'  "GovernedFlag" in row number '+(i+1)+' is invalid.(Valid Vales: TRUE Or FALSE)');
                }
            }
            if(String.isNotBlank(approvedOn)) {
                try {
                    List<String> listOfDateStr = approvedOn.split('/');
                    if(listOfDateStr.size() == 3) {
                        String updatedDate = listOfDateStr[2]+'-'+listOfDateStr[0]+'-'+listOfDateStr[1]; //2021-08-30 yyy-mm-dd MM/DD/YYYY
                        Date d = Date.valueOf(updatedDate);
                    } else {
                        errors.add('\n'+System.now()+'  "Approved On" in row number '+(i+1)+' is not a valid date. Date format should be MM/DD/YYYY');
                    }
                }catch(TypeException e) {
                    errors.add('\n'+System.now()+'  "Approved On" in row number '+(i+1)+' is not a valid date. Date format should be MM/DD/YYYY');
                }
            } 
            if(String.isNotBlank(lastReviewDate)) {
                try {
                    List<String> listOfDateStr = lastReviewDate.split('/');
                    if(listOfDateStr.size() == 3) {
                        String updatedDate = listOfDateStr[2]+'-'+listOfDateStr[0]+'-'+listOfDateStr[1];
                        Date d = Date.valueOf(updatedDate);
                    } else {
                        errors.add('\n'+System.now()+'  "Last Review Date" in row number '+(i+1)+' is not a valid date. Date format should be MM/DD/YYYY');
                    }
                }catch(TypeException e) {
                    errors.add('\n'+System.now()+'  "Last Review Date" in row number '+(i+1)+' is not a valid date. Date format should be MM/DD/YYYY');
                }
            }      
        }
        system.debug('errorsin UploadValidation::::::::::'+errors);
        return errors;
    }

    private static List<String> uploadDataForDataasset(String filesContent){
        Map<String,Set<String>> mapOfFieldWithOptions = 
            getPickListOptions(dcmgt_alation_datasource_management.getCustomFieldsValueSet());
        String data = JSON.deserializeUntyped(filesContent).toString();
        System.debug('*********************'+data);
        List<String> csvFileLines = data.split('\n');
        System.debug(csvFileLines.size());
        List<String> errors= new List<String>();
        List<String> csvRecordcolumn = csvFileLines.get(0).split(',');
        Map<String,Integer> mapofcolumnnamewithindex = new Map<String,Integer>();
        
        for(Integer x=0;x<csvRecordcolumn.size();x++) {
            mapofcolumnnamewithindex.put(csvRecordcolumn.get(x).trim(),x);
        }
        System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@'+mapofcolumnnamewithindex);
        Set<String> setOfUsersName = new Set<String>();
        for(Integer i=0;i<csvFileLines.size()-1;i++) {  
            string csvLine=removeCommas(csvFileLines.get(i+1))+' ';
            List<String> csvRecordData = csvLine.split(',');
            for(String recordData : csvRecordData){
                recordData = recordData.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            }
            String serviceOwner, dataSteward, dataConsumer, tenant;
            if(mapofcolumnnamewithindex.containsKey('Data Owner')){
                serviceOwner  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Owner')).trim();
            }
            if(mapofcolumnnamewithindex.containsKey('Data Steward')){
                dataSteward  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Steward')).trim();
            }
            if(mapofcolumnnamewithindex.containsKey('Data Consumer')){
                dataConsumer  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Consumer')).trim();
            }
            if(mapofcolumnnamewithindex.containsKey('Tenant')){
                tenant  = csvRecordData.get(mapofcolumnnamewithindex.get('Tenant')).trim();
            }
            if(String.isNotBlank(serviceOwner)) {
                List<String> serviceOwners = serviceOwner.split(';');
                setOfUsersName.addAll(serviceOwners);
            }
            if(String.isNotBlank(dataSteward)) {
                List<String> dataStewards = dataSteward.split(';');
                setOfUsersName.addAll(dataStewards);
            }
            if(String.isNotBlank(dataConsumer)) {
                List<String> dataConsumers = dataConsumer.split(';');
                setOfUsersName.addAll(dataConsumers);
            }
            if(String.isNotBlank(tenant)) {
                List<String> tenants = tenant.split(';');
                setOfUsersName.addAll(tenants);
            }
        }
        System.debug('setOfUsersName'+setOfUsersName);
        List<User> listOfUser= [SELECT Name FROM User WHERE Name IN :setOfUsersName LIMIT 49000];
        for(Integer i=0;i<csvFileLines.size()-1;i++) {  
            string csvLine=removeCommas(csvFileLines.get(i+1))+' ';
            List<String> csvRecordData = csvLine.split(',');
            for(String recordData : csvRecordData){
                recordData = recordData.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            }
            string name,DataOwner,DataSteward='',Type,RefreshFrequency,IndicationMetric,serviceOwner='',SubjectArea,description;
            if(mapofcolumnnamewithindex.containsKey('Name')){
                name  = csvRecordData.get(mapofcolumnnamewithindex.get('Name')).trim();
            }
            if(mapofcolumnnamewithindex.containsKey('Data Owner')){
                serviceOwner  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Owner')).trim();
            }
            if(mapofcolumnnamewithindex.containsKey('Data Steward')){
                DataSteward  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Steward')).trim();
            }
            if(mapofcolumnnamewithindex.containsKey('Type')){
                Type  = csvRecordData.get(mapofcolumnnamewithindex.get('Type')).trim();
            }
            if(mapofcolumnnamewithindex.containsKey('Subject Area')){
                SubjectArea  = csvRecordData.get(mapofcolumnnamewithindex.get('Subject Area')).trim();
            }
            if(mapofcolumnnamewithindex.containsKey('Indication Metric')){
                IndicationMetric  = csvRecordData.get(mapofcolumnnamewithindex.get('Indication Metric')).trim();
            }
            if(mapofcolumnnamewithindex.containsKey('Refresh Frequency')){
                RefreshFrequency  = csvRecordData.get(mapofcolumnnamewithindex.get('Refresh Frequency')).trim();
            }
            if(mapofcolumnnamewithindex.containsKey('Description')){
                description  = csvRecordData.get(mapofcolumnnamewithindex.get('Description')).trim();
            }
            
            String businessProcess;
            if(mapofcolumnnamewithindex.containsKey('Business Process')){
                businessProcess  = csvRecordData.get(mapofcolumnnamewithindex.get('Business Process')).trim();
            }
            String dataCategory;
            if(mapofcolumnnamewithindex.containsKey('Data Category')){
                dataCategory  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Category')).trim();
            }  
            String dataClassification;
            if(mapofcolumnnamewithindex.containsKey('Data Classification')){
                dataClassification  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Classification')).trim();
            }
            String dataRetention;
            if(mapofcolumnnamewithindex.containsKey('Data Retention')){
                dataRetention  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Retention')).trim();
            }
            String valueUpdate;
            if(mapofcolumnnamewithindex.containsKey('Value Update')){
                valueUpdate  = csvRecordData.get(mapofcolumnnamewithindex.get('Value Update')).trim();
            }
            String schema;
            if(mapofcolumnnamewithindex.containsKey('Schema')){
                schema  = csvRecordData.get(mapofcolumnnamewithindex.get('Schema')).trim();
            }
            String fullName;
            if(mapofcolumnnamewithindex.containsKey('Full Name')){
                schema  = csvRecordData.get(mapofcolumnnamewithindex.get('Full Name')).trim();
            }
            String dataAsset;
            if(mapofcolumnnamewithindex.containsKey('Data Assets')){
                dataAsset  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Assets')).trim();
            }
            String businessRules;
            if(mapofcolumnnamewithindex.containsKey('Business Rules')){
                businessRules  = csvRecordData.get(mapofcolumnnamewithindex.get('Business Rules')).trim();
            }
            String dataConsumer;
            if(mapofcolumnnamewithindex.containsKey('Data Consumer')){
                dataConsumer  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Consumer')).trim();
            }
            String dataDictionaryField;
            if(mapofcolumnnamewithindex.containsKey('Data Dictionary Field')){
                dataDictionaryField  = csvRecordData.get(mapofcolumnnamewithindex.get('Data Dictionary Field')).trim();
            }
            String businessCalculation;
            if(mapofcolumnnamewithindex.containsKey('Derived logic/Business Calculation')){
                businessCalculation  = csvRecordData.get(mapofcolumnnamewithindex.get('Derived logic/Business Calculation')).trim();
            }
            String dimensions;
            if(mapofcolumnnamewithindex.containsKey('Dimensions')){
                dimensions  = csvRecordData.get(mapofcolumnnamewithindex.get('Dimensions')).trim();
            }
            String tenant;
            if(mapofcolumnnamewithindex.containsKey('Tenant')){
                tenant  = csvRecordData.get(mapofcolumnnamewithindex.get('Tenant')).trim();
            }
            if(String.isNotBlank(name)) {
                if(name.length() > 80) {
                     errors.add('\n'+System.now()+'  "Name" in row number '+(i+1)+' is too long(Max length:80 character)');
                 }
            } else {
                errors.add('\n'+System.now()+'  "Name" in row number '+(i+1)+' is null');
            }
            Set<String> typeValues=new Set<String>();
            if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Type')) {
                typeValues = mapOfFieldWithOptions.get('Type');
            } else {
                Schema.DescribeFieldResult typePicklist = dcmgt_Data_Assets__c.dcmgt_Type__c.getDescribe();
                List<Schema.PicklistEntry> typeValue = typePicklist.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : typeValue){
                    typeValues.add(pickListVal.getLabel());
                }
            }
            if(String.isBlank(Type) || !(typeValues.contains(Type))){
                errors.add('\n'+System.now()+'  "Type" in row number '+(i+1)+' please provide correct one');
            }
            Set<String> businessProcessValues=new Set<String>();
            if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Business Process')) {
                businessProcessValues = mapOfFieldWithOptions.get('Business Process');
                if(String.isNotBlank(businessProcess) && !(businessProcessValues.contains(businessProcess))){
                    errors.add('\n'+System.now()+'  "Business Process" in row number '+(i+1)+' is invalid');
                }
            }
            Set<String> dataCategoryValues=new Set<String>();
            if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Data Category')) {
                dataCategoryValues = mapOfFieldWithOptions.get('Data Category');
                if(String.isNotBlank(dataCategory) && !(dataCategoryValues.contains(dataCategory))){
                    errors.add('\n'+System.now()+'  "Data Category" in row number '+(i+1)+' is invalid');
                }
            }
            if(String.isNotBlank(dataConsumer)){
                List<String> dataConsumerList=dataConsumer.split(';');
                System.debug(dataConsumer+'###@@@@@@@@@@@@@@@@@@@@@@@@@#####################'+dataConsumerList);
                for(Integer n=0;n<dataConsumerList.size();n++){
                    System.debug('*************************************#'+dataConsumerList.get(n));
                    Set<String> dataConsumersList= new Set<String>();
                    // List<User> ownerList= [select name from User where name=:dataConsumerList.get(n)];
                    for (User user: listOfUser){
                        System.debug('User Exists:'+user.name);
                        dataConsumersList.add(user.name);
                    }
                    if(!dataConsumersList.contains(dataConsumerList.get(n))){
                        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*#'+dataConsumerList.get(n));
                        errors.add('\n'+System.now()+'  "Data Consumer" in row number '+(i+1)+' is invalid or null');
                        break;
                    }
                }
            }
            Set<String> dataClassificationValues=new Set<String>();
            if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Data Classification')) {
                dataClassificationValues = mapOfFieldWithOptions.get('Data Classification');
                if(String.isNotBlank(dataClassification) && !(dataClassificationValues.contains(dataClassification))){
                    errors.add('\n'+System.now()+'  "Data Classification" in row number '+(i+1)+' is invalid');
                }
            } 
            if(String.isNotBlank(DataSteward)) {
                List<String> StewardAreacolumn1 = DataSteward.split(';');
                System.debug(DataSteward+'###@@@@@@@@@@@@@@@@@@@@@@@@@#####################'+StewardAreacolumn1);
                for(Integer n=0;n<StewardAreacolumn1.size();n++) {
                    System.debug('*************************************#'+StewardAreacolumn1.get(n));
                    Set<String> usersStewardList= new Set<String>();
                    // List<User> stewardList= [select name from User where name=:StewardAreacolumn1.get(n)];
                    for (User user: listOfUser) {
                        System.debug('User Exists:'+user.name);
                        usersStewardList.add(user.name);
                    }
                    if(!usersStewardList.contains(StewardAreacolumn1.get(n))) {
                        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*#'+StewardAreacolumn1.get(n));
                        errors.add('\n'+System.now()+'  "Data Steward" in row number '+(i+1)+' is invalid or null');
                        break;
                    }
                }
            } else {
                errors.add('\n'+System.now()+'  "Data Steward" in row number '+(i+1)+' is null');
            }
            if(String.isNotBlank(serviceOwner)) {
                List<String> serviceOwnerList=serviceOwner.split(';');
                System.debug(serviceOwner+'###@@@@@@@@@@@@@@@@@@@@@@@@@#####################'+serviceOwnerList);
                for(Integer n=0;n<serviceOwnerList.size();n++){
                    System.debug('*************************************#'+serviceOwnerList.get(n));
                    Set<String> serviceOwnersList= new Set<String>();
                    // List<User> ownerList= [select name from User where name=:serviceOwnerList.get(n)];
                    for (User user: listOfUser){
                        System.debug('User Exists:'+user.name);
                        serviceOwnersList.add(user.name);
                    }
                    if(!serviceOwnersList.contains(serviceOwnerList.get(n))){
                        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*#'+serviceOwnerList.get(n));
                        errors.add('\n'+System.now()+'  "Data Owner" in row number '+(i+1)+' is invalid or null');
                        break;
                    }
                }
            } else {
                errors.add('\n'+System.now()+'  "Data Owner" in row number '+(i+1)+' is null');
            }
            Set<String> indicationMetrics = new Set<String>();
            if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Indication Metric')) {
                indicationMetrics = mapOfFieldWithOptions.get('Indication Metric');
            } else {
                Schema.DescribeFieldResult indicationMetricsPicklist = dcmgt_Data_Assets__c.dcmgt_Indication_Metric__c.getDescribe();
                List<Schema.PicklistEntry> indicationMetricsPicklistValue = indicationMetricsPicklist.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : indicationMetricsPicklistValue){
                    indicationMetrics.add(pickListVal.getLabel());
                }
            }
            if(String.isNotBlank(IndicationMetric) && !indicationMetrics.contains(IndicationMetric)) {
                errors.add('\n'+System.now()+'  "Indication Metric" in row number '+(i+1)+' please provide correct one');
            }
            Set<String> rfValues=new Set<String>();
            if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Refresh Frequency')) {
                rfValues = mapOfFieldWithOptions.get('Refresh Frequency');
            } else {
                Schema.DescribeFieldResult rfPicklist = dcmgt_Data_Assets__c.dcmgt_Refresh_Frequency__c.getDescribe();
                List<Schema.PicklistEntry> rfValue = rfPicklist.getPicklistValues();
                for( Schema.PicklistEntry pickListVal : rfValue){
                    rfValues.add(pickListVal.getLabel());
                }
            }
            if(!String.isBlank(RefreshFrequency)){
                if(!rfValues.contains(RefreshFrequency)){
                    errors.add('\n'+System.now()+'  "Refresh Frequency" in row number '+(i+1)+' please provide correct one');
                }
            }
            if(String.isNotBlank(SubjectArea)) {
                Set<String> SubjectArea1= new Set<String>();
                if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Subject Area')) {
                    SubjectArea1 = mapOfFieldWithOptions.get('Subject Area');
                } 
                for(String str:SubjectArea1 ){
                    System.debug('-'+str+'-');
                }
                
                List<String> SubjectAreacolumn = SubjectArea.split(';');
                System.debug('SubjectArea1:'+SubjectArea1);
                System.debug(SubjectArea+'###@@@@@@@@@@@@@@@@@@@@@@@@@#####################'+SubjectAreacolumn);
                for(Integer k=0;k<SubjectAreacolumn.size();k++){
                    System.debug('*************************************#'+SubjectAreacolumn.get(k));
                    if(!String.isBlank(SubjectAreacolumn.get(k))) {
                        System.debug('SubjectArea is not blank');
                    if((!SubjectArea1.contains(SubjectAreacolumn.get(k)))){
                        System.debug('SA:'+SubjectAreacolumn.get(k)+'SA');
                        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*#'+SubjectAreacolumn.get(k));
                        errors.add('\n'+System.now()+'  "Subject Area" in row number '+(i+1)+' please provide correct one');
                        break;
                    }
                    }
                }
            }
            if(String.isNotBlank(tenant)){
                List<String> tenantList=tenant.split(';');
                System.debug(dataConsumer+'###@@@@@@@@@@@@@@@@@@@@@@@@@#####################'+tenantList);
                for(Integer n=0;n<tenantList.size();n++){
                    System.debug('*************************************#'+tenantList.get(n));
                    Set<String> tenantListsList= new Set<String>();
                    // List<User> ownerList= [select name from User where name=:tenantList.get(n)];
                    for (User user: listOfUser){
                        System.debug('User Exists:'+user.name);
                        tenantListsList.add(user.name);
                    }
                    if(!tenantListsList.contains(tenantList.get(n))){
                        System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*#'+tenantList.get(n));
                        errors.add('\n'+System.now()+'  "Tenant" in row number '+(i+1)+' is invalid or null');
                        break;
                    }
                }
            }
            Set<String> valueUpdateValues=new Set<String>();
            if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Value Update')) {
                valueUpdateValues = mapOfFieldWithOptions.get('Value Update');
                if(String.isNotBlank(valueUpdate) && !(valueUpdateValues.contains(valueUpdate))){
                    errors.add('\n'+System.now()+'  "Value Update" in row number '+(i+1)+' is invalid');
                }
            }
            Set<String> dataRetentionValues=new Set<String>();
            if(mapOfFieldWithOptions  != null && mapOfFieldWithOptions.containsKey('Data Retention')) {
                dataRetentionValues = mapOfFieldWithOptions.get('Data Retention');
                if(String.isNotBlank(dataRetention) && !(dataRetentionValues.contains(dataRetention))){
                    errors.add('\n'+System.now()+'  "Data Retention" in row number '+(i+1)+' is invalid');
                }
            } 
        }
        system.debug('errorsin UploadValidation::::::::::'+errors);
        return errors;
        
    }

    public static Map<String,Set<String>> getPickListOptions(String fieldJSON) {
        // String fields = dcmgt_alation_article_management.getCustomFieldsValueSet();
        System.debug('fieldJSON'+fieldJSON.length());
        Map<String,Set<String>> mapOfFieldWithOptions = new Map<String,Set<String>>();
        Map<String,Object> mapOfJson = (Map<String,Object>) JSON.deserializeUntyped(fieldJSON);
        Set<String> setOfOptions; 
        Set<String> setOfPicklistOptions;
        System.debug(mapOfJson);
        for( String key : mapOfJson.keySet()){
            String value = mapOfJson.get(key).toString();
            String field = key.replaceAll('%20',' ');
            if(value.substringBetween('(', ')') != null) {
                setOfOptions = new Set<String>(value.substringBetween('(', ')').split(','));
                setOfPicklistOptions = new Set<String>();
                for(String option : setOfOptions) {
                    setOfPicklistOptions.add(option.trim());
                }
                System.debug('setOfOptions:-'+setOfPicklistOptions);
                mapOfFieldWithOptions.put(field, setOfPicklistOptions);
            }
            
            if('Subject Area'.equalsIgnoreCase(field)) {
                Set<String> setOfSubjectArea = new Set<String>{'Product', 'Marketing', 
                    'Sales', 'Finance', 'Partner', 'Support', 'Legal', 'Order', 'Security', 'Employee', 'IT', 
                    'Infrastructure', 'Customer', 'Operations' };
                mapOfFieldWithOptions.get(field).addAll(setOfSubjectArea);
            }
        } 
        System.debug(mapOfFieldWithOptions);
        return mapOfFieldWithOptions;
    }

}