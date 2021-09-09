public with sharing class dcmgt_alation_dataAsset_batchUpdate  implements Database.Batchable<sObject>{
    
  Public static final String TOKEN = dcmgt_alation_token_management.createAPIAccessToken(); 
  public Database.QueryLocator start(Database.BatchableContext bc)
  {
      String Query = 'Select id from dcmgt_Data_Assets__c where dcmgt_Change_Request__c  != null AND dcmgt_Status__c=\'Approved\'';
    return Database.getQueryLocator(Query);
   }
  
  public void execute(Database.BatchableContext bc, List<dcmgt_Data_Assets__c> alationdataassets)
  {
     //To fetch Alation host
      try{
          dcmgt_Alation_Settings__mdt alationSetting=[Select dcmgt_Alation_Base_Endpoint_URL__c from dcmgt_Alation_Settings__mdt LIMIT 1];        
          List<dcmgt_Data_Assets__c> alationdataassetslist = [Select id,Name,dcmgt_Alation_Id__c,dcmgt_Approval_date__c,dcmgt_Business_Process__c,dcmgt_Business_Rules__c,dcmgt_Data_Assets_Name__c,dcmgt_Data_category__c,dcmgt_Data_Classification__c,dcmgt_Data_Consumer__c,dcmgt_Data_Dictionary_Field__c,dcmgt_Data_Dictionary_Name__c,dcmgt_Data_Steward__c,dcmgt_Description__c,dcmgt_Dimensions__c,dcmgt_External_Id__c,dcmgt_Full_name__c,dcmgt_Indication_Metric__c,dcmgt_IsActive__c,dcmgt_IsApproved__c,dcmgt_Locked_Fields__c,dcmgt_NextApproverRequired__c,dcmgt_Public_Schema_Visibility__c,dcmgt_Refresh_Frequency__c,dcmgt_Schema_Name__c,dcmgt_Service_Owners__c,dcmgt_Status__c,dcmgt_Subject_Area__c,dcmgt_Tenant__c,dcmgt_Type__c,dcmgt_Updated_Fields__c,dcmgt_Value_Update__c,dcmgt_Derived_logic_Business_Calculation__c,dcmgt_Data_Retention__c,dcmgt_Business_Owners__c,dcmgt_Data_Stewards__c,dcmgt_Big_ID_URL__c from dcmgt_Data_Assets__c where id in : alationdataassets];        
          Map<Id,User> userMap=new Map<Id,User>([Select Id,Email from User]);
          for(dcmgt_Data_Assets__c dataassetRec : alationdataassetslist)
         {
             if((dataassetRec.dcmgt_Change_Request__r.dcmgt_Change_Type__c == 'Update')&&(dataassetRec.dcmgt_Approval_date__c == date.today())||((dataassetRec.dcmgt_Change_Request__r.dcmgt_Change_Type__c == 'Add')&&(dataassetRec.dcmgt_Approval_date__c == date.today())))
            { 
             Integer dsID; 
             HttpResponse dsresponse = invokeGetRestAPI(alationSetting.dcmgt_Alation_Base_Endpoint_URL__c+'/catalog/table/?schema_name='+dataassetRec.dcmgt_Schema_Name__c,token) ;
      List<Object> dsResults = (List<Object>) JSON.deserializeUntyped(dsresponse.getBody());
      for (Object dsJsonNode:dsResults)
              {   
                 Map<String,Object> dsResult=(Map<String,Object>)dsJsonNode;                              
                 dsID = (Integer)dsResult.get('ds_id');
                 break;
               }
             if(dataassetRec.dcmgt_Type__c == 'Table')
             {
                Map<String,Object> postMap=new Map<String,Object>();
                 postMap.put('key',dsID.format()+'.'+dataassetRec.dcmgt_Schema_Name__c+'.'+dataassetRec.Name);
                 if(dataassetRec.dcmgt_Description__c!=null)
                 {
                      postMap.put('description',dataassetRec.dcmgt_Description__c);
                 }
         if(dataassetRec.dcmgt_Business_Process__c!=null)
                 {
                       postMap.put('Business Process',dataassetRec.dcmgt_Business_Process__c);
                 }
         if(dataassetRec.dcmgt_Business_Rules__c!=null)
                 {
                     postMap.put('Business Rules',dataassetRec.dcmgt_Business_Rules__c);
                 }
                 if(dataassetRec.dcmgt_Data_category__c!=null)
                 {
                    postMap.put('Data Category',dataassetRec.dcmgt_Data_category__c);  
                 }
                 if(dataassetRec.dcmgt_Data_Consumer__c!=null)
        { 
                      List<Map<String,String>> dataConsumerList=new List<Map<String,String>>();
                      List<String> userIds=(dataassetRec.dcmgt_Data_Consumer__c).split(',');
                      for(String userID:userIds)
                     {
                       User user=userMap.get(userID);
                       Map<String,String> dataConsumerJsonMap=new Map<String,String>();
                       dataConsumerJsonMap.put('type','user');
                       dataConsumerJsonMap.put('key',user.Email);
                       dataConsumerList.add(dataConsumerJsonMap);                    
                      }
                       postMap.put('Data Consumer',dataConsumerList);
        }
                 if(dataassetRec.dcmgt_Data_Dictionary_Name__c!=null)
                   {
                       postMap.put('Data Dictionary',dataassetRec.dcmgt_Data_Dictionary_Name__c);
                   }
                  if(dataassetRec.dcmgt_Derived_logic_Business_Calculation__c!=null)
                   {
                       postMap.put('Business Calculation',dataassetRec.dcmgt_Derived_logic_Business_Calculation__c);
                   }
                  if(dataassetRec.dcmgt_Dimensions__c!=null)
                   {
                        postMap.put('Dimensions',dataassetRec.dcmgt_Dimensions__c);
                   }
                  if(dataassetRec.dcmgt_Indication_Metric__c!=null)
                   {
                       postMap.put('Indication Metric',dataassetRec.dcmgt_Indication_Metric__c);
                   }
                  if(dataassetRec.dcmgt_Refresh_Frequency__c!=null)
                  { 
                    postMap.put('Refresh Frequency',dataassetRec.dcmgt_Refresh_Frequency__c);        
                  }
                  if(dataassetRec.dcmgt_Data_Retention__c!=null)
                 {
                    postMap.put('Data Retention',dataassetRec.dcmgt_Data_Retention__c);
                 }
                //  if(dataassetRec.dcmgt_Business_Owners__c!=null)
                //  {
                //       List<Map<String,String>> dataOwnersList=new List<Map<String,String>>();
                //   Map<String,String> dataOwnersMap = (Map<String,String>)JSON.deserialize((dataassetRec.dcmgt_Business_Owners__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                //   List<String> userIds=new List<String>(dataOwnersMap.keyset());
                //   for(String userID:userIds)
                //   {
                //        User user=userMap.get(userID);
                //        Map<String,String> dataOwnerJsonMap=new Map<String,String>();
                //        dataOwnerJsonMap.put('type','user');
                //        dataOwnerJsonMap.put('key',user.Email);
                //        dataOwnersList.add(dataOwnerJsonMap);                    
                //   }
                //   //  postMap.put('Business Owner',dataOwnersList); 
                //     postMap.put('Data Owner',dataOwnersList); 
                //  }
                 if(dataassetRec.dcmgt_Data_Stewards__c!=null)
                 {
                     List<Map<String,String>> stewardList=new List<Map<String,String>>();
                      Map<String,String> stewardMap = (Map<String,String>)JSON.deserialize((dataassetRec.dcmgt_Data_Stewards__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
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
                 
                 }			   
                 if(dataassetRec.dcmgt_Subject_Area__c!=null)
                 {
					  String listSubjectArea = dataassetRec.dcmgt_Subject_Area__c.replace(';',',');
                        System.debug(listSubjectArea);
                        List<String> subArea = listSubjectArea.split(',');
                        postMap.put('Subject Area',subArea);    
                 }
         if(dataassetRec.dcmgt_Value_Update__c!=null)
                   {
                        postMap.put('Value Update',dataassetRec.dcmgt_Value_Update__c); 
                   }
         if(dataassetRec.dcmgt_Tenant__c!=null)
                 {
                    List<Map<String,String>> tenantList=new List<Map<String,String>>();
                     //Map<String,String> stewardMap = (Map<String,String>)JSON.deserialize((dataassetRec.dcmgt_Data_Stewards__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                     List<String> userIds=(dataassetRec.dcmgt_Tenant__c).split(',');
                      for(String userID:userIds)
                     {
                       User user=userMap.get(userID);
                       Map<String,String> tenantJsonMap=new Map<String,String>();
                       tenantJsonMap.put('type','user');
                       tenantJsonMap.put('key',user.Email);
                       tenantList.add(tenantJsonMap);                    
                      }
                       postMap.put('Tenant',tenantList);
                 }
                 if(dataassetRec.dcmgt_Type__c!=null)
                 {
                      postMap.put('Data Asset Type',dataassetRec.dcmgt_Type__c);
                 }                  
                
                 /*if(dataassetRec.dcmgt_Data_Attributes__c!=null)
                 {
                     //postMap.put('Data Attributes',dataassetRec.dcmgt_Data_Attributes__c);
                 }*/
                 if(dataassetRec.dcmgt_Service_Owners__c!=null)
                 {
                     List<Map<String,String>> serviceOwnerList=new List<Map<String,String>>();
                     Map<String,String> serviceOwnerMap = (Map<String,String>)JSON.deserialize((dataassetRec.dcmgt_Service_Owners__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                     List<String> userIds=new List<String>(serviceOwnerMap.keyset());
                     System.debug(userIds);
                      for(String userID:userIds)
                     {
                       User user=userMap.get(userID);
                       Map<String,String> serviceOwnerJsonMap=new Map<String,String>();
                       serviceOwnerJsonMap.put('type','user');
                       serviceOwnerJsonMap.put('key',user.Email);
                       serviceOwnerList.add(serviceOwnerJsonMap);                    
                      }
                       //postMap.put('Service  Owner',serviceOwnerList);
                       postMap.put('Data Owner',serviceOwnerList);
                     
                 }
                 String body=JSON.serialize(postMap);
                 
                if(alationSetting!=null)
                 {         
                     HttpRequest req = new HttpRequest();
                     //Create Article API
                     req.setEndpoint(alationSetting.dcmgt_Alation_Base_Endpoint_URL__c+'/api/v1/bulk_metadata/custom_fields/default/table?replace_values=true');
                     req.setMethod('POST');
                     req.setHeader('Content-Type','application/json');
                     req.setHeader('Token', TOKEN);
                     req.setBodyAsBlob(Blob.valueOf(body));
                     //req.setBodyAsBlob(body);
                     req.setTimeout(30000);
                     Http http = new Http();
                     HttpResponse response = http.send(req);
                    if(response.getStatusCode()==200)
                     { 
                        String returnValue = String.valueOf(response.getStatusCode());
                        String result = response.getBody();
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
               else if(dataassetRec.dcmgt_Type__c == 'Column')
               {
                   Map<String,Object> postMap=new Map<String,Object>();
                   String attributeName = dataassetRec.dcmgt_Full_name__c.substringAfter('.');
                   System.debug(attributeName);
                   postMap.put('key',dsID+'.'+attributeName);
                   if(dataassetRec.dcmgt_Description__c!=null)
                   {
                       postMap.put('description',dataassetRec.dcmgt_Description__c);
                   }
                   if(dataassetRec.dcmgt_Business_Process__c!=null)
                 {
                       postMap.put('Business Process',dataassetRec.dcmgt_Business_Process__c);
                 }
         if(dataassetRec.dcmgt_Business_Rules__c!=null)
                 {
                     postMap.put('Business Rules',dataassetRec.dcmgt_Business_Rules__c);
                 }
                 if(dataassetRec.dcmgt_Data_category__c!=null)
                 {
                    postMap.put('Data Category',dataassetRec.dcmgt_Data_category__c);  
                 }
                 if(dataassetRec.dcmgt_Data_Consumer__c!=null)
        { 
                      List<Map<String,String>> dataConsumerList=new List<Map<String,String>>();
                      List<String> userIds=(dataassetRec.dcmgt_Data_Consumer__c).split(',');
                      for(String userID:userIds)
                     {
                       User user=userMap.get(userID);
                       Map<String,String> dataConsumerJsonMap=new Map<String,String>();
                       dataConsumerJsonMap.put('type','user');
                       dataConsumerJsonMap.put('key',user.Email);
                       dataConsumerList.add(dataConsumerJsonMap);                    
                      }
                       postMap.put('Data Consumer',dataConsumerList);
        }
                 if(dataassetRec.dcmgt_Data_Dictionary_Name__c!=null)
                   {
                       postMap.put('Data Dictionary',dataassetRec.dcmgt_Data_Dictionary_Name__c);
                   }
                  if(dataassetRec.dcmgt_Derived_logic_Business_Calculation__c!=null)
                   {
                       postMap.put('Business Calculation',dataassetRec.dcmgt_Derived_logic_Business_Calculation__c);
                   }
                  if(dataassetRec.dcmgt_Dimensions__c!=null)
                   {
                        postMap.put('Dimensions',dataassetRec.dcmgt_Dimensions__c);
                   }
                  if(dataassetRec.dcmgt_Indication_Metric__c!=null)
                   {
                       postMap.put('Indication Metric',dataassetRec.dcmgt_Indication_Metric__c);
                   }
                  if(dataassetRec.dcmgt_Refresh_Frequency__c!=null)
                  { 
                    postMap.put('Refresh Frequency',dataassetRec.dcmgt_Refresh_Frequency__c);        
                  }
                  if(dataassetRec.dcmgt_Data_Retention__c!=null)
                 {
                    postMap.put('Data Retention',dataassetRec.dcmgt_Data_Retention__c);
                 }
                //  if(dataassetRec.dcmgt_Business_Owners__c!=null)
                //  {
                //       List<Map<String,String>> dataOwnersList=new List<Map<String,String>>();
                //   Map<String,String> dataOwnersMap = (Map<String,String>)JSON.deserialize((dataassetRec.dcmgt_Business_Owners__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                //   List<String> userIds=new List<String>(dataOwnersMap.keyset());
                //   for(String userID:userIds)
                //   {
                //        User user=userMap.get(userID);
                //        Map<String,String> dataOwnerJsonMap=new Map<String,String>();
                //        dataOwnerJsonMap.put('type','user');
                //        dataOwnerJsonMap.put('key',user.Email);
                //        dataOwnersList.add(dataOwnerJsonMap);                    
                //   }
                //   //  postMap.put('Business Owner',dataOwnersList); 
                //     postMap.put('Data Owner',dataOwnersList);
                //  }
                if(dataassetRec.dcmgt_Service_Owners__c!=null)
                 {
                     List<Map<String,String>> serviceOwnerList=new List<Map<String,String>>();
                     Map<String,String> serviceOwnerMap = (Map<String,String>)JSON.deserialize((dataassetRec.dcmgt_Service_Owners__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                     List<String> userIds=new List<String>(serviceOwnerMap.keyset());
                     System.debug(userIds);
                      for(String userID:userIds)
                     {
                       User user=userMap.get(userID);
                       Map<String,String> serviceOwnerJsonMap=new Map<String,String>();
                       serviceOwnerJsonMap.put('type','user');
                       serviceOwnerJsonMap.put('key',user.Email);
                       serviceOwnerList.add(serviceOwnerJsonMap);                    
                      }
                       //postMap.put('Service  Owner',serviceOwnerList);
                       postMap.put('Data Owner',serviceOwnerList);
                     
                 }
                 if(dataassetRec.dcmgt_Data_Stewards__c!=null)
                 {
                     List<Map<String,String>> stewardList=new List<Map<String,String>>();
                      Map<String,String> stewardMap = (Map<String,String>)JSON.deserialize((dataassetRec.dcmgt_Data_Stewards__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
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
                 
                 }			   
                 if(dataassetRec.dcmgt_Subject_Area__c!=null)
                 {
				 
					  String listSubjectArea = dataassetRec.dcmgt_Subject_Area__c.replace(';',',');
                        System.debug(listSubjectArea);
                        List<String> subArea = listSubjectArea.split(',');
                        postMap.put('Subject Area',subArea);
                 }
         if(dataassetRec.dcmgt_Value_Update__c!=null)
                   {
                        postMap.put('Value Update',dataassetRec.dcmgt_Value_Update__c); 
                   }
         if(dataassetRec.dcmgt_Tenant__c!=null)
                 {
                    List<Map<String,String>> tenantList=new List<Map<String,String>>();
                     //Map<String,String> stewardMap = (Map<String,String>)JSON.deserialize((dataassetRec.dcmgt_Data_Stewards__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                     List<String> userIds=(dataassetRec.dcmgt_Tenant__c).split(',');
                      for(String userID:userIds)
                     {
                       User user=userMap.get(userID);
                       Map<String,String> tenantJsonMap=new Map<String,String>();
                       tenantJsonMap.put('type','user');
                       tenantJsonMap.put('key',user.Email);
                       tenantList.add(tenantJsonMap);                    
                      }
                       postMap.put('Tenant',tenantList);
                 }
                 if(dataassetRec.dcmgt_Type__c!=null)
                 {
                      postMap.put('Data Asset Type',dataassetRec.dcmgt_Type__c);
                 } 
                 

           String body=JSON.serialize(postMap);
          
        if(alationSetting!=null)
         {    
          
     HttpRequest req = new HttpRequest();
          
            req.setEndpoint(alationSetting.dcmgt_Alation_Base_Endpoint_URL__c+'/api/v1/bulk_metadata/custom_fields/default/attribute?replace_values=true');
            req.setMethod('POST');
            req.setHeader('Content-Type','application/json');
            req.setHeader('Token',TOKEN);
           req.setBodyAsBlob(Blob.valueOf(body));
           //req.setBodyAsBlob(body);
           req.setTimeout(30000);
           Http http = new Http();
           HttpResponse response = http.send(req);
           if(response.getStatusCode()==200)
                     { 
                        String returnValue = String.valueOf(response.getStatusCode());
                        String result = response.getBody();
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
                      
       }
          //If block for Delete Operation for making isActive False
          if((dataassetRec.dcmgt_Change_Request__r.dcmgt_Change_Type__c == 'Delete')&&(dataassetRec.dcmgt_Approval_date__c == date.today()))
          { 
              dataassetRec.dcmgt_IsActive__c = false;
              update dataassetRec;
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
  
      public static HttpResponse invokeGetRestAPI(String url,String token)
    {
         HttpRequest req = new HttpRequest();
         req.setEndpoint(url);
         req.setMethod('GET');
         req.setHeader('Token', token);
         req.setTimeout(30000);
         Http http = new Http();
         HttpResponse response = http.send(req);
         return response;   
    }
  

}