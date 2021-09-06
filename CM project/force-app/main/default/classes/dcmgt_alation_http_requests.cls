public class dcmgt_alation_http_requests {
    
  public static String HOST='http://34.199.204.90';  
  public static final String refresh_token='GUBTcayxrr69vPM6XaS4y296gmJzyS1TJYViYghNRdfOrkn9CsYlPHblQcgiiVZjDLHopnTQefVLRHxTHMJVqg';
  public static final String user_id='28';  
    
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
    
    public static String createAPIAccessToken()
    {
        String API_accessToken=null;
        try{
            
            HttpRequest request = new HttpRequest();
            request.setEndpoint(HOST+'/integration/v1/createAPIAccessToken/');
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            request.setBody('user_id='+user_id+'&refresh_token='+refresh_token);
            request.setTimeout(30000);
            Http http = new Http();
            HttpResponse response = http.send(request);
            if(response.getStatusCode()==201)
            {
                Map<String,Object> responseMap=(Map<String,Object>)JSON.deserializeUntyped(response.getBody()); 
                API_accessToken=(String)responseMap.get('api_access_token');
                System.debug(API_accessToken); 
            }else{
                return 'Error while creating APIAccessToken';
            }
           }catch(System.CalloutException ex) 
           {
                return 'Error while creating APIAccessToken';
           }
       return API_accessToken; 
    }
    public static String getArticles(String glossaryName)
    {
        system.debug('AlationArticle'+glossaryName);
        List<Map<String,String>> finalResponseList= new List<Map<String,String>>(); 
        try{
            String token =createAPIAccessToken();
            if(token.startsWith('Error'))
            {
                CalloutException execption = new CalloutException();
                execption.setMessage('Error while creating APIAccessToken');
                throw execption;  
            }
            String glossaryurl=HOST+'/integration/v1/custom_template/?title='+glossaryName;
            String articleurl=HOST+'/integration/v1/article/?custom_field_templates=[';                 
            Map<String,String> usersMap= new Map<String,String>();
            String datadictionary='';
            HttpResponse glossaryResponse=invokeGetRestAPI(glossaryurl,token);
            HttpResponse userResponse = invokeGetRestAPI(HOST+'/integration/v1/user/',token);
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
                execption.setMessage('Error while fetching users');
                throw execption; 
            }
            
            if (glossaryResponse.getStatusCode() == 200) {
              // Deserialize the JSON string into collections of primitive data types.
               List<Object> glossayResults = (List<Object>) JSON.deserializeUntyped(glossaryResponse.getBody());
    
                  for (Object obj : glossayResults) {
                    Map<String, Object> jsonMap=(Map<String, Object>) obj;
                      Integer id=(Integer)jsonMap.get('id');
                      //System.debug(id);
                      HttpResponse articleResponse=invokeGetRestAPI(articleurl+id+']',token); 
                      if (articleResponse.getStatusCode() == 200) {
                            //System.debug(articleResponse.getBody());
                            List<Object> articleJsonList= (List<Object>)JSON.deserializeUntyped(articleResponse.getBody());
                            for(Object articleJsonObject:articleJsonList)
                            {
                                Map<String,String> finalResponse= new Map<String,String>();
                                Map<String, Object> articleJsonMap= (Map<String, Object>)articleJsonObject;
                                List<Object> customFields=(List<Object>)articleJsonMap.get('custom_fields');
                                List<Object> children=(List<Object>)articleJsonMap.get('children');
                                String[] selected_fields= new String[]{'Acronym / Synonym','Approval date','Classification','Last Review Date','Term Type','Business Owner','Steward','Governed Flag','Subject Area','Life Cycle Status'};
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
                                             if((String)fieldMap.get('field_name') !='Business Owner' && (String)fieldMap.get('field_name') !='Steward' && (String)fieldMap.get('field_name') !='datadictionary')
                                             {
                                                selected_field_dict.put((String)fieldMap.get('field_name'),fieldMap.get('value'));
                                             } 	
                                             else if(fieldMap.get('field_name') =='Steward')
                                             {
                                                if(stewards=='')
                                                {
                                                    stewards=usersMap.get(((Integer)fieldMap.get('id')).format());
                                                }else{
                                                   stewards=stewards+','+usersMap.get(((Integer)fieldMap.get('id')).format());
                                                 }						   
                                                
                                                selected_field_dict.put((String)fieldMap.get('field_name'),stewards);
                                             }
                                             else if((String)fieldMap.get('field_name') =='Business Owner')
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
                                             }						
                                            else if((String)fieldMap.get('field_name') =='datadictionary')
                                            {
                                               datadictionary='{id:'+fieldMap.get('id')+',name:'+fieldMap.get('value')+'})';
                                            }
                                       }			
                                //System.debug(JSON.serialize(selected_field_dict));
                                finalResponse.put('Glossary id',((Integer)jsonMap.get('id')).format());
                                finalResponse.put('Glossary name',(String)jsonMap.get('title'));
                                finalResponse.put('Name',isEmpty(articleJsonMap.get('title')));
                                finalResponse.put('id',((Integer)articleJsonMap.get('id')).format());
                                finalResponse.put('Description',isEmpty(articleJsonMap.get('body')).stripHtmlTags());
                                finalResponse.put('url',(String)articleJsonMap.get('url'));
                                finalResponse.put('Last Review Date',isEmpty(selected_field_dict.get('Last Review Date')));
                                finalResponse.put('Acronym / Synonym',isEmpty(selected_field_dict.get('Acronym / Synonym')));
                                finalResponse.put('Approval date',isEmpty(selected_field_dict.get('Approval date')));
                                finalResponse.put('Classification',isEmpty(selected_field_dict.get('Classification')));
                                finalResponse.put('Life Cycle Status',isEmpty(selected_field_dict.get('Life Cycle Status')));
                                finalResponse.put('Term Type',isEmpty(selected_field_dict.get('Term Type')));
                                finalResponse.put('Business Owner',isEmpty(selected_field_dict.get('Business Owner')));
                                finalResponse.put('Steward',isEmpty(selected_field_dict.get('Steward')));
                                finalResponse.put('Governed Flag',isEmpty(selected_field_dict.get('Governed Flag')));
                                finalResponse.put('Subject Area',isEmpty(selected_field_dict.get('Subject Area')));
                                finalResponse.put('children',JSON.serialize(children_articles));
                                finalResponse.put('datadictionary',JSON.serialize(datadictionary));
                                //System.debug(JSON.serialize(finalResponse)); 
                                finalResponseList.add(finalResponse);
                        }
                  }else{
                      CalloutException execption = new CalloutException();
                        execption.setMessage('Error while fetching Alation articles');
                        throw execption;  
                    }  
                  }
          }else{
                CalloutException execption = new CalloutException();
                execption.setMessage('Error while fetching Gossary details');
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
       System.debug(JSON.serializePretty(finalResponseList));     
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
  
    public static String getDatasourceHierarchy(String datasource_name)
    {
        system.debug('DataSourceName'+datasource_name);
        List<Object> schemasFinalResponse= new List<Object>();
        try{
            String datasourceURL=HOST+'/catalog/datasource/?title='+datasource_name;
            String articleurl=HOST+'/integration/v1/article/';
            String token =createAPIAccessToken();
            if(token.startsWith('Error'))
            {
                CalloutException execption = new CalloutException();
                execption.setMessage('Error while creating APIAccessToken');
                throw execption;  
            }
            //Fetch datasource  
            HttpResponse datasourceresponse=invokeGetRestAPI(datasourceURL,token); 
            
            if (datasourceresponse.getStatusCode() == 200) {              
               List<Object> datasourceResults = (List<Object>) JSON.deserializeUntyped(datasourceresponse.getBody());
               for (Object node:datasourceResults)
               {
                Map<String,Object> datasourceResult=(Map<String,Object>)node;
                 String title=(String)datasourceResult.get('title');
                 if(EncodingUtil.urlDecode(datasource_name, 'UTF-8').equals(title))
                 {
                  Integer datasource_id=(Integer)datasourceResult.get('id');
                  //System.debug(datasource_id);
                     
                  //Fetch schema's
                  HttpResponse schemaresponse=invokeGetRestAPI(HOST+'/catalog/schema/?ds_id='+datasource_id,token);
                  if (schemaresponse.getStatusCode() == 200) {
                     List<Object> scemaResults = (List<Object>) JSON.deserializeUntyped(schemaresponse.getBody());
                      for(Object schemaNode:scemaResults)
                      {
                         Map<String,Object> schemaFinalMap=new Map<String,Object>(); 
                         Map<String,Object> schemaResult=(Map<String,Object>)schemaNode;
                         List<Object> schemaCustomFields=(List<Object>)schemaResult.get('custom_fields');
                         String[] schemaSelectedFields= new String[]{'Schema Type','Life cycle status','Tenant','Subject Area','Data Rentation','Description','Business Owner','Steward'};
                         List<String> schemaSelectedFieldList=new List<String>(schemaSelectedFields);
                         Map<String,Object> schema_custom_fields_selected=new Map<String,Object>();
                         for(Object field :schemaCustomFields)
                         {
                            Map<String,Object>  fieldMap=(Map<String,Object>)field;
                            if(schemaSelectedFieldList.contains((String)fieldMap.get('field_name')))
                            {
                              schema_custom_fields_selected.put((String)fieldMap.get('field_name'),fieldMap.get('value'));
                                //System.debug((String)fieldMap.get('field_name'));
                            }    
                         }
                       //Fetch alation tables
                       List<Object> tablesFinalResponse= new List<Object>();
                       HttpResponse tablesresponse = invokeGetRestAPI(HOST+'/catalog/table/?schema_id='+((Integer)schemaResult.get('id')).format(),token) ;
                       if (tablesresponse.getStatusCode() == 200) 
                       {
                         List<Object> tableResults = (List<Object>) JSON.deserializeUntyped(tablesresponse.getBody());
                          for (Object tableJsonNode:tableResults)
                          {
                               Map<String,Object> tableFinalMap=new Map<String,Object>();   
                               Map<String,Object> tableResult=(Map<String,Object>)tableJsonNode;
                               List<Object> tableCustomFields=(List<Object>)tableResult.get('custom_fields');
                               Map<String,Object> table_custom_fields_selected=new Map<String,Object>();
                               String[] tableSelectedFields= new String[]{'Business rules','Data category','Subject Area','Data asset type','Data Rentation','Data consumer','Refresh Frequency','Tenant','Business Owner','Steward'};
                               List<String> tableSelectedFieldList=new List<String>(tableSelectedFields);
                               for(Object field : tableCustomFields)
                               {
                                   Map<String,Object>  tableFieldMap=(Map<String,Object>)field;
                                    if(tableSelectedFieldList.contains((String)tableFieldMap.get('field_name')))
                                    {
                                      table_custom_fields_selected.put((String)tableFieldMap.get('field_name'),tableFieldMap.get('value'));
                                      //System.debug((String)tableFieldMap.get('field_name'));
                                    }
                               }
                              //Fetch column details
                              List<Object> columnsFinalResponse= new List<Object>();
                              HttpResponse columnsresponse = invokeGetRestAPI(HOST+'/catalog/column/?table_id='+((Integer)tableResult.get('id')).format(),token);
                              if (columnsresponse.getStatusCode() == 200) 
                               {
                                 List<Object> columnsResults = (List<Object>) JSON.deserializeUntyped(columnsresponse.getBody());
                                  for (Object columnJsonNode:columnsResults)
                                  {
                                       Map<String,Object> columnFinalMap=new Map<String,Object>();
                                       Map<String,Object> columnResult=(Map<String,Object>)columnJsonNode;
                                       List<Object> columnCustomFields=(List<Object>)columnResult.get('custom_fields');
                                       Map<String,Object> column_custom_fields_selected=new Map<String,Object>();
                                       String[] columnSelectedFields= new String[]{'Dimensions','Data dictionary',
                                            'Business process','Business rules',
                                            'Data category','Subject Area',
                                            'Buisness Calculaqtion','Indication Metric',
                                            'Value update','Data Rentation','Business Owner','Steward'};
                                       List<String> columnSelectedFieldList=new List<String>(columnSelectedFields);
                                       for(Object field : columnCustomFields)
                                       {
                                           Map<String,Object>  columnFieldMap=(Map<String,Object>)field;
                                            if(columnSelectedFieldList.contains((String)columnFieldMap.get('field_name')))
                                            {
                                              column_custom_fields_selected.put((String)columnFieldMap.get('field_name'),columnFieldMap.get('value'));
                                              //System.debug((String)columnFieldMap.get('field_name'));
                                            }
                                       }
                                    columnFinalMap.put('name',(String)columnResult.get('name'));
                                    columnFinalMap.put('id',((Integer)columnResult.get('id')).format());
                                    columnFinalMap.put('url',(String)columnResult.get('url'));
                                    columnFinalMap.put('table_id',((Integer)columnResult.get('table_id')).format());
                                    columnFinalMap.put('table_name',(String)columnResult.get('table_name'));
                                    columnFinalMap.put('description',(String)columnResult.get('description'));
                                    columnFinalMap.put('Dimensions',isEmpty(column_custom_fields_selected.get('Dimensions')));
                                    columnFinalMap.put('Data dictionary',isEmpty(column_custom_fields_selected.get('Data dictionary')));
                                    columnFinalMap.put('Business process',isEmpty(column_custom_fields_selected.get('Business process')));
                                    columnFinalMap.put('Business rules',isEmpty(column_custom_fields_selected.get('Business rules')));
                                    columnFinalMap.put('Data category',isEmpty(column_custom_fields_selected.get('Data category')));
                                    columnFinalMap.put('Subject Area',isEmpty(column_custom_fields_selected.get('Subject Area')));
                                    columnFinalMap.put('Buisness Calculaqtion',isEmpty(column_custom_fields_selected.get('Buisness Calculaqtion')));
                                    columnFinalMap.put('Indication Metric',isEmpty(column_custom_fields_selected.get('Indication Metric')));
                                    columnFinalMap.put('Value update',isEmpty(column_custom_fields_selected.get('Value update')));
                                    columnFinalMap.put('Data Rentation',isEmpty(column_custom_fields_selected.get('Data Rentation')));
                                    columnFinalMap.put('Business Owner',isEmpty(column_custom_fields_selected.get('Business Owner')));
                                    columnFinalMap.put('Steward',isEmpty(column_custom_fields_selected.get('Steward')));
                                    // System.debug(JSON.serialize(columnFinalMap));   
                                    columnsFinalResponse.add(columnFinalMap);
                                  }
                               }else{
                                    CalloutException execption = new CalloutException();
                                    execption.setMessage('Error while fetching column details');
                                    throw execption;
                                }
                              
                            tableFinalMap.put('id',((Integer)tableResult.get('id')).format());
                            tableFinalMap.put('name',(String)tableResult.get('name'));
                            tableFinalMap.put('url',(String)tableResult.get('url'));
                            tableFinalMap.put('description',((String)tableResult.get('description')).stripHtmlTags());
                            tableFinalMap.put('schema_name',(String)tableResult.get('schema_name'));
                            tableFinalMap.put('Business rules',isEmpty(table_custom_fields_selected.get('Business rules')));
                            tableFinalMap.put('Data category',isEmpty(table_custom_fields_selected.get('Data category')));
                            tableFinalMap.put('Subject Area',isEmpty(table_custom_fields_selected.get('Subject Area')));
                            tableFinalMap.put('Data asset type',isEmpty(table_custom_fields_selected.get('Data asset type')));
                            tableFinalMap.put('Data Rentation',isEmpty(table_custom_fields_selected.get('Data Rentation')));
                            tableFinalMap.put('Data consumer',isEmpty(table_custom_fields_selected.get('Data consumer')));
                            tableFinalMap.put('Refresh Frequency',isEmpty(table_custom_fields_selected.get('Refresh Frequency')));
                            tableFinalMap.put('Tenant',isEmpty(table_custom_fields_selected.get('Tenant')));
                            tableFinalMap.put('Business Owner',isEmpty(table_custom_fields_selected.get('Business Owner')));
                            tableFinalMap.put('Steward',isEmpty(table_custom_fields_selected.get('Steward')));
                            tableFinalMap.put('columns',JSON.serialize(columnsFinalResponse));
                            tablesFinalResponse.add(tableFinalMap);  
                          } 
                       }else{
                            CalloutException execption = new CalloutException();
                            execption.setMessage('Error while fetching table details');
                            throw execption;
                        }
                          
                        schemaFinalMap.put('id',((Integer)schemaResult.get('id')).format());
                        schemaFinalMap.put('url',(String)schemaResult.get('url'));
                        schemaFinalMap.put('description',((String)schemaResult.get('description')).stripHtmlTags());
                        schemaFinalMap.put('name',(String)schemaResult.get('name'));
                        schemaFinalMap.put('ds_id',((Integer)schemaResult.get('ds_id')).format());
                        schemaFinalMap.put('Schema Type',isEmpty(schema_custom_fields_selected.get('Schema Type')));
                        schemaFinalMap.put('Life cycle status',isEmpty(schema_custom_fields_selected.get('Life cycle status')));
                        schemaFinalMap.put('Tenant',isEmpty(schema_custom_fields_selected.get('Tenant')));
                        schemaFinalMap.put('Subject Area',isEmpty(schema_custom_fields_selected.get('Subject Area')));
                        schemaFinalMap.put('Data Rentation',isEmpty(schema_custom_fields_selected.get('Data Rentation')));
                        schemaFinalMap.put('Description',isEmpty(schema_custom_fields_selected.get('Description')));
                        schemaFinalMap.put('Business Owner',isEmpty(schema_custom_fields_selected.get('Business Owner')));
                        schemaFinalMap.put('Steward',isEmpty(schema_custom_fields_selected.get('Steward')));
                        schemaFinalMap.put('tables',tablesFinalResponse);
                        schemasFinalResponse.add(schemaFinalMap);  
                     }
                  }else{
                         CalloutException execption = new CalloutException();
                         execption.setMessage('Error while fetching schema details');
                         throw execption;
                     }
                 }
               }
            }else{
                 CalloutException execption = new CalloutException();
                 execption.setMessage('Error while fetching datasource details');
                 throw execption;
                 }
        }
        catch(System.CalloutException ex) 
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
     System.debug(JSON.serializePretty(schemasFinalResponse));        
     return JSON.serialize(schemasFinalResponse);     
    }    
}