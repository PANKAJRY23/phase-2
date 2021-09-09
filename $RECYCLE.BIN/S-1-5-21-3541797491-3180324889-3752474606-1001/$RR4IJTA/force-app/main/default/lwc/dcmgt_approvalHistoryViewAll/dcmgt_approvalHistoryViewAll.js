import { LightningElement,api, track,wire } from 'lwc';
import getApprovalHistory from "@salesforce/apex/dcmgt_ApprovalHistoryController.getApprovalHistory";
import setApproversForStep2 from "@salesforce/apex/dcmgt_ApprovalHistoryController.setApproversForStep2";
import processStep from "@salesforce/apex/dcmgt_ApprovalHistoryController.processStep";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import publicRequestStep from "@salesforce/apex/dcmgt_ApprovalHistoryController.publicRequestStep";
import timeZone from '@salesforce/i18n/timeZone';
import approvalHistoryUtil from 'c/dcmgt_approvalHistoryUtil'

// import {
//   verifyIfNextApproverWasNeeded,
//   hideModal,
//   showModal,
//   getCommentPropertyFromModal,
//   getEffectiveDateFromModal,
//   showGetNextApproverModal,
//   validateUserLookup,
//   setSelectedUser,
//   clearModalState,
//   displayToast,
//   extractErrorMessage,
//   modalStates,
//   displayToastErrorQuery
// } from "./dcmgt_approvalHistoryUtil.js";

const ERROR = "error";
const SUCCESS = "success";
const columns = [
  {
    label: "Step Name",
    fieldName: "stepUrl",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "stepName"
      }
    }
  },
  {
    label: "Date",
    fieldName: "createdDate",
    type: "date",
    typeAttributes: {
      month: "numeric",
      day: "numeric",
      year: "numeric",
      hour: "numeric",
      minute: "numeric"
    }
  },
  { label: "Status", fieldName: "stepStatus" },
  {
    label: "Assigned To",
    fieldName: "assignedToUrl",
    type: "url",
    typeAttributes: {
      label: {
        fieldName: "assignedTo"
      }
    }
  },
  {label: "Comments", fieldName: "comments" },
	{label: "Approval Effective Date", fieldName: "effectiveDate" }	
];


export default class Dcmgt_approvalHistoryViewAll extends LightningElement {
  @api targetRecordId;
    @track approvalHistory; 
    wiredApprovalHistory;
    currentModalState;
    modalComment;
    approvalEffectiveDate;
    @api publicationrequest = false;
    @api objectApiName;
    connectedCallback(){
      console.log('targetRecordId',this.targetRecordId);
      if(this.objectApiName == 'dcmgt_Data_Publication_Request__c' || this.objectApiName == 'dcmgt_Data_Sub_Request__c'){
        console.log("conncteddd :");
        this.publicationrequest = true;
        
      }
    }
    @wire(getApprovalHistory, { recordId: "$targetRecordId" })
  wiredGetApprovalHist(value) {
    this.wiredApprovalHistory = value;
    if (value.data) {
      this.approvalHistory = value.data;
    } else if (value.error) {
      console.log(value.error)
      approvalHistoryUtil.displayToastErrorQuery(this, ShowToastEvent);
    }
  }

  get showDataTable() {
    return this.approvalHistory && this.approvalHistory.approvalSteps.length > 0
      ? true
      : false;
  }

  get columns() {
    return columns;
  }

  get modalTitle() {
    if (this.currentModalState && approvalHistoryUtil.modalStates[this.currentModalState])
      return approvalHistoryUtil.modalStates[this.currentModalState].title;
    return "";
  }

  get showCommentModal() {
    return (
      this.currentModalState === approvalHistoryUtil.modalStates.SUBMIT_APPROVAL.state ||
      this.currentModalState === approvalHistoryUtil.modalStates.APPROVE.state ||
      this.currentModalState === approvalHistoryUtil.modalStates.REJECT.state ||
      this.currentModalState === approvalHistoryUtil.approvalHistoryUtil.modalStates.RECALL.state
    );
  }

 

  get modalsubmitLabel() {
    if (this.currentModalState && approvalHistoryUtil.modalStates[this.currentModalState])
      return approvalHistoryUtil.modalStates[this.currentModalState].submitLabel;
    return "";
  } 

  get showButtonMenu() {
    return (
      this.approvalHistory.isCurrentUserApprover ||
      this.approvalHistory.showRecall
    );
  }

  refreshApprovalHistory() {
    console.log('refreshing')
   return  refreshApex(this.wiredApprovalHistory);
  }

  handleApproveClick() {
    approvalHistoryUtil.showModal(this);
    this.currentModalState = approvalHistoryUtil.modalStates.APPROVE.state;
  }

  handleModalCancel() {
    approvalHistoryUtil.hideModal(this);
    approvalHistoryUtil.clearModalState(this);
  }

  handleRejectClick() {
    approvalHistoryUtil.showModal(this);
    this.currentModalState = approvalHistoryUtil.modalStates.REJECT.state;
  }
    
