public class dcmgt_AlationTest {
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
    public static void testArticle()
    {
        String TOKEN = dcmgt_alation_token_management.createAPIAccessToken();
        try{  
            List<dcmgt_Alation_Article__c> alationarticleslist = [Select id,Name,dcmgt_Multi_Subject_Area__c,dcmgt_Alation_Id__c,dcmgt_Life_Cycle_Status__c,dcmgt_Description__c,
                                                                  dcmgt_Alation_Articles__c,dcmgt_Term_Type__c,dcmgt_Classification__c,dcmgt_Last_Review_Date__c,dcmgt_Data_Owners__c,
                                                                  dcmgt_DataStewards__c,dcmgt_Status__c,dcmgt_Alation_Data_Dictionary_Name__c,dcmgt_Governed_Flag__c,dcmgt_Approval_Comment_Check__c,
                                                                  dcmgt_NextApproverRequired__c,dcmgt_Approval_date__c,dcmgt_Is_Active__c,dcmgt_Acronynm_Synonym__c,dcmgt_Staged_Alation_Article__c,
                                                                  dcmgt_Change_Request__c,dcmgt_Change_Request__r.dcmgt_Change_Request_Type__c, dcmgt_Change_Request__r.dcmgt_Change_Type__c
                                                                  from dcmgt_Alation_Article__c where id ='a057d00000DGc0AAAT'];
            dcmgt_Alation_Settings__mdt alationSetting=[Select dcmgt_Alation_Base_Endpoint_URL__c from dcmgt_Alation_Settings__mdt LIMIT 1];
            SET<string> setUserIds=new set<string>();
            for(dcmgt_Alation_Article__c arctileRec : alationarticleslist)
            {
                if(arctileRec.dcmgt_Data_Owners__c != null){
                    setUserIds.addall(((map<string,object>) json.deserializeUntyped((arctileRec.dcmgt_Data_Owners__c).unescapeHtml4())).keyset());
                }
                if(arctileRec.dcmgt_DataStewards__c != null){
                    setUserIds.addall(((map<string,object>) json.deserializeUntyped((arctileRec.dcmgt_DataStewards__c).unescapeHtml4())).keyset());
                }
            }
            Map<Id,User> userMap=new Map<Id,User>([Select Id,Email from User where id in :setUserIds]);
            System.debug('Outside Alation Articles');  
            for(dcmgt_Alation_Article__c arctileRec : alationarticleslist)
            {
                //If Block for Updation and Creation of Articles
                System.debug('inside Alation Articles Test');
                System.debug(arctileRec.dcmgt_Description__c);
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
                /*if(arctileRec.dcmgt_Multi_Subject_Area__c!=null)
                {
                    postMap.put('SUBJECT AREAS',arctileRec.dcmgt_Multi_Subject_Area__c);
                }*/
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
                   
                }  
                String body=JSON.serialize(postMap);
                System.debug(body);
                String Glossaries;
                dcmgt_Glossary_Article__c glossary_article=new dcmgt_Glossary_Article__c();
                if(arctileRec.dcmgt_Staged_Alation_Article__c != null){
                    glossary_article=[Select dcmgt_Alation_Glossary__r.Name from dcmgt_Glossary_Article__c where dcmgt_Alation_Article__c = :arctileRec.dcmgt_Staged_Alation_Article__c];
                    dcmgt_Alation_Glossary__c alation_glossary=glossary_article.dcmgt_Alation_Glossary__r;
                    Glossaries = (alation_glossary.Name).replace(' ','%20');
                }
                else{
                    Glossaries=('Business Glossary').replace(' ','%20');
                }
                if(alationSetting!=null)
                {
                    HttpRequest req = new HttpRequest();
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
                        //Updating the Status to Complete
                        arctileRec.dcmgt_Status__c = 'Completed';
                        update arctileRec;
                    }else{
                        CalloutException execption = new CalloutException();
                        execption.setMessage(getErrorMessage(response.getStatusCode()));
                        throw execption;
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
    public static void test()
    {
        String TOKEN = dcmgt_alation_token_management.createAPIAccessToken();
        //To fetch Alation host
        try{
            dcmgt_Alation_Settings__mdt alationSetting=[Select dcmgt_Alation_Base_Endpoint_URL__c from dcmgt_Alation_Settings__mdt LIMIT 1];        
            List<dcmgt_Data_Assets__c> alationdataassetslist = [Select id,Name,dcmgt_Alation_Id__c,dcmgt_Approval_date__c,dcmgt_Business_Process__c,dcmgt_Business_Rules__c,
                                                                dcmgt_Data_Assets_Name__c,dcmgt_Data_category__c,dcmgt_Data_Classification__c,dcmgt_Data_Consumer__c,
                                                                dcmgt_Data_Dictionary_Field__c,dcmgt_Data_Dictionary_Name__c,dcmgt_Data_Steward__c,dcmgt_Description__c,dcmgt_Dimensions__c,
                                                                dcmgt_External_Id__c,dcmgt_Full_name__c,dcmgt_Indication_Metric__c,dcmgt_IsActive__c,dcmgt_IsApproved__c,dcmgt_Locked_Fields__c,
                                                                dcmgt_NextApproverRequired__c,dcmgt_Public_Schema_Visibility__c,dcmgt_Refresh_Frequency__c,dcmgt_Schema_Name__c,dcmgt_Service_Owners__c,
                                                                dcmgt_Status__c,dcmgt_Subject_Area__c,dcmgt_Tenant__c,dcmgt_Type__c,dcmgt_Updated_Fields__c,dcmgt_Value_Update__c,dcmgt_Derived_logic_Business_Calculation__c,
                                                                dcmgt_Data_Retention__c,dcmgt_Business_Owners__c,dcmgt_Data_Stewards__c,dcmgt_Big_ID_URL__c
                                                                from dcmgt_Data_Assets__c where id ='aEr0R000000CazUSAS'];
            SET<string> setUserIds=new set<string>();
            for(dcmgt_Data_Assets__c arctileRec : alationdataassetslist)
            {
                if(arctileRec.dcmgt_Service_Owners__c != null){
                    setUserIds.addall(((map<string,object>) json.deserializeUntyped((arctileRec.dcmgt_Service_Owners__c).unescapeHtml4())).keyset());
                }
                if(arctileRec.dcmgt_Data_Stewards__c != null){
                    setUserIds.addall(((map<string,object>) json.deserializeUntyped((arctileRec.dcmgt_Data_Stewards__c).unescapeHtml4())).keyset());
                }
            }
           
            Map<Id,User> userMap=new Map<Id,User>([Select Id,Email from User where id in :setUserIds]);
            for(dcmgt_Data_Assets__c dataassetRec : alationdataassetslist)
            {
                Integer dsID;
                HttpResponse dsresponse = invokeGetRestAPI(alationSetting.dcmgt_Alation_Base_Endpoint_URL__c+'/catalog/table/?schema_name='+dataassetRec.dcmgt_Schema_Name__c,token) ;
                List<Object> dsResults = (List<Object>) JSON.deserializeUntyped(dsresponse.getBody());
                for (Object dsJsonNode:dsResults)
                {  
                    Map<String,Object> dsResult=(Map<String,Object>)dsJsonNode;                              
                    dsID = (Integer)dsResult.get('ds_id');
                    System.debug('DSID'+dsID);
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
                    if(dataassetRec.dcmgt_Data_Classification__c!=null)
                    {
                        postMap.put('Data Classification',dataassetRec.dcmgt_Data_Classification__c);
                    }    
                    if(dataassetRec.dcmgt_Business_Process__c!=null)
                    {
                        postMap.put('Business Process',dataassetRec.dcmgt_Business_Process__c);
                    }
                    if(dataassetRec.dcmgt_Business_Rules__c!=null)
                    {
                        postMap.put('Business Rules',dataassetRec.dcmgt_Business_Rules__c);
                    }
                    if(dataassetRec.dcmgt_Subject_Area__c!=null)
                {
                    String listSubjectArea = dataassetRec.dcmgt_Subject_Area__c.replace(';',',');
                    System.debug(listSubjectArea);
                    List<String> subArea = listSubjectArea.split(',');
                    postMap.put('Subject Area',subArea);
                   
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
                    if(dataassetRec.dcmgt_Business_Owners__c!=null)
                    {
                        List<Map<String,String>> dataOwnersList=new List<Map<String,String>>();
                        Map<String,String> dataOwnersMap = (Map<String,String>)JSON.deserialize((dataassetRec.dcmgt_Business_Owners__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                        List<String> userIds=new List<String>(dataOwnersMap.keyset());
                        for(String userID:userIds)
                        {
                            User user=userMap.get(userID);
                            Map<String,String> dataOwnerJsonMap=new Map<String,String>();
                            dataOwnerJsonMap.put('type','user');
                            dataOwnerJsonMap.put('key',user.Email);
                            dataOwnersList.add(dataOwnerJsonMap);                    
                        }
                        postMap.put('Service Owner',dataOwnersList);
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
                        postMap.put('Data Steward',stewardList);
                       
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
                    if(dataassetRec.dcmgt_Big_ID_URL__c!=null)
                    {
                        postMap.put('BigID URL',dataassetRec.dcmgt_Big_ID_URL__c);
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
                        postMap.put('Data  Owner',serviceOwnerList);
                       
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
                        System.debug('Body:'+Blob.valueOf(body));
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
                    System.debug(dataassetRec.dcmgt_Data_Assets_Name__c.removeEnd('.'));
                    System.debug(dataassetRec.dcmgt_Full_name__c);
                    String s1 = dataassetRec.dcmgt_Full_name__c.substringAfter('.');
                    System.debug(s1);
                    postMap.put('key',dsID+'.'+s1);
                    if(dataassetRec.dcmgt_Description__c!=null)
                    {
                        postMap.put('description',dataassetRec.dcmgt_Description__c);
                    }
                    if(dataassetRec.dcmgt_Business_Process__c!=null)
                    {
                        postMap.put('Business Process',dataassetRec.dcmgt_Business_Process__c);
                    }
                     if(dataassetRec.dcmgt_Data_Classification__c!=null)
                     {
                         postMap.put('Data Classification',dataassetRec.dcmgt_Data_Classification__c);
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
                    if(dataassetRec.dcmgt_Business_Owners__c!=null)
                    {
                        System.debug('Inside Business Owner method');
                        List<Map<String,String>> dataOwnersList=new List<Map<String,String>>();
                        Map<String,String> dataOwnersMap = (Map<String,String>)JSON.deserialize((dataassetRec.dcmgt_Business_Owners__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
                        List<String> userIds=new List<String>(dataOwnersMap.keyset());
                        for(String userID:userIds)
                        {
                            User user=userMap.get(userID);
                            Map<String,String> dataOwnerJsonMap=new Map<String,String>();
                            dataOwnerJsonMap.put('type','user');
                            dataOwnerJsonMap.put('key',user.Email);
                            dataOwnersList.add(dataOwnerJsonMap);                    
                        }
                        postMap.put('Service Owner',dataOwnersList);
                    }
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
                        postMap.put('Data Owner',serviceOwnerList);
                       
                    }
                    if(dataassetRec.dcmgt_Data_Stewards__c!=null)
                    {
                        System.debug('Inside Data Stewrd if condition');
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
                        Map<String,String> stewardMap = (Map<String,String>)JSON.deserialize((dataassetRec.dcmgt_Tenant__c).replaceAll('&quot;','"').replaceAll(';',','), Map<String,String>.class);
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
                        //Create Article API
                        req.setEndpoint(alationSetting.dcmgt_Alation_Base_Endpoint_URL__c+'/api/v1/bulk_metadata/custom_fields/default/attribute?replace_values=true');
                        req.setMethod('POST');
                        req.setHeader('Content-Type','application/json');
                        req.setHeader('Token',TOKEN);
                        req.setBodyAsBlob(Blob.valueOf(body));
                        //req.setBodyAsBlob(body);
                        req.setTimeout(30000);
                        System.debug('Body:'+body);
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
        }catch(System.CalloutException ex)
        {
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }
        catch(Exception ex)
        {
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }  
    }
     public static void testDeleteArticles()
    {
        String TOKEN = dcmgt_alation_token_management.createAPIAccessToken();
         String result = '';
            List<dcmgt_Alation_Article__c> alationarticleslist = [Select id,Name,dcmgt_Is_Active__c,dcmgt_Life_Cycle_Status__c,dcmgt_Staged_Alation_Article__c,
                                                                  dcmgt_Change_Request__c,dcmgt_Change_Request__r.dcmgt_Change_Request_Type__c, dcmgt_Change_Request__r.dcmgt_Change_Type__c
                                                                  from dcmgt_Alation_Article__c where id in ('a057d00000DGVIzAAP')];
            dcmgt_Alation_Settings__mdt alationSetting=[Select dcmgt_Alation_Base_Endpoint_URL__c from dcmgt_Alation_Settings__mdt LIMIT 1];
        System.debug(alationSetting);    
        SET<string> setUserIds=new set<string>();
        Map<String,Object> postMap=new Map<String,Object>();
         
            for(dcmgt_Alation_Article__c arctileRec : alationarticleslist)
            {
                 postMap.put('key',arctileRec.Name);
                System.debug(arctileRec.Name);
                if(arctileRec.dcmgt_Is_Active__c == false){
                    postMap.put('LIFE CYCLE STATUS','Deprecated');  
                }
                   
String body=JSON.serialize(postMap);
                System.debug(body);
                String Glossaries;
                dcmgt_Glossary_Article__c glossary_article=new dcmgt_Glossary_Article__c();
                if(arctileRec.dcmgt_Staged_Alation_Article__c != null){
                    glossary_article=[Select dcmgt_Alation_Glossary__r.Name from dcmgt_Glossary_Article__c where dcmgt_Alation_Article__c = :arctileRec.dcmgt_Staged_Alation_Article__c];
                    dcmgt_Alation_Glossary__c alation_glossary=glossary_article.dcmgt_Alation_Glossary__r;
                    Glossaries = (alation_glossary.Name).replace(' ','%20');
                }
                else{
                    Glossaries=('Business Glossary').replace(' ','%20');
                }
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
}
}