public with sharing class dcmgt_salesforceCRFController {

    private static Set<String> setOfTempLookupFields = new Set<String>{
        'schema', 'dataAssert', 'parentArticle', 'dataDictionary'
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

    @AuraEnabled(continuation=true)
    public static Object getArticleByGlossary(String glossaryId){
        Continuation con = new Continuation(30);
        con.continuationMethod='getResponse'; 
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
            dcmgt_Alation_Glossary__c glossary =  [SELECT Id, Name, dcmgt_Alation_ID__c 
                                                    FROM dcmgt_Alation_Glossary__c
                                                    WHERE Id = :glossaryId LIMIT 1];
        String glossaryName = glossary.Name.replaceAll(' ', '%20');
        req.setEndpoint('http://66.226.75.170:5000/get/articles/?glossery_name='+glossaryName);
        con.addHttpRequest(req);
        con.state='This is state from request method';
        return con;       
    }

    @AuraEnabled(continuation=true)
    public static Object getDataAssertByDictionary(String dataDictionaryId){
        Continuation con = new Continuation(30);
        con.continuationMethod='getResponse'; 
        HttpRequest req = new HttpRequest();
        req.setMethod('GET');
        dcmgt_Alation_Data_Dictionary__c dataDictionary =  [SELECT  Id, Name, dcmgt_Alation_ID__c 
                                                    FROM dcmgt_Alation_Data_Dictionary__c
                                                    WHERE Id = :dataDictionaryId LIMIT 1];
        String dataDictionaryName = dataDictionary.Name.replaceAll(' ', '%20');
        req.setEndpoint('http://66.226.75.170:5000/get/datasourcehierarchy/?datasource_name='+dataDictionaryName);
        con.addHttpRequest(req);
        con.state='This is state from request method';
        return con;       
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
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(objectName).getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                mapOfNameAndAPIName.put(dfield.getLabel(), dfield.getname());
                // system.debug('@@@API Name : '  + dfield.getname());
                // system.debug('####Label Name : ' + dfield.getLabel ());
            }
            // if('dcmgt_Alation_Article__c'.equalsIgnoreCase(objectName)) {
            //     mapOfNameAndAPIName = new Map<String, String>{
            //         'Name' => 'Name',
            //         'Description' => 'Description',
            //         'Acronynm/Synonym' => 'Acronym / Synonym',
            //         'Last Review Date' => 'Last Review Date',
            //         'Term Type' => 'Term Type',
            //         'Life Cycle Status' => 'Life Cycle Status',
            //         'Classification' => 'Classification',
            //         'Data Owner' => 'Business Owner',
            //         'Data Steward' => 'Steward',
            //         'Alation Article' => 'Alation Article',
            //         'Alation Data Dictionary' => 'datadictionary',
            //         'Approval date' => 'Approval date',
            //         'Governed Flag' => 'Governed Flag',
            //         'Subject Area' => 'Subject area'
            //     };
            // } else if('dcmgt_Data_Assets__c'.equalsIgnoreCase(objectName)) {
            //     mapOfNameAndAPIName = new Map<String, String> {
            //         'Name' => 'name',
            //         'Schema' => 'schema_name',
            //         'Full Name' => 'Full_Name',
            //         'Type' => 'Type',
            //         'Description' => 'description',
            //         'Data Assets' => 'Data_Asset',
            //         'Business Process' => 'Business process',
            //         'Business Rules' => 'Business rules',
            //         'Data Category' => 'Data category',
            //         'Data Consumer' => 'Data consumer',
            //         'Data Dictionary Field' => 'Data dictionary',
            //         'Data Steward' => 'Steward',
            //         'Service Owner' => 'Business Owner',
            //         'Derived logic/Business Calculation' => 'Buisness Calculaqtion',
            //         'Dimensions' => 'Dimensions',
            //         'Indication Metric' => 'Indication Metric',
            //         'Refresh Frequency' => 'Refresh Frequency',
            //         'Subject Area' => 'Subject Area',
            //         'Tenant' => 'Tenant',
            //         'Value Update' => 'Value Update'
            //         // 'Data Rentation'
            //     };
                
            // } 

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
            return [Select Id, name, dcmgt_Description__c,dcmgt_Acronynm_Synonym__c,
            dcmgt_Last_Review_Date__c,dcmgt_Term_Type__c,dcmgt_Life_Cycle_Status__c,
            dcmgt_Classification__c, dcmgt_Alation_Article__c, 
            dcmgt_Data_Owner__c, dcmgt_Data_Steward__c, dcmgt_Data_Steward__r.Name,dcmgt_Data_Owner__r.Name,
            dcmgt_Alation_Article__r.name,
			dcmgt_Alation_Data_Dictionary__c, dcmgt_Alation_Data_Dictionary__r.Name, dcmgt_Approval_date__c,
			dcmgt_Governed_Flag__c,dcmgt_Multi_Subject_Area__c, dcmgt_DataStewards__c, dcmgt_Data_Owners__c
            FROM dcmgt_Alation_Article__c WHERE Id IN
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
    public static void storeStageRecord(Id changeRequestId, String tableData, String requestType, String operation){
      System.debug('changeRequestId:- '+changeRequestId);
      System.debug('tableData:- '+tableData);
      System.debug('requestType:- '+requestType);
      System.debug('operation:- '+operation);
      try {
          if('Data Dictionary'.equalsIgnoreCase(requestType)) {
              modifyDataAssert(changeRequestId, tableData, operation);
          } else if('Business glossary'.equalsIgnoreCase(requestType)) {
              modifyArticle(changeRequestId, tableData, operation);
          }
      } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
      }
    }

    private static void modifyDataAssert(Id changeRequestId, String recsString, String opperation) {
        
        if('Add'.equalsIgnoreCase(opperation)) {
            addDataAssert(changeRequestId, recsString);
        } else if('Update'.equalsIgnoreCase(opperation)) {
            updateAndDeleteDataAssert(changeRequestId, recsString, false);
        } else if('Delete'.equalsIgnoreCase(opperation)) {
            updateAndDeleteDataAssert(changeRequestId, recsString, true);  
        }
    }

    private static void modifyArticle(Id changeRequestId, String recsString, String opperation) {
          if('Add'.equalsIgnoreCase(opperation)) {
              addArticle(changeRequestId, recsString);
          } else if('Update'.equalsIgnoreCase(opperation)) {
              updateAndDeleteArticle(changeRequestId, recsString, false);
          } else if('Delete'.equalsIgnoreCase(opperation)) {
              updateAndDeleteArticle(changeRequestId, recsString, true);  
          }
    }

    private static void addArticle(Id changeRequestId, String recsString) {
        dcmgt_Change_Request__c changeRequest = [SELECT Id, dcmgt_Alation_Glossary__c, dcmgt_Change_Request_Type__c,dcmgt_Change_Type__c
                                                    FROM dcmgt_Change_Request__c
                                                    WHERE Id = :changeRequestId];
        
        
        List<dcmgt_Alation_Article__c> listOfArticleToBeInsert = new List<dcmgt_Alation_Article__c>();
        List<dcmgt_Alation_Article__c> listOfArticle;
        
        // if('Single'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
        //     listOfArticle = 
        //       (List<dcmgt_Alation_Article__c>) JSON.deserialize(recsString, List<dcmgt_Alation_Article__c>.class);
        //     for(dcmgt_Alation_Article__c article : listOfArticle) {
        //         article.dcmgt_Change_Request__c = changeRequestId;
        //         listOfArticleToBeInsert.add(article);
        //     }
        // } else if('Bulk'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
            listOfArticleToBeInsert = getListOfAtricleByJSON(recsString, changeRequest);
        // }
        
        List<Database.SaveResult> results = Database.insert(listOfArticleToBeInsert, false) ;
        System.debug('result:- '+results);
        //insert listOfArticleToBeInsert;
        List<dcmgt_Alation_Article__c> listOfNewArticles = [SELECT Id FROM dcmgt_Alation_Article__c
                                                                WHERE dcmgt_Change_Request__c = :changeRequestId ];
        List<dcmgt_Glossary_Article__c> listOfGlossaryArticle = new List<dcmgt_Glossary_Article__c>();
        for(dcmgt_Alation_Article__c article : listOfNewArticles) {
            dcmgt_Glossary_Article__c glossaryArticle = new dcmgt_Glossary_Article__c (
                dcmgt_Alation_Article__c = article.Id,
                dcmgt_Alation_Glossary__c = changeRequest.dcmgt_Alation_Glossary__c
            );
            listOfGlossaryArticle.add(glossaryArticle);
        }
        List<Database.SaveResult> resultsForGlossary = Database.insert(listOfGlossaryArticle, false);
        System.debug('Add A:- '+resultsForGlossary);
        
    }

    // public static List<dcmgt_Alation_Article__c> getListOfAtricleByJSON(String jsonTableData, String changeRequestId, Boolean isDelete ) {
    //     List<dcmgt_Alation_Article__c> listOfArticle = new List<dcmgt_Alation_Article__c>();
    //     List<Object> listOfArticleAsAObj = (List<Object>)JSON.deserializeUntyped(jsonTableData);
    //     System.debug(listOfArticleAsAObj);
    //     dcmgt_Alation_Article__c articleInstance;
    //     Set<String> setOfDateFields = new Set<String> {
    //         'Last Review Date', 'Approval date'
    //     };
    //     Set<String> setOfUserFields = new Set<String> {
    //         'Steward', 'Business Owner'
    //     };
    //     String updatedFields;

    //     for(Object obj : listOfArticleAsAObj) {
    //         String jsonObject = Json.serialize(obj);
    //         Map<String, Object> mapOfFieldWithValue = (Map<String, Object>)JSON.deserializeUntyped(jsonObject);
    //         System.debug(mapOfFieldWithValue);
    //         Map<String, Object> mapOfOriginalArticle;
    //         if(mapOfFieldWithValue.containsKey('originalRecord')) {
    //             mapOfOriginalArticle = (Map<String, Object>)JSON.deserializeUntyped(Json.serialize(mapOfFieldWithValue.get('originalRecord')));
    //             updatedFields = '{';
    //         } 
    //         articleInstance = new dcmgt_Alation_Article__c();
            
    //         for(String key : mapOfFieldWithValue.keySet()) {
    //             System.debug('value 1:- '+mapOfFieldWithValue.get(key));
    //             if('Id'.equalsIgnoreCase(key)) {
    //                 System.debug('ID value 1:- '+''+mapOfFieldWithValue.get(key));
    //             }
                
    //             if(mapOfAliationArticleFieldsWithSFFields.containsKey(key) && 
    //                 (!('originalRecord'.equalsIgnoreCase(key) /*|| 'Id'.equalsIgnoreCase(key)*/))) {

    //                 String mapValue;
    //                 if('Id'.equalsIgnoreCase(key)) {
    //                     System.debug('ID value 1:- '+''+mapOfFieldWithValue.get(key));
    //                     mapValue = ''+mapOfFieldWithValue.get(key);
    //                     System.debug('ID value 1:- '+mapValue);
    //                 } else {
    //                     mapValue = (mapOfFieldWithValue.get(key) == null) ?
    //                         null : (String.isEmpty(mapOfFieldWithValue.get(key).toString()) ? null : mapOfFieldWithValue.get(key).toString());
    //                 }
    //                 System.debug('key:- '+key);
    //                 System.debug('mapValue:- '+mapValue);

    //                 if(mapValue == null) {
    //                     continue;
    //                 }
                    
    //                     System.debug('key 2:- '+key);
    //                 String fieldApiName = mapOfAliationArticleFieldsWithSFFields.get(key);
    //                 System.debug('fieldApiName:- '+fieldApiName);
    //                 if('Governed Flag'.equalsIgnoreCase(key)) {
    //                     mapValue = String.isBlank(mapValue) ? 'false' : mapValue;
    //                     articleInstance.put(fieldApiName, Boolean.valueOf(mapValue));
    //                 } else if('Id'.equalsIgnoreCase(key)) {
    //                     articleInstance.put(fieldApiName, Integer.valueOf(mapValue));
    //                 } else if(setOfDateFields.contains(key)) {
    //                     if(!String.isBlank(mapValue)) {
    //                         articleInstance.put(fieldApiName, Date.valueOf(mapValue));
    //                     }
    //                 } else if(setOfUserFields.contains(key)) {
    //                     if(mapOfUserByEmail.size() <= 0) {
    //                         getMapOfUserEmailAndName();
    //                     }
    //                     String jsnonData = '{';
    //                     List<String> listOfUserEmails = mapValue.split(';');
    //                     System.debug('listOfUserEmails'+listOfUserEmails);
    //                     for(String userEmailId : listOfUserEmails) {
    //                         User userInstance = mapOfUserByEmail.get(userEmailId);
    //                         if(userInstance != null) {
    //                             jsnonData = jsnonData + '"' + userInstance.Id + '":"' + userInstance.Name + '",';
    //                         }
    //                     }
    //                     jsnonData = jsnonData.removeEnd(',');
    //                     jsnonData += '}';
    //                     System.debug('listOfUserEmails'+listOfUserEmails);
    //                     // hpriya@information-asset.com;integration@example.com
    //                     articleInstance.put(fieldApiName, jsnonData);
    //                 } else {
    //                     articleInstance.put(fieldApiName, mapValue);
    //                 }
    //                 if(mapOfOriginalArticle != null) {
    //                     String orignalValue = mapOfOriginalArticle.get(key) == null ? 'null' : mapOfOriginalArticle.get(key).toString();
    //                     System.debug('orignalValue:- '+orignalValue);
    //                     if(mapValue != orignalValue) {
    //                         updatedFields = updatedFields + '"' + key + '":"' + 
    //                         orignalValue + '---' + mapValue + '" ,';
    //                     }
    //                 }
    //                 System.debug('articleInstance:- '+articleInstance);
    //             }  
    //         }
    //         if(mapOfOriginalArticle != null) {
    //             updatedFields = updatedFields.removeEnd(',');
    //             updatedFields += '}';
    //             System.debug('updatedFields:- '+updatedFields);
    //             articleInstance.dcmgt_Updates_Fields__c = updatedFields;
    //         } 
    //         if(isDelete) {
    //             articleInstance.dcmgt_Is_Active__c = false;
    //         }
    //         articleInstance.dcmgt_Change_Request__c = changeRequestId;
    //         listOfArticle.add(articleInstance);
    //         System.debug('listOfArticle:- '+listOfArticle);
    //     }
    //     return listOfArticle;
    // }

    // private static List<dcmgt_Data_Assets__c> getListOfDataAssertByJSON(String jsonTableData, String changeRequestId, Boolean isDelete ) {
    //     List<dcmgt_Data_Assets__c> listOfDataAssert = new List<dcmgt_Data_Assets__c>();
    //     List<Object> listOfDataAssertAsAObj = (List<Object>)JSON.deserializeUntyped(jsonTableData);
    //     System.debug(listOfDataAssertAsAObj);
    //     dcmgt_Data_Assets__c dataAssertInstance;
    //     Set<String> setOfUserFields = new Set<String> {
    //         'Steward', 'Business Owner'
    //     };
    //     String updatedFields;

    //     for(Object obj : listOfDataAssertAsAObj) {
    //         String jsonObject = Json.serialize(obj);
    //         Map<String, Object> mapOfFieldWithValue = (Map<String, Object>)JSON.deserializeUntyped(jsonObject);
    //         System.debug(mapOfFieldWithValue);
    //         Map<String, Object> mapOfOriginalDataAssert;
    //         if(mapOfFieldWithValue.containsKey('originalRecord')) {
    //             mapOfOriginalDataAssert = (Map<String, Object>)JSON.deserializeUntyped(Json.serialize(mapOfFieldWithValue.get('originalRecord')));
    //             updatedFields = '{';
    //         } 
    //         dataAssertInstance = new dcmgt_Data_Assets__c();
            
    //         for(String key : mapOfFieldWithValue.keySet()) {
    //             System.debug('value 1:- '+mapOfFieldWithValue.get(key));
    //             System.debug('key:- '+key);
    //             if(mapOfAliationDataAssertFieldsWithSFFields.containsKey(key) && 
    //                 (!('originalRecord'.equalsIgnoreCase(key) || 'Id'.equalsIgnoreCase(key)))) {

    //                 String mapValue = (mapOfFieldWithValue.get(key) == null) ?
    //                     null : (String.isEmpty(mapOfFieldWithValue.get(key).toString()) ? null : mapOfFieldWithValue.get(key).toString());
    //                 System.debug('key:- '+key);
    //                 System.debug('mapValue:- '+mapValue);

    //                 if(mapValue == null) {
    //                     continue;
    //                 }
                    
    //                     System.debug('key 2:- '+key);
    //                 String fieldApiName = mapOfAliationDataAssertFieldsWithSFFields.get(key);
    //                 System.debug('fieldApiName:- '+fieldApiName);
    //                 if(setOfUserFields.contains(key)) {
    //                     if(mapOfUserByEmail.size() <= 0) {
    //                         getMapOfUserEmailAndName();
    //                     }
    //                     String jsnonData = '{';
    //                     List<String> listOfUserEmails = mapValue.split(';');
    //                     System.debug('listOfUserEmails'+listOfUserEmails);
    //                     for(String userEmailId : listOfUserEmails) {
    //                         User userInstance = mapOfUserByEmail.get(userEmailId);
    //                         if(userInstance != null) {
    //                             jsnonData = jsnonData + '"' + userInstance.Id + '":"' + userInstance.Name + '",';
    //                         }
    //                     }
    //                     jsnonData = jsnonData.removeEnd(',');
    //                     jsnonData += '}';
    //                     System.debug('listOfUserEmails'+listOfUserEmails);
    //                     // hpriya@information-asset.com;integration@example.com
    //                     dataAssertInstance.put(fieldApiName, jsnonData);
    //                 } else {
    //                     dataAssertInstance.put(fieldApiName, mapValue);
    //                 }
    //                 if(mapOfOriginalDataAssert != null) {
    //                     String orignalValue = mapOfOriginalDataAssert.get(key) == null ? 'null' : mapOfOriginalDataAssert.get(key).toString();
    //                     System.debug('orignalValue:- '+orignalValue);
    //                     if(mapValue != orignalValue) {
    //                         updatedFields = updatedFields + '"' + key + '":"' + 
    //                         orignalValue + '---' + mapValue + '" ,';
    //                     }
    //                 }
    //                 System.debug('dataAssertInstance:- '+dataAssertInstance);
    //             }  
    //         }
    //         if(mapOfOriginalDataAssert != null) {
    //             updatedFields = updatedFields.removeEnd(',');
    //             updatedFields += '}';
    //             System.debug('updatedFields:- '+updatedFields);
    //             dataAssertInstance.dcmgt_Updated_Fields__c = updatedFields;
    //         } 
    //         if(isDelete) {
    //             dataAssertInstance.dcmgt_IsActive__c = false;
    //         }
    //         dataAssertInstance.dcmgt_Change_Request__c = changeRequestId;
    //         listOfDataAssert.add(dataAssertInstance);
    //         System.debug('listOfDataAssert:- '+listOfDataAssert);
    //     }
    //     return listOfDataAssert;
    // }

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
                for(String key : mapOfFieldWithValue.keySet()) {
                    if(setOfTempLookupFields.contains(key) || key.endsWithIgnoreCase('__r')) {
                        continue;
                    }
                    String mapValue = mapOfFieldWithValue.get(key).toString();
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
                for(String key : mapOfFieldWithValue.keySet()) {
                    if(setOfTempLookupFields.contains(key) || key.endsWithIgnoreCase('__r')) {
                        continue;
                    }
                    String mapValue = mapOfFieldWithValue.get(key).toString();
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

    // private static void updateAndDeleteDataAssert(Id changeRequestId, String recsString, Boolean isDelete) {
    //     List<dcmgt_Data_Assets__c> listOfDataAssertToBeInsert = getListOfDataAssertByJSON(recsString, changeRequestId, isDelete);
    //     List<Database.SaveResult> results = Database.insert(listOfDataAssertToBeInsert, false) ;
    //     System.debug('U&D DA:-'+results);
    // }

    private static void updateAndDeleteArticle(Id changeRequestId, String recsString, Boolean isDelete) {
        dcmgt_Change_Request__c changeRequest = [SELECT Id, dcmgt_Alation_Glossary__c, dcmgt_Change_Request_Type__c, dcmgt_Change_Type__c
                                                    FROM dcmgt_Change_Request__c
                                                    WHERE Id = :changeRequestId];
        
        List<dcmgt_Alation_Article__c> listOfArticle;
        
        // if('Single'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c) || isDelete){
        //     listOfArticle = 
        //       (List<dcmgt_Alation_Article__c>) JSON.deserialize(recsString, List<dcmgt_Alation_Article__c>.class); 
        // } else if('Bulk'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
            listOfArticle = getListOfAtricleByJSON(recsString, changeRequest);
        // }
        // Map<Id, dcmgt_Alation_Article__c> mapOfOrignalArticle;
        // if(!isDelete) {
        //     mapOfOrignalArticle = new Map<Id, dcmgt_Alation_Article__c>(
        //         [SELECT Id, dcmgt_Data_Steward__c, dcmgt_Data_Owner__c FROM 
        //             dcmgt_Alation_Article__c WHERE Id IN :listOfArticle]);
        // }
        List<dcmgt_Alation_Article__c> listOfArticleToBeUpdate = new List<dcmgt_Alation_Article__c>();
        for(dcmgt_Alation_Article__c article : listOfArticle) {
            dcmgt_Alation_Article__c newArticle = article.clone();
            newArticle.dcmgt_Change_Request__c = changeRequestId;
            newArticle.dcmgt_Staged_Alation_Article__c = article.Id;
            newArticle.dcmgt_External_ID__c = null;
            newArticle.dcmgt_Alation_Id__c = null;
            if(isDelete) {
              newArticle.dcmgt_Is_Active__c = false;
            } 
            // else if(mapOfOrignalArticle.containsKey(article.Id)) {
            //     if(newArticle.dcmgt_Data_Steward__c == null) {
            //         newArticle.dcmgt_Data_Steward__c = 
            //             mapOfOrignalArticle.get(article.Id).dcmgt_Data_Steward__c;
            //     }
            //     if(newArticle.dcmgt_Data_Owner__c == null) {
            //         newArticle.dcmgt_Data_Owner__c =
            //             mapOfOrignalArticle.get(article.Id).dcmgt_Data_Owner__c;
            //     }
            // }
            listOfArticleToBeUpdate.add(newArticle);
        }
        List<Database.SaveResult> results = Database.insert(listOfArticleToBeUpdate, false) ;
        System.debug('U&D A:-'+results);
    }

    private static void addDataAssert(Id changeRequestId, String recsString) {
        dcmgt_Change_Request__c changeRequest = [SELECT Id, dcmgt_Alation_Data_Dictionary__c, dcmgt_Change_Request_Type__c,
                                                    dcmgt_Change_Type__c
                                                    FROM dcmgt_Change_Request__c
                                                    WHERE Id = :changeRequestId];
        
        
        List<dcmgt_Data_Assets__c> listOfDataAssertToBeInsert = new List<dcmgt_Data_Assets__c>();
        List<dcmgt_Data_Assets__c> listOfDataAssert;
        
        // if('Single'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
        //     listOfDataAssert = 
        //       (List<dcmgt_Data_Assets__c>) JSON.deserialize(recsString, List<dcmgt_Data_Assets__c>.class);
        //     for(dcmgt_Data_Assets__c dataAssert : listOfDataAssert) {
        //         dataAssert.dcmgt_Change_Request__c = changeRequestId;
        //         listOfDataAssertToBeInsert.add(dataAssert);
        //     }
        // } else if('Bulk'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
            listOfDataAssertToBeInsert = getListOfDataAssertByJSON(recsString, changeRequest);
        // }
        List<Database.SaveResult> results = Database.insert(listOfDataAssertToBeInsert, false) ;
        System.debug('Add DA:-'+results);
        //insert listOfDataAssertToBeInsert;
    }

    
    private static void updateAndDeleteDataAssert(Id changeRequestId, String recsString, Boolean isDelete) {
        dcmgt_Change_Request__c changeRequest = [SELECT Id, dcmgt_Alation_Data_Dictionary__c, dcmgt_Change_Request_Type__c,dcmgt_Change_Type__c
                                                    FROM dcmgt_Change_Request__c
                                                    WHERE Id = :changeRequestId];
        
        List<dcmgt_Data_Assets__c> listOfDataAssert;
        
        // if('Single'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c) || isDelete){
        //     listOfDataAssert = 
        //       (List<dcmgt_Data_Assets__c>) JSON.deserialize(recsString, List<dcmgt_Data_Assets__c>.class); 
        // } else if('Bulk'.equalsIgnoreCase(changeRequest.dcmgt_Change_Request_Type__c)){
            listOfDataAssert = getListOfDataAssertByJSON(recsString, changeRequest);
        // }
        Map<Id, dcmgt_Data_Assets__c> mapOfOrignalDataAssert;
        if(!isDelete) {
            mapOfOrignalDataAssert = new Map<Id, dcmgt_Data_Assets__c>(
                [SELECT Id, dcmgt_Data_Steward__c, dcmgt_Service_Owner__c FROM 
                dcmgt_Data_Assets__c WHERE Id IN :listOfDataAssert]);
        }
        List<dcmgt_Data_Assets__c> listOfDataAssertToBeUpdate = new List<dcmgt_Data_Assets__c>();
        for(dcmgt_Data_Assets__c dataAssert : listOfDataAssert) {
            dcmgt_Data_Assets__c newDataAssert = dataAssert.clone();
            newDataAssert.dcmgt_Change_Request__c = changeRequestId;
            newDataAssert.dcmgt_Staged_Data_Assets__c = dataAssert.Id;
            newDataAssert.dcmgt_External_Id__c = null;
            newDataAssert.dcmgt_Alation_Id__c = null;
            if(isDelete) {
                newDataAssert.dcmgt_IsActive__c = false;
            } else if(mapOfOrignalDataAssert.containsKey(dataAssert.Id)) {
                if(newDataAssert.dcmgt_Data_Steward__c == null) {
                    newDataAssert.dcmgt_Data_Steward__c = 
                        mapOfOrignalDataAssert.get(dataAssert.Id).dcmgt_Data_Steward__c;
                }
                if(newDataAssert.dcmgt_Service_Owner__c == null) {
                    newDataAssert.dcmgt_Service_Owner__c =
                        mapOfOrignalDataAssert.get(dataAssert.Id).dcmgt_Service_Owner__c;
                }
            }
            listOfDataAssertToBeUpdate.add(newDataAssert);
        }
        List<Database.SaveResult> results = Database.insert(listOfDataAssertToBeUpdate, false) ;
        System.debug('U&D DA:-'+results);
        //insert listOfDataAssertToBeUpdate;
    }

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
          [SELECT Id, Name, dcmgt_Full_name__c, dcmgt_Type__c, dcmgt_Description__c, 
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