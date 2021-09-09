public class dcmgt_alation_datasource_management {

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
              map<string,string> mapPicklistValueWithAllowMultiple=new map<string,string>{'Business Process'=>'false','Data Category'=>'false','Indication Metric'=>'false','Refresh Frequency'=>'false','Data Retention'=>'false','Subject Area'=>'true','Value Update'=>'false','Data Classification'=>'false'};
              //list of all custom fields and picklist type values
              //List<String> customFields= new String[]{'Business Process','Data Category','Indication Metric','Refresh Frequency','Data Retention','Subject Area','Value Update','Data Classification'};  
               
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
  
  public static String getDatasourceHierarchy(String datasource_name)
  {
      List<Object> schemasFinalResponse= new List<Object>();
      try{
          //To fetch Alation host
          dcmgt_Alation_Settings__mdt alationSetting=[Select dcmgt_Alation_Base_Endpoint_URL__c from dcmgt_Alation_Settings__mdt LIMIT 1];
          if(alationSetting!=null)
          {
              String host=alationSetting.dcmgt_Alation_Base_Endpoint_URL__c;
              String token =dcmgt_alation_token_management.createAPIAccessToken();
              
              String datasourceURL=host+'/catalog/datasource/?title='+datasource_name;
              String articleurl=host+'/integration/v1/article/';
         
              if(token.startsWith('Error'))
              {
                  CalloutException execption = new CalloutException();
                  execption.setMessage(token);
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
                    HttpResponse schemaresponse=invokeGetRestAPI(host+'/catalog/schema/?ds_id='+datasource_id,token);
                    if (schemaresponse.getStatusCode() == 200) {
                       List<Object> scemaResults = (List<Object>) JSON.deserializeUntyped(schemaresponse.getBody());
                        for(Object schemaNode:scemaResults)
                        {
                           Map<String,Object> schemaFinalMap=new Map<String,Object>(); 
                           Map<String,Object> schemaResult=(Map<String,Object>)schemaNode;
                           List<Object> schemaCustomFields=(List<Object>)schemaResult.get('custom_fields');
                           String[] schemaSelectedFields= new String[]{'Schema Type','Life cycle status','Tenant','Subject Area','Data Retention','Description','Data Owner','Data Steward','Data Classification'};
                           List<String> schemaSelectedFieldList=new List<String>(schemaSelectedFields);
                           Map<String,Object> schema_custom_fields_selected=new Map<String,Object>();
                           for(Object field :schemaCustomFields)
                           {
                              Map<String,Object>  fieldMap=(Map<String,Object>)field;
                              if(schemaSelectedFieldList.contains((String)fieldMap.get('field_name')))
                              {
                                schema_custom_fields_selected.put((String)fieldMap.get('field_name'),fieldMap.get('value'));
                                System.debug(schema_custom_fields_selected.put((String)fieldMap.get('field_name'),fieldMap.get('value')));
                                  //System.debug((String)fieldMap.get('field_name'));
                              }    
                           }
                         //Fetch alation tables
                         List<Object> tablesFinalResponse= new List<Object>();
                         HttpResponse tablesresponse = invokeGetRestAPI(host+'/catalog/table/?schema_id='+((Integer)schemaResult.get('id')).format(),token) ;
                         if (tablesresponse.getStatusCode() == 200) 
                         {
                           List<Object> tableResults = (List<Object>) JSON.deserializeUntyped(tablesresponse.getBody());
                            for (Object tableJsonNode:tableResults)
                            {
                                 Map<String,Object> tableFinalMap=new Map<String,Object>();   
                                 Map<String,Object> tableResult=(Map<String,Object>)tableJsonNode;
                                 List<Object> tableCustomFields=(List<Object>)tableResult.get('custom_fields');
                                 Map<String,Object> table_custom_fields_selected=new Map<String,Object>();
                                 //String[] tableSelectedFields= new String[]{'Business Rules','Data Category','Subject Area','Data Asset Type','Data Retention','Data Consumer','Refresh Frequency','Tenant','Business Owner','Steward'};
                                String[] tableSelectedFields= new String[]{'Business Process','Business Rules','Data Category','Data Consumer','Data Dictionary','Business Calculation','Dimensions','Indication Metric','Refresh Frequency','Data Retention','Data Owner','Data Steward','Subject Area','Value Update','Tenant','Data Asset Type','Data Classification'};  
                                String[] tableSelectedFields_multiVal= new String[]{'Data Consumer','Tenant','Data Owner','Data Steward'};    
                                List<String> tableSelectedFieldList=new List<String>(tableSelectedFields);
                                 
                                 for(Object field : tableCustomFields)
                                 {
                                     system.debug('**tableCustomFields**'+field);
                                     Map<String,Object>  tableFieldMap=(Map<String,Object>)field;
                                      if(tableSelectedFieldList.contains((String)tableFieldMap.get('field_name')))
                                      {
                                        if(!tableSelectedFields_multiVal.contains((String)tableFieldMap.get('field_name')))
                                           {
                                              table_custom_fields_selected.put((String)tableFieldMap.get('field_name'),tableFieldMap.get('value'));
                                           } 	
                                           else 
                                           {
                                              if(table_custom_fields_selected.get((String)tableFieldMap.get('field_name'))==null)
                                              {
                                                  table_custom_fields_selected.put((String)tableFieldMap.get('field_name'),(String)tableFieldMap.get('value'));
                                                  //stewards=(String)tableFieldMap.get('value');
                                              }
                                               else if((String)tableFieldMap.get('field_name') =='Subject Area'){
                                                  //list<string> lstSubjectArea=new  list<string>(); 
                                                  //lstSubjectArea.addall((list<string>)fieldMap.get('value'));
                                                  list<object> lstSubjectAreaTemp = (list<object>)tableFieldMap.get('value');
                                                  List<string> lstSubjectArea = (List<string>)JSON.deserialize(json.serialize(lstSubjectAreaTemp), List<string>.class);
                                                  system.debug('***lstSubjectArea***'+lstSubjectArea);
                                                  table_custom_fields_selected.put((String)tableFieldMap.get('field_name'),string.join(lstSubjectArea, ';'));
                                                  
                                              }	
                                               else{
                                                 String fieldVal= (String)table_custom_fields_selected.get((String)tableFieldMap.get('field_name'));
                                                 fieldVal=fieldVal+','+(String)tableFieldMap.get('value');
                                                  
                                                 table_custom_fields_selected.put((String)tableFieldMap.get('field_name'),fieldVal);
                                               }						   
                                              
                                              //table_custom_fields_selected.put((String)tableFieldMap.get('field_name'),stewards);
                                           }
                                           
                                      }
                                 }
                                System.debug('Table ID'+((Integer)tableResult.get('id')));
                                //Fetch column details
                                List<Object> columnsFinalResponse= new List<Object>();
                                HttpResponse columnsresponse = invokeGetRestAPI(host+'/catalog/column/?table_id='+((Integer)tableResult.get('id')),token);
                                System.debug('Http Response'+columnsresponse);
                                if (columnsresponse.getStatusCode() == 200) 
                                 {
                                   List<Object> columnsResults = (List<Object>) JSON.deserializeUntyped(columnsresponse.getBody());
                                    for (Object columnJsonNode:columnsResults)
                                    {
                                         Map<String,Object> columnFinalMap=new Map<String,Object>();
                                         Map<String,Object> columnResult=(Map<String,Object>)columnJsonNode;
                                         List<Object> columnCustomFields=(List<Object>)columnResult.get('custom_fields');
                                        
                                         Map<String,Object> column_custom_fields_selected=new Map<String,Object>();
                                         /*String[] columnSelectedFields= new String[]{'Dimensions','Data Dictionary',
                                              'Business Process','Business Rules',
                                              'Data Category','Subject Area',
                                              'Business Calculation','Indication Metric',
                                              'Value Update','Data Retention','Business Owner','Steward'};
                                           */
                                        String[] columnSelectedFields= new String[]{'Business Process','Business Rules','Data Category','Data Consumer','Data Dictionary','Business Calculation','Dimensions','Indication Metric','Refresh Frequency','Data Retention','Data Owner','Data Steward','Subject Area','Value Update','Tenant','Data Asset Type','Data Classification'};
                                        String[] columnSelectedFields_multiVal= new String[]{'Data Consumer','Tenant','Data Owner','Data Steward'};
                                            List<String> columnSelectedFieldList=new List<String>(columnSelectedFields);
                                         for(Object field : columnCustomFields)
                                         {
                                             system.debug('**columnCustomFields**'+field);
                                             Map<String,Object>  columnFieldMap=(Map<String,Object>)field;
                                              if(columnSelectedFieldList.contains((String)columnFieldMap.get('field_name')))
                                              {
                                                if(!columnSelectedFields_multiVal.contains((String)columnFieldMap.get('field_name')))
                                               {  
                                                    column_custom_fields_selected.put((String)columnFieldMap.get('field_name'),columnFieldMap.get('value'));
                                               }   
                                                else{
                                                  String fieldVal= (String)column_custom_fields_selected.get((String)columnFieldMap.get('field_name'));
                                                 fieldVal=fieldVal+','+(String)columnFieldMap.get('value');
                                                   
                                                 column_custom_fields_selected.put((String)columnFieldMap.get('field_name'),fieldVal); 
                                               }
                                                  
                                              }
                                         }
                                        
                                      columnFinalMap.put('name',(String)columnResult.get('name'));
                                      columnFinalMap.put('id',((Integer)columnResult.get('id')).format());
                                      columnFinalMap.put('url',(String)columnResult.get('url'));
                                      columnFinalMap.put('schema_name',(String)columnResult.get('schema_name'));
                                      columnFinalMap.put('datasource_name',datasource_name);
                                      columnFinalMap.put('table_id',((Integer)columnResult.get('table_id')).format());
                                      columnFinalMap.put('table_name',(String)columnResult.get('table_name'));
                                      columnFinalMap.put('description',((String)columnResult.get('description')).stripHtmlTags());
                                      columnFinalMap.put('Business Process',isEmpty(column_custom_fields_selected.get('Business Process')));
                  					  columnFinalMap.put('Business Rules',isEmpty(column_custom_fields_selected.get('Business Rules')).stripHtmlTags());
                                      columnFinalMap.put('Data Classification',isEmpty(column_custom_fields_selected.get('Data Classification')).stripHtmlTags());
                  					  columnFinalMap.put('Data Category',isEmpty(column_custom_fields_selected.get('Data Category')));
                  					  columnFinalMap.put('Data Consumer',isEmpty(column_custom_fields_selected.get('Data Consumer')));
                                      columnFinalMap.put('Data Dictionary',isEmpty(column_custom_fields_selected.get('Data Dictionary')));
                                      columnFinalMap.put('Business Calculation',isEmpty(column_custom_fields_selected.get('Business Calculation')).stripHtmlTags());
                                      columnFinalMap.put('Dimensions',isEmpty(column_custom_fields_selected.get('Dimensions')).stripHtmlTags());
                                      columnFinalMap.put('Indication Metric',isEmpty(column_custom_fields_selected.get('Indication Metric')));
                                      columnFinalMap.put('Refresh Frequency',isEmpty(column_custom_fields_selected.get('Refresh Frequency')));
                                      columnFinalMap.put('Data Retention',isEmpty(column_custom_fields_selected.get('Data Retention')));
                                      columnFinalMap.put('Business Owner',isEmpty(column_custom_fields_selected.get('Data Owner')));
                                      columnFinalMap.put('Steward',isEmpty(column_custom_fields_selected.get('Data Steward')));	
                                      columnFinalMap.put('Subject Area',isEmpty(column_custom_fields_selected.get('Subject Area')));
                                      columnFinalMap.put('Value update',isEmpty(column_custom_fields_selected.get('Value update')));
                                      columnFinalMap.put('Tenant',isEmpty(column_custom_fields_selected.get('Tenant')));
                                      columnFinalMap.put('Data Asset Type',isEmpty(column_custom_fields_selected.get('Data Asset Type')));
                                      System.debug('JSSSS'+JSON.serialize(columnFinalMap));   
                                      columnsFinalResponse.add(columnFinalMap);
                                    }
                                 }else{
                                      CalloutException execption = new CalloutException();
                                      execption.setMessage(getErrorMessage(columnsresponse.getStatusCode()));
                                      throw execption;
                                  }
                                
                              tableFinalMap.put('id',((Integer)tableResult.get('id')).format());
                              tableFinalMap.put('name',(String)tableResult.get('name'));
                              tableFinalMap.put('url',(String)tableResult.get('url'));
                              tableFinalMap.put('description',((String)tableResult.get('description')).stripHtmlTags());
                              tableFinalMap.put('schema_name',(String)tableResult.get('schema_name'));
                              tableFinalMap.put('datasource_name',datasource_name);
                              tableFinalMap.put('Business Process',isEmpty(table_custom_fields_selected.get('Business Process')));
                              tableFinalMap.put('Business Rules',isEmpty(table_custom_fields_selected.get('Business Rules')).stripHtmlTags());
                              tableFinalMap.put('Data Category',isEmpty(table_custom_fields_selected.get('Data Category')));
              tableFinalMap.put('Data Consumer',isEmpty(table_custom_fields_selected.get('Data Consumer')));
              tableFinalMap.put('Data Dictionary',isEmpty(table_custom_fields_selected.get('Data Dictionary')));
              tableFinalMap.put('Business Calculation',isEmpty(table_custom_fields_selected.get('Business Calculation')).stripHtmlTags());
              tableFinalMap.put('Dimensions',isEmpty(table_custom_fields_selected.get('Dimensions')).stripHtmlTags());
              tableFinalMap.put('Indication Metric',isEmpty(table_custom_fields_selected.get('Indication Metric')));
              tableFinalMap.put('Refresh Frequency',isEmpty(table_custom_fields_selected.get('Refresh Frequency')));
                                tableFinalMap.put('Data Classification',isEmpty(table_custom_fields_selected.get('Data Classification')).stripHtmlTags());
              tableFinalMap.put('Data Retention',isEmpty(table_custom_fields_selected.get('Data Retention')));
              tableFinalMap.put('Business Owner',isEmpty(table_custom_fields_selected.get('Data Owner')));
              tableFinalMap.put('Steward',isEmpty(table_custom_fields_selected.get('Data Steward')));
                              tableFinalMap.put('Subject Area',isEmpty(table_custom_fields_selected.get('Subject Area')));
              tableFinalMap.put('Value Update',isEmpty(table_custom_fields_selected.get('Value Update')));
              tableFinalMap.put('Tenant',isEmpty(table_custom_fields_selected.get('Tenant')));
                              tableFinalMap.put('Data Asset Type',isEmpty(table_custom_fields_selected.get('Data Asset Type')));
                              tableFinalMap.put('columns',JSON.serialize(columnsFinalResponse));
                              tablesFinalResponse.add(tableFinalMap);  
                            } 
                         }else{
                              CalloutException execption = new CalloutException();
                              execption.setMessage(getErrorMessage(tablesresponse.getStatusCode()));
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
                          schemaFinalMap.put('Data Retention',isEmpty(schema_custom_fields_selected.get('Data Retention')));
                          schemaFinalMap.put('Description',isEmpty(schema_custom_fields_selected.get('Description')));
                          schemaFinalMap.put('Business Owner',isEmpty(schema_custom_fields_selected.get('Data Owner')));
                          schemaFinalMap.put('Steward',isEmpty(schema_custom_fields_selected.get('Data Steward')));
                            schemaFinalMap.put('Data Classification',isEmpty(schema_custom_fields_selected.get('Data Classification')));
                          schemaFinalMap.put('tables',tablesFinalResponse);
                          schemasFinalResponse.add(schemaFinalMap);  
                       }
                    }else{
                           CalloutException execption = new CalloutException();
                           execption.setMessage(getErrorMessage(schemaresponse.getStatusCode()));
                           throw execption;
                       }
                   }
                 }
              }else{
                   CalloutException execption = new CalloutException();
                   execption.setMessage(getErrorMessage(datasourceresponse.getStatusCode()));
                   throw execption;
                   }
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