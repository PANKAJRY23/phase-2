import { api, LightningElement, track, wire } from 'lwc';
import TEAM_OBJECT from '@salesforce/schema/dcmgt_Team__c';
import TEAM_NAME from '@salesforce/schema/dcmgt_Team__c.Name'
import TEAM_DESCRIPTION from '@salesforce/schema/dcmgt_Team__c.dcmgt_Team_Description__c'
import TEAM_OWNER from '@salesforce/schema/dcmgt_Team__c.dcmgt_Team_Owner__c'
import getTenants from '@salesforce/apex/dcmgt_TenantDetailsController.getTenantsByCurrentUser'
import createTeamMenberForTenant from '@salesforce/apex/dcmgt_TenantDetailsController.createTeamMenberForTenant'
import { refreshApex } from '@salesforce/apex'
import pubSubMessageChannel from '@salesforce/messageChannel/dcmgt_PubSubMessageChannel__c'
import { APPLICATION_SCOPE, MessageContext, publish, subscribe } from 'lightning/messageService';
import updatePublicationRequest from '@salesforce/apex/dcmgt_PublicationController.updatePublicationRequest'

export default class Dcmgt_tenantDetailsComp extends LightningElement {
    objectName = TEAM_OBJECT
    // @track fieldList = [TEAM_NAME, TEAM_DESCRIPTION, TEAM_OWNER]
    @track fieldList = [
        {fieldApiName: TEAM_NAME, required: true, class: 'required'},
        {fieldApiName: TEAM_DESCRIPTION,  required: true, class: 'required'},
        {fieldApiName: TEAM_OWNER,  required: true, class: 'required'}
    ]
    isCreateModelOpen = false
    title = 'New Tenant'
    @track tenantMap = new Map();
    @track tenantNameList
    @api pubTenantId
    @api publiactionId
    tenantId
    selectedTenant
    tenantDescription
    tenantAdmin
    wiredAccountResults
    @track dataSourceId

    @wire(MessageContext)
    context

    // @wire(getTenants)
    // getTenantDetails(response) {
    //     this.wiredAccountResults = response
    //     if(response.data) {
    //         this.tenantNameList = []
    //         console.log('tenant data', response.data)
    //         response.data.forEach(element => {
    //             // let obj = {}
    //             // obj[element.Name] = element
    //             this.tenantMap.set(element.Id, element);
    //             // this.tenantList.push(obj)
    //             this.tenantNameList.push({
    //                 value: element.Id, 
    //                 label: element.Name
    //             })
    //             if(!this.selectedTenant) {
    //                 if(this.tenantId && element.Id) {
    //                     this.selectedTenant = element.Id
    //                     if(element.dcmgt_Team_Owner__c) {
    //                         this.tenantAdmin = element.dcmgt_Team_Owner__r.Email
    //                     }
    //                     this.tenantDescription = element.dcmgt_Team_Description__c
    //                 } else if(this.tenantId == null || this.tenantId == undefined){
    //                     this.selectedTenant = element.Id
    //                     if(element.dcmgt_Team_Owner__c) {
    //                         this.tenantAdmin = element.dcmgt_Team_Owner__r.Email
    //                     }
    //                     this.tenantDescription = element.dcmgt_Team_Description__c
    //                 }
                    
    //             }
    //         });
    //         if(this.selectedTenant) {
    //             let tenantName
    //             if(this.tenantMap.has(this.selectedTenant)){
    //                 let tenant = this.tenantMap.get(this.selectedTenant)
    //                 tenantName = tenant.Name
    //             }
    //             const message = {
    //                 tenantId:{
    //                     value:this.selectedTenant,
    //                     name:tenantName
    //                 }
    //             }
    //             publish(this.context, pubSubMessageChannel, message )
    //             // this.dispatchEvent(new CustomEvent('tenantchange', 
    //             //     {
    //             //         detail: {id : this.selectedTenant}
    //             //     }
    //             // ))
    //         }
    //         console.log('tenantList data', this.tenantList)
    //         console.log('tenantNameList data', this.tenantNameList)
    //     }else if(response.error) {
    //         console.error('tenant error',response.error)
    //     }
    // }

    connectedCallback() {
        console.log('this.pubTenantId', this.pubTenantId)
        console.log('this.pubTenantId', this.publiactionId)
        this.dataSourceId = {}
        this.getTenantsByCurrentUser()
        this.subscribeTenant();
    }

    subscribeTenant() {
        this.subscription = subscribe(this.context, pubSubMessageChannel,  (message) => {this.handleMessage(message)}, {scope:APPLICATION_SCOPE} )
    }

    handleMessage(message) { 
        this.dataSourceId = message.dataSourceId;
    }

