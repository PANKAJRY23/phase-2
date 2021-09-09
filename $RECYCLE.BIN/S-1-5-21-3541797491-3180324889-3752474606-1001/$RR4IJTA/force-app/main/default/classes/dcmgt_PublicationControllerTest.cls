@isTest
private class dcmgt_PublicationControllerTest {
    static dcmgt_Data_Publication_Request__c createDraftPublicationRequet() {
        dcmgt_Data_Publication_Request__c publicationRequet = new dcmgt_Data_Publication_Request__c (
            dcmgt_Status__c = 'Draft',
            dcmgt_Requestor__c = UserInfo.getUserId()
        );
        insert publicationRequet;
        return publicationRequet;
    }
    
    static dcmgt_Data_Publication_Request__c createApprovedPublicationRequet() {
        dcmgt_Data_Publication_Request__c publicationRequet = new dcmgt_Data_Publication_Request__c (
            dcmgt_Status__c = 'Approval',
            dcmgt_Requestor__c = UserInfo.getUserId()
        );
        insert publicationRequet;
        return publicationRequet;
    }
    
    @isTest
    static void testGetDataPubRequestForCurrentUserWithExistingDraftPubReq() {
        createDraftPublicationRequet();
        Test.startTest();
        	dcmgt_Data_Publication_Request__c publicationRequet = 
                dcmgt_PublicationController.getDataPubRequestForCurrentUser();
        Test.stopTest();
        System.assertNotEquals(null, publicationRequet, 'It should return a Publication request');
    }
    
    @isTest
    static void testGetDataPubRequestForCurrentUserWithoutExistingDraftPubReq() {
        createApprovedPublicationRequet();
        Test.startTest();
        	dcmgt_Data_Publication_Request__c publicationRequet = 
                dcmgt_PublicationController.getDataPubRequestForCurrentUser();
        Test.stopTest();
        System.assertNotEquals(null, publicationRequet, 'It should return a Publication request');
    }
    
    @isTest
    static void testGetDataPubRequestForCurrentUserWithoutExistingPubReq() {
        Test.startTest();
        	dcmgt_Data_Publication_Request__c publicationRequet = 
                dcmgt_PublicationController.getDataPubRequestForCurrentUser();
        Test.stopTest();
        System.assertNotEquals(null, publicationRequet, 'It should return a Publication request');
    }
    
    @isTest
    static void testUpdatePublicationRequest() {
        dcmgt_Data_Publication_Request__c pubReq = createDraftPublicationRequet();
        dcmgt_Team__c team = new dcmgt_Team__c(
            name = 'test team'
        );
        insert team;
        dcmgt_Service__c service = new dcmgt_Service__c(
            name = 'test service',
            dcmgt_Service_Owner__c = team.Id
        );
        insert service;
        dcmgt_Alation_Data_Dictionary__c dataDictionary = new dcmgt_Alation_Data_Dictionary__c(
            name = 'test Data Dictionary'
        );
        insert dataDictionary;
        Test.startTest();
        	dcmgt_PublicationController.updatePublicationRequest(pubReq.Id, team.Id, service.Id, dataDictionary.Id);
        Test.stopTest();
        dcmgt_Data_Publication_Request__c publicationRequet = [SELECT Id, dcmgt_Team__c FROM dcmgt_Data_Publication_Request__c
                                                              WHERE Id = :pubReq.Id];
        System.assertEquals(team.Id, publicationRequet.dcmgt_Team__c, 'It should return a Publication request with tenant Id');
    }
    
    @isTest
    static void testPublishDataPublicationRequestWithAllDetails() {
        dcmgt_Data_Publication_Request__c pubReq = createDraftPublicationRequet();
        dcmgt_Team__c team = new dcmgt_Team__c(
            name = 'test team'
        );
        insert team;
        dcmgt_Service__c service = new dcmgt_Service__c(
            name = 'test service',
            dcmgt_Service_Owner__c = team.Id
        );
        insert service;
        dcmgt_Alation_Data_Dictionary__c dataDictionary = new dcmgt_Alation_Data_Dictionary__c(
            name = 'test Data Dictionary'
        );
        insert dataDictionary;
        pubReq.dcmgt_Team__c = team.Id;
        pubReq.dcmgt_Service__c = service.Id;
        pubReq.dcmgt_Alation_Data_Dictionary__c = dataDictionary.Id;
        update pubReq;
        String jsonData = '[{"Id":"a071h000004fWdoAAE","tenantName":"HR","dataSource":"ABC Insurance",'+
            '"Name":"Data Assert 27","classification":"Internal","publicVisiblity":true,'+
            '"schema":"ABCInsurance.dbo","type":"Table"}]';
        Test.startTest();
        	String result = dcmgt_PublicationController.publishDataPublicationRequest(pubReq.Id, jsonData);
        Test.stopTest();
		System.assertEquals('success', result, 'It should return success String');        
	}
    
