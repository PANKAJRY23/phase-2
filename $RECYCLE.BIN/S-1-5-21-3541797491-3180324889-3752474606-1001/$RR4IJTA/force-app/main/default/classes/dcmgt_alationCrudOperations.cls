public with sharing class dcmgt_alationCrudOperations implements Database.Batchable<sObject> {
    
    Public static final String TOKEN = dcmgt_alation_token_management.createAPIAccessToken();
    
    public Database.QueryLocator start(Database.BatchableContext bc)
    {
        String Query = 'Select id from dcmgt_Alation_Article__c where dcmgt_Change_Request__c  != null AND dcmgt_Status__c=\'Approved\'';
    	return Database.getQueryLocator(Query);
     }
    
    public void execute(Database.BatchableContext bc, List<dcmgt_Alation_Article__c> alationarticles)
    {
         
     try{ //
         List<dcmgt_Alation_Article__c> alationarticleslist = [Select id,Name,dcmgt_Description__c,dcmgt_Multi_Subject_Area__c,dcmgt_Alation_Id__c,dcmgt_Life_Cycle_Status__c,dcmgt_Alation_Articles__c,dcmgt_Term_Type__c,dcmgt_Classification__c,dcmgt_Last_Review_Date__c,dcmgt_Data_Owners__c,dcmgt_DataStewards__c,dcmgt_Status__c,dcmgt_Alation_Data_Dictionary_Name__c,dcmgt_Governed_Flag__c,dcmgt_Approval_Comment_Check__c,dcmgt_NextApproverRequired__c,dcmgt_Approval_date__c,dcmgt_Is_Active__c,dcmgt_Acronynm_Synonym__c,dcmgt_Staged_Alation_Article__c, dcmgt_Change_Request__c,dcmgt_Change_Request__r.dcmgt_Change_Request_Type__c, dcmgt_Change_Request__r.dcmgt_Change_Type__c from dcmgt_Alation_Article__c where id in:alationarticles];
         dcmgt_Alation_Settings__mdt alationSetting=[Select dcmgt_Alation_Base_Endpoint_URL__c from dcmgt_Alation_Settings__mdt LIMIT 1];
         Map<Id,User> userMap=new Map<Id,User>([Select Id,Email from User]);
         for(dcmgt_Alation_Article__c arctileRec : alationarticleslist)
           { 
             //If Block for Updation and Creation of Articles
              if((arctileRec.dcmgt_Change_Request__r.dcmgt_Change_Type__c == 'Update')&&(arctileRec.dcmgt_Approval_date__c == date.today())||((arctileRec.dcmgt_Change_Request__r.dcmgt_Change_Type__c == 'Add')&&(arctileRec.dcmgt_Approval_date__c == date.today())))
               { 
                   String result = '';
                   Map<String,Object> postMap=new Map<String,Object>();
                   postMap.put('key',arctileRec.Name);
                   if(arctileRec.dcmgt_Description__c!=null){
                     postMap.put('description',arctileRec.dcmgt_Description__c); 
                   }
                   if(arctileRec.dcmgt_Approval_date__c!=null)
                   {
                        postMap.put('APPROVAL DATE',arctileRec.dcmgt_Approval_date__c);
                   }
                   if(arctileRec.dcmgt_Governed_Flag__c)
                   {
                       postMap.put('GOVERNED FLAG','Yes');
                   }else if(arctileRec.dcmgt_Governed_Flag__c == false)
                   {
                       postMap.put('GOVERNED FLAG','No');
                   }
                   if(arctileRec.dcmgt_Last_Review_Date__c!=null)
                   {
                       postMap.put('LAST REVIEW DATE',arctileRec.dcmgt_Last_Review_Date__c);
                   }
                   if(arctileRec.dcmgt_Life_Cycle_Status__c!=null)
                   {
                       postMap.put('LIFE CYCLE STATUS',arctileRec.dcmgt_Life_Cycle_Status__c);  
                   }
                   if(arctileRec.dcmgt_Multi_Subject_Area__c!=null)
                   {
						 String listSubjectArea = arctileRec.dcmgt_Multi_Subject_Area__c.replace(';',',');
                        System.debug(listSubjectArea);
                        List<String> subArea = listSubjectArea.split(',');
                        postMap.put('Subject Area',subArea);
                   }
                  if(arctileRec.dcmgt_Acronynm_Synonym__c!=null)
                  {
                       postMap.put('Acronym / Synonym',arctileRec.dcmgt_Acronynm_Synonym__c);
                  }
                  if(arctileRec.dcmgt_Classification__c!=null)
                  {
                      postMap.put('Classification',arctileRec.dcmgt_Classification__c);
                  }
                  if(arctileRec.dcmgt_Term_Type__c!=null)
                  {
                       postMap.put('TERM TYPE',arctileRec.dcmgt_Term_Type__c);
                  }
                  if(arctileRec.dcmgt_Data_Owners__c!=null)
                  { 
                    List<Map<String,String>> dataOwnersList=new List<Map<String,String>>();
                    Map<String,String> dataOwnersMap = (Map<String,String>)JSON.deserialize((arctileRec.dcmgt_Data_Owners__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                    List<String> userIds=new List<String>(dataOwnersMap.keyset());
                    for(String userID:userIds)
                    {
                         User user=userMap.get(userID);
                         Map<String,String> dataOwnerJsonMap=new Map<String,String>();
                         dataOwnerJsonMap.put('type','user');
                         dataOwnerJsonMap.put('key',user.Email);
                         dataOwnersList.add(dataOwnerJsonMap);                    
                    }
                     //postMap.put('Business Owner',dataOwnersList);
                     postMap.put('Data Owner',dataOwnersList);  
                  }
                  if(arctileRec.dcmgt_Alation_Data_Dictionary_Name__c!=null)
                  {
                      //postMap.put('datadictionary',arctileRec.dcmgt_Alation_Data_Dictionary_Name__c);
                  }
                  if(arctileRec.dcmgt_DataStewards__c!=null)
                  {
                    List<Map<String,String>> stewardList=new List<Map<String,String>>();
                    Map<String,String> stewardMap = (Map<String,String>)JSON.deserialize((arctileRec.dcmgt_DataStewards__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                    List<String> userIds=new List<String>(stewardMap.keyset());
                    for(String userID:userIds)
                    {
                         User user=userMap.get(userID);
                         Map<String,String> stewardJsonMap=new Map<String,String>();
                         stewardJsonMap.put('type','user');
                         stewardJsonMap.put('key',user.Email);
                         stewardList.add(stewardJsonMap);                    
                    }
                     //postMap.put('Steward',stewardList);
                     postMap.put('Data Steward',stewardList);
                     	
                     //Updating the Status to Complete
                     	arctileRec.dcmgt_Status__c = 'Completed';
                		update arctileRec;       
                      
                      
                  }  
                   String body=JSON.serialize(postMap);
                   dcmgt_Glossary_Article__c glossary_article=[Select dcmgt_Alation_Glossary__r.Name from dcmgt_Glossary_Article__c where dcmgt_Alation_Article__c = :arctileRec.dcmgt_Staged_Alation_Article__c];
				   dcmgt_Alation_Glossary__c alation_glossary=glossary_article.dcmgt_Alation_Glossary__r;
                   String Glossaries = (alation_glossary.Name).replace(' ','%20');	
                   if(alationSetting!=null)
                   {
                       HttpRequest req = new HttpRequest();
                       //Update Article API
                       req.setEndpoint(alationSetting.dcmgt_Alation_Base_Endpoint_URL__c+'/api/v1/bulk_metadata/custom_fields/'+Glossaries+'/article?replace_values=true');
                       req.setMethod('POST');
                       req.setHeader('Content-Type','application/json');
                       req.setHeader('Token', TOKEN); 
                       req.setBodyAsBlob(Blob.valueOf(body));
                       req.setTimeout(30000);
                       Http http = new Http();
                       HttpResponse response = http.send(req);
                      if(response.getStatusCode()==200)
                       { 
                          String returnValue = String.valueOf(response.getStatusCode());
                          result = response.getBody();
                          System.debug('Response '+returnValue);
                          System.debug(result);
                          System.debug(returnValue);
                       }else{
                           CalloutException execption = new CalloutException();
                             execption.setMessage(getErrorMessage(response.getStatusCode()));
                             throw execption;
                       }
                   }  
            }
    
            //If block for Delete Operation for making isActive False
            if((arctileRec.dcmgt_Change_Request__r.dcmgt_Change_Type__c == 'Delete')&&(arctileRec.dcmgt_Approval_date__c == date.today()))
            { 
                arctileRec.dcmgt_Is_Active__c = false;
                update arctileRec;
            }
         }
        }catch(System.CalloutException ex) 
                   {
                        System.debug('The following exception has occurred: ' + ex.getMessage());
                   }
                   catch(Exception ex) 
                   {
                       System.debug('The following exception has occurred: ' + ex.getMessage());
                   }    
    }
    
    public void finish(Database.BatchableContext bc)
    {
        
    }
    
   
    public static String getErrorMessage(Integer statusCode)
    {
        String errorMessage='';
        if(statusCode==500)
        {
          errorMessage='Error Code:'+statusCode+'-Internal Server Error,Unexpected error while processing request, try again later';   
        }
        else if(statusCode==503)
        {
          errorMessage='Error Code:'+statusCode+'-Service Unavailable,Cannot reach service, try again later';   
        }
        else if(statusCode>=400)
        {
            errorMessage='Error Code:'+statusCode+'-Bad Request,Improperly formatted request, review request and try again';
        }
        return errorMessage;
    }

}