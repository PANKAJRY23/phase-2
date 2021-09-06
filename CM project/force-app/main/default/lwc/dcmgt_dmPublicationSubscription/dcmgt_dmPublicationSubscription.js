import { LightningElement, wire, track } from 'lwc';
//import { CurrentPageReference } from 'lightning/navigation';
//import getSubRequest from '@salesforce/apex/dcmgt_SubscriptionTenantController.getSubRequest'

export default class Dcmgt_dmPublicationSubscription extends LightningElement {


    // urrentPageReference = null; 
    // urlStateParameters = null;

    // @track subscribtionRequestRecord
 
    // /* Params from Url */    
    // urlType = 'Publication';

    // @wire(getSubRequest)
    // checkSubscribtionRecord({data, error}){
    //     console.log('==data=29=',data)
    //     if(data){
    //         this.subscribtionRequestRecord = data[0]
    //     }
    // }
    // connectedCallback(){
    //     this.genricMethod();
    // }
 
    // @wire(CurrentPageReference)
    // getStateParameters(currentPageReference) {
    //    if (currentPageReference) {
    //       this.urlStateParameters = currentPageReference.state;
    //       this.setParametersBasedOnUrl();
    //    }
    // }
 
    // setParametersBasedOnUrl() {  
    //     if(this.urlStateParameters.c__id && this.urlStateParameters.c__counter){
    //         this.subscribtionRequestRecord = true
    //         this.urlType = 'Subscription'
    //     }
    //     console.log('==urlType=49='+this.urlType);
        
       
    // }

    // genricMethod(){
    //     getSubRequest()
    //     .then(data => {
    //         console.log('==data=49=',data);

    //         if(data.length >0){
    //             this.subscribtionRequestRecord = true
    //         }
            
    //     }).catch(error => {
    //         console.error('createTeamMenberForTenant error', error)
    //     })
    // }
}