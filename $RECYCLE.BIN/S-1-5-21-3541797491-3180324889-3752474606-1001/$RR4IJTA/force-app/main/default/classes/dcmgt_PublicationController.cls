public with sharing class dcmgt_PublicationController {
    
    @AuraEnabled
    public static dcmgt_Data_Publication_Request__c getDataPubRequestForCurrentUser(){
        try {
            Set<String> setOfReuestStatus = new Set<String> {
                'Draft'
            };
            List<dcmgt_Data_Publication_Request__c>  listOfDraftPublicationRequest = new List<dcmgt_Data_Publication_Request__c> ();
            Id currentUserId = UserInfo.getUserId();
            listOfDraftPublicationRequest = [SELECT Id, dcmgt_Requestor__c, dcmgt_Team__c,dcmgt_Service__c, 
                    dcmgt_Alation_Data_Dictionary__c, dcmgt_Status__c 
                FROM dcmgt_Data_Publication_Request__c 
                WHERE dcmgt_Requestor__c = :currentUserId 
                    AND  dcmgt_Status__c  IN :setOfReuestStatus 
                WITH SECURITY_ENFORCED
                ORDER BY CreatedDate DESC LIMIT 1];
            if(listOfDraftPublicationRequest.isEmpty()) {
                setOfReuestStatus = new Set<String> {
                    'Pending Approval', 'Approval'
                };
                List<dcmgt_Data_Publication_Request__c> listOfPublishedRequest = new List<dcmgt_Data_Publication_Request__c>();
                listOfPublishedRequest = [SELECT Id, dcmgt_Requestor__c, dcmgt_Team__c,dcmgt_Service__c, 
                        dcmgt_Alation_Data_Dictionary__c, dcmgt_Status__c 
                    FROM dcmgt_Data_Publication_Request__c 
                    WHERE dcmgt_Requestor__c = :currentUserId 
                        AND  dcmgt_Status__c  IN :setOfReuestStatus 
                    WITH SECURITY_ENFORCED
                    ORDER BY CreatedDate DESC LIMIT 1];
                if(listOfPublishedRequest.isEmpty()) {
                    listOfDraftPublicationRequest = new List<dcmgt_Data_Publication_Request__c>{
                        new dcmgt_Data_Publication_Request__c(
                            dcmgt_Requestor__c = currentUserId,
                            dcmgt_Status__c = 'Draft'
                        )};
                } else {
                    dcmgt_Data_Publication_Request__c publicationRequest = listOfPublishedRequest[0].clone();
                    // publicationRequest.dcmgt_NextApproverRequired__c = false;
                    publicationRequest.dcmgt_Status__c = 'Draft';
                    listOfDraftPublicationRequest.add(publicationRequest);
                }
                
                insert listOfDraftPublicationRequest;
                System.debug('publicationRequest'+listOfDraftPublicationRequest);
            }
            return listOfDraftPublicationRequest[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void updatePublicationRequest(String publicationRequestId, String tenantId, 
        String serviceId, String dataSourceId){

        try {
            System.debug('publicationRequestId:- '+publicationRequestId);
            System.debug('tenantId:- '+tenantId);
            System.debug('serviceId:- '+serviceId);
            System.debug('dataSourceId:- '+dataSourceId);
            if(!String.isBlank(publicationRequestId)) {
                
                Boolean isRecordUpdated = false;
                dcmgt_Data_Publication_Request__c  publicationRequest = 
                    new dcmgt_Data_Publication_Request__c(Id = publicationRequestId);
                if(!String.isBlank(tenantId) || !String.isBlank(serviceId)) {
                    publicationRequest.dcmgt_Team__c = tenantId;
                    publicationRequest.dcmgt_Service__c = serviceId;
                    isRecordUpdated = true;
                }
                // if(!String.isBlank(serviceId)) {
                //     publicationRequest.dcmgt_Service__c = serviceId;
                //     isRecordUpdated = true;
                // }
                if(!String.isBlank(dataSourceId)) {
                    publicationRequest.dcmgt_Alation_Data_Dictionary__c = dataSourceId;
                    isRecordUpdated = true;
                }
                if(isRecordUpdated) {
                    update publicationRequest;
                }
            }
            

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String publishDataPublicationRequest(String publicationRequestId, 
        String dataAssetJsonString){
        try {
            String result = 'success';
            System.debug('dataAssetJsonString:- '+dataAssetJsonString);
            System.debug('publicationRequestId:- '+publicationRequestId);
            if(!String.isBlank(publicationRequestId)) {
                dcmgt_Data_Publication_Request__c publicationReq =
                    [SELECT Id, dcmgt_Requestor__c, dcmgt_Team__c, dcmgt_Service__c, 
                        dcmgt_Alation_Data_Dictionary__c, dcmgt_Status__c 
                    FROM dcmgt_Data_Publication_Request__c 
                    WHERE Id = :publicationRequestId 
                    WITH SECURITY_ENFORCED];
                if(String.isBlank(publicationReq.dcmgt_Team__c) || 
                    String.isBlank(publicationReq.dcmgt_Service__c) || 
                    String.isBlank(publicationReq.dcmgt_Alation_Data_Dictionary__c)) {

                    result = 'error';
                } else {
                    dcmgt_Data_Publication_Request__c  publicationRequest = 
                        new dcmgt_Data_Publication_Request__c(
                            Id = publicationRequestId,
                            dcmgt_Status__c = 'Pending Approval'
                        );
                    update publicationRequest;

                    List<dcmgt_Data_Asset_Publication_Request__c> listOfDataAssetPubliactionReq =
                        new List<dcmgt_Data_Asset_Publication_Request__c>();
                    List<Object> listOfDataAsset = (List<Object>)JSON.deserializeUntyped(dataAssetJsonString);
                    for(Object dataAsset : listOfDataAsset) {
                        dcmgt_Data_Asset_Publication_Request__c dataAssetPubReq = 
                            new dcmgt_Data_Asset_Publication_Request__c();
                        String jsonData = JSON.serialize(dataAsset);
                        Map<String,Object> mapOfJsonData = (Map<String,Object>)JSON.deserializeUntyped(jsonData);
                        dataAssetPubReq.dcmgt_Data_Publication_Request__c = publicationRequestId;
                        dataAssetPubReq.dcmgt_Data_Asset_Name__c = mapOfJsonData.get('Name').toString();
                        dataAssetPubReq.dcmgt_Data_Asset_USC_ID__c = mapOfJsonData.get('id').toString();
                        dataAssetPubReq.dcmgt_Public_Visibility__c = Boolean.valueOf(mapOfJsonData.get('publicVisiblity').toString());
                        dataAssetPubReq.dcmgt_Data_Asset_Type__c = mapOfJsonData.get('type').toString();
                        dataAssetPubReq.dcmgt_Full_Name__c = mapOfJsonData.get('Full_Name').toString();
                        dataAssetPubReq.dcmgt_Description__c = mapOfJsonData.get('description').toString();
                        listOfDataAssetPubliactionReq.add(dataAssetPubReq);
                    }
                    insert listOfDataAssetPubliactionReq;
                    System.debug('listOfDataAssetPubliactionReq:- '+listOfDataAssetPubliactionReq);
                }
            }
            return result;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<publicationReqWrapper> getAllPendingRequest(){
        return getPubliactionRequestWrapper('Pending Approval');
    }

    private static List<publicationReqWrapper> getPubliactionRequestWrapper(String requestStatus){
        try {
            List<publicationReqWrapper> listOfRequestWrapper = new List<publicationReqWrapper>();
            List<dcmgt_Data_Asset_Publication_Request__c> listOfDataAssetPubReq = 
                [SELECT Id, dcmgt_Data_Publication_Request__c,
                        dcmgt_Data_Publication_Request__r.dcmgt_Alation_Data_Dictionary__r.name,
                        dcmgt_Data_Publication_Request__r.dcmgt_Team__r.Name, 
                        dcmgt_Data_Asset_Name__c, dcmgt_Data_Asset_USC_ID__c
                    FROM dcmgt_Data_Asset_Publication_Request__c 
                    WHERE dcmgt_Data_Publication_Request__r.dcmgt_Requestor__c = :UserInfo.getUserId()
                        AND dcmgt_Data_Publication_Request__r.dcmgt_Status__c = :requestStatus
                    WITH SECURITY_ENFORCED 
                    LIMIT 50000];
            Set<String> setOfdataAssetPubReqUSCId = new Set<String>();
            for(dcmgt_Data_Asset_Publication_Request__c dataAssetPub : listOfDataAssetPubReq) {
                setOfdataAssetPubReqUSCId.add(dataAssetPub.dcmgt_Data_Asset_USC_ID__c);
            }
            System.debug('setOfdataAssetPubReqUSCId'+setOfdataAssetPubReqUSCId);
            List<dcmgt_Data_Asset_Sub_Request__c> listOfDataAssetSubReq = 
                [SELECT Id, Name, dcmgt_Data_Asset_Name__c, dcmgt_Data_Asset_USC_ID__c, 
                    dcmgt_Data_Subscription_Request__r.dcmgt_Requestor__c, 
                    dcmgt_Data_Subscription_Request__r.dcmgt_Requestor__r.Name  
                FROM dcmgt_Data_Asset_Sub_Request__c 
                WHERE dcmgt_Data_Asset_USC_ID__c IN :setOfdataAssetPubReqUSCId
                WITH SECURITY_ENFORCED];
            System.debug('listOfDataAssetSubReq'+listOfDataAssetSubReq);
            Map<String, Set<String>> mapOdDataAssetUSCIdAndRequestor = new Map<String, Set<String>>();
            for(dcmgt_Data_Asset_Sub_Request__c dataAssetSubReq : listOfDataAssetSubReq) {
                if(!mapOdDataAssetUSCIdAndRequestor.containsKey(
                    dataAssetSubReq.dcmgt_Data_Asset_USC_ID__c)) {

                    mapOdDataAssetUSCIdAndRequestor.put(
                        dataAssetSubReq.dcmgt_Data_Asset_USC_ID__c, new Set<String>());
                }
                Set<String> setOfRequestor = mapOdDataAssetUSCIdAndRequestor.get(
                    dataAssetSubReq.dcmgt_Data_Asset_USC_ID__c);
                setOfRequestor.add(dataAssetSubReq.dcmgt_Data_Subscription_Request__r.dcmgt_Requestor__c);
                mapOdDataAssetUSCIdAndRequestor.put(
                        dataAssetSubReq.dcmgt_Data_Asset_USC_ID__c, setOfRequestor);
            }
            System.debug('mapOdDataAssetUSCIdAndRequestor'+mapOdDataAssetUSCIdAndRequestor);
            publicationReqWrapper requestWrapper;
            for(dcmgt_Data_Asset_Publication_Request__c dataAssetPub : listOfDataAssetPubReq) {
                // Integer existingCustomers = 
                //     mapOdDataAssetUSCIdAndRequestor.containsKey(dataAssetPub.dcmgt_Data_Asset_USC_ID__c) :
                //     mapOdDataAssetUSCIdAndRequestor.get(dataAssetPub.dcmgt_Data_Asset_USC_ID__c).size() ?
                //     0;
                requestWrapper = new publicationReqWrapper(
                    dataAssetPub.dcmgt_Data_Publication_Request__r.dcmgt_Team__r.Name,
                    dataAssetPub.dcmgt_Data_Publication_Request__r.dcmgt_Alation_Data_Dictionary__r.name,
                    dataAssetPub.dcmgt_Data_Asset_Name__c,
                    mapOdDataAssetUSCIdAndRequestor.containsKey(dataAssetPub.dcmgt_Data_Asset_USC_ID__c) ?
                        mapOdDataAssetUSCIdAndRequestor.get(dataAssetPub.dcmgt_Data_Asset_USC_ID__c).size() :
                        0,
                    dataAssetPub.dcmgt_Data_Asset_USC_ID__c,
                    '/'+dataAssetPub.dcmgt_Data_Publication_Request__c
                );
                if('Approval'.equalsIgnoreCase(requestStatus)) {
                    requestWrapper.setOfRequestor = new List<String> (
                        mapOdDataAssetUSCIdAndRequestor.get(dataAssetPub.dcmgt_Data_Asset_USC_ID__c)
                    );
                }
                listOfRequestWrapper.add(requestWrapper);
            }
            return listOfRequestWrapper;
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(Cacheable = true)
    public static List<publicationReqWrapper> getAllApprovals(){
        try {
            return getPubliactionRequestWrapper('Approval');
            // return [SELECT Id, dcmgt_Data_Publication_Request__c,
            //             dcmgt_Data_Publication_Request__r.dcmgt_Alation_Data_Dictionary__r.name,
            //             dcmgt_Data_Publication_Request__r.dcmgt_Team__r.Name, 
            //             dcmgt_Data_Asset_Name__c  
            //         FROM dcmgt_Data_Asset_Publication_Request__c 
            //         WHERE dcmgt_Data_Publication_Request__r.dcmgt_Requestor__c = :UserInfo.getUserId()
            //             AND dcmgt_Data_Publication_Request__r.dcmgt_Status__c = 'Approval'
            //         WITH SECURITY_ENFORCED 
            //         LIMIT 50000];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static string notifySubscribers(String notificationMessage, List<Id> listOfUserId){
        try {
            System.debug('notificationMessage:- '+notificationMessage);
            System.debug('setOfUserId:- '+listOfUserId);
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>(); 
            List<String> lstOfToAddress = new List<String>{'rjadam@yourdataconnect.com'};
            // List<String> lstOfCcAddress = new List<String>();
            Set<String> setOfBccAddress = new Set<String>();
            List<User> listOfUser = [SELECT Id, Email FROM User WHERE Id IN :listOfUserId];
            for(User user : listOfUser) {
                setOfBccAddress.add(user.Email);
            }
            Messaging.SingleEmailMessage mail =  new Messaging.SingleEmailMessage();
            mail.setHtmlBody(notificationMessage);
            mail.setSubject('Notify Subscribers');
            if(lstOfToAddress.size()>0){  
                mail.setToAddresses(lstOfToAddress);   
            }
            System.debug('setOfBccAddress:- '+setOfBccAddress);
            // if(lstOfBccAddress.size()>0){ 
            //     mail.setBccAddresses(setOfBccAddress);
            // }
            mails.add(mail);
            if(mails.size() > 0 && !Test.isRunningTest()){  
                Messaging.sendEmail(mails);
            } 
            return String.join(new List<String>(setOfBccAddress), ',');
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<DataContractWrapper> getDataContractByCurrentUser(){
        try {
            List<DataContractWrapper> listOfDataContract = new List<DataContractWrapper>();
            List<dcmgt_Data_Sub_Request__c> listOfDataSubReq = 
                [SELECT Id, Name, 
                    (SELECT Id, dcmgt_Preferred_duration__c,
                        dcmgt_Data_Assets__r.Name, dcmgt_Data_Source__r.Name,
                        dcmgt_Data_Consumer_Tenant__c, dcmgt_Data_Producer_Tenant__c
                    FROM Data_Contracts__r 
                    ORDER BY dcmgt_Data_Source__c DESC LIMIT 1) 
                FROM dcmgt_Data_Sub_Request__c 
                WHERE dcmgt_Requestor__c = :UserInfo.getUserId()
                WITH SECURITY_ENFORCED]; //'0055e0000044RchAAE'
            for(dcmgt_Data_Sub_Request__c subReq : listOfDataSubReq) {
                if(!subReq.Data_Contracts__r.isEmpty()) {
                    dcmgt_Data_Contract__c dataContract = subReq.Data_Contracts__r[0];
                    DataContractWrapper dataContractWrapper = new DataContractWrapper(
                        dataContract.id,
                        dataContract.dcmgt_Preferred_duration__c, 
                        dataContract.dcmgt_Data_Assets__r.Name,
                        dataContract.dcmgt_Data_Source__r.Name,
                        dataContract.dcmgt_Data_Producer_Tenant__c, 
                        dataContract.dcmgt_Data_Consumer_Tenant__c);
                    listOfDataContract.add(dataContractWrapper);
                }
            }
            return listOfDataContract;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @testVisible class DataContractWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String preferredDuration;
        @AuraEnabled
        public String dataAsset;
        @AuraEnabled
        public String dataSource;
        @AuraEnabled
        public String producerTenant;
        @AuraEnabled
        public String consumerTenant;
        public DataContractWrapper(String id, String preferredDuration, String dataAsset,
            String dataSource, String producerTenant, String consumerTenant) {
              
            this.dataSource = dataSource;
            this.id = id;
            this.preferredDuration = preferredDuration;
            this.dataAsset = dataAsset;
            this.producerTenant = producerTenant;
            this.consumerTenant = consumerTenant;
        }
    }

    @testVisible class publicationReqWrapper {
        @AuraEnabled
        public String tenantName;
        @AuraEnabled
        public String publicationReqLink;
        @AuraEnabled
        public String dataSource;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String uscId;
        @AuraEnabled
        public Integer existingCustomers;
        @AuraEnabled
        public List<String> setOfRequestor;
        public publicationReqWrapper(String tenantName, String dataSource, String name, 
            Integer existingCustomers, String uscId, String publicationReqLink) {

            this.tenantName = tenantName;
            this.dataSource = dataSource;
            this.name = name;
            this.existingCustomers = existingCustomers;
            this.uscId = uscId;
            this.publicationReqLink = publicationReqLink;
        }
    }
}