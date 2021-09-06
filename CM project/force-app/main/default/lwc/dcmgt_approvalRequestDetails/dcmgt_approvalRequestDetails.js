import { api, LightningElement, track, wire } from 'lwc';
import getApprovalRequestDetails from '@salesforce/apex/dcmgt_ApprovalRequestDetailsCtrl.getApprovalRequestDetails'

export default class ApprovalRequestDetails extends LightningElement {
    @api recordId
    @track aprrovalDetails = []
    @wire(getApprovalRequestDetails,{approvalRequestId: '$recordId'})
    approvalDetails({data,error}) {
        if(data) {
            console.log("++++++++++++++++++++++++++",data)
            this.aprrovalDetails = []
            if(data.updatedFields) {
                for(let index = 0; index < data.updatedFields.length; index++) {
                    let obj ={}
                    obj['changeRequestUrl'] = data.changeRequestUrl
                    obj['stagedRecordUrl'] = data.stagedRecordUrl
                    obj['changeRequestName'] = data.changeRequestName
                    obj['stagedRecordName'] = data.stagedRecordName
                    obj['Requester'] = data.Requester
                    obj['Requesttype'] = data.Requesttype
                    obj['approver'] = data.approver
                    obj['approvertype'] = data.approvertype
                    obj['LastModifiedBy'] = data.LastModifiedBy
                    obj['RequestedDate'] = data.RequestedDate
                    obj['Status'] = data.Status
                    obj['fieldName'] = data.updatedFields[index]
                    obj['Oldvalue'] = data.Oldvalue[index]
                    obj['Newvalue'] = data.Newvalue[index]
                    this.aprrovalDetails.push(obj)
                }
            } else {
                let obj ={}
                obj['changeRequestUrl'] = data.changeRequestUrl
                obj['stagedRecordUrl'] = data.stagedRecordUrl
                obj['changeRequestName'] = data.changeRequestName
                obj['stagedRecordName'] = data.stagedRecordName
                obj['Requester'] = data.Requester
                obj['Requesttype'] = data.Requesttype
                obj['approver'] = data.approver
                obj['approvertype'] = data.approvertype
                obj['LastModifiedBy'] = data.LastModifiedBy
                obj['RequestedDate'] = data.RequestedDate
                obj['Status'] = data.Status
                this.aprrovalDetails.push(obj)
            }

            // Array[data];
            console.log('approvalDetails data',this.approvalDetails)
        }
        if(error) {
            console.error('approvalDetails error',error)
        }
    }
    
}