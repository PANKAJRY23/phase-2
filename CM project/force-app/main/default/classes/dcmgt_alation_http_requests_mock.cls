@isTest
global class dcmgt_alation_http_requests_mock implements HttpCalloutMock {
 protected String type;
 public dcmgt_alation_http_requests_mock(String type)
 {
     this.type=type;
 }
 global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        
        if(this.type.equals('accessToken'))
        {
         response.setBody('GUBTcayxrr69vPM6XaS4y296gmJzyS');
        }
     	if(this.type.equals('article'))
        {
            response.setBody('{"article","{id:201}"}');
        }
     	if(this.type.equals('datasource'))
        {
         response.setBody('{"datasource","{id:201}"}');
        }
        response.setStatusCode(200);
        return response;

}
    
}