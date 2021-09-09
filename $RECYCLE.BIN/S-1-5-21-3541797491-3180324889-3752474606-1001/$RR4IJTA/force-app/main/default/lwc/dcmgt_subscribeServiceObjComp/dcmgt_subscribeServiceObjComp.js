import { api, LightningElement,track, wire } from 'lwc';
import SERVICE_OBJECT from '@salesforce/schema/dcmgt_Service__c';
import SERVICE_NAME from '@salesforce/schema/dcmgt_Service__c.Name'
import SERVICE_DATA_CLASSIFICATION from '@salesforce/schema/dcmgt_Service__c.dcmgt_Data_Classification__c'
import SERVICE_DESCRIPTION from '@salesforce/schema/dcmgt_Service__c.dcmgt_Service_Description__c'
import SERVICE_SERVICE_OWNER from '@salesforce/schema/dcmgt_Service__c.dcmgt_Service_Owner__c'
import SERVICE_SYSTEM_ACCOUNT from '@salesforce/schema/dcmgt_Service__c.dcmgt_System_Account__c'
import getServices from '@salesforce/apex/dcmgt_SubscriptionServiceController.getServiceByTeamId'
import getServiceById from '@salesforce/apex/dcmgt_SubscriptionServiceController.getServiceById'
import { refreshApex } from '@salesforce/apex'
import pubSubMessageChannel from '@salesforce/messageChannel/dcmgt_SubMessageChannel__c'
import updateDataSubRequestRecMethod from '@salesforce/apex/dcmgt_SubscriptionServiceController.updateDataSubRequestRecMethod'
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';

export default class Dcmgt_subscribeServiceObjComp extends LightningElement {
    objectName = SERVICE_OBJECT
    @track fieldList = [
        {fieldApiName: SERVICE_NAME, required: true, class: 'required'},
        {fieldApiName: SERVICE_DATA_CLASSIFICATION, required: false},
        {fieldApiName: SERVICE_DESCRIPTION, required: false},
        {fieldApiName: SERVICE_SYSTEM_ACCOUNT, required: false}
    ]
    isCreateModelOpen = false
    title = 'New Service'
    @track selectedTenantId
    serviceId
    servicesNameList;
    @track servicetMap = new Map();
    @api pubServiceId
    ServiceAdmin;
    ServiceDescription;
    selectedService;
    dataClassification;
    wiredServiceResults

    @wire(MessageContext)
    context

    @wire(getServices, { teamId: '$selectedTenantId' })
    getServiceDetails(response) {
        this.wiredServiceResults = response
        if(response.data) {
            //console.log('this.selectedService',this.selectedService);
            this.selectedService = null
            if(response.data.length <= 0) {
                this.servicesNameList = null
            } else {
                this.servicesNameList = []
               // console.log('Service data', response.data)
                response.data.forEach(element => {
                    
                    this.servicetMap.set(element.Id, element);                
                    this.servicesNameList.push({
                        value: element.Id, 
                        label: element.Name
                    })
                    if(!this.selectedService) {
                        this.selectedService = element.Id
                        if(element.dcmgt_Service_Owner__c) {
                            this.ServiceAdmin = element.dcmgt_Service_Owner__r.dcmgt_Team_Owner__r.Email
                        }
                        this.ServiceDescription = element.dcmgt_Service_Description__c
                        this.dataClassification = element.dcmgt_Data_Classification__c
                        this.updateSubscription(this.selectedService);
                    }
                });
            }
        }else if(response.error) {
            console.error('tenant error',response.error)
        }
    }
    

    connectedCallback() {
        if(!this.subscription) {
            this.subscribeTenant()
        }
    }

    subscribeTenant() {
        this.subscription = subscribe(this.context, pubSubMessageChannel,  (message) => {this.handleMessage(message)}, {scope:APPLICATION_SCOPE} )
    }

    handleMessage(message) { 
        this.selectedTenantId = message.tenantId.value;
        
       // console.log('sevice tenant Id', message.tenantId.value)
       // console.log('sevice tenant name', message.tenantId.name)
    }

    newClickHandler() {
        this.isCreateModelOpen = true
    }

    closeHandler(event) {
        this.isCreateModelOpen = false
        let message = event.detail.message
        //console.log('close message',message)
        if(message === 'Save') {
            console.log('Id', event.detail.newRecordId)
            this.serviceId = event.detail.newRecordId
            this.getServiceDetailById()
        } 
    }

    getServiceDetailById() {
        if(this.serviceId) {
            getServiceById({serviceId:this.serviceId, tenantId:this.selectedTenantId})
            .then(data => {
                refreshApex(this.wiredServiceResults)
                this.selectedService = data.Id
                this.updateSubscription(this.selectedService);
                if(data.dcmgt_Service_Owner__c) {
                    this.ServiceAdmin = data.dcmgt_Service_Owner__r.dcmgt_Team_Owner__r.Email
                }
                this.ServiceDescription = data.dcmgt_Service_Description__c
                this.dataClassification = data.dcmgt_Data_Classification__c
                this.servicesNameList.push({
                    value: data.Id, 
                    label: data.Name
                })
                this.servicetMap.set(data.Id, data);
            }).catch(error => {
                console.error('getServiceById error', error);
            })
        }
        
    }    

    ServiceChangeHandler(event) {
        this.selectedService = event.target.value
        console.log('this.tenantMap', this.servicetMap)
        if(this.servicetMap.has(this.selectedService)) {
            console.log('this.tenantMap has')
            let tenant = this.servicetMap.get(this.selectedService)
            if(tenant.dcmgt_Service_Owner__c) {
                this.ServiceAdmin = tenant.dcmgt_Service_Owner__r.dcmgt_Team_Owner__r.Email
            }
            this.ServiceDescription = tenant.dcmgt_Service_Description__c
            this.dataClassification = tenant.dcmgt_Data_Classification__c
        }     
         
        this.updateSubscription(this.selectedService);
        
        
    }

    updateSubscription(value){
        updateDataSubRequestRecMethod({serviceId: value})
        .then(data => {
            
        }).catch(error => {
            console.error('createTeamMenberForTenant error', error)
        }) 
    }
}