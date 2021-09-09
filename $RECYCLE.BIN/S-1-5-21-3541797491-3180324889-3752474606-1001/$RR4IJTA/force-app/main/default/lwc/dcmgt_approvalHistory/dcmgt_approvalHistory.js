import { LightningElement, api, track, wire } from "lwc";
import getApprovalHistory from "@salesforce/apex/dcmgt_ApprovalHistoryController.getApprovalHistory";
import setApproversForStep2 from "@salesforce/apex/dcmgt_ApprovalHistoryController.setApproversForStep2";
import processStep from "@salesforce/apex/dcmgt_ApprovalHistoryController.processStep";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from '@salesforce/apex';
import publicRequestStep from "@salesforce/apex/dcmgt_ApprovalHistoryController.publicRequestStep";
import timeZone from '@salesforce/i18n/timeZone';
import { NavigationMixin } from 'lightning/navigation';

import {
    verifyIfNextApproverWasNeeded,
    hideModal,
    showModal,
    getCommentPropertyFromModal,
    getEffectiveDateFromModal,
    showGetNextApproverModal,
    validateUserLookup,
    setSelectedUser,
    clearModalState,
    displayToast,
    extractErrorMessage,
    modalStates,
    displayToastErrorQuery
} from "./dcmgt_approvalHistoryUtil.js";

const ERROR = "error";
const SUCCESS = "success";


