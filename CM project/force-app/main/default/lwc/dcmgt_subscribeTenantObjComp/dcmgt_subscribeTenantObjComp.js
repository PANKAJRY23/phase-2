import { LightningElement, track, wire } from 'lwc';
import TEAM_OBJECT from '@salesforce/schema/dcmgt_Team__c';
import TEAM_NAME from '@salesforce/schema/dcmgt_Team__c.Name'
import TEAM_DESCRIPTION from '@salesforce/schema/dcmgt_Team__c.dcmgt_Team_Description__c'
import TEAM_OWNER from '@salesforce/schema/dcmgt_Team__c.dcmgt_Team_Owner__c'
import getTenants from '@salesforce/apex/dcmgt_SubscriptionTenantController.getTenantsByCurrentUser'
import createTeamMenberForTenant from '@salesforce/apex/dcmgt_SubscriptionTenantController.createTeamMenberForTenant'
import updateDataSubRequestRecMethod from '@salesforce/apex/dcmgt_SubscriptionTenantController.updateDataSubRequestRecMethod'
import getSubRequest from '@salesforce/apex/dcmgt_SubscriptionTenantController.getSubRequest'
import pubSubMessageChannel from '@salesforce/messageChannel/dcmgt_SubMessageChannel__c'
import { APPLICATION_SCOPE, MessageContext, publish } from 'lightning/messageService';
import { CurrentPageReference } from 'lightning/navigation';

export default class Dcmgt_tenantDetailsComp extends LightningElement {
    objectName = TEAM_OBJECT
    @track fieldList = [
        {fieldApiName: TEAM_NAME, required: true, class: 'required'},
        {fieldApiName: TEAM_DESCRIPTION,  required: true, class: 'required'},
        {fieldApiName: TEAM_OWNER,  required: true, class: 'required'}
    ]

    isCreateModelOpen = false
    title = 'New Tenant'
    @track tenantMap = new Map();
    @track tenantNameList
    tenantId
    selectedTenant
    tenantDescription
    tenantAdmin

    @track subscribtionRequestRecord

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
       if (currentPageReference) {
          this.urlStateParameters = currentPageReference.state;
          this.setParametersBasedOnUrl();
       }
    }
 
    setParametersBasedOnUrl() {     
        //console.log('==urlStateParameters=='+this.urlStateParameters.c__counter); 
        let urlType = this.urlStateParameters.c__id ;
        console.log('==urlType=='+urlType);
        if(urlType){
            this.subscribtionRequestRecord = true
            this.methodForCallTenantRec();
            
        }
       
    }

    @wire(getSubRequest)
    checkSubscribtionRecord({data, error}){
        console.log('==data=29=',data)
        if(data){
            this.subscribtionRequestRecord = data[0]
        }
    }

    @wire(MessageContext)
    context

    connectedCallback(){
       this.methodForCallTenantRec(); 
    
    }

    methodForCallTenantRec(){
        getTenants()
        .then(data => {
            this.subscribtionRequestRecord =true;
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
                    if(this.tenantId && element.Id) {
                        this.selectedTenant = element.Id
                        if(element.dcmgt_Team_Owner__c) {
                            this.tenantAdmin = element.dcmgt_Team_Owner__r.Email
                        }
                        this.tenantDescription = element.dcmgt_Team_Description__c
                    } else if(this.tenantId == null || this.tenantId == undefined){
                        this.selectedTenant = element.Id
                        if(element.dcmgt_Team_Owner__c) {
                            this.tenantAdmin = element.dcmgt_Team_Owner__r.Email
                        }
                        this.tenantDescription = element.dcmgt_Team_Description__c
                    }   
                    this.updateTenantRecord(this.selectedTenant)                 
                }
            });   
            if(this.selectedTenant) {
                let tenantName
                if(this.tenantMap.has(this.selectedTenant)){
                    let tenant = this.tenantMap.get(this.selectedTenant)
                    tenantName = tenant.Name
                }
                this.updateTenantRecord(this.selectedTenant)            
            }         

            const message = {
                tenantId:{
                    value:this.selectedTenant,
                    name:this.selectedTenant
                }
            }
            publish(this.context, pubSubMessageChannel, message )  
        
        }).catch(error => {
            console.error('createTeamMenberForTenant error', error)
        }) 
    }
    
    // @wire(getTenants)
    // getTenantDetails({data, error}) {
    //     if(data) {
    //         this.tenantNameList = []
    //         console.log('tenant data', data)
    //         data.forEach(element => {
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
    //                 this.updateTenantRecord(this.selectedTenant)                 
    //             }
    //         });   
    //         if(this.selectedTenant) {
    //             let tenantName
    //             if(this.tenantMap.has(this.selectedTenant)){
    //                 let tenant = this.tenantMap.get(this.selectedTenant)
    //                 tenantName = tenant.Name
    //             }
    //             this.updateTenantRecord(this.selectedTenant)            
    //         }         

    //         const message = {
    //             tenantId:{
    //                 value:this.selectedTenant,
    //                 name:this.selectedTenant
    //             }
    //         }
    //         publish(this.context, pubSubMessageChannel, message )  
    //     }else if(error) {
    //         console.error('tenant error',error)
    //     }
    // }

    
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
            this.createTeamMenberForNewTenant()
        } else {

        }
    }

    createTeamMenberForNewTenant() {
        if(this.tenantId) {
            createTeamMenberForTenant({tenantId: this.tenantId})
            .then(data => {
                console.log('data', JSON.stringify(data))
                this.selectedTenant = data.Id
                if(data.dcmgt__dcmgt_Team_Owner__c) {
                    this.tenantAdmin = data.dcmgt__dcmgt_Team_Owner__r.Email
                }
                this.tenantDescription = data.dcmgt_Team_Description__c 
                console.log('=this.tenantDescription='+this.tenantDescription)
                this.tenantNameList.push({
                    value: data.Id, 
                    label: data.Name
                })
                this.tenantMap.set(data.Id, data);
                this.updateTenantRecord(data.Id)
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
        
        console.log(event.target.value)
        if(this.selectedTenant) {
            let tenantName
            if(this.tenantMap.has(this.selectedTenant)){
                let tenant = this.tenantMap.get(this.selectedTenant)
                tenantName = tenant.Name
            }
            
            this.updateTenantRecord(this.selectedTenant)
              
        }
    }

    updateTenantRecord(tenantId){
        if(this.subscribtionRequestRecord){
            updateDataSubRequestRecMethod({tenantId: tenantId})
            .then(data => {
                if(this.subscribtionRequestRecord){
                    const message = {
                        tenantId:{
                            value:tenantId,
                            name:tenantId
                        }
                    }
                    publish(this.context, pubSubMessageChannel, message )       
                }   
            }).catch(error => {
                console.error('createTeamMenberForTenant error', error)
            }) 
        }
    }
}