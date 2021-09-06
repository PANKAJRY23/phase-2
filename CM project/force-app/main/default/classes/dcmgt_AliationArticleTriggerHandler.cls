public with sharing class dcmgt_AliationArticleTriggerHandler {
    // public static void approveChangeRequest(Map<Id, dcmgt_Alation_Article__c> newMapOfArticle,
    //     Map<Id, dcmgt_Alation_Article__c> oldMapOfArticle) {

    //     Set<Id> setOfChageRequestId = new Set<Id>();
    //     for(String key : newMapOfArticle.keySet()) {
    //         if(newMapOfArticle.get(key).dcmgt_IsApproved__c == true &&
    //             oldMapOfArticle.get(key).dcmgt_IsApproved__c 
    //             != newMapOfArticle.get(key).dcmgt_IsApproved__c ) {

    //             setOfChageRequestId.add(newMapOfArticle.get(key).dcmgt_Change_Request__c);
    //         }
    //     }

    //     List<dcmgt_Change_Request__c> lsitOfChangeRequest = [ 
    //         SELECT Id, dcmgt_Status__c, 
    //             (SELECT Id FROM dcmgt_Alation_Article__r WHERE dcmgt_IsApproved__c = false) 
    //         FROM dcmgt_Change_Request__c WHERE Id IN :setOfChageRequestId
    //     ];
    //     List<dcmgt_Change_Request__c> lsitOfChangeRequestToBeUpdate = 
    //         new List<dcmgt_Change_Request__c>();
    //     for(dcmgt_Change_Request__c changeRequest : lsitOfChangeRequest) {
    //         if(changeRequest.dcmgt_Alation_Article__r.size() == 0) {
    //             changeRequest.dcmgt_Status__c = 'Approved';
    //             lsitOfChangeRequestToBeUpdate.add(changeRequest);
    //         }
    //     }
    //     if(!lsitOfChangeRequestToBeUpdate.isEmpty()) {
    //         Database.update(lsitOfChangeRequestToBeUpdate, false);
    //     }
    // }


    public static void rejectChangeRequest(Map<Id, dcmgt_Alation_Article__c> newMapOfArticle,
    Map<Id, dcmgt_Alation_Article__c> oldMapOfArticle) {

    Set<Id> setOfChageRequestId = new Set<Id>();
    for(String key : newMapOfArticle.keySet()) {
        if(newMapOfArticle.get(key).dcmgt_Status__c == 'Rejected' || newMapOfArticle.get(key).dcmgt_IsApproved__c == true) {
            System.debug('setOfChageRequest' + setOfChageRequestId);
            setOfChageRequestId.add(newMapOfArticle.get(key).dcmgt_Change_Request__c);
        }
    }

    List<dcmgt_Change_Request__c> lsitOfChangeRequest = [ 
        SELECT Id, dcmgt_Status__c, 
        (SELECT Id,dcmgt_Status__c FROM dcmgt_Alation_Article__r) 
        FROM dcmgt_Change_Request__c WHERE Id IN :setOfChageRequestId
    ];
    System.debug('listodchange'+lsitOfChangeRequest);
    List<dcmgt_Change_Request__c> lsitOfChangeRequestToBeUpdate = 
        new List<dcmgt_Change_Request__c>();
    for(dcmgt_Change_Request__c changeRequest : lsitOfChangeRequest) {
        Integer completedStatus = 0;
        Integer submittedStatus = 0;
        Integer inReviewStatus = 0;
        Integer approvedStatus = 0;
        Integer rejectedStatus = 0;
        Integer underProcessingStatus = 0;
        Integer completedRejectedStatus = 0;
        for(dcmgt_Alation_Article__c articles : changeRequest.dcmgt_Alation_Article__r )
        {
            if(articles.dcmgt_Status__c== 'Completed')
            {
                completedStatus++;
            }
            else if(articles.dcmgt_Status__c== 'Submitted')
            {
                submittedStatus++;
            }
            else if(articles.dcmgt_Status__c== 'In Review')
            {
                inReviewStatus++;
            }
            else if(articles.dcmgt_Status__c== 'Approved')
            {
                approvedStatus++;
            }
            else if(articles.dcmgt_Status__c== 'Rejected')
            {
                rejectedStatus++;
            }
            else if(articles.dcmgt_Status__c== 'Under Processing')
            {
                underProcessingStatus++;
            }
        
        }
        	if(changeRequest.dcmgt_Alation_Article__r.size() == submittedStatus )
            {
                changeRequest.dcmgt_Status__c = 'Submitted';
                lsitOfChangeRequestToBeUpdate.add(changeRequest);
            }
            if(changeRequest.dcmgt_Alation_Article__r.size() == completedStatus )
            {
                changeRequest.dcmgt_Status__c = 'Implemented';
                lsitOfChangeRequestToBeUpdate.add(changeRequest);
            }else if((changeRequest.dcmgt_Alation_Article__r.size() == approvedStatus)||(changeRequest.dcmgt_Alation_Article__r.size() == rejectedStatus))
            {
                 changeRequest.dcmgt_Status__c = 'Completed';
                lsitOfChangeRequestToBeUpdate.add(changeRequest);
            }else if(changeRequest.dcmgt_Alation_Article__r.size() == (completedStatus+rejectedStatus))
            {
                changeRequest.dcmgt_Status__c = 'Implemented';
                lsitOfChangeRequestToBeUpdate.add(changeRequest);
            }
        	else if(changeRequest.dcmgt_Alation_Article__r.size() == (approvedStatus+rejectedStatus))
            {
                changeRequest.dcmgt_Status__c = 'Completed';
                lsitOfChangeRequestToBeUpdate.add(changeRequest);
            }
            
        
  
    }
    if(!lsitOfChangeRequestToBeUpdate.isEmpty()) {
        Database.update(lsitOfChangeRequestToBeUpdate, false);
    }
}

    
     	
    public static void checkDuplicateArticleUpdateRequest(List<dcmgt_Alation_Article__c> listOfArticle) {	
        Set<Decimal> setOfAliationId = new Set<Decimal>();	
        for(dcmgt_Alation_Article__c article : listOfArticle) {	
            if(article.dcmgt_Alation_Id__c != null) {
                setOfAliationId.add(article.dcmgt_Alation_Id__c);	
            }
        }	
        Set<String> setOfStatus = new Set<String>{
            'Rejected' , 'Approved'
        };
        List<dcmgt_Alation_Article__c> listOfExistingArticle = [SELECT Id, dcmgt_Alation_Id__c 	
                                                                FROM dcmgt_Alation_Article__c 	
                                                                WHERE dcmgt_Alation_Id__c IN :setOfAliationId 	
                                                                	AND dcmgt_Status__c Not IN :setOfStatus];	
        Set<Decimal> setOfExistingAliationId = new Set<Decimal>();	
        for(dcmgt_Alation_Article__c article : listOfExistingArticle) {	
            setOfExistingAliationId.add(article.dcmgt_Alation_Id__c);	
        }	
        List<Id> listOfChangeRequestIds = new List<Id>();
        List<String> articleNames = new List<String>();
        for(dcmgt_Alation_Article__c article : listOfArticle) {	
            if(setOfExistingAliationId.contains(article.dcmgt_Alation_Id__c)) {	
                listOfChangeRequestIds.add(article.dcmgt_Change_Request__c);	
                //delete [SELECT Id FROM dcmgt_Change_Request__c WHERE Id = :article.dcmgt_Change_Request__c];	
                article.addError('Duplicate Article request ---'+article.Name);
                System.debug('Duplicate Articles'+article.Name);
            }	
        }	
        	
    }
}