const columns = [{
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
    { label: "Comments", fieldName: "comments" },
    {
        label: "Approval Effective Date",
        fieldName: "effectiveDate",
        type: "date",
        typeAttributes: {
            month: "numeric",
            day: "numeric",
            year: "numeric"
        }
    }
];

export default class Dcmgt_approvalHistory extends NavigationMixin(LightningElement) {
    @api recordId;
    @track approvalHistory;
    wiredApprovalHistory;
    currentModalState;
    modalComment;
    todaydate;
    approvalEffectiveDate;
    hideEffectiveDateOnReject = true;
    @api publicationrequest = false;
    @api objectApiName;
    @api isViewAllClicked = false
    connectedCallback() {
        if (this.objectApiName == 'dcmgt_Data_Publication_Request__c' || this.objectApiName == 'dcmgt_Data_Sub_Request__c') {
            console.log("conncteddd :");
            this.publicationrequest = true;

        }
         var today = new Date();
         var dd = String(today.getDate()).padStart(2, '0');
         var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
         var yyyy = today.getFullYear();
         today = yyyy + '-' + mm + '-' + dd;
         this.todaydate = today;
			  	console.log('@@@@@@@@@@ time zoneeee'+ this.timeZone);
    }
    @wire(getApprovalHistory, { recordId: "$recordId" })
    wiredGetApprovalHist(value) {
        this.wiredApprovalHistory = value;
        if (value.data) {
            this.approvalHistory = value.data;
            console.log('$$$$$$$$$$$$$$$$$$$$$$$' + JSON.stringify(this.approvalHistory));
            console.log('#######################' + this.approvalEffectiveDate);
        } else if (value.error) {
            console.log(value.error)
            displayToastErrorQuery(this, ShowToastEvent);
        }
    }

    get showDataTable() {
        return this.approvalHistory && this.approvalHistory.approvalSteps.length > 0 ?
            true :
            false;
    }

    get viewAllUrl() {
        //return "/lightning/r/" + this.recordId + "/related/ProcessSteps/view";
        return `/lightning/r/${this.approvalHistory.objectApiName}/${this.recordId}/related/ProcessSteps/view`
    }

    get viewAll() {
        return (!this.isViewAllClicked) && this.showDataTable
    }

    get columns() {
        return columns;
    }

    get modalTitle() {
        if (this.currentModalState && modalStates[this.currentModalState])
            return modalStates[this.currentModalState].title;
        return "";
    }

    get showCommentModal() {
        return (
            this.currentModalState === modalStates.SUBMIT_APPROVAL.state ||
            this.currentModalState === modalStates.APPROVE.state ||
            this.currentModalState === modalStates.REJECT.state ||
            this.currentModalState === modalStates.RECALL.state
        );
    }



    get modalsubmitLabel() {
        if (this.currentModalState && modalStates[this.currentModalState])
            return modalStates[this.currentModalState].submitLabel;
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
        return refreshApex(this.wiredApprovalHistory);
    }

    handleApproveClick() {
        showModal(this);
        this.currentModalState = modalStates.APPROVE.state;
        this.hideEffectiveDateOnReject = true;
    }

    handleModalCancel() {
        hideModal(this);
        clearModalState(this);
    }

    handleRejectClick() {
        showModal(this);
        this.currentModalState = modalStates.REJECT.state;
        this.hideEffectiveDateOnReject = false;
    }

    handleModalSubmit() {
        this.modalComment = getCommentPropertyFromModal(this);
        this.approvalEffectiveDate = getEffectiveDateFromModal(this);
        if ((this.modalComment.length > 0 && this.modalComment.trim().length !== 0 && this.approvalEffectiveDate.length > 0) || ((this.modalComment.length > 0 && this.hideEffectiveDateOnReject != true))) {
            var today = new Date();
            var options = {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric',
                timeZone: timeZone
								
            };
						console.log('time zoneeee'+ this.timeZone);

            var formattedDate = new Intl.DateTimeFormat('en-US', options).format(today);
            var formattedDateTemp = formattedDate.split('/');
            console.log('**' + formattedDateTemp);
            var month = parseInt(formattedDateTemp[0]) - 1;
            var fDate = new Date(formattedDateTemp[2], month, formattedDateTemp[1]);
            if (this.approvalEffectiveDate) {
                var approvalED = this.approvalEffectiveDate.split('-');
                var approvalEDFormatted = new Date(approvalED[0], approvalED[1] - 1, approvalED[2]);
                console.log('^^^^^^^^' + this.fDate);
                console.log('@@@@@@' + this.todaydate);

                if (approvalEDFormatted < fDate) {
                    alert("Please enter the effective date greater or equal today date.");
                    return;
                }
            }

            switch (this.currentModalState) {
                case modalStates.APPROVE.state:
                    this.processStepApexCall(modalStates.APPROVE.action);
                    break;
                case modalStates.REJECT.state:
                    this.processStepApexCall(modalStates.REJECT.action);
                    break;
                default:
                    break;
            }
        } else {
            if (this.modalComment.length === 0 && this.modalComment.trim().length === 0 && this.approvalEffectiveDate.length > 0) {
                alert("Please enter the comments");
            } else if (this.approvalEffectiveDate.length === 0 && this.modalComment.length > 0) {
                alert("Please enter the effective date");
            } else {
                alert("Please enter the required fields");
            }
        }

    }

    handlePublicationSubmit() {
        this.modalComment = getCommentPropertyFromModal(this);
        if (this.modalComment.length > 0 && this.modalComment.trim().length !== 0) {
            switch (this.currentModalState) {
                case modalStates.APPROVE.state:
                    this.publicProcessStepApexCall(modalStates.APPROVE.action);
                    break;
                case modalStates.REJECT.state:
                    this.publicProcessStepApexCall(modalStates.REJECT.action);
                    break;
                default:
                    break;
            }
        } else {
            if (this.modalComment.length === 0 && this.modalComment.trim().length === 0) {
                alert("Please enter the comments");
            } else {
                alert("Please enter the required fields");
            }
        }

    }


    processStepApexCall(action) {
        hideModal(this);
        console.log(this.approvalEffectiveDate);
        processStep({
                recordId: this.recordId,
                comments: this.modalComment + '\n' + this.approvalEffectiveDate,
                action: action,
                effectiveDate: this.approvalEffectiveDate
            })
            .then(result => {
                let jsonResult = JSON.parse(result);
                if (jsonResult.success) {
                    displayToast(this, ShowToastEvent, SUCCESS);
                    this.refreshApprovalHistory();
                } else {
                    displayToast(this, ShowToastEvent, ERROR);
                }
                clearModalState(this);
            })
            .catch(error => {
                if (verifyIfNextApproverWasNeeded(error.body.pageErrors)) {
                    setApproversForStep2({
                        recordId: this.recordId,
                        comments: this.modalComment + '\n' + this.approvalEffectiveDate,
                        action: action,
                        effectiveDate: this.approvalEffectiveDate
                    }).then(result2 => {
                        this.refreshApprovalHistory();
                    })
                } else {
                    let errorMessage = extractErrorMessage(error.body.pageErrors);
                    displayToast(this, ShowToastEvent, ERROR, errorMessage);
                    clearModalState(this);
                }
            });
    }


    publicProcessStepApexCall(action) {
        hideModal(this);
        console.log('&&&&&&&&&&&&&&&' + this.approvalEffectiveDate);
        publicRequestStep({
                recordId: this.recordId,
                comments: this.modalComment,
                action: action
            })
            .then(result => {
                let jsonResult = JSON.parse(result);
                if (jsonResult.success) {
                    displayToast(this, ShowToastEvent, SUCCESS);
                    this.refreshApprovalHistory();
                } else {
                    displayToast(this, ShowToastEvent, ERROR);
                }
                clearModalState(this);
            })
            .catch(error => {
                if (verifyIfNextApproverWasNeeded(error.body.pageErrors)) {
                    setApproversForStep2({
                        recordId: this.recordId,
                        comments: this.modalComment,
                        action: action
                    }).then(result2 => {
                        this.refreshApprovalHistory();
                    })
                } else {
                    let errorMessage = extractErrorMessage(error.body.pageErrors);
                    displayToast(this, ShowToastEvent, ERROR, errorMessage);
                    clearModalState(this);
                }
            });
    }


    handleViewAllClick() {
        var compDefinition = {
            componentDef: "c:dcmgt_approvalHistory",
            attributes: {
                recordId: this.recordId,
                isViewAllClicked: true
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
        //     this[NavigationMixin.Navigate]({
        //      type: 'standard__component',
        //      attributes: {
        //          componentName: 'c__dcmgt_approvalHistoryViewAll'
        //      },
        //      state: {
        //          c__counter: '5'
        //      }
        //  });
    }


}