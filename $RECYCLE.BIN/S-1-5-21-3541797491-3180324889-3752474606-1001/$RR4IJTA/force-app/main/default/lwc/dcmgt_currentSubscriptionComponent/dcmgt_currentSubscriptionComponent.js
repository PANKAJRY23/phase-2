import { LightningElement, track } from 'lwc';
import updateSubscriptionRec from '@salesforce/apex/dcmgt_CurrentSubscriptionController.getAllCurrentSubscriptionRec'
import extendApprovedSubscriptionRec from '@salesforce/apex/dcmgt_CurrentSubscriptionController.extendApprovedSubscriptionRec'
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation'

const Extended_Time = [
    {value: '3', label: '3 months'},
    {value: '6', label: '6 months'},
    {value: '9', label: '9 months'},
    {value: '12', label: '12 months'}    
];

export default class Dcmgt_currentSubscriptionComponent extends NavigationMixin(LightningElement) {

    data
    dataAssetSubscriptionRequestId
    @track extendComment
    @track ExtendedTimeOptions = Extended_Time
    @track selectedOptionsOfExtention

    connectedCallback() {       
        this.getCurrentRecordSub();
    }

    getCurrentRecordSub(){
        updateSubscriptionRec()
        .then(result => {
            //console.log('CurrentSubscriptionRecord',result)
            this.data = result
            
        })
        .catch(error => {
            console.log('error-578-',error); 
        });
    }

    onCheckBoxSelect(event){
        //console.log('==event.target==',event.target.dataset.id) 
        
        if(event.target.checked){           
            if(this.dataAssetSubscriptionRequestId){
                this.dataAssetSubscriptionRequestId = this.dataAssetSubscriptionRequestId+','+event.target.dataset.id;
            }else{
                this.dataAssetSubscriptionRequestId = event.target.dataset.id;
            }
        }else{
            if(this.dataAssetSubscriptionRequestId.includes(event.target.dataset.id+',')){
                this.dataAssetSubscriptionRequestId = this.dataAssetSubscriptionRequestId.replace(event.target.dataset.id+',','');
            }
            if(this.dataAssetSubscriptionRequestId.includes(event.target.dataset.id)){
                this.dataAssetSubscriptionRequestId = this.dataAssetSubscriptionRequestId.replace(event.target.dataset.id,'');
            }
        }
        let str = this.dataAssetSubscriptionRequestId;
        if(str.charAt(str.length-1) === ','){
            
            this.dataAssetSubscriptionRequestId = str.slice(0, -1);  
        }
        //console.log('==event.checked==',this.dataAssetSubscriptionRequestId)

        
    }

    richTextArea(event){
        //console.log('==event.target.value=='+event.target.value);
        this.extendComment = event.target.value;
    }

    selectTimeOptions(event){
        //console.log('==event.target.value=='+event.target.value);
        this.selectedOptionsOfExtention = event.target.value;
    }

    extendSubscription(){
       // console.log('==dataAssetSubscriptionRequestId=='+this.dataAssetSubscriptionRequestId);
       // console.log('==selectedOptionsOfExtention=='+this.selectedOptionsOfExtention);
      //  console.log('==extendComment=='+this.extendComment);

        if(!this.dataAssetSubscriptionRequestId || !this.selectedOptionsOfExtention){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!', 
                    message: 'Please select the Records and period for extending Subscription', 
                    variant: 'error'
                }),
            );
        }else{
            extendApprovedSubscriptionRec({ ids: this.dataAssetSubscriptionRequestId, extendComment: this.extendComment, extendedTime: this.selectedOptionsOfExtention})
            .then(result => {
                if(result == 'success') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'SUCCESS!', 
                            message: 'Extended successfully', 
                            variant: 'success'
                        }),
                    );       
                    this.getCurrentRecordSub();            
                } else {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error in Extend', 
                            message: 'Diffrent Owner Record is Selected', 
                            variant: 'error'
                        }),
                    );
                }
                
            })
            .catch(error => {
                console.log('error-496-',error);           
            
            });
        }
    }

    navigateToViewDriverPage(event) {
        // console.log('==event.target.data-id=1=113==',event.target.dataset.id);


        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.dataset.id,
                objectApiName: 'dcmgt_Data_Asset_Sub_Request__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
    }
}