import { LightningElement, track, wire } from 'lwc';
import getAllPendingRequest from '@salesforce/apex/dcmgt_PublicationController.getAllPendingRequest'
import getAllApprovals from '@salesforce/apex/dcmgt_PublicationController.getAllApprovals'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import notifySubscribers from '@salesforce/apex/dcmgt_PublicationController.notifySubscribers'
import getDataContract from '@salesforce/apex/dcmgt_PublicationController.getDataContractByCurrentUser'

export default class Dcmgt_publicationDetailsComp extends LightningElement {
    @track pendingPublicationRequest
    @track approvalPublicationRequest
    @track dataContracts
    isLoading = true
    notifiactionMessage
    activeSections = 'Your Publications'
    tempActiveSections = ['Your Publications']
    columns = [
        { label: 'Tenant', fieldName: 'tenantName', type: 'text',  sortable: true},
        { label: 'Data Source', fieldName: 'dataSource', type: 'text',  sortable: true},
        { label: 'Data Asset', fieldName: 'name', type: 'text',  sortable: true}, 
        { label: 'Existing Customers', fieldName: 'existingCustomers', type: 'number',  sortable: true},
        {
            label: 'Action',
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:preview',
                title: 'View',
                variant: 'border-filled',
                alternativeText: 'View'
            }
        },
    ]
    dataContractColumns = [
        { label: 'Data Consumer Tenant', fieldName: 'consumerTenant', type: 'text',  sortable: true},
        { label: 'Data Source', fieldName: 'dataSource', type: 'text',  sortable: true},
        { label: 'Data Assets', fieldName: 'dataAsset', type: 'text',  sortable: true}, 
        { label: 'Preferred Duration', fieldName: 'preferredDuration', type: 'text',  sortable: true}, 
        {
            label: 'Action',
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:preview',
                title: 'View',
                variant: 'border-filled',
                alternativeText: 'View'
            }
        },
    ]
    connectedCallback() {
        this.getPendingPublicationReq()
        this.getApprovalPublicationReq()
        this.getAllDatacontract()
    }
    getPendingPublicationReq(){
        getAllPendingRequest()
        .then(data => {
            // this.pendingPublicationRequest = []
            // data.forEach(element => {
            //     let rowData = {...element}
            //     rowData.Name = element.name
            //     this.pendingPublicationRequest.push(rowData)
            // });
            this.isLoading = false
            this.pendingPublicationRequest = data
            console.log('getPendingPublicationReq data', data)
        }).catch(error => {
            this.isLoading = false
            console.error('getPendingPublicationReq error', error)
        }) 
    }

    getApprovalPublicationReq(){
        getAllApprovals()
        .then(data => {
            // this.approvalPublicationRequest = []
            // data.forEach(element => {
            //     let rowData = {}
            //     if(element.dcmgt_Data_Publication_Request__c) {
            //         rowData.tenantName = element.dcmgt_Data_Publication_Request__r.dcmgt_Team__r.Name
            //         rowData.dataSource = element.dcmgt_Data_Publication_Request__r.dcmgt_Alation_Data_Dictionary__r.Name
            //     }
            //     rowData.Name = element.dcmgt_Data_Asset_Name__c
            //     rowData.existingCustomers = 23
            //     this.approvalPublicationRequest.push(rowData)
            // });
            this.approvalPublicationRequest = data
            console.log('getApprovalsPublicationReq data', data)
            this.isLoading = false
        }).catch(error => {
            this.isLoading = false
            console.error('getApprovalsPublicationReq error', error)
        }) 
    }

    getAllDatacontract() {
        getDataContract()
        .then(data => {
            this.isLoading = false
            this.dataContracts = data
            console.log('dataContracts data',data );
        }).catch(error => {
            this.isLoading = false
            console.error('dataContracts error',error );
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

    // sectionClickHandler(event) {
    //     console.log('sectionClickHandler 2')
    //     this.activeSections = ''
    // }

    notifiactionMessageChangeHandler(event) {
        this.notifiactionMessage = event.target.value
        console.log('notifiactionMessage',this.notifiactionMessage)
    }

    handleRowAction(event) {
        console.log('handleRowAction');
        let row = event.detail.row;
        console.log('row-->'+JSON.stringify(row)); 
        window.open(row.publicationReqLink, "_blank")
    }

    handleDataContractRowAction(event) {
        console.log('handleRowAction');
        let row = event.detail.row;
        console.log('row-->'+JSON.stringify(row)); 
        window.open(`/${row.id}`, "_blank")
    }

    notifySubscribersClick(event) {
        console.log('notifySubscribers  Click');
        let listOfUserId = []
        let selectedRow = this.template.querySelector('.approvedPubRequests').getSelectedRows()
        console.log('selectedRow ',selectedRow);
        console.log('this.notifiactionMessage ',this.notifiactionMessage);
        if(selectedRow && selectedRow.length > 0) {
            if(this.notifiactionMessage) {
                selectedRow.forEach(element => {
                    let row = element.setOfRequestor
                    row.forEach(userId => {
                        if(!listOfUserId.includes(userId)) {
                            listOfUserId.push(userId)
                        }
                    })
                });
                console.log('listOfUserId',listOfUserId);
                notifySubscribers({notificationMessage: this.notifiactionMessage, listOfUserId})
                .then(data => {
                    console.log('notifySubscribers data', data);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'SUCCESS!', 
                            message: 'Notify successfully', 
                            variant: 'success'
                        }),
                    );
                }).catch(error => {
                    console.error('notifySubscribers error', error);
                })
            } else {
                this.isLoading = false
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while Notify Subscribers', 
                        message: 'Please provide Notifiaction message', 
                        variant: 'error'
                    }),
                );
            }
            
        } else {
            this.isLoading = false
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while Notify Subscribers', 
                    message: 'Please select at least one data asset for the Notifiaction', 
                    variant: 'error'
                }),
            );
        }
    }
}