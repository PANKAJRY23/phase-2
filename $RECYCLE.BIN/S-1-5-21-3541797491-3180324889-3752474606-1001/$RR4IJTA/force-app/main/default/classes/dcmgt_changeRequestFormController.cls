public with sharing class dcmgt_changeRequestFormController {

    private static Set<String> setOfTempLookupFields = new Set<String>{
        'schema', 'dataAssert', 'parentArticle', 'dataDictionary'
    };

    private static Map<String, String> mapOfAliationArticleFieldsWithSFFields = new Map<String, String> {
        'Name' => 'Name',
        'Description' => 'dcmgt_Description__c',
        'Acronym / Synonym' => 'dcmgt_Acronynm_Synonym__c',
        'Last Review Date' => 'dcmgt_Last_Review_Date__c',
        'Term Type' => 'dcmgt_Term_Type__c',
        'Life Cycle Status' => 'dcmgt_Life_Cycle_Status__c',
        'Classification' => 'dcmgt_Classification__c',
        'Business Owner' => 'dcmgt_Data_Owners__c',
        'Steward' => 'dcmgt_DataStewards__c',
        'Alation Article' => 'dcmgt_Alation_Articles__c',
        'Data Dictionary' => 'dcmgt_Alation_Data_Dictionary_Name__c',
        'Approval date' => 'dcmgt_Approval_date__c',
        'Governed Flag' => 'dcmgt_Governed_Flag__c',
        'Subject Area' => 'dcmgt_Multi_Subject_Area__c',
        'Id' => 'dcmgt_Alation_Id__c',
        'id' => 'dcmgt_Alation_Id__c'
    };

    private static Map<String, String> mapOfAliationArticleFieldsWithLabel = new Map<String, String> {
        'Name' => 'Business Term Name',
        'Description' => 'Business Term Definition',
        'Acronym / Synonym' => 'Acronym/Synonym',
        'Life Cycle Status' => 'Lifecycle Status',
        'Classification' => 'Data Classification',
        'Business Owner' => 'Data Owner',
        'Steward' => 'Data Steward',
        'Data Dictionary' => 'Children/Data Dictionary Reference',
        'Approval date' => 'Approved On',
        'Subject Area' => 'Data Subject Area'
    };

    private static Map<String, String> mapOfAliationDataAssertFieldsWithLabel = new Map<String, String> {
        'name' => 'Name',
        'schema_name' => 'Schema',
        'Full_Name' => 'Full Name',
        'description' => 'Description',
        'Data_Asset' => 'Data Assets',
        'Data Dictionary' => 'Data Dictionary Field',
        'Steward' => 'Data Steward',
        'Business Owner' => 'Data Owner',
        'Business Calculation' => 'Derived logic/Business Calculation'
    };

    private static Map<String, String> mapOfAliationDataAssertFieldsWithSFFields = new Map<String, String> {
        'name' => 'Name',
        'schema_name' => 'dcmgt_Schema_Name__c',
        'Full_Name' => 'dcmgt_Full_name__c',
        'Type' => 'dcmgt_Type__c',
        'description' => 'dcmgt_Description__c',
        'Data_Asset' => 'dcmgt_Data_Assets_Name__c',
        'Business Process' => 'dcmgt_Business_Process__c',
        'Business Rules' => 'dcmgt_Business_Rules__c',
        'Data Category' => 'dcmgt_Data_category__c',
        'Data Consumer' => 'dcmgt_Data_Consumer__c',
        'Data Dictionary' => 'dcmgt_Data_Dictionary_Field__c',
        'Data Classification' => 'dcmgt_Data_Classification__c',
        'Steward' => 'dcmgt_Data_Stewards__c',
        'Business Owner' => 'dcmgt_Service_Owners__c',
        'Business Calculation' => 'dcmgt_Derived_logic_Business_Calculation__c',
        'Dimensions' => 'dcmgt_Dimensions__c',
        'Indication Metric' => 'dcmgt_Indication_Metric__c',
        'Refresh Frequency' => 'dcmgt_Refresh_Frequency__c',
        'Subject Area' => 'dcmgt_Subject_Area__c',
        'Tenant' => 'dcmgt_Tenant__c',
        'Value Update' => 'dcmgt_Value_Update__c',
        'Id' => 'dcmgt_Alation_Id__c',
        'Data Retention' => 'dcmgt_Data_Retention__c',
        'id' => 'dcmgt_Alation_Id__c'
    };

    private static Map<String, User> mapOfUserByName;

    @AuraEnabled(Cacheable = true)
    public static Map<String, String> getMapOfUserIdAndName(){
        try {
            mapOfUserByName = new Map<String, User>();
            // return [SELECT Id, Name, Email FROM User WHERE IsActive = true];
            Map<String, String> mapOfUserIdAndName = new Map<String, String>();
            List<User> listOfUser = [SELECT Id, Name, Email FROM User WHERE IsActive = true ];
            for(User userObj : listOfUser) {
                mapOfUserIdAndName.put(userObj.Id, userObj.Name);
                mapOfUserByName.put(userObj.Name, userObj);
            }
            return mapOfUserIdAndName;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // @AuraEnabled(Cacheable = true)
    // public static Map<String, List<SelectOptionWrapper>> getPickListValues(){
    //     try {
    //         Schema.DescribeFieldResult fieldResult = dcmgt_Alation_Article__c.dcmgt_Multi_Subject_Area__c.getDescribe();
    //      Set<String> SubjectArea1= new Set<String>();
    //      List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    //         Map<String, List<SelectOptionWrapper>> mapOfFieldAndPicklistValue = new Map<String, List<SelectOptionWrapper>>();
    //         List<SelectOptionWrapper> listOfSelectOptionWrapper = new List<SelectOptionWrapper>();
    //      for( Schema.PicklistEntry pickListVal : ple){
    //          listOfSelectOptionWrapper.add(
    //                 new SelectOptionWrapper(pickListVal.getLabel(), pickListVal.getValue())
    //             );
    //      }
    //         mapOfFieldAndPicklistValue.put('Subject Area', listOfSelectOptionWrapper);

    //         fieldResult = dcmgt_Alation_Article__c.dcmgt_Life_Cycle_Status__c.getDescribe();
    //         ple = fieldResult.getPicklistValues();
    //         listOfSelectOptionWrapper = new List<SelectOptionWrapper>();
    //         for( Schema.PicklistEntry pickListVal : ple)
    //         {
    //             listOfSelectOptionWrapper.add(
    //                 new SelectOptionWrapper(pickListVal.getLabel(), pickListVal.getValue())
    //             );
    //         }    
    //         mapOfFieldAndPicklistValue.put('Life Cycle Status', listOfSelectOptionWrapper);
            
    //         fieldResult = dcmgt_Alation_Article__c.dcmgt_Classification__c.getDescribe();
    //         ple = fieldResult.getPicklistValues();
    //         listOfSelectOptionWrapper = new List<SelectOptionWrapper>();
    //         for( Schema.PicklistEntry pickListVal : ple)
    //         {
    //             listOfSelectOptionWrapper.add(
    //                 new SelectOptionWrapper(pickListVal.getLabel(), pickListVal.getValue())
    //             );
    //         }    
    //         mapOfFieldAndPicklistValue.put('Classification', listOfSelectOptionWrapper);

    //         fieldResult = dcmgt_Data_Assets__c.dcmgt_Type__c.getDescribe();
    //         ple = fieldResult.getPicklistValues();
    //         listOfSelectOptionWrapper = new List<SelectOptionWrapper>();
    //         for( Schema.PicklistEntry pickListVal : ple)
    //         {
    //             listOfSelectOptionWrapper.add(
    //                 new SelectOptionWrapper(pickListVal.getLabel(), pickListVal.getValue())
    //             );
    //         }    
    //         mapOfFieldAndPicklistValue.put('Type', listOfSelectOptionWrapper);

    //         fieldResult = dcmgt_Data_Assets__c.dcmgt_Refresh_Frequency__c.getDescribe();
    //         ple = fieldResult.getPicklistValues();
    //         listOfSelectOptionWrapper = new List<SelectOptionWrapper>();
    //         for( Schema.PicklistEntry pickListVal : ple)
    //         {
    //             listOfSelectOptionWrapper.add(
    //                 new SelectOptionWrapper(pickListVal.getLabel(), pickListVal.getValue())
    //             );
    //         }    
    //         mapOfFieldAndPicklistValue.put('Refresh Frequency', listOfSelectOptionWrapper);

    //         fieldResult = dcmgt_Data_Assets__c.dcmgt_Value_Update__c.getDescribe();
    //         ple = fieldResult.getPicklistValues();
    //         listOfSelectOptionWrapper = new List<SelectOptionWrapper>();
    //         for( Schema.PicklistEntry pickListVal : ple)
    //         {
    //             listOfSelectOptionWrapper.add(
    //                 new SelectOptionWrapper(pickListVal.getLabel(), pickListVal.getValue())
    //             );
    //         }    
    //         mapOfFieldAndPicklistValue.put('Value Update', listOfSelectOptionWrapper);

    //         fieldResult = dcmgt_Data_Assets__c.dcmgt_Business_Process__c.getDescribe();
    //         ple = fieldResult.getPicklistValues();
    //         listOfSelectOptionWrapper = new List<SelectOptionWrapper>();
    //         for( Schema.PicklistEntry pickListVal : ple)
    //         {
    //             listOfSelectOptionWrapper.add(
    //                 new SelectOptionWrapper(pickListVal.getLabel(), pickListVal.getValue())
    //             );
    //         }    
    //         mapOfFieldAndPicklistValue.put('Business Process', listOfSelectOptionWrapper);

    //         fieldResult = dcmgt_Data_Assets__c.dcmgt_Data_category__c.getDescribe();
    //         ple = fieldResult.getPicklistValues();
    //         listOfSelectOptionWrapper = new List<SelectOptionWrapper>();
    //         for( Schema.PicklistEntry pickListVal : ple)
    //         {
    //             listOfSelectOptionWrapper.add(
    //                 new SelectOptionWrapper(pickListVal.getLabel(), pickListVal.getValue())
    //             );
    //         }    
    //         mapOfFieldAndPicklistValue.put('Data Category', listOfSelectOptionWrapper);

    //         fieldResult = dcmgt_Data_Assets__c.dcmgt_Indication_Metric__c.getDescribe();
    //         ple = fieldResult.getPicklistValues();
    //         listOfSelectOptionWrapper = new List<SelectOptionWrapper>();
    //         for( Schema.PicklistEntry pickListVal : ple)
    //         {
    //             listOfSelectOptionWrapper.add(
    //                 new SelectOptionWrapper(pickListVal.getLabel(), pickListVal.getValue())
    //             );
    //         }    
    //         mapOfFieldAndPicklistValue.put('Indication Metric', listOfSelectOptionWrapper);

    //         fieldResult = dcmgt_Data_Assets__c.dcmgt_Subject_Area__c.getDescribe();
    //         ple = fieldResult.getPicklistValues();
    //         listOfSelectOptionWrapper = new List<SelectOptionWrapper>();
    //         for( Schema.PicklistEntry pickListVal : ple)
    //         {
    //             listOfSelectOptionWrapper.add(
    //                 new SelectOptionWrapper(pickListVal.getLabel(), pickListVal.getValue())
    //             );
    //         }    
    //         mapOfFieldAndPicklistValue.put('Subject Area', listOfSelectOptionWrapper);

    //         fieldResult = dcmgt_Data_Assets__c.dcmgt_Data_Retention__c.getDescribe();
    //         ple = fieldResult.getPicklistValues();
    //         listOfSelectOptionWrapper = new List<SelectOptionWrapper>();
    //         for( Schema.PicklistEntry pickListVal : ple)
    //         {
    //             listOfSelectOptionWrapper.add(
    //                 new SelectOptionWrapper(pickListVal.getLabel(), pickListVal.getValue())
    //             );
    //         }    
    //         mapOfFieldAndPicklistValue.put('Data Retention', listOfSelectOptionWrapper);
            
    //         return mapOfFieldAndPicklistValue;


    //     } catch (Exception e) {
    //         throw new AuraHandledException(e.getMessage());
    //     }
    // }

    
    class SelectOptionWrapper {
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        public SelectOptionWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    @AuraEnabled
    public static String getTemplateFields(String requestTypeId){
        try {
            dcmgt_CSV_Template_for_ChangeType__c template =  [SELECT Id, dcmgt_Fields__c 
                FROM dcmgt_CSV_Template_for_ChangeType__c 
                WHERE dcmgt_Request_Type__c = :requestTypeId
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate desc LIMIT 1];
            return template.dcmgt_Fields__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<dcmgt_Alation_Article__c> getAllArticle() {
        return [SELECT Id, Name FROM dcmgt_Alation_Article__c WHERE
            dcmgt_Change_Request__c = null AND dcmgt_Is_Active__c = true LIMIT 50000];
    }

    @AuraEnabled(cacheable=true)
    public static List<dcmgt_Data_Assets__c> getAllDataAsserts() {
        return [SELECT Id, Name FROM dcmgt_Data_Assets__c  
            WHERE dcmgt_Change_Request__c  = null AND dcmgt_IsActive__c  = true  LIMIT 50000];
    }

    // @AuraEnabled(continuation=true)
    // public static Object getArticleByGlossary(String glossaryId){
    //     Continuation con = new Continuation(30);
    //     con.continuationMethod='getResponse'; 
    //     HttpRequest req = new HttpRequest();
    //     req.setMethod('GET');
    //         dcmgt_Alation_Glossary__c glossary =  [SELECT Id, Name, dcmgt_Alation_ID__c 
    //                                                 FROM dcmgt_Alation_Glossary__c
    //                                                 WHERE Id = :glossaryId LIMIT 1];
    //     String glossaryName = glossary.Name.replaceAll(' ', '%20');
    //     req.setEndpoint('http://66.226.75.170:5000/get/articles/?glossery_name='+glossaryName);
    //     con.addHttpRequest(req);
    //     con.state='This is state from request method';
    //     return con;       
    // }

    // @AuraEnabled(continuation=true)
    // public static Object getDataAssertByDictionary(String dataDictionaryId){
    //     Continuation con = new Continuation(30);
    //     con.continuationMethod='getResponse'; 
    //     HttpRequest req = new HttpRequest();
    //     req.setMethod('GET');
    //     dcmgt_Alation_Data_Dictionary__c dataDictionary =  [SELECT  Id, Name, dcmgt_Alation_ID__c 
    //                                                 FROM dcmgt_Alation_Data_Dictionary__c
    //                                                 WHERE Id = :dataDictionaryId LIMIT 1];
    //     String dataDictionaryName = dataDictionary.Name.replaceAll(' ', '%20');
    //     req.setEndpoint('http://66.226.75.170:5000/get/datasourcehierarchy/?datasource_name='+dataDictionaryName);
    //     con.addHttpRequest(req);
    //     con.state='This is state from request method';
    //     return con;       
    // }

    @AuraEnabled(Cacheable = true)
    public static String getDataAssertByDictionary(String dataDictionaryId){
        dcmgt_Alation_Data_Dictionary__c dataDictionary =  [SELECT  Id, Name, dcmgt_Alation_ID__c 
                                                    FROM dcmgt_Alation_Data_Dictionary__c
                                                    WHERE Id = :dataDictionaryId LIMIT 1];
        String dataDictionaryName = dataDictionary.Name.replaceAll(' ', '%20');
        System.debug('dictionary name:'+dataDictionaryName);
        return dcmgt_alation_datasource_management.getDatasourceHierarchy(dataDictionaryName);
    }

    @AuraEnabled
    public static String getArticleByGlossary(String glossaryId){
        dcmgt_Alation_Glossary__c glossary =  [SELECT Id, Name, dcmgt_Alation_ID__c 
                                                    FROM dcmgt_Alation_Glossary__c
                                                    WHERE Id = :glossaryId LIMIT 1];
        String glossaryName = glossary.Name.replaceAll(' ', '%20');
        System.debug('glossary name:'+glossaryName);
        return dcmgt_alation_article_management.getArticles(glossaryName);       
    }
    
    @AuraEnabled
    public static Object getResponse(List<String> labels, Object state) {
        HttpResponse response = Continuation.getResponse(labels[0]);
        String result = response.getBody();
        return result;
    }

    @AuraEnabled
    public static Map<String, String> getMapOfUserNameAndId(){
        try {
            Map<String, String> mapOfUserNameAndId = new Map<String, String>();
            List<User> listOfUser = [select id, name from user where IsActive = true ];
            for(User userObj : listOfUser) {
                mapOfUserNameAndId.put(userObj.Name, userObj.Id);
            }
            return mapOfUserNameAndId;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static Map<String, String> getMapOfFieldNameWithAPIName(String objectName){
        try {
            Map<String, String> mapOfNameAndAPIName = new Map<String, String>();
            // Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            // Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
            // for(Schema.SObjectField sfield : fieldMap.Values())
            // {
            //     schema.describefieldresult dfield = sfield.getDescribe();
            //     mapOfNameAndAPIName.put(dfield.getLabel(), dfield.getname());
            //     // system.debug('@@@API Name : '  + dfield.getname());
            //     // system.debug('####Label Name : ' + dfield.getLabel ());
            // }
            //System.debug('api namesssssss'+mapOfNameAndAPIName);

            //key -> csv header, Value -> table fieldName
            if('dcmgt_Alation_Article__c'.equalsIgnoreCase(objectName)) {
                mapOfNameAndAPIName = new Map<String, String>{
                    'Business Term Name' => 'Name',
                    'Business Term Definition' => 'Description',
                    'Acronym/Synonym' => 'Acronym / Synonym',
                    'Last Review Date' => 'Last Review Date',
                    'Term Type' => 'Term Type',
                    'Lifecycle Status' => 'Life Cycle Status',
                    'Data Classification' => 'Classification',
                    'Data Owner' => 'Business Owner',
                    'Data Steward' => 'Steward',
                    'Alation Article' => 'Alation Article',
                    'Children/Data Dictionary Reference' => 'Data Dictionary',
                    'Approved On' => 'Approval date',
                    'Governed Flag' => 'Governed Flag',
                    'Data Subject Area' => 'Subject Area'
                };
            } else if('dcmgt_Data_Assets__c'.equalsIgnoreCase(objectName)) {
                mapOfNameAndAPIName = new Map<String, String> {
                    'Name' => 'name',
                    'Schema' => 'schema_name',
                    'Full Name' => 'Full_Name',
                    'Type' => 'Type',
                    'Description' => 'description',
                    'Data Assets' => 'Data_Asset',
                    'Business Process' => 'Business Process',
                    'Business Rules' => 'Business Rules',
                    'Data Category' => 'Data Category',
                    'Data Consumer' => 'Data Consumer',
                    'Data Classification' => 'Data Classification',
                    'Data Dictionary Field' => 'Data Dictionary',
                    'Data Steward' => 'Steward',
                    'Data Owner' => 'Business Owner',
                    'Derived logic/Business Calculation' => 'Business Calculation',
                    'Dimensions' => 'Dimensions',
                    'Indication Metric' => 'Indication Metric',
                    'Refresh Frequency' => 'Refresh Frequency',
                    'Subject Area' => 'Subject Area',
                    'Tenant' => 'Tenant',
                    'Value Update' => 'Value Update',
                    'Data Retention' => 'Data Retention'
                };
                
            } 

            return mapOfNameAndAPIName;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static String getRequestTypeName(Id requestTypeId){
        dcmgt_Request_Type__c requestType = [SELECT Name FROM dcmgt_Request_Type__c WHERE Id = :requestTypeId LIMIT 1];
        return requestType.Name;
    }

    @AuraEnabled(Cacheable = true)
    public static List<dcmgt_Request_Type__c> getRequestTypes(){
        try {
            return [SELECT Id, Name FROM dcmgt_Request_Type__c LIMIT 50000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<dcmgt_Alation_Article__c> getAlationArticleDataByGlossaryId(Id glossaryId){
        try {
        //
            return [Select Id, name,dcmgt_Description__c,dcmgt_Acronynm_Synonym__c,dcmgt_Last_Review_Date__c,dcmgt_Term_Type__c,
            dcmgt_Life_Cycle_Status__c,dcmgt_Classification__c, dcmgt_Alation_Article__c, dcmgt_Data_Owner__c, dcmgt_Data_Steward__c, 
            dcmgt_Data_Steward__r.Name,dcmgt_Data_Owner__r.Name,dcmgt_Alation_Article__r.name,dcmgt_Alation_Data_Dictionary__c, 
            dcmgt_Alation_Data_Dictionary__r.Name, dcmgt_Approval_date__c, dcmgt_Governed_Flag__c,dcmgt_Multi_Subject_Area__c, 
            dcmgt_DataStewards__c, dcmgt_Data_Owners__c FROM dcmgt_Alation_Article__c WHERE Id IN
                (SELECT dcmgt_Alation_Article__c
                FROM dcmgt_Glossary_Article__c WHERE 
                dcmgt_Alation_Glossary__c = :glossaryId
                AND dcmgt_Alation_Glossary__r.dcmgt_IsActive__c = true)
                AND dcmgt_Is_Active__c = true AND dcmgt_Change_Request__c = null];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String saveRecords(String recsString) {
        List<Opportunity> recs2Save = (List<Opportunity>) JSON.deserialize(recsString, List<Opportunity>.class);
        update recs2Save;
        return 'success';
    }

    @AuraEnabled
    public static List<String> storeStageRecord(Id changeRequestId, String tableData, String requestType, String operation){
      System.debug('changeRequestId:- '+changeRequestId);
      System.debug('tableData:- '+tableData);
      System.debug('requestType:- '+requestType);
      System.debug('operation:- '+operation);
      try {
          if('Data Dictionary'.equalsIgnoreCase(requestType)) {
               return modifyDataAssert(changeRequestId, tableData, operation);
          } else if('Business glossary'.equalsIgnoreCase(requestType)) {
               return modifyArticle(changeRequestId, tableData, operation);
          }
          return new List<String>();
      } catch (Exception e) {
        delete [select id from dcmgt_Change_Request__c where id = :changeRequestId];
        System.debug('delete'+changeRequestId);
        throw new AuraHandledException(e.getMessage());
      }
       
    }

    @AuraEnabled
    public static void deleteErrorChangeRecord(Id changeRequestId){
        try {
            delete [select id from dcmgt_Change_Request__c where id = :changeRequestId];
        } catch (Exception e) {
            
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<String> modifyDataAssert(Id changeRequestId, String recsString, String opperation) {
        
        if('Add'.equalsIgnoreCase(opperation)) {
            addDataAssert(changeRequestId, recsString);
        } else if('Update'.equalsIgnoreCase(opperation)) {
            return updateAndDeleteDataAssert(changeRequestId, recsString, false);
        } else if('Delete'.equalsIgnoreCase(opperation)) {
            return updateAndDeleteDataAssert(changeRequestId, recsString, true);  
        }
        return new List<String>();
    }

    private static List<String> modifyArticle(Id changeRequestId, String recsString, String opperation) {
          if('Add'.equalsIgnoreCase(opperation)) {
                addArticle(changeRequestId, recsString);
          } else if('Update'.equalsIgnoreCase(opperation)) {
              return  updateAndDeleteArticle(changeRequestId, recsString, false);
          } else if('Delete'.equalsIgnoreCase(opperation)) {
               return updateAndDeleteArticle(changeRequestId, recsString, true);  
          }
        return new List<String>();
    }
    private static Map<String, User> mapOfUserByEmail = new Map<String, User>();

    @AuraEnabled(Cacheable = true)
    public static Map<String, String> getMapOfUserEmailAndName(){
        try {
            // return [SELECT Id, Name, Email FROM User WHERE IsActive = true];
            Map<String, String> mapOfUserEmailAndName = new Map<String, String>();
            Map<String,String> alationUsers=dcmgt_alation_article_management.getAlationUsers();
            List<User> listOfUser = [SELECT Id, Name, Email FROM User WHERE IsActive = true and Email in:alationUsers.keySet()];
            for(User userObj : listOfUser) {               
                mapOfUserEmailAndName.put(userObj.Email, userObj.Name);
                mapOfUserByEmail.put(userObj.Email, userObj);
                mapOfUserByEmail.put(userObj.Name, userObj);               
            }
            return mapOfUserEmailAndName;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static List<String> updateAndDeleteArticle(Id changeRequestId, String recsString, Boolean isDelete) {
        List<dcmgt_Alation_Article__c> listOfArticleToBeInsert = getListOfAtricleByJSON(recsString, changeRequestId, isDelete);
        List<Database.SaveResult> results = Database.insert(listOfArticleToBeInsert, false) ;
        System.debug('Results of Update and Delete Articles'+listOfArticleToBeInsert);
        List<String> listOfExsistingArticles =new List<String>();
        dcmgt_ApprovalHistoryUtil.SubmitForApprovalBatch(changeRequestId);
         List<String> listOfErrors = new List<String>();
         for(Database.SaveResult result : results) {
             if(!result.isSuccess()) {
                 for(Database.Error err : result.getErrors()) {
                    System.debug('@@err'+err);
                     listOfErrors.add(err.getMessage());
                     String Errormsg = err.getMessage();
                     System.debug('ERR'+err.getMessage());
                    //  listOfExsistingArticles.add(Errormsg.split('---')[1]);
                    //  System.debug(Errormsg.split('||')[0]);
                     System.debug('List of Err'+listOfErrors);
                 }
             }
         }
        System.debug('U&D DA:-'+results);
         System.debug('Listofexsistingarticles'+listOfExsistingArticles);
         return listOfErrors;
    }

    private static void addArticle(Id changeRequestId, String recsString){
        List<dcmgt_Alation_Article__c> listOfArticleToBeInsert = new List<dcmgt_Alation_Article__c>();
        // List<dcmgt__Alation_Article__c> listOfArticle = 
        //       (List<dcmgt__Alation_Article__c>) JSON.deserialize(recsString, List<dcmgt__Alation_Article__c>.class);
        //     for(dcmgt__Alation_Article__c article : listOfArticle) {
        //         article.dcmgt__Is_Active__c = true;
        //         article.dcmgt__Change_Request__c = changeRequestId;
        //         listOfArticleToBeInsert.add(article);
        //     }
        List<dcmgt_Alation_Article__c> listOfArticle = getListOfAtricleByJSON(recsString, changeRequestId, false);
        // for(dcmgt__Alation_Article__c article : listOfArticle) {
        //     article.dcmgt__Is_Active__c = true;
        //     listOfArticleToBeInsert.add(article);
        // }
        System.debug('listOfArticleToBeInsert'+listOfArticle);
        List<Database.SaveResult> results = Database.insert(listOfArticle, true) ;
        dcmgt_ApprovalHistoryUtil.SubmitForApprovalBatch(changeRequestId);
        // List<String> listOfErrors = new List<String>();
        // for(Database.SaveResult result : results) {
        //     if(!result.isSuccess()) {
        //         for(Database.Error err : result.getErrors()) {
        //             listOfErrors.add(err.getMessage());
        //         }
        //     }
        // }
        System.debug('Add A:-'+results);
        //return listOfErrors;
        //System.debug('U&D DA:-'+results);
        dcmgt_Change_Request__c changeRequest = [SELECT Id, dcmgt_Alation_Glossary__c, dcmgt_Change_Request_Type__c,dcmgt_Change_Type__c
                                                    FROM dcmgt_Change_Request__c
                                                    WHERE Id = :changeRequestId];
        // List<dcmgt_Alation_Article__c> listOfNewArticles = [SELECT Id FROM dcmgt_Alation_Article__c
        //                                                         WHERE dcmgt_Change_Request__c = :changeRequestId ];
        // List<dcmgt_Glossary_Article__c> listOfGlossaryArticle = new List<dcmgt_Glossary_Article__c>();
        // for(dcmgt_Alation_Article__c article : listOfNewArticles) {
        //     dcmgt_Glossary_Article__c glossaryArticle = new dcmgt_Glossary_Article__c (
        //         dcmgt_Alation_Article__c = article.Id,
        //         dcmgt_Alation_Glossary__c = changeRequest.dcmgt_Alation_Glossary__c
        //     );
        //     listOfGlossaryArticle.add(glossaryArticle);
        // }
        // List<Database.SaveResult> resultsForGlossary = Database.insert(listOfGlossaryArticle, true);
        // System.debug('Add A:- '+resultsForGlossary);
        
    }

    // private static void addArticle(Id changeRequestId, String recsString) {
    //     dcmgt_Change_Request__c changeRequest = [SELECT Id, dcmgt_Alation_Glossary__c, dcmgt_Change_Request_Type__c,dcmgt_Change_Type__c
    //                                                 FROM dcmgt_Change_Request__c
    //                                                 WHERE Id = :changeRequestId];
        
        
    //     List<dcmgt_Alation_Article__c> listOfArticleToBeInsert = new List<dcmgt_Alation_Article__c>();
    //     List<dcmgt_Alation_Article__c> listOfArticle;
        
    //     // if('Single'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
    //     //     listOfArticle = 
    //     //       (List<dcmgt_Alation_Article__c>) JSON.deserialize(recsString, List<dcmgt_Alation_Article__c>.class);
    //     //     for(dcmgt_Alation_Article__c article : listOfArticle) {
    //     //         article.dcmgt_Change_Request__c = changeRequestId;
    //     //         listOfArticleToBeInsert.add(article);
    //     //     }
    //     // } else if('Bulk'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
    //         listOfArticleToBeInsert = getListOfAtricleByJSON(recsString, changeRequest);
    //     // }
        
    //     List<Database.SaveResult> results = Database.insert(listOfArticleToBeInsert, false) ;
    //     System.debug('result:- '+results);
    //     //insert listOfArticleToBeInsert;
    //     List<dcmgt_Alation_Article__c> listOfNewArticles = [SELECT Id FROM dcmgt_Alation_Article__c
    //                                                             WHERE dcmgt_Change_Request__c = :changeRequestId ];
    //     List<dcmgt_Glossary_Article__c> listOfGlossaryArticle = new List<dcmgt_Glossary_Article__c>();
    //     for(dcmgt_Alation_Article__c article : listOfNewArticles) {
    //         dcmgt_Glossary_Article__c glossaryArticle = new dcmgt_Glossary_Article__c (
    //             dcmgt_Alation_Article__c = article.Id,
    //             dcmgt_Alation_Glossary__c = changeRequest.dcmgt_Alation_Glossary__c
    //         );
    //         listOfGlossaryArticle.add(glossaryArticle);
    //     }
    //     List<Database.SaveResult> resultsForGlossary = Database.insert(listOfGlossaryArticle, false);
    //     System.debug('Add A:- '+resultsForGlossary);
        
    // }

    public static List<dcmgt_Alation_Article__c> getListOfAtricleByJSON(String jsonTableData, String changeRequestId, Boolean isDelete ) {
        dcmgt_Change_Request__c changeRequest = [SELECT Id, dcmgt_Alation_Glossary__c, dcmgt_Change_Request_Type__c,dcmgt_Change_Type__c
                                                    FROM dcmgt_Change_Request__c
                                                    WHERE Id = :changeRequestId];
        List<dcmgt_Alation_Article__c> listOfArticle = new List<dcmgt_Alation_Article__c>();
        List<Object> listOfArticleAsAObj = (List<Object>)JSON.deserializeUntyped(jsonTableData);
        System.debug(listOfArticleAsAObj);
        dcmgt_Alation_Article__c articleInstance;
        Set<String> setOfDateFields = new Set<String> {
            'Last Review Date', 'Approval date'
        };
        Set<String> setOfUserFields = new Set<String> {
            'Steward', 'Business Owner'
        };
        String updatedFields;
        if(mapOfUserByEmail.size() <= 0) {
            getMapOfUserEmailAndName();
        }

        for(Object obj : listOfArticleAsAObj) {
            String jsonObject = Json.serialize(obj);
            Map<String, Object> mapOfFieldWithValue = (Map<String, Object>)JSON.deserializeUntyped(jsonObject);
            System.debug(mapOfFieldWithValue);
            Map<String, Object> mapOfOriginalArticle;
            if(mapOfFieldWithValue.containsKey('originalRecord')) {
                mapOfOriginalArticle = (Map<String, Object>)JSON.deserializeUntyped(Json.serialize(mapOfFieldWithValue.get('originalRecord')));
                updatedFields = '{';
            } else if(!isDelete) {
                updatedFields = '{';
            }
            articleInstance = new dcmgt_Alation_Article__c();
            
            for(String key : mapOfFieldWithValue.keySet()) {
                System.debug('value 1:- '+mapOfFieldWithValue.get(key));
                if('Id'.equalsIgnoreCase(key)) {
                    System.debug('ID value 1:- '+''+mapOfFieldWithValue.get(key));
                }
                
                if(mapOfAliationArticleFieldsWithSFFields.containsKey(key) && 
                    (!('originalRecord'.equalsIgnoreCase(key) /*|| 'Id'.equalsIgnoreCase(key)*/))) {

                    String mapValue;
                    if('Id'.equalsIgnoreCase(key)) {
                        System.debug('ID value 1:- '+''+mapOfFieldWithValue.get(key));
                        mapValue = ''+mapOfFieldWithValue.get(key);
                        System.debug('ID value 1:- '+mapValue);
                    } else {
                        mapValue = (mapOfFieldWithValue.get(key) == null) ?
                            null : (String.isEmpty(mapOfFieldWithValue.get(key).toString()) ? null : mapOfFieldWithValue.get(key).toString());
                    }
                    System.debug('key:- '+key);
                    System.debug('mapValue:- '+mapValue);

                    if(mapValue == null) {
                        continue;
                    }
                    
                        System.debug('key 2:- '+key);
                    String fieldApiName = mapOfAliationArticleFieldsWithSFFields.get(key);
                    System.debug('fieldApiName:- '+fieldApiName);
                    if('Governed Flag'.equalsIgnoreCase(key)) {
                        mapValue = String.isBlank(mapValue) ? 'false' : mapValue;
                        articleInstance.put(fieldApiName, Boolean.valueOf(mapValue));
                    } else if('Id'.equalsIgnoreCase(key)) {
                        articleInstance.put(fieldApiName, Integer.valueOf(mapValue));
                    } else if(setOfDateFields.contains(key)) {
                        if(!String.isBlank(mapValue)) {
                            mapValue = mapValue.replaceAll('/', '-');
                            if('Bulk'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c) || 
                                'Add'.equalsIgnoreCase(changeRequest.dcmgt_Change_Type__c)) {
                                    String updatedDate;
                                    List<String> listOfDateStr = mapValue.split('-');
                                    if(listOfDateStr.size() == 3) {
                                        updatedDate = listOfDateStr[2]+'-'+listOfDateStr[0]+'-'+listOfDateStr[1]; //2021-08-30 yyy-mm-dd MM/DD/YYYY
                                        try{
                                            articleInstance.put(fieldApiName, Date.valueOf(updatedDate));
                                        } catch(Exception ex){
                                            articleInstance.put(fieldApiName, Date.valueOf(mapValue));
                                        }
                                    }
                                    
                            } else {
                                articleInstance.put(fieldApiName, Date.valueOf(mapValue));
                            }
                            
                            
                            
                        }
                    } else if(setOfUserFields.contains(key)) {
                        String jsnonData = '{';
                        List<String> listOfUserEmails = mapValue.split(';');
                        System.debug('listOfUserEmails'+listOfUserEmails);
                        for(String userEmailId : listOfUserEmails) {
                            User userInstance = mapOfUserByEmail.get(userEmailId);
                            if(userInstance != null) {
                                jsnonData = jsnonData + '"' + userInstance.Id + '":"' + userInstance.Name + '",';
                            }
                        }
                        jsnonData = jsnonData.removeEnd(',');
                        jsnonData += '}';
                        System.debug('listOfUserEmails'+listOfUserEmails);
                        // hpriya@information-asset.com;integration@example.com
                        articleInstance.put(fieldApiName, jsnonData);
                    } else {
                        articleInstance.put(fieldApiName, mapValue);
                    }
                    
                    if((mapOfOriginalArticle != null) && (!'Id'.equalsIgnoreCase(key))) {
                        String orignalValue = mapOfOriginalArticle.get(key) == null ? 'null' : mapOfOriginalArticle.get(key).toString();
                        System.debug('orignalValue:- '+orignalValue);
                        if(mapValue != orignalValue) {
                            String updateLabel=key;
                            if(mapOfAliationArticleFieldsWithLabel.containsKey(key)) {
                                updateLabel = mapOfAliationArticleFieldsWithLabel.get(key);
                            }
                            // if('Business Owner'.equalsIgnoreCase(key))
                            // {
                            //     updateLabel = 'Data Owner';
                            // } else if('Steward'.equalsIgnoreCase(key)) {
                            //     updateLabel = 'Data Steward';
                            // }
                            updatedFields = updatedFields + '"' + updateLabel + '":"' + 
                            orignalValue.replaceAll(';', '; ') + '---' + mapValue.replaceAll(';', '; ') + '" ,';
                        }
                    } else if((!isDelete) && (!'Id'.equalsIgnoreCase(key))) {
                        String updateLabel=key;
                        if(mapOfAliationArticleFieldsWithLabel.containsKey(key)) {
                            updateLabel = mapOfAliationArticleFieldsWithLabel.get(key);
                        }
                        // if('Business Owner'.equalsIgnoreCase(key))
                        // {
                        //     updateLabel = 'Data Owner';
                        // } else if('Steward'.equalsIgnoreCase(key)) {
                        //     updateLabel = 'Data Steward';
                        // }
                        updatedFields = updatedFields + '"' + updateLabel + '":"' + 
                             + '---' + mapValue.replaceAll(';', '; ') + '" ,';
                    }
                    System.debug('articleInstance:- '+articleInstance);
                }  
            }
            if(mapOfOriginalArticle != null || (!isDelete)) {
                updatedFields = updatedFields.removeEnd(',');
                updatedFields += '}';
                System.debug('updatedFields:- '+updatedFields);
                articleInstance.dcmgt_Updates_Fields__c = updatedFields;
            } 
            if(isDelete) {
                articleInstance.dcmgt_Is_Active__c = false;
                articleInstance.dcmgt_Updates_Fields__c = '{"Is Active":"true---false"}';
            }
            articleInstance.dcmgt_Change_Request__c = changeRequestId;
            listOfArticle.add(articleInstance);
            System.debug('listOfArticle:- '+listOfArticle);
        }
        return listOfArticle;
    }

    private static List<dcmgt_Data_Assets__c> getListOfDataAssertByJSON(String jsonTableData, String changeRequestId, Boolean isDelete ) {
        List<dcmgt_Data_Assets__c> listOfDataAssert = new List<dcmgt_Data_Assets__c>();
        List<Object> listOfDataAssertAsAObj = (List<Object>)JSON.deserializeUntyped(jsonTableData);
        System.debug(listOfDataAssertAsAObj);
        dcmgt_Data_Assets__c dataAssertInstance;
        Set<String> setOfUserFields = new Set<String> {
            'Steward', 'Business Owner', 'Data Consumer' , 'Tenant'
        };
        Set<String> setOfUserFieldToStoreId = new Set<String> {
            'Data Consumer' , 'Tenant'
        };
        String updatedFields;
        if(mapOfUserByEmail.size() <= 0) {
            getMapOfUserEmailAndName();
        }

        for(Object obj : listOfDataAssertAsAObj) {
            String jsonObject = Json.serialize(obj);
            Map<String, Object> mapOfFieldWithValue = (Map<String, Object>)JSON.deserializeUntyped(jsonObject);
            System.debug(mapOfFieldWithValue);
            Map<String, Object> mapOfOriginalDataAssert;
            if(mapOfFieldWithValue.containsKey('originalRecord')) {
                mapOfOriginalDataAssert = (Map<String, Object>)JSON.deserializeUntyped(Json.serialize(mapOfFieldWithValue.get('originalRecord')));
                updatedFields = '{';
            } else if(!isDelete) {
                updatedFields = '{';
            }
            dataAssertInstance = new dcmgt_Data_Assets__c();
            
            for(String key : mapOfFieldWithValue.keySet()) {
                System.debug('value 1:- '+mapOfFieldWithValue.get(key));
                System.debug('key:- '+key);
                if(mapOfAliationDataAssertFieldsWithSFFields.containsKey(key) && 
                    (!('originalRecord'.equalsIgnoreCase(key)))) {

                    String mapValue = (mapOfFieldWithValue.get(key) == null) ?
                        null : (String.isEmpty(mapOfFieldWithValue.get(key).toString()) ? null : mapOfFieldWithValue.get(key).toString());
                    System.debug('key:- '+key);
                    System.debug('mapValue:- '+mapValue);

                    if(mapValue == null) {
                        continue;
                    }
                    
                        System.debug('key 2:- '+key);
                    String fieldApiName = mapOfAliationDataAssertFieldsWithSFFields.get(key);
                    System.debug('fieldApiName:- '+fieldApiName);
                    if(setOfUserFields.contains(key)) {
                        
                        String jsnonData = '{';
                        String userIds = '';
                        List<String> listOfUserEmails = mapValue.split(';');
                        System.debug('listOfUserEmails'+listOfUserEmails);
                        for(String userEmailId : listOfUserEmails) {
                            User userInstance = mapOfUserByEmail.get(userEmailId);
                            if(userInstance != null) {
                                jsnonData = jsnonData + '"' + userInstance.Id + '":"' + userInstance.Name + '",';
                                userIds = userIds + userInstance.Id + ',';
                            }
                        }
                        userIds = userIds.removeEnd(',');
                        jsnonData = jsnonData.removeEnd(',');
                        jsnonData += '}';
                        System.debug('listOfUserEmails'+listOfUserEmails);
                        // hpriya@information-asset.com;integration@example.com
                        if(setOfUserFieldToStoreId.contains(key)) {
                            dataAssertInstance.put(fieldApiName, userIds);
                        } else {
                            dataAssertInstance.put(fieldApiName, jsnonData);
                        }
                    } else if('Id'.equalsIgnoreCase(key)) {
                        String alationId=mapValue.removeEnd('/');
                        alationId = alationId.substringAfterLast('/');
                        if(alationId.isNumeric()) {
                            dataAssertInstance.put('dcmgt_Alation_Id__c', Decimal.valueOf(alationId));
                        }
                    } else {
                        dataAssertInstance.put(fieldApiName, mapValue);
                    }
                    if((mapOfOriginalDataAssert != null)&&(!'Id'.equalsIgnoreCase(key))) {
                        String orignalValue = mapOfOriginalDataAssert.get(key) == null ? 'null' : mapOfOriginalDataAssert.get(key).toString();
                        System.debug('orignalValue:- '+orignalValue);
                        if(mapValue != orignalValue) {
                            String updateLabel=key;
                            if(mapOfAliationDataAssertFieldsWithLabel.containsKey(key)) {
                                updateLabel = mapOfAliationDataAssertFieldsWithLabel.get(key);
                            }
                            // if('Business Owner'.equalsIgnoreCase(key))
                            // {
                            //     updateLabel = 'Data Owner';
                            // } else if('Steward'.equalsIgnoreCase(key)) {
                            //     updateLabel = 'Data Steward';
                            // }
                            updatedFields = updatedFields + '"' + updateLabel + '":"' + 
                            orignalValue.replaceAll(';', '; ') + '---' + mapValue.replaceAll(';', '; ') + '" ,';
                        }
                    } else if((!isDelete) && (!'Id'.equalsIgnoreCase(key))) {
                        String updateLabel=key;
                        if(mapOfAliationDataAssertFieldsWithLabel.containsKey(key)) {
                            updateLabel = mapOfAliationDataAssertFieldsWithLabel.get(key);
                        }
                        // if('Business Owner'.equalsIgnoreCase(key))
                        // {
                        //     updateLabel = 'Data Owner';
                        // } else if('Steward'.equalsIgnoreCase(key)) {
                        //     updateLabel = 'Data Steward';
                        // }
                        updatedFields = updatedFields + '"' + updateLabel + '":"' + 
                             + '---' + mapValue.replaceAll(';', '; ') + '" ,';
                    }
                    System.debug('dataAssertInstance:- '+dataAssertInstance);
                }  
            }
            if(mapOfOriginalDataAssert != null || (!isDelete)) {
                updatedFields = updatedFields.removeEnd(',');
                updatedFields += '}';
                System.debug('updatedFields:- '+updatedFields);
                dataAssertInstance.dcmgt_Updated_Fields__c = updatedFields;
            } 
            if(isDelete) {
                dataAssertInstance.dcmgt_IsActive__c = false;
                dataAssertInstance.dcmgt_Updated_Fields__c = '{"Is Active":"true---false"}';
            }
            dataAssertInstance.dcmgt_Change_Request__c = changeRequestId;
            listOfDataAssert.add(dataAssertInstance);
            System.debug('listOfDataAssert:- '+listOfDataAssert);
        }
        return listOfDataAssert;
    }

    private static List<dcmgt_Alation_Article__c> getListOfAtricleByJSON(String jsonTableData, dcmgt_Change_Request__c changeRequest ) {
        Map<String, Id> mapOfOrignalArticleNameAndId = new Map<String, Id>();
        if('Update'.equalsIgnoreCase(changeRequest.dcmgt_Change_Type__c)) {
            List<dcmgt_Alation_Article__c> listOfOrignalArticle = getAlationArticleDataByGlossaryId(changeRequest.dcmgt_Alation_Glossary__c);
            for(dcmgt_Alation_Article__c orignalArticle : listOfOrignalArticle) {
                mapOfOrignalArticleNameAndId.put(orignalArticle.Name, orignalArticle.Id);
            }
        }
        
        Set<String> setOfUserLookupFields = new Set<String> {
            'dcmgt_DataStewards__c', 'dcmgt_Data_Owners__c'
        };
        Set<String> setOfArticleLookupFields = new Set<String> {
            'dcmgt_Alation_Article__c'
        };
        Set<String> setOfDataDictionaryLookupFields = new Set<String> {
            'dcmgt_Alation_Data_Dictionary__c'
        };
        Set<String> setOfDateFields = new Set<String> {
            'dcmgt_Last_Review_Date__c', 'dcmgt_Approval_date__c'
        };
        if(mapOfUserByName == null) {
            getMapOfUserIdAndName();
        }
        map<string,string> mapFieldNameVSApiName=new map<string,string>{'Id'=>'Id', 'Name'=>'Name','Description'=>'dcmgt_Description__c','Acronym / Synonym'=>'dcmgt_Acronynm_Synonym__c','Last Review Date'=>'dcmgt_Last_Review_Date__c','Term Type'=>'dcmgt_Term_Type__c','Life Cycle Status'=>'dcmgt_Life_Cycle_Status__c','Data Classification'=>'dcmgt_Classification__c',
    'Business Owner'=>'dcmgt_Data_Owners__c', 'Steward'=>'dcmgt_DataStewards__c','Approval date'=>'dcmgt_Approval_date__c','Governed Flag'=>'dcmgt_Governed_Flag__c'};
        Set<String> setOfArticle = new Set<String>();
        Set<String> setOfDataDictionary = new Set<String>();
        List<dcmgt_Alation_Article__c> listOfArticleToBeInsert = new List<dcmgt_Alation_Article__c>();
        List<dcmgt_Alation_Article__c> listOfArticle;
        Map<String,String> mapOfAricle = new Map<String,String>();
        Map<String,String> mapOfDataDictionary = new Map<String,String>();
        listOfArticle = new List<dcmgt_Alation_Article__c>();
            dcmgt_Alation_Article__c articleInstance;
            List<Object> listOfArticleAsAObj = (List<Object>)JSON.deserializeUntyped(jsonTableData);
            for(Object obj :listOfArticleAsAObj) {
                articleInstance = new dcmgt_Alation_Article__c();
                String jsonObject = Json.serialize(obj);
                Map<String, Object> mapOfFieldWithValue = (Map<String, Object>)JSON.deserializeUntyped(jsonObject);
                for(String label : mapOfFieldWithValue.keySet()) {
                    string key=mapFieldNameVSApiName.get(label);
                    if(setOfTempLookupFields.contains(key) || key.endsWithIgnoreCase('__r')) {
                        continue;
                    }
                    String mapValue = mapOfFieldWithValue.get(label).toString();
                    System.debug('mapValue:- '+mapValue);
                    if('undefined'.equalsIgnoreCase(key)) {
                        continue;
                    } else if(setOfUserLookupFields.contains(key)) {
                        //pankaj yadav;Contract Management
                        if(!String.isBlank(mapValue)) {
                            List<String> listOfUserName = mapValue.split(';');
                            String userJSON = '{';
                            for(String userName : listOfUserName) {
                                if(mapOfUserByName.containsKey(userName)) {
                                    userJSON = userJSON + '"' + mapOfUserByName.get(userName).Id +
                                        '":"' + userName + '",';
                                }
                            }
                            userJSON = userJSON.removeEnd(',');
                            userJSON += '}';
                            articleInstance.put(key, userJSON);
                        }
                        // if('dcmgt_Data_Steward__c'.equalsIgnoreCase(key)) {
                        //     mapOfDataOwner.put(mapOfFieldWithValue.get('Name').toString(), mapValue);
                        // } else if('dcmgt_Data_Owner__c'.equalsIgnoreCase(key)) {
                        //     mapOfDataSteward.put(mapOfFieldWithValue.get('Name').toString(), mapValue);
                        // }
                        // setOfUser.add(mapValue);
                    } else if(setOfArticleLookupFields.contains(key)){
                        mapOfAricle.put(mapOfFieldWithValue.get('Name').toString(), mapValue);
                        setOfArticle.add(mapValue);
                    }  else if(setOfDataDictionary.contains(key)){
                        mapOfDataDictionary.put(mapOfFieldWithValue.get('Name').toString(), mapValue);
                        setOfDataDictionary.add(mapValue);
                    } else if('dcmgt_Governed_Flag__c'.equalsIgnoreCase(key)){
                        articleInstance.put(key, Boolean.valueOf(mapValue));
                    } else if(setOfDateFields.contains(key)) {
                        if(!String.isBlank(mapValue)) {
                            mapValue = mapValue.replaceAll('/', '-');
                            articleInstance.put(key, Date.valueOf(mapValue));
                        }
                    } else{
                        System.debug('key:- '+key);
                        articleInstance.put(key, mapValue);
                    }
                }
                listOfArticle.add(articleInstance);
                //System.debug(mapOfFieldWithValue);
            }
            List<dcmgt_Alation_Article__c> articleList = [SELECT Id, Name FROM dcmgt_Alation_Article__c WHERE Name IN :setOfArticle];
            List<dcmgt_Alation_Data_Dictionary__c> dataDictionaryList = [SELECT Id, Name FROM dcmgt_Alation_Data_Dictionary__c WHERE Name IN :setOfDataDictionary];
            Map<String, Id> mapOfArticleNameandId = new Map<String, Id>();
            Map<String, Id> mapOfDataDictionaryNameandId = new Map<String, Id>();
            for(dcmgt_Alation_Article__c article : articleList) {
                mapOfArticleNameandId.put(article.name, article.Id);
            }
            for(dcmgt_Alation_Data_Dictionary__c dataDictionary : dataDictionaryList) {
                mapOfDataDictionaryNameandId.put(dataDictionary.name, dataDictionary.Id);
            }
            for(dcmgt_Alation_Article__c article : listOfArticle ) {
                if(mapOfAricle.containsKey(article.name)) {
                    String articleName = mapOfAricle.get(article.name);
                    article.dcmgt_Alation_Article__c = 
                        mapOfArticleNameandId.containsKey(articleName) ?
                        mapOfArticleNameandId.get(articleName) : null;
                }
                if(mapOfDataDictionary.containsKey(article.name)) {
                    String datDictionaryName = mapOfDataDictionary.get(article.name);
                    article.dcmgt_Alation_Data_Dictionary__c = 
                        mapOfDataDictionaryNameandId.containsKey(datDictionaryName) ?
                        mapOfDataDictionaryNameandId.get(datDictionaryName) : null;
                }
                article.dcmgt_Change_Request__c = changeRequest.Id;
                if('Update'.equalsIgnoreCase(changeRequest.dcmgt_Change_Type__c)) {
                    article.Id = mapOfOrignalArticleNameAndId.containsKey(article.name) ? mapOfOrignalArticleNameAndId.get(article.name) : null;
                }
                
                
                
                listOfArticleToBeInsert.add(article);
            }
            return listOfArticleToBeInsert;
    }

    private static List<dcmgt_Data_Assets__c> getListOfDataAssertByJSON(String jsonTableData, dcmgt_Change_Request__c changeRequest) {
        Map<String, Id> mapOfOrignalDataAssertNameAndId = new Map<String, Id>();
        if('Update'.equalsIgnoreCase(changeRequest.dcmgt_Change_Type__c)) {
            List<dcmgt_Data_Assets__c> listOfOrignalDataAssert = getListOfDataAssetsByDictionaryId(changeRequest.dcmgt_Alation_Data_Dictionary__c);
            for(dcmgt_Data_Assets__c orignalDataAssert : listOfOrignalDataAssert) {
                mapOfOrignalDataAssertNameAndId.put(orignalDataAssert.Name, orignalDataAssert.Id);
            }
        }
        Set<String> setOfUserLookupFields = new Set<String> {
            'dcmgt_Data_Stewards__c', 'dcmgt_Service_Owners__c'
        };
        Set<String> setOfSchemaLookupFields = new Set<String> {
            'dcmgt_Schema__c'
        };
        Set<String> setOfDataAssertLookupFields = new Set<String> {
            'dcmgt_Data_Assets__c'
        };
        
        if(mapOfUserByName == null) {
            getMapOfUserIdAndName();
        }
        Set<String> setOfSchema = new Set<String>();
        Set<String> setOfDataAssert = new Set<String>();
         map<string,string> mapFieldNameVSApiName=new map<string,string>{'Id'=>'Id', 'name'=>'Name','Full_Name'=>'dcmgt_Full_name__c','schema_name'=>'dcmgt_Schema_Name__c','Type'=>'dcmgt_Type__c','description'=>'dcmgt_Description__c',
         'Business rules'=>'dcmgt_Business_Rules__c','Data category'=>'dcmgt_Data_category__c','Data Classification'=>'dcmgt_Data_Classification__c','Data consumer'=>'dcmgt_Data_Consumer__c', 
         'Steward'=>'dcmgt_Data_Stewards__c','Business Owner'=>'dcmgt_Service_Owners__c','Refresh Frequency'=>'dcmgt_Refresh_Frequency__c',
         'Subject Area'=>'dcmgt_Subject_Area__c','Tenant'=>'dcmgt_Tenant__c'};
        List<dcmgt_Data_Assets__c> listOfDataAssertToBeInsert = new List<dcmgt_Data_Assets__c>();
        List<dcmgt_Data_Assets__c> listOfDataAssert;
        Map<String,String> mapOfSchema = new Map<String,String>();
        Map<String,String> mapOfDataAssert = new Map<String,String>();
        listOfDataAssert = new List<dcmgt_Data_Assets__c>();
            dcmgt_Data_Assets__c dataAssertInstance;
            List<Object> listOfDataAssertAsAObj = (List<Object>)JSON.deserializeUntyped(jsonTableData);
            for(Object obj :listOfDataAssertAsAObj) {
                dataAssertInstance = new dcmgt_Data_Assets__c();
                String jsonObject = Json.serialize(obj);
                Map<String, Object> mapOfFieldWithValue = (Map<String, Object>)JSON.deserializeUntyped(jsonObject);
                for(String label : mapOfFieldWithValue.keySet()) {
                    string key=mapFieldNameVSApiName.get(label);
                    if(setOfTempLookupFields.contains(key) || key.endsWithIgnoreCase('__r')) {
                        continue;
                    }
                    String mapValue = mapOfFieldWithValue.get(label).toString();
                    System.debug('mapValue:- '+mapValue);
                    if('undefined'.equalsIgnoreCase(key)) {
                        continue;
                    } else if(setOfUserLookupFields.contains(key)) {
                        if(!String.isBlank(mapValue)) {
                            List<String> listOfUserName = mapValue.split(';');
                            String userJSON = '{';
                            for(String userName : listOfUserName) {
                                if(mapOfUserByName.containsKey(userName)) {
                                    userJSON = userJSON + '"' + mapOfUserByName.get(userName).Id +
                                        '":"' + userName + '",';
                                }
                            }
                            userJSON = userJSON.removeEnd(',');
                            userJSON += '}';
                            dataAssertInstance.put(key, userJSON);
                        }
                    } else if(setOfSchemaLookupFields.contains(key)){
                        mapOfSchema.put(mapOfFieldWithValue.get('Name').toString(), mapValue);
                        setOfSchema.add(mapValue);
                    }  else if(setOfDataAssertLookupFields.contains(key)){
                        mapOfDataAssert.put(mapOfFieldWithValue.get('Name').toString(), mapValue);
                        setOfDataAssert.add(mapValue);
                    } else{
                        System.debug('key:- '+key);
                        dataAssertInstance.put(key, mapValue);
                    }
                }
                listOfDataAssert.add(dataAssertInstance);
                //System.debug(mapOfFieldWithValue);
            }
            List<dcmgt_Data_Assets__c> dataAssertList = [SELECT Id, Name FROM dcmgt_Data_Assets__c WHERE Name IN :setOfDataAssert];
            List<dcmgt_Schema__c> schemaList = [SELECT Id, Name FROM dcmgt_Schema__c WHERE Name IN :setOfSchema];
            Map<String, Id> mapOfDataAssertNameAndId = new Map<String, Id>();
            Map<String, Id> mapOfSchemaNameAndId = new Map<String, Id>();
            for(dcmgt_Data_Assets__c dataAssert : dataAssertList) {
                mapOfDataAssertNameAndId.put(dataAssert.name, dataAssert.Id);
            }
            for(dcmgt_Schema__c schema : schemaList) {
                mapOfSchemaNameAndId.put(schema.name, schema.Id);
            }
            for(dcmgt_Data_Assets__c dataAssert : listOfDataAssert ) {
                if(mapOfSchema.containsKey(dataAssert.name)) {
                    String schemaName = mapOfSchema.get(dataAssert.name);
                    dataAssert.dcmgt_Schema__c = 
                        mapOfDataAssertNameAndId.containsKey(schemaName) ?
                        mapOfDataAssertNameAndId.get(schemaName) : null;
                }
                if(mapOfDataAssert.containsKey(dataAssert.name)) {
                    String dataAssertName = mapOfDataAssert.get(dataAssert.name);
                    dataAssert.dcmgt_Data_Assets__c = 
                        mapOfSchemaNameAndId.containsKey(dataAssertName) ?
                        mapOfSchemaNameAndId.get(dataAssertName) : null;
                }
                dataAssert.dcmgt_Change_Request__c = changeRequest.Id; 
                if('Update'.equalsIgnoreCase(changeRequest.dcmgt_Change_Type__c)) {
                    dataAssert.Id = mapOfOrignalDataAssertNameAndId.containsKey(dataAssert.name) ? mapOfOrignalDataAssertNameAndId.get(dataAssert.name) : null;
                }               
                listOfDataAssertToBeInsert.add(dataAssert);
            }
            return listOfDataAssertToBeInsert;
    }

    // private static void updateAndDeleteArticle(Id changeRequestId, String recsString, Boolean isDelete) {
    //     List<dcmgt_Alation_Article__c> listOfArticleToBeInsert = getListOfAtricleByJSON(recsString, changeRequestId, isDelete);
    //     List<Database.SaveResult> results = Database.insert(listOfArticleToBeInsert, false) ;
    //     System.debug('U&D DA:-'+results);
    // }

    private static List<String> updateAndDeleteDataAssert(Id changeRequestId, String recsString, Boolean isDelete) {
        List<dcmgt_Data_Assets__c> listOfDataAssertToBeInsert = getListOfDataAssertByJSON(recsString, changeRequestId, isDelete);
        List<String> listOfExsistingArticles =new List<String>();
        List<Database.SaveResult> results = Database.insert(listOfDataAssertToBeInsert, false) ;
        dcmgt_ApprovalHistoryUtil.SubmitForApprovalBatch(changeRequestId);
         List<String> listOfErrors = new List<String>();
         for(Database.SaveResult result : results) {
             if(!result.isSuccess()) {
                 for(Database.Error err : result.getErrors()) {
                    System.debug('@@err'+err);
                     listOfErrors.add(err.getMessage());
                     String Errormsg = err.getMessage();
                     System.debug('ERR'+err.getMessage());
                    //  listOfExsistingArticles.add(Errormsg.split('---')[1]);
                    //  System.debug(Errormsg.split('||')[0]);
                     
                 }
             }
         }
         System.debug('U&D DA:-'+results);
         return listOfErrors;
    }

    // private static void updateAndDeleteArticle(Id changeRequestId, String recsString, Boolean isDelete) {
    //     dcmgt_Change_Request__c changeRequest = [SELECT Id, dcmgt_Alation_Glossary__c, dcmgt_Change_Request_Type__c, dcmgt_Change_Type__c
    //                                                 FROM dcmgt_Change_Request__c
    //                                                 WHERE Id = :changeRequestId];
        
    //     List<dcmgt_Alation_Article__c> listOfArticle;
        
    //     // if('Single'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c) || isDelete){
    //     //     listOfArticle = 
    //     //       (List<dcmgt_Alation_Article__c>) JSON.deserialize(recsString, List<dcmgt_Alation_Article__c>.class); 
    //     // } else if('Bulk'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
    //         listOfArticle = getListOfAtricleByJSON(recsString, changeRequest);
    //     // }
    //     // Map<Id, dcmgt_Alation_Article__c> mapOfOrignalArticle;
    //     // if(!isDelete) {
    //     //     mapOfOrignalArticle = new Map<Id, dcmgt_Alation_Article__c>(
    //     //         [SELECT Id, dcmgt_Data_Steward__c, dcmgt_Data_Owner__c FROM 
    //     //             dcmgt_Alation_Article__c WHERE Id IN :listOfArticle]);
    //     // }
    //     List<dcmgt_Alation_Article__c> listOfArticleToBeUpdate = new List<dcmgt_Alation_Article__c>();
    //     for(dcmgt_Alation_Article__c article : listOfArticle) {
    //         dcmgt_Alation_Article__c newArticle = article.clone();
    //         newArticle.dcmgt_Change_Request__c = changeRequestId;
    //         newArticle.dcmgt_Staged_Alation_Article__c = article.Id;
    //         newArticle.dcmgt_External_ID__c = null;
    //         newArticle.dcmgt_Alation_Id__c = null;
    //         if(isDelete) {
    //           newArticle.dcmgt_Is_Active__c = false;
    //         } 
    //         // else if(mapOfOrignalArticle.containsKey(article.Id)) {
    //         //     if(newArticle.dcmgt_Data_Steward__c == null) {
    //         //         newArticle.dcmgt_Data_Steward__c = 
    //         //             mapOfOrignalArticle.get(article.Id).dcmgt_Data_Steward__c;
    //         //     }
    //         //     if(newArticle.dcmgt_Data_Owner__c == null) {
    //         //         newArticle.dcmgt_Data_Owner__c =
    //         //             mapOfOrignalArticle.get(article.Id).dcmgt_Data_Owner__c;
    //         //     }
    //         // }
    //         listOfArticleToBeUpdate.add(newArticle);
    //     }
    //     List<Database.SaveResult> results = Database.insert(listOfArticleToBeUpdate, false) ;
    //     System.debug('U&D A:-'+results);
    // }

    // private static void addDataAssert(Id changeRequestId, String recsString) {
    //     dcmgt_Change_Request__c changeRequest = [SELECT Id, dcmgt_Alation_Data_Dictionary__c, dcmgt_Change_Request_Type__c,
    //                                                 dcmgt_Change_Type__c
    //                                                 FROM dcmgt_Change_Request__c
    //                                                 WHERE Id = :changeRequestId];
        
        
    //     List<dcmgt_Data_Assets__c> listOfDataAssertToBeInsert = new List<dcmgt_Data_Assets__c>();
    //     List<dcmgt_Data_Assets__c> listOfDataAssert;
        
    //     // if('Single'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
    //     //     listOfDataAssert = 
    //     //       (List<dcmgt_Data_Assets__c>) JSON.deserialize(recsString, List<dcmgt_Data_Assets__c>.class);
    //     //     for(dcmgt_Data_Assets__c dataAssert : listOfDataAssert) {
    //     //         dataAssert.dcmgt_Change_Request__c = changeRequestId;
    //     //         listOfDataAssertToBeInsert.add(dataAssert);
    //     //     }
    //     // } else if('Bulk'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
    //         listOfDataAssertToBeInsert = getListOfDataAssertByJSON(recsString, changeRequest);
    //     // }
    //     List<Database.SaveResult> results = Database.insert(listOfDataAssertToBeInsert, false) ;
    //     System.debug('Add DA:-'+results);
    //     //insert listOfDataAssertToBeInsert;
    // }

    private static void addDataAssert(Id changeRequestId, String recsString) {
        // List<dcmgt__Data_Assets__c> listOfDataAssertToBeInsert = new List<dcmgt__Data_Assets__c>();
        List<dcmgt_Data_Assets__c> listOfDataAssert = getListOfDataAssertByJSON(recsString, changeRequestId, false);
        // for(dcmgt__Data_Assets__c article : listOfArticle) {
        //     article.dcmgt__Is_Active__c = true;
        //     listOfDataAssertToBeInsert.add(article);
        // }
        System.debug('listOfDataAssertToBeInsert'+listOfDataAssert);
        List<Database.SaveResult> results = Database.insert(listOfDataAssert, true) ;
        dcmgt_ApprovalHistoryUtil.SubmitForApprovalBatch(changeRequestId);
        // List<String> listOfErrors = new List<String>();
        // for(Database.SaveResult result : results) {
        //     if(!result.isSuccess()) {
        //         for(Database.Error err : result.getErrors()) {
        //             listOfErrors.add(err.getMessage());
        //         }
        //     }
        // }
        // System.debug('Add DA:-'+results);
        // return listOfErrors;
    }

    
    // private static void updateAndDeleteDataAssert(Id changeRequestId, String recsString, Boolean isDelete) {
    //     dcmgt_Change_Request__c changeRequest = [SELECT Id, dcmgt_Alation_Data_Dictionary__c, dcmgt_Change_Request_Type__c,dcmgt_Change_Type__c
    //                                                 FROM dcmgt_Change_Request__c
    //                                                 WHERE Id = :changeRequestId];
        
    //     List<dcmgt_Data_Assets__c> listOfDataAssert;
        
    //     // if('Single'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c) || isDelete){
    //     //     listOfDataAssert = 
    //     //       (List<dcmgt_Data_Assets__c>) JSON.deserialize(recsString, List<dcmgt_Data_Assets__c>.class); 
    //     // } else if('Bulk'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
    //         listOfDataAssert = getListOfDataAssertByJSON(recsString, changeRequest);
    //     // }
    //     Map<Id, dcmgt_Data_Assets__c> mapOfOrignalDataAssert;
    //     if(!isDelete) {
    //         mapOfOrignalDataAssert = new Map<Id, dcmgt_Data_Assets__c>(
    //             [SELECT Id, dcmgt_Data_Steward__c, dcmgt_Service_Owner__c FROM 
    //             dcmgt_Data_Assets__c WHERE Id IN :listOfDataAssert]);
    //     }
    //     List<dcmgt_Data_Assets__c> listOfDataAssertToBeUpdate = new List<dcmgt_Data_Assets__c>();
    //     for(dcmgt_Data_Assets__c dataAssert : listOfDataAssert) {
    //         dcmgt_Data_Assets__c newDataAssert = dataAssert.clone();
    //         newDataAssert.dcmgt_Change_Request__c = changeRequestId;
    //         newDataAssert.dcmgt_Staged_Data_Assets__c = dataAssert.Id;
    //         newDataAssert.dcmgt_External_Id__c = null;
    //         newDataAssert.dcmgt_Alation_Id__c = null;
    //         if(isDelete) {
    //             newDataAssert.dcmgt_IsActive__c = false;
    //         } else if(mapOfOrignalDataAssert.containsKey(dataAssert.Id)) {
    //             if(newDataAssert.dcmgt_Data_Steward__c == null) {
    //                 newDataAssert.dcmgt_Data_Steward__c = 
    //                     mapOfOrignalDataAssert.get(dataAssert.Id).dcmgt_Data_Steward__c;
    //             }
    //             if(newDataAssert.dcmgt_Service_Owner__c == null) {
    //                 newDataAssert.dcmgt_Service_Owner__c =
    //                     mapOfOrignalDataAssert.get(dataAssert.Id).dcmgt_Service_Owner__c;
    //             }
    //         }
    //         listOfDataAssertToBeUpdate.add(newDataAssert);
    //     }
    //     List<Database.SaveResult> results = Database.insert(listOfDataAssertToBeUpdate, false) ;
    //     System.debug('U&D DA:-'+results);
    //     //insert listOfDataAssertToBeUpdate;
    // }

    private static void deleteDataAssert(Id changeRequestId, List<dcmgt_Data_Assets__c> listOfDataAssert) {
        List<dcmgt_Data_Assets__c> listOfDataAssertToBeDelete = new List<dcmgt_Data_Assets__c>();
        for(dcmgt_Data_Assets__c dataAssert : listOfDataAssert) {
            dcmgt_Data_Assets__c newDataAssert = dataAssert.clone();
            newDataAssert.dcmgt_Change_Request__c = changeRequestId;
            newDataAssert.dcmgt_Staged_Data_Assets__c = dataAssert.Id;
            newDataAssert.dcmgt_External_Id__c = null;
            newDataAssert.dcmgt_Alation_Id__c = null;
            newDataAssert.dcmgt_IsActive__c = false;
            listOfDataAssertToBeDelete.add(newDataAssert);
        }
        insert listOfDataAssertToBeDelete;
    }

    @AuraEnabled(Cacheable = true)
    public static List<dcmgt_Data_Assets__c> getListOfDataAssetsByDictionaryId(Id dictionaryId){
      try {
        System.debug('dictionaryId:- '+dictionaryId);
        Map<Id, dcmgt_Data_Assets__c> mapOfDataAssetsWithId = new Map<Id, dcmgt_Data_Assets__c>(
          [SELECT Id, Name, dcmgt_Full_name__c, dcmgt_Type__c, dcmgt_Description__c, 
          dcmgt_Data_Assets__c, dcmgt_Business_Process__c, 
          dcmgt_Business_Rules__c, dcmgt_Data_Assets__r.Name, dcmgt_Data_category__c,
          dcmgt_Data_Consumer__c, dcmgt_Data_Dictionary_Field__c, dcmgt_Data_Steward__c,
           dcmgt_Derived_logic_Business_Calculation__c, dcmgt_Data_Classification__c,
          dcmgt_Dimensions__c, dcmgt_Indication_Metric__c, dcmgt_Refresh_Frequency__c,
          dcmgt_Schema__c, dcmgt_Schema__r.Name, dcmgt_Service_Owner__c,
          dcmgt_Subject_Area__c, dcmgt_Tenant__c, dcmgt_Public_Schema_Visibility__c,
          dcmgt_Value_Update__c, dcmgt_Data_Stewards__c, dcmgt_Service_Owners__c
          FROM dcmgt_Data_Assets__c 
          WHERE dcmgt_Schema__c IN 
          (SELECT Id FROM dcmgt_Schema__c WHERE dcmgt_Alation_Data_Dictionary__c = :dictionaryId
          AND dcmgt_Alation_Data_Dictionary__r.dcmgt_IsActive__c = true
          AND dcmgt_IsActive__c = true)
          AND dcmgt_IsActive__c = true AND dcmgt_Change_Request__c = null
          ]);

        Set<Id> setOfDataAssetIds = new Set<Id>();
        for(dcmgt_Data_Assets__c dataAssets : mapOfDataAssetsWithId.values()) {
          setOfDataAssetIds.add(dataAssets.Id);
        }

        Map<Id, dcmgt_Data_Assets__c> mapOfChildDataAssetsWithId =  new Map<Id, dcmgt_Data_Assets__c>(
          [SELECT Id, Name, dcmgt_Full_name__c, dcmgt_Type__c, 
          dcmgt_Data_Assets__c, dcmgt_Business_Process__c, dcmgt_Public_Schema_Visibility__c,
          dcmgt_Business_Rules__c, dcmgt_Data_Assets__r.Name, dcmgt_Data_category__c,
          dcmgt_Data_Consumer__c, dcmgt_Data_Dictionary_Field__c, dcmgt_Data_Steward__c,
          dcmgt_Data_Steward__r.Name, dcmgt_Derived_logic_Business_Calculation__c,
          dcmgt_Dimensions__c, dcmgt_Indication_Metric__c, dcmgt_Refresh_Frequency__c,
          dcmgt_Schema__c, dcmgt_Schema__r.Name, dcmgt_Service_Owner__c, dcmgt_Data_Classification__c,
          dcmgt_Service_Owner__r.Name, dcmgt_Subject_Area__c, dcmgt_Tenant__c,
          dcmgt_Value_Update__c, dcmgt_Data_Stewards__c, dcmgt_Service_Owners__c
          FROM dcmgt_Data_Assets__c 
          WHERE dcmgt_Data_Assets__c IN : setOfDataAssetIds
          AND dcmgt_IsActive__c = true AND dcmgt_Change_Request__c = null]);

        mapOfDataAssetsWithId.putAll(mapOfChildDataAssetsWithId);
        return mapOfDataAssetsWithId.values();
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }

    @AuraEnabled(Cacheable = true)
    public static List<dcmgt_Alation_Data_Dictionary__c> getAllDataDictionary(){
        try {
            return [SELECT Id, Name FROM dcmgt_Alation_Data_Dictionary__c LIMIT 50000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static map<id,String> getAllActiveDataDictionary(){
        try {
            list<dcmgt_Alation_Data_Dictionary__c > allDataSchema = [SELECT Id, Name
                                                                        FROM dcmgt_Alation_Data_Dictionary__c 
                                                                        where dcmgt_IsActive__c = true                                                                            
                                                                        WITH SECURITY_ENFORCED
                                                                        limit 10000];
                                                                                        
             map<id,String> mapOfAllDataDictionary = new map<id,String>();
             for(dcmgt_Alation_Data_Dictionary__c schemaRec: allDataSchema){
                 mapOfAllDataDictionary.put(schemaRec.id,schemaRec.Name);             
             }
             
            return mapOfAllDataDictionary;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
    @AuraEnabled(Cacheable = true)
    public static map<id,String> getAllActiveSchema(){
        try {
            list<dcmgt_Schema__c> allDataSchema = [SELECT Id, Name
                                                            FROM dcmgt_Schema__c
                                                            where dcmgt_IsActive__c = true                                                                            
                                                            WITH SECURITY_ENFORCED
                                                            limit 10000];
                                                                            
             map<id,String> mapOfAllSchema = new map<id,String>();
             for(dcmgt_Schema__c schemaRec: allDataSchema){
                 mapOfAllSchema.put(schemaRec.id,schemaRec.Name);             
             }
             
            return mapOfAllSchema;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<dcmgt_Alation_Glossary__c> getAllGlossary(){
        try {
            return [SELECT Id, Name FROM dcmgt_Alation_Glossary__c LIMIT 50000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(Cacheable = true)
    public static String getNameByID(String recordID){
         String name ='';
        if(recordID =='novalue'){
            
        }else{
            Id recId = Id.valueOf(recordID);
            List<sObject> returnValues=Database.query('select Name from ' + recId.getSObjectType()+ ' where Id = :recId');
       
        for(sObject s:returnValues){
            name=String.valueOf(s.get('Name'));
        }
        }
      return name;  
    }
}