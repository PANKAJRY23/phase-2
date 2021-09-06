public class dcmgt_alation_token_management {
    
    public static String createAPIAccessToken()
    {
        String API_accessToken=null;
        try{
            dcmgt_Alation_Settings__mdt alationSetting=[Select dcmgt_Alation_Base_Endpoint_URL__c,dcmgt_Alation_Refresh_Token__c,dcmgt_Alation_User_ID__c from dcmgt_Alation_Settings__mdt LIMIT 1];
            if(alationSetting!=null)
            {
                HttpRequest request = new HttpRequest();
                request.setEndpoint(alationSetting.dcmgt_Alation_Base_Endpoint_URL__c+'/integration/v1/createAPIAccessToken/');
                request.setMethod('POST');
                request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
                request.setBody('user_id='+alationSetting.dcmgt_Alation_User_ID__c+'&refresh_token='+alationSetting.dcmgt_Alation_Refresh_Token__c);
                request.setTimeout(30000);
                Http http = new Http();
                HttpResponse response = http.send(request);
                if(response.getStatusCode()==201)
                {
                    Map<String,Object> responseMap=(Map<String,Object>)JSON.deserializeUntyped(response.getBody()); 
                    API_accessToken=(String)responseMap.get('api_access_token');
                }else{
                    return getErrorMessage(response.getStatusCode());
                }
            }
           }catch(System.CalloutException ex) 
           {
                return ex.getMessage();
           }
           catch(Exception ex) 
           {
                return ex.getMessage();
           }
       return API_accessToken; 
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