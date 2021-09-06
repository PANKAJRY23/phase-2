import { LightningElement, track, wire } from 'lwc';
import pubSubMessageChannel from '@salesforce/messageChannel/dcmgt_SubMessageChannel__c'
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import methodForUpdateSubTeamId from '@salesforce/apex/dcmgt_SubscriptionDataSourceController.methodForUpdateSubTeamId'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Dcmgt_dmPublication extends LightningElement {
    
    SelectMaintenantId


    @wire(MessageContext)
    context


    connectedCallback() {
        if(!this.subscription) {
            this.subscribeTenant()
        }


    }
    
    
    handleToggleSection(event) {
        console.log(event.detail.openSections)
    }

    subscribeTenant() {
        this.subscription = subscribe(this.context, pubSubMessageChannel,  (message) => {this.handleMessage(message)}, {scope:APPLICATION_SCOPE} )
    }

    handleMessage(message) { 
        
        
        console.log('Data Source Tenant Id 34', message.tenantId.value)
        console.log('Data Source tenant name', message.tenantId.name)
        this.SelectMaintenantId = message.tenantId.value
        
    }

    subscribeRequest(){
        methodForUpdateSubTeamId({teamId : this.SelectMaintenantId })
        .then(data => {
            console.log('Subscribe-Request', data);
            if(data) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'SUCCESS!', 
                        message: 'Subscribe successfully', 
                        variant: 'success'
                    }),
                );
                window.open('/lightning/r/dcmgt_Data_Sub_Request__c/'+data.Id+'/view', "_self")
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in Subscribe', 
                        message: 'Please provide details for Tenant, Service And Data Source.', 
                        variant: 'error'
                    }),
                );
            }
        }).catch(error => { 
            console.error('SubscribeRequest', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in Subscribe', 
                    message: error.body.message, 
                    variant: 'error'
                }),
            );
        })
    }

}