    @isTest
    static void testPublishDataPublicationRequestWithoutAllDetails() {
        dcmgt_Data_Publication_Request__c pubReq = createDraftPublicationRequet();
        String jsonData = '[{"Id":"a071h000004fWdoAAE","tenantName":"HR","dataSource":"ABC Insurance",'+
            '"Name":"Data Assert 27","classification":"Internal","publicVisiblity":true,'+
            '"schema":"ABCInsurance.dbo","type":"Table"}]';
        Test.startTest();
        	String result = dcmgt_PublicationController.publishDataPublicationRequest(pubReq.Id, jsonData);
        Test.stopTest();
		System.assertEquals('error', result, 'It should return error String');        
	}
    
    @isTest
    static void testGetAllPendingRequest() {
        dcmgt_Data_Publication_Request__c publicationRequet = new dcmgt_Data_Publication_Request__c (
            dcmgt_Status__c = 'Pending Approval',
            dcmgt_Requestor__c = UserInfo.getUserId()
        );
        insert publicationRequet;
        dcmgt_Data_Assets__c dataAsset = new dcmgt_Data_Assets__c(
            name = 'test Data Asset'
        );
        insert dataAsset;
        dcmgt_Data_Asset_Publication_Request__c dataAssetPubReq = new dcmgt_Data_Asset_Publication_Request__c(
            dcmgt_Data_Publication_Request__c = publicationRequet.Id,
            dcmgt_Data_Publication_Request__r = publicationRequet,
            dcmgt_Data_Asset_USC_ID__c = dataAsset.Id
        );
        insert dataAssetPubReq;
        Test.startTest();
        	List<dcmgt_PublicationController.publicationReqWrapper> pubReqWrapper = 
                dcmgt_PublicationController.getAllPendingRequest();
        Test.stopTest();
		System.assertNotEquals(null, pubReqWrapper, 'Result can not be null');
    }
    
    @isTest
    static void testGetAllApprovals() {
        dcmgt_Data_Publication_Request__c pubReq = createApprovedPublicationRequet();
        Test.startTest();
        	List<dcmgt_PublicationController.publicationReqWrapper> pubReqWrapper = 
                dcmgt_PublicationController.getAllApprovals();
        Test.stopTest();
		System.assertNotEquals(null, pubReqWrapper, 'Result can not be null');
    }
    
    @isTest static void testNotifySubscribers() {
        Test.startTest();
        String result = dcmgt_PublicationController.notifySubscribers('Test Message', 
        	new List<Id>{UserInfo.getUserId()});
        Test.stopTest();
        System.assertNotEquals(null, result, 'Result can not be null');
    }
    
    @isTest static void testGetDataContractByCurrentUser() {
        dcmgt_Data_Sub_Request__c subReq = new dcmgt_Data_Sub_Request__c(
            dcmgt_Requestor__c = UserInfo.getUserId()
        );
        insert subReq;
        Test.startTest();
        List<dcmgt_PublicationController.DataContractWrapper> listOfDataContrcat = dcmgt_PublicationController.getDataContractByCurrentUser();
        Test.stopTest();
        System.assertNotEquals(null, listOfDataContrcat, 'Result can not be null');
        //dcmgt_Data_Contract__c dataContract = 
    }
    
    @isTest static void testWrapperConstuctor() {
        dcmgt_PublicationController.DataContractWrapper dataContractWrapper =
            new dcmgt_PublicationController.DataContractWrapper('id', 'preferredDuration', 'dataAsset',
            'dataSource', 'producerTenant', 'consumerTenant');
        dcmgt_PublicationController.publicationReqWrapper publicationReqWrapper =
            new dcmgt_PublicationController.publicationReqWrapper('tenantName', 'dataSource', 'name', 
            10, 'uscId', 'publicationReqLink');
        System.assertNotEquals(null, dataContractWrapper, 'Wrapper can not be null');
        System.assertNotEquals(null, publicationReqWrapper, 'Wrapper can not be null');
    }
}