  handleModalSubmit() {
    this.modalComment = approvalHistoryUtil.getCommentPropertyFromModal(this);
    this.approvalEffectiveDate = approvalHistoryUtil.getEffectiveDateFromModal(this);
    if(this.modalComment.length >0 && this.approvalEffectiveDate.length >0 ){
      var today = new Date();
      var options = {
          year: 'numeric', month: 'numeric', day: 'numeric',
          timeZone: timeZone
        };
        
      var formattedDate = new Intl.DateTimeFormat('en-US', options).format(today);
      var formattedDateTemp=formattedDate.split('/');
      console.log('**'+formattedDateTemp);
      var month=parseInt(formattedDateTemp[0])-1;
      var fDate=new Date(formattedDateTemp[2],month,formattedDateTemp[1]);
      var approvalED=this.approvalEffectiveDate.split('-');
      var approvalEDFormatted=new Date(approvalED[0],approvalED[1]-1,approvalED[2]);

      if(approvalEDFormatted < fDate){
        alert("Please enter the effective date greater or equal today date.");
        return;
      }
      switch (this.currentModalState) {
        case approvalHistoryUtil.modalStates.APPROVE.state:
          this.processStepApexCall(approvalHistoryUtil.modalStates.APPROVE.action);
          break;
        case approvalHistoryUtil.modalStates.REJECT.state:
          this.processStepApexCall(approvalHistoryUtil.modalStates.REJECT.action);
          break;
        default:
          break;
      }
    }else{
      if(this.modalComment.length === 0 && this.approvalEffectiveDate.length > 0){
        alert("Please enter the comments");
      }else if(this.approvalEffectiveDate.length === 0 && this.modalComment.length >0){
        alert("Please enter the effective date");
      }else{
        alert("Please enter the required fields");
      }
    }
    
  }

  handlePublicationSubmit() {
    this.modalComment = approvalHistoryUtil.getCommentPropertyFromModal(this);
    if(this.modalComment.length >0){
      switch (this.currentModalState) {
        case approvalHistoryUtil.modalStates.APPROVE.state:
          this.publicProcessStepApexCall(approvalHistoryUtil.modalStates.APPROVE.action);
          break;
        case approvalHistoryUtil.modalStates.REJECT.state:
          this.publicProcessStepApexCall(approvalHistoryUtil.modalStates.REJECT.action);
          break;
        default:
          break;
      }
    }else{
      if(this.modalComment.length === 0 ){
        alert("Please enter the comments");
      }else{
        alert("Please enter the required fields");
      }
    }
    
  }


  processStepApexCall(action) {
    approvalHistoryUtil.hideModal(this);
    console.log(this.approvalEffectiveDate);
    processStep({
      recordId: this.targetRecordId,
      comments: this.modalComment,
      action: action,
      effectiveDate:this.approvalEffectiveDate
    })
      .then(result => {
        let jsonResult = JSON.parse(result);
        if (jsonResult.success) {
          approvalHistoryUtil.displayToast(this, ShowToastEvent, SUCCESS);
          this.refreshApprovalHistory();
        } else {
          approvalHistoryUtil.displayToast(this, ShowToastEvent, ERROR);
        }
        approvalHistoryUtil.clearModalState(this);
      })
      .catch(error => {
        if (approvalHistoryUtil.verifyIfNextApproverWasNeeded(error.body.pageErrors)) {
          setApproversForStep2({
            recordId: this.targetRecordId,
            comments: this.modalComment,
            action: action 
          }).then(result2 =>{
            this.refreshApprovalHistory(); 
          })
        } else {
          let errorMessage = approvalHistoryUtil.extractErrorMessage(error.body.pageErrors);
          approvalHistoryUtil.displayToast(this, ShowToastEvent, ERROR, errorMessage);
          approvalHistoryUtil.clearModalState(this);
        }
      });
  }


  publicProcessStepApexCall(action) {
    approvalHistoryUtil.hideModal(this);
    console.log(this.approvalEffectiveDate);
    publicRequestStep({
      recordId: this.targetRecordId,
      comments: this.modalComment,
      action: action
    })
      .then(result => {
        let jsonResult = JSON.parse(result);
        if (jsonResult.success) {
          approvalHistoryUtil.displayToast(this, ShowToastEvent, SUCCESS);
          this.refreshApprovalHistory();
        } else {
          approvalHistoryUtil.displayToast(this, ShowToastEvent, ERROR);
        }
        approvalHistoryUtil.clearModalState(this);
      })
      .catch(error => {
        if (approvalHistoryUtil.verifyIfNextApproverWasNeeded(error.body.pageErrors)) {
          setApproversForStep2({
            recordId: this.targetRecordId,
            comments: this.modalComment,
            action: action 
          }).then(result2 =>{
            this.refreshApprovalHistory(); 
          })
        } else {
          let errorMessage = approvalHistoryUtil.extractErrorMessage(error.body.pageErrors);
          approvalHistoryUtil.displayToast(this, ShowToastEvent, ERROR, errorMessage);
          approvalHistoryUtil.clearModalState(this);
        }
      });
  }
}