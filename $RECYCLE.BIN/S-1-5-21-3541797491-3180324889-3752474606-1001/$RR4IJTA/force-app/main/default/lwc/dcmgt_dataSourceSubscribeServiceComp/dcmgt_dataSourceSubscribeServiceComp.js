import { LightningElement, track, wire } from 'lwc';
import pubSubMessageChannel from '@salesforce/messageChannel/dcmgt_SubMessageChannel__c'
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import getDataSubRequestByTeamId from '@salesforce/apex/dcmgt_SubscriptionDataSourceController.getDataSubRequestByTeamId'
import updateSubscriptionRec from '@salesforce/apex/dcmgt_SubscriptionDataSourceController.updateSubscriptionRec'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class Dcmgt_dataSourceSubscribeServiceComp extends LightningElement {


    @wire(MessageContext)
    context
    @track SelecttenantId
    dataSourceId
    selectedSubscriptionReq

    connectedCallback() {
        if(!this.subscription) {
            this.subscribeTenant()
        }


    }

    getDataScoreId(teamIdValue){
        console.log('=teamIdValue=0'+teamIdValue)
        getDataSubRequestByTeamId({teamId: teamIdValue})
        .then(result => {
            console.log('=resultteamIdValue=0'+result)
            if(result.dcmgt_Alation_Data_Dictionary__c){
                this.dataSourceId = result.dcmgt_Alation_Data_Dictionary__c;
            }
            this.selectedSubscriptionReq = result.Id
            
        })
        .catch(error => {
            console.log('error-578-',error);
        });
    }

    subscribeTenant() {
        this.subscription = subscribe(this.context, pubSubMessageChannel,  (message) => {this.handleMessage(message)}, {scope:APPLICATION_SCOPE} )
    }

    handleMessage(message) { 
        
        
        console.log('Data Source Tenant Id', message.tenantId.value)
        console.log('Data Source tenant name', message.tenantId.name)
        this.SelecttenantId = message.tenantId.value
        if(this.SelecttenantId){
            this.getDataScoreId(message.tenantId.value)
        }
    }

    handleSuccess(event) {
        let newRecordId = event.detail.id
        console.log('Id==48==', newRecordId)
        console.log('Id==this.dataSourceId=='+this.dataSourceId)
        if(!this.dataSourceId){
            this.dataSourceId = event.detail.id
            this.updateSubscription(event.detail.id)
        }
       
        this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Data Source Submitted Successfully',
                variant: 'success',
            })
        )
    }

    updateSubscription(value){
        updateSubscriptionRec({dataSourceId: value, teamId:this.SelecttenantId})
        .then(data => {
            
        }).catch(error => {
            console.error('createTeamMenberForTenant error', error)
        }) 
    }



}