    getTenantsByCurrentUser() {
        getTenants()
        .then(data => {
            this.tenantNameList = []
            console.log('tenant data', data)
            data.forEach(element => {
                // let obj = {}
                // obj[element.Name] = element
                this.tenantMap.set(element.Id, element);
                // this.tenantList.push(obj)
                this.tenantNameList.push({
                    value: element.Id, 
                    label: element.Name
                })
                if(!this.selectedTenant) {
                    this.selectedTenant = element.Id
                }
                // if(!this.selectedTenant) {
                //     if(this.tenantId && element.Id) {
                //         this.selectedTenant = element.Id
                //         if(element.dcmgt_Team_Owner__c) {
                //             this.tenantAdmin = element.dcmgt_Team_Owner__r.Email
                //         }
                //         this.tenantDescription = element.dcmgt_Team_Description__c
                //     } else if(this.tenantId == null || this.tenantId == undefined){
                //         this.selectedTenant = element.Id
                //         if(element.dcmgt_Team_Owner__c) {
                //             this.tenantAdmin = element.dcmgt_Team_Owner__r.Email
                //         }
                //         this.tenantDescription = element.dcmgt_Team_Description__c
                //     }
                    
                // }
            });
            // if(this.selectedTenant) {
            // let tenantName
            // let tenantId
            let tenant
            console.log(this.tenantMap)
            if(this.pubTenantId && this.tenantMap.has(this.pubTenantId)){
                tenant = this.tenantMap.get(this.pubTenantId)
                // tenantName = tenant.Name
                // tenantId = tenant.Id
            } else if(this.selectedTenant && this.tenantMap.has(this.selectedTenant)){
                tenant = this.tenantMap.get(this.selectedTenant)
                // tenantName = tenant.Name
                // tenantId = tenant.Id
            }
            if(tenant) {
                let selectedTenantId = this.selectedTenant
                this.selectedTenant = tenant.Id
                if(selectedTenantId != this.pubTenantId) {
                    this.updateDataPublicationRequest()
                }
                if(tenant.dcmgt_Team_Owner__c) {
                    this.tenantAdmin = tenant.dcmgt_Team_Owner__r.Email
                }
                this.tenantDescription = tenant.dcmgt_Team_Description__c
                const message = {
                    tenantId:{
                        value:tenant.Id,
                        name:tenant.Name
                    },
                    dataSourceId:this.dataSourceId
                }
                publish(this.context, pubSubMessageChannel, message )
                // this.dispatchEvent(new CustomEvent('tenantchange', 
                //     {
                //         detail: {id : this.selectedTenant}
                //     }
                // ))
            }
            console.log('tenantList data', this.tenantList)
            console.log('tenantNameList data', this.tenantNameList)
        }).catch(error => {
            console.error('tenant error',error)
        })
    }

    updateDataPublicationRequest() {
        // updatePublicationRequest({publicationRequestId:this.publiactionId,
        //     tenantId:this.selectedTenant,serviceId:'', dataSourceId:''})
        // .then(data=>{
        //     console.log('updatePublicationRequest',data);
        // }).catch(error => {
        //     console.error('updatePublicationRequest',error);
        // })
        
    }
    newClickHandler() {
        this.isCreateModelOpen = true
    }

    closeHandler(event) {
        this.isCreateModelOpen = false
        let message = event.detail.message
        console.log('close message',message)
        if(message === 'Save') {
            console.log('Id', event.detail.newRecordId)
            this.tenantId = event.detail.newRecordId
            // this.updateDataPublicationRequest()
            this.createTeamMenberForNewTenant()
        } 
    }

    createTeamMenberForNewTenant() {
        if(this.tenantId) {
            createTeamMenberForTenant({tenantId: this.tenantId})
            .then(data => {
                // refreshApex(this.wiredAccountResults)
                console.log('data', JSON.stringify(data))
                this.tenantMap.set(data.Id, data);
                if(data.dcmgt_Team_Owner__c) {
                    this.tenantAdmin = data.dcmgt_Team_Owner__r.Email
                }
                this.tenantDescription = data.dcmgt_Team_Description__c
                this.tenantNameList.push({
                    value: data.Id, 
                    label: data.Name
                })
                this.selectedTenant = data.Id
                const message = {
                    tenantId:{
                        value:data.Id,
                        name:data.Name
                    },
                    dataSourceId:this.dataSourceId
                }
                publish(this.context, pubSubMessageChannel, message )
                this.updateDataPublicationRequest()
            }).catch(error => {
                console.error('createTeamMenberForTenant error', error)
            })
        }
        
    }

    tenantChangeHandler(event) {
        this.selectedTenant = event.target.value
        console.log('this.tenantMap', this.tenantMap)
        if(this.tenantMap.has(this.selectedTenant)) {
            console.log('this.tenantMap has')
            let tenant = this.tenantMap.get(this.selectedTenant)
            if(tenant.dcmgt_Team_Owner__c) {
                this.tenantAdmin = tenant.dcmgt_Team_Owner__r.Email
            }
            this.tenantDescription = tenant.dcmgt_Team_Description__c
        }
        this.updateDataPublicationRequest()
        console.log(event.target.value)
        if(this.selectedTenant) {
            let tenantName
            if(this.tenantMap.has(this.selectedTenant)){
                let tenant = this.tenantMap.get(this.selectedTenant)
                tenantName = tenant.Name
            }
            const message = {
                tenantId:{
                    value:this.selectedTenant,
                    name:tenantName
                },
                dataSourceId:this.dataSourceId
            }
            publish(this.context, pubSubMessageChannel, message )
            // this.dispatchEvent(new CustomEvent('tenantchange', 
            //     {
            //         detail: {id : this.selectedTenant}
            //     }
            // ))
        }
    }
}