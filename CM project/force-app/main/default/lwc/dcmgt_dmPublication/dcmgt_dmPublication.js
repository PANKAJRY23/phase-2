import { LightningElement, wire, track } from 'lwc';
import getPublicationRequest from '@salesforce/apex/dcmgt_PublicationController.getDataPubRequestForCurrentUser'
import publishDataPublicationRequest from '@salesforce/apex/dcmgt_PublicationController.publishDataPublicationRequest'
import pubSubMessageChannel from '@salesforce/messageChannel/dcmgt_PubSubMessageChannel__c'
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class Dcmgt_dmPublication extends LightningElement {
    tenantId
    serviceId
    dataDictionaryId
    dataPubliactionId
    isLoading = true
    activeSections = 'Tenant Details'
    tempActiveSections = ['Tenant Details']

    subscription
    @track selectedRow = []
    @track  tableData
    @track columns = [
        { label: 'Tenant', fieldName: 'tenantName', type: 'text',  sortable: true},
        { label: 'Data Source', fieldName: 'dataSource', type: 'text',  sortable: true},
        { label: 'Data Assets', fieldName: 'Name', type: 'text',  sortable: true}, 
        { label: 'Data Classifiaction', fieldName: 'classification', type: 'text',  sortable: true},
        { label: 'Public Visiblity', fieldName: 'publicVisiblity', type: 'boolean' },
        { label: 'Schema', fieldName: 'schema', type: 'text',  sortable: true},  
    ]

    @wire(MessageContext)
    context

    connectedCallback() {
        this.getPublicationRequestDetais();
        if(!this.subscription) {
            this.subscribeTenant()
        }
        this.dispatchEvent(new CustomEvent('tableload', {
            detail:{
                tableRef: this.template.querySelector('lightning-datatable')
            }
        }))
    }

    subscribeTenant() {
        this.subscription = subscribe(this.context, pubSubMessageChannel,  (message) => {this.handleMessage(message)}, {scope:APPLICATION_SCOPE} )
    }

    handleMessage(message) { 
        console.log('DA message',message)
        if(message.dataSourceId.dataAssets) {
            this.tableData = message.dataSourceId.dataAssets.map(data=> {
                if(message.tenantId.name) {
                    return {...data, tenantName:message.tenantId.name}
                } else {
                    return {...data}
                }
            });
        }
        
        
        console.log('sevice tenant Id', message.dataSourceId.dataDictionaryId)
        console.log('sevice tenant Id', message.dataSourceId.dataDictionaryName)
        console.log('sevice tenant name', message.dataSourceId.dataAssets)
    }

    // connectedCallback() {
    //     this.getPublicationRequestDetais();
    // }
    
    getPublicationRequestDetais() {
        getPublicationRequest()
        .then(data=> {
            console.log('getPublicationRequestDetais data', data);
            this.dataPubliactionId = data.Id
            if(data.dcmgt_Team__c) {
                this.tenantId = data.dcmgt_Team__c
            }
            if(data.dcmgt_Service__c) {
                this.serviceId = data.dcmgt_Service__c
            }
            if(data.dcmgt_Alation_Data_Dictionary__c) {
                this.dataDictionaryId = data.dcmgt_Alation_Data_Dictionary__c
            }
            this.isLoading = false
        }).catch(error=> {
            this.isLoading = false
            console.error('getPublicationRequestDetais error', error);
        })
    }

    tenantChangeHandler(event) {
        this.tenantId = event.detail.id
        console.log('Pub tenant Id', this.tenantId)
    }

    publishHandler(event) {
        this.isLoading = true
        this.selectedRow = this.template.querySelector('.dataAssetTable').getSelectedRows()
        if(this.selectedRow && this.selectedRow.length > 0){
            this.publishRequest()
        } else {
            this.isLoading = false
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in Publication', 
                    message: 'Please select at least one data asset for the publication', 
                    variant: 'error'
                }),
            );
        }
        console.log(this.selectedRow)
        console.log(this.selectedRow.length)
    }

    publishRequest(){
        publishDataPublicationRequest({publicationRequestId:this.dataPubliactionId,
             dataAssetJsonString: JSON.stringify(this.selectedRow)})
        .then(data => {
            console.log('publishRequest', data);
            if(data == 'success') {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'SUCCESS!', 
                        message: 'Publish successfully', 
                        variant: 'success'
                    }),
                );
                window.open(`/${this.dataPubliactionId}`, "_self")
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error in Publication', 
                        message: 'Please provide details for Tenant, Service And Data Source.', 
                        variant: 'error'
                    }),
                );
            }
            this.isLoading = false
        }).catch(error => {
            this.isLoading = false
            console.error('publishRequest', error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error in Publication', 
                    message: error.body.message, 
                    variant: 'error'
                }),
            );
        })
    }

    handleToggleSection(event) {
        console.log('activeSections',this.activeSections)
        console.log(JSON.stringify(event.detail))
        event.detail.openSections.forEach(section => {
            console.log('section', section);
            if(!this.tempActiveSections.includes(section)) {
                this.activeSections = section
            }
        })
        this.tempActiveSections = event.detail.openSections
    }
}