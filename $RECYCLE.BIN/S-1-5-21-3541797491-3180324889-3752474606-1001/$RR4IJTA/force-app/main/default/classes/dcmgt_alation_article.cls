public class dcmgt_alation_article_management {

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
  
  @AuraEnabled
  public static String getCustomFieldsValueSet()
  {
      Map<String,Object> customFieldFinalResponseMap=new Map<String,Object>();
      try{
          //To fetch Alation host
          dcmgt_Alation_Settings__mdt alationSetting=[Select dcmgt_Alation_Base_Endpoint_URL__c from dcmgt_Alation_Settings__mdt LIMIT 1];
          if(alationSetting!=null)
          {
              String host=alationSetting.dcmgt_Alation_Base_Endpoint_URL__c;
              String token =dcmgt_alation_token_management.createAPIAccessToken();
              if(token.startsWith('Error'))
              {
                  CalloutException execption = new CalloutException();
                  execption.setMessage(token);
                  throw execption;  
              }
              map<string,string> mapPicklistValueWithAllowMultiple=new map<string,string>{'Life Cycle Status'=>'false','Classification'=>'false', 
                    'Term Type'=>'false', 'Subject Area'=>'true'};
              
              //list of all custom fields and picklist type values
              //List<String> customFields= new String[]{'Life Cycle Status','Classification','Subject Area'};  
               
              for(String customField:mapPicklistValueWithAllowMultiple.keyset())
              {
                  String customFieldURL=host+'/integration/v2/custom_field/?allow_multiple='+mapPicklistValueWithAllowMultiple.get(customField)+'&limit=100';
                customField=customField.replace(' ','%20');   
                HttpResponse valueSetresponse=invokeGetRestAPI(customFieldURL+'&name_singular='+customField+'&skip=0',token); 
                if (valueSetresponse.getStatusCode() == 200) {
                      List<Object> valueSetResults = (List<Object>) JSON.deserializeUntyped(valueSetresponse.getBody());
                     for(Object valueSetNode:valueSetResults)
                        {
                           Map<String,Object> valueSetJsonResult=(Map<String,Object>)valueSetNode;
                           Object options=valueSetJsonResult.get('options');
                            customFieldFinalResponseMap.put(customField,options);
                        }
                  }
              }
          }
      }catch(System.CalloutException ex) 
      {
         Map<String,String> errorMap=new Map<String,String>();
         errorMap.put('Error detail',ex.getMessage());
          return JSON.serialize(errorMap);
      }
      catch(Exception ex) 
      {
         Map<String,String> errorMap=new Map<String,String>();
         errorMap.put('Error detail',ex.getMessage());
          return JSON.serialize(errorMap);
      }     
   System.debug(JSON.serializePretty(customFieldFinalResponseMap));        
   return JSON.serialize(customFieldFinalResponseMap); 
  }
  public static Map<String,String> getAlationUsers()
  {
      Map<String,String> usersMap= new Map<String,String>();
      try{
        dcmgt_Alation_Settings__mdt alationSetting=[Select dcmgt_Alation_Base_Endpoint_URL__c from dcmgt_Alation_Settings__mdt LIMIT 1];
          if(alationSetting!=null)
          {
              String token =dcmgt_alation_token_management.createAPIAccessToken();
              HttpResponse userResponse = invokeGetRestAPI(alationSetting.dcmgt_Alation_Base_Endpoint_URL__c+'/integration/v1/user/',token);
              if(userResponse.getStatusCode()==200)
              {
                  List<Object> usersList = (List<Object>) JSON.deserializeUntyped(userResponse.getBody()); 
                  for(Object userObject:usersList)
                  {
                      Map<String,Object> userJsonMap=(Map<String,Object>)userObject;
                      usersMap.put((String)userJsonMap.get('email'),(String)userJsonMap.get('display_name'));
                  }
              }else{
                  CalloutException execption = new CalloutException();
                  execption.setMessage(getErrorMessage(userResponse.getStatusCode()));
                  throw execption; 
              }
          }
      }catch(System.CalloutException ex) 
      {
         Map<String,String> errorMap=new Map<String,String>();
         errorMap.put('Error detail',ex.getMessage());
          return errorMap;
      }
      catch(Exception ex) 
      {
         Map<String,String> errorMap=new Map<String,String>();
         errorMap.put('Error detail',ex.getMessage());
          return errorMap;
      }
      return usersMap;    
  }
  public static String getArticles(String glossaryName)
  {
      List<Map<String,String>> finalResponseList= new List<Map<String,String>>(); 
      try{
          //To fetch Alation host
          dcmgt_Alation_Settings__mdt alationSetting=[Select dcmgt_Alation_Base_Endpoint_URL__c from dcmgt_Alation_Settings__mdt LIMIT 1];
          String host=alationSetting.dcmgt_Alation_Base_Endpoint_URL__c;
          String token =dcmgt_alation_token_management.createAPIAccessToken();
          if(token.startsWith('Error'))
          {
              CalloutException execption = new CalloutException();
              execption.setMessage(token);
              throw execption;  
          }
          String glossaryURL=host+'/integration/v1/custom_template/?title='+glossaryName;
          String articleURL=host+'/integration/v1/article/?custom_field_templates=[';                 
          Map<String,String> usersMap= new Map<String,String>();
          String Data_Dictionary='';
          HttpResponse glossaryResponse=invokeGetRestAPI(glossaryURL,token);
          HttpResponse userResponse = invokeGetRestAPI(host+'/integration/v1/user/',token);
          if(userResponse.getStatusCode()==200)
          {
              List<Object> usersList = (List<Object>) JSON.deserializeUntyped(userResponse.getBody()); 
              for(Object userObject:usersList)
              {
                  Map<String,Object> userJsonMap=(Map<String,Object>)userObject;
                  usersMap.put(((Integer)userJsonMap.get('id')).format(),(String)userJsonMap.get('email'));
              }
          }else{
              CalloutException execption = new CalloutException();
              execption.setMessage(getErrorMessage(userResponse.getStatusCode()));
              throw execption; 
          }
          
          if (glossaryResponse.getStatusCode() == 200) {
            // Deserialize the JSON string into collection
             List<Object> glossayResults = (List<Object>) JSON.deserializeUntyped(glossaryResponse.getBody());
  
                for(Object obj : glossayResults) {
                  Map<String, Object> jsonMap=(Map<String, Object>) obj;
                    Integer id=(Integer)jsonMap.get('id');
                    HttpResponse articleResponse=invokeGetRestAPI(articleurl+id+']',token); 
                    if (articleResponse.getStatusCode() == 200) {
                          
                          List<Object> articleJsonList= (List<Object>)JSON.deserializeUntyped(articleResponse.getBody());
                          for(Object articleJsonObject:articleJsonList)
                          {
                              Map<String,String> responseMap= new Map<String,String>();
                              Map<String, Object> articleJsonMap= (Map<String, Object>)articleJsonObject;
                              List<Object> customFields=(List<Object>)articleJsonMap.get('custom_fields');
                              List<Object> children=(List<Object>)articleJsonMap.get('children');
                              String[] selected_fields= new String[]{'Acronym / Synonym','Approval date','Classification','Last Review Date','Term Type','Data Owner','Data Steward','Governed Flag','Subject Area','Life Cycle Status'};
                              Map<String,Object> selected_field_dict=new Map<String,Object>();
                              List<String> selected_field_list=new List<String>(selected_fields); 
                              List<Object> children_articles=new List<Object>();
                                  for(Object child:children)
                                  {
                                    Map<String,Object> childMap=(Map<String,Object>)child;
                                    if(childMap.get('otype')=='article')
                                    {
                                        children_articles.add(child);
                                    }
                                  }
                                    String stewards='';
                                    String businessowners='';
                                    for(Object field:customFields)
                                    {
                                        Map<String,Object> fieldMap=(Map<String,Object>)field;
                                          if(selected_field_list.contains((String)fieldMap.get('field_name')))
                                          {
                                              system.debug('****FIELDVALUESET***'+fieldMap.get('value'));
                                           if((String)fieldMap.get('field_name') !='Data Owner' && (String)fieldMap.get('field_name') !='Data Steward' && (String)fieldMap.get('field_name') !='Data Dictionary' && (String)fieldMap.get('field_name') !='Subject Area')
                                           {
                                              selected_field_dict.put((String)fieldMap.get('field_name'),fieldMap.get('value'));
                                           } 	
                                           //else if(fieldMap.get('field_name') =='Steward')
                                           else if(fieldMap.get('field_name') =='Data Steward')
                                           {
                                              if(stewards=='')
                                              {
                                                  stewards=usersMap.get(((Integer)fieldMap.get('id')).format());
                                              }else{
                                                 stewards=stewards+','+usersMap.get(((Integer)fieldMap.get('id')).format());
                                               }						   
                                              
                                              selected_field_dict.put((String)fieldMap.get('field_name'),stewards);
                                           }
                                           //else if((String)fieldMap.get('field_name') =='Business Owner')
                                           else if((String)fieldMap.get('field_name') =='Data Owner')
                                              {   
                                              if(businessowners=='')
                                              {
                                                  businessowners=usersMap.get(((Integer)fieldMap.get('id')).format());
                                              }    
                                              else
                                              {  
                                                 businessowners=businessowners+','+usersMap.get(((Integer)fieldMap.get('id')).format());
                                              }
                                                 selected_field_dict.put((String)fieldMap.get('field_name'),businessowners);
                                              }
                                              else if((String)fieldMap.get('field_name') =='Subject Area'){
                                                  //list<string> lstSubjectArea=new  list<string>(); 
                                                  //lstSubjectArea.addall((list<string>)fieldMap.get('value'));
                                                  list<object> lstSubjectAreaTemp = (list<object>)fieldMap.get('value');
                                                  List<string> lstSubjectArea = (List<string>)JSON.deserialize(json.serialize(lstSubjectAreaTemp), List<string>.class);
                                                  system.debug('***lstSubjectArea***'+lstSubjectArea);
                                                  selected_field_dict.put((String)fieldMap.get('field_name'),string.join(lstSubjectArea, ';'));
                                                  
                                              }	
                                           }	
                                        
                                          else if((String)fieldMap.get('field_name') =='Data Dictionary')
                                          {
                                             Data_Dictionary='{id:'+fieldMap.get('id')+',name:'+fieldMap.get('value')+'})';
                                          }
                                     }			
                              
                              responseMap.put('Glossary id',((Integer)jsonMap.get('id')).format());
                              responseMap.put('Glossary name',(String)jsonMap.get('title'));
                              responseMap.put('Name',isEmpty(articleJsonMap.get('title')));
                              responseMap.put('id',((Integer)articleJsonMap.get('id')).format());
                              responseMap.put('Description',isEmpty(articleJsonMap.get('body')).stripHtmlTags());
                              responseMap.put('url',(String)articleJsonMap.get('url'));
                              responseMap.put('Last Review Date',isEmpty(selected_field_dict.get('Last Review Date')));
                              responseMap.put('Acronym / Synonym',isEmpty(selected_field_dict.get('Acronym / Synonym')));
                              responseMap.put('Approval date',isEmpty(selected_field_dict.get('Approval date')));
                              responseMap.put('Classification',isEmpty(selected_field_dict.get('Classification')));
                              responseMap.put('Life Cycle Status',isEmpty(selected_field_dict.get('Life Cycle Status')));
                              responseMap.put('Term Type',isEmpty(selected_field_dict.get('Term Type')));
                              responseMap.put('Business Owner',isEmpty(selected_field_dict.get('Data Owner')));
                              responseMap.put('Steward',isEmpty(selected_field_dict.get('Data Steward')));
                              responseMap.put('Governed Flag',isEmpty(selected_field_dict.get('Governed Flag')));
                              responseMap.put('Subject Area',isEmpty(selected_field_dict.get('Subject Area')));
                              responseMap.put('children',JSON.serialize(children_articles));
                              responseMap.put('Data Dictionary',JSON.serialize(Data_Dictionary));
                              System.debug('JSON Article Response'+JSON.serialize(responseMap)); 
                              finalResponseList.add(responseMap);
                      }
                }else{
                    CalloutException execption = new CalloutException();
                      execption.setMessage(getErrorMessage(articleResponse.getStatusCode()));
                      throw execption;  
                  }  
                }
        }else{
              CalloutException execption = new CalloutException();
              execption.setMessage(getErrorMessage(glossaryResponse.getStatusCode()));
              throw execption;
          }
      }catch(System.CalloutException ex) 
      {
         Map<String,String> errorMap=new Map<String,String>();
         errorMap.put('Error detail',ex.getMessage());
          return JSON.serialize(errorMap);
      }
      catch(Exception ex) 
      {
         Map<String,String> errorMap=new Map<String,String>();
         errorMap.put('Error detail',ex.getMessage());
          return JSON.serialize(errorMap);
      }
     //System.debug(JSON.serializePretty(finalResponseList));     
    return JSON.serialize(finalResponseList);    
  }
  
  public static String isEmpty(Object obj ) 
    {
      if(obj==null)
      {
        return '';  
      }else{
          return obj.toString();
      }
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