import { LightningElement, api, wire } from 'lwc';
import getProcessInstanceWorkitem from "@salesforce/apex/dcmgt_highlightPanelController.getProcessInstanceWorkitem";
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
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import searchUsers from "@salesforce/apex/dcmgt_ApprovalHistoryController.searchUsers";
import setApproversForStep2 from "@salesforce/apex/dcmgt_highlightPanelController.setApproversForStep2";
import processStep from "@salesforce/apex/dcmgt_highlightPanelController.processStep";
import timeZone from '@salesforce/i18n/timeZone';
const ERROR = "error";
const SUCCESS = "success";
export default class dcmgt_highlightPanel extends NavigationMixin(LightningElement) {
    @api recordId;
    data;
    currentModalState;
    lookupErrors = [];
    isMultiEntry = false;
    hideEffectiveDateOnReject = true;
    modalComment;
    todaydate;
    approvalEffectiveDate;
    parameters = {};

    connectedCallback() {

        if (this.recordId) {
            console.log(this.recordId)
            getProcessInstanceWorkitem({ workItemId: this.recordId }).then(result => {
                console.log('new');
                this.data = result;
                console.log(this.data);
            })
        }
        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        this.todaydate = today;
    }

    renderedCallback() {
        try {
            const approveparam = 'c__approve';
            const approveParamValue = this.getUrlParamValue(window.location.href, approveparam);
            console.log('==approveParamValue==', approveParamValue);
            if (approveParamValue != null) {
                if (approveParamValue === 'true') {
                    console.log('Parameters', approveParamValue);
                    showModal(this);
                    this.currentModalState = modalStates.APPROVE.state;
										this.hideEffectiveDateOnReject = true;
                } else if (approveParamValue === 'false') {
                    showModal(this);
                    this.currentModalState = modalStates.REJECT.state;
										this.hideEffectiveDateOnReject = false;
                }
            }

        } catch (err) {
            console.log(err.message);
        }
    }

    getUrlParamValue(url, key) {

        return new URL(url).searchParams.get(key);
    }


    get data() {
        if (this.data) {
            return this.data
        } else {
            return null;
        }
    }

    get showHighlightPanel() {
        if (this.data) {
            if (this.data.objectLabel === "Alation Article" || this.data.objectLabel === "Data Assets") {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }


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

    get showLookupModal() {
        return (
            this.currentModalState === modalStates.GET_NEXT_APPROVER_SUBMIT.state ||
            this.currentModalState === modalStates.REASSIGN.state ||
            this.currentModalState === modalStates.GET_NEXT_APPROVER_APPROVE.state
        );
    }

    get lookupLabel() {
        return modalStates[this.currentModalState].lookupLabel;
    }

    handleApproveClick() {
        showModal(this);
        this.currentModalState = modalStates.APPROVE.state;
        this.hideEffectiveDateOnReject = true;
    }

    handleModalCancel() {
        hideModal(this);
        clearModalState(this);
        const approveparam = 'c__approve';
        const approveParamValue = this.getUrlParamValue(window.location.href, approveparam);
        if (approveParamValue != null) {
            let url = window.location.href;
            const strarr = url.split("?");
            location.replace(strarr[0]);
            window.location.href = strarr[0];
        }
    }

    handleRejectClick() {
        showModal(this);
        this.currentModalState = modalStates.REJECT.state;
        this.hideEffectiveDateOnReject = false;
    }

    handleReassignClick() {
        showModal(this);
        this.currentModalState = modalStates.REASSIGN.state;
    }

    handleLookupSearch(event) {
        console.log(event.detail);
        searchUsers(event.detail)
            .then(results => {
                this.template.querySelector("c-dcmgt_lookup").setSearchResults(results);
            })
            .catch(error => {
                this.lookupErrors = [error];
            });
    }

    handleSelectionChange() {
        this.lookupErrors = [];
    }

    handleModalSubmit() {
        console.log('Inside the function');
        switch (this.currentModalState) {
            case modalStates.REASSIGN.state:
                if (validateUserLookup(this)) {
                    setSelectedUser(this);
                    this.reassignApexCall();
                }
                break;
            case modalStates.APPROVE.state:
                this.modalComment = getCommentPropertyFromModal(this);
                this.approvalEffectiveDate = getEffectiveDateFromModal(this);
                if (this.modalComment.length > 0 && this.modalComment.trim().length !== 0 && this.approvalEffectiveDate.length > 0) {

                    var today = new Date();
                    var options = {
                        month: 'numeric',
                        day: 'numeric',
												
                        timeZone: timeZone
                    };

                    var formattedDate = new Intl.DateTimeFormat('en-US', options).format(today);
                    var formattedDateTemp = formattedDate.split('/');
                    console.log('****' + formattedDateTemp);
                    var month = parseInt(formattedDateTemp[0]) - 1;
                    var fDate = new Date(formattedDateTemp[2], month, formattedDateTemp[1]);
                    var approvalED = this.approvalEffectiveDate.split('-');
                    var approvalEDFormatted = new Date(approvalED[0], approvalED[1] - 1, approvalED[2]);

                    console.log('(((((((((())))))))))' + fDate);
                    console.log('@@@@@@QQ@@@QQ' + this.todaydate);

                    if (approvalEDFormatted < fDate) {
                        alert("Please enter the effective date greater or equal today date.");
                        return;
                    }


                    this.processStepApexCall(modalStates.APPROVE.action);
                    break;
                } else if (this.modalComment.length === 0  && this.modalComment.trim().length === 0 && this.approvalEffectiveDate.length > 0) {
                    alert("Please enter the comments");
                    return;
                } else if (this.approvalEffectiveDate.length === 0 && this.modalComment.length > 0) {
                    alert("Please enter the effective date");
                    return;
                } else {
                    alert("Please enter the required fields");
                    return;
                }
            case modalStates.REJECT.state:
                this.modalComment = getCommentPropertyFromModal(this);
                this.approvalEffectiveDate = getEffectiveDateFromModal(this);
                debugger;
                if ((this.modalComment.length > 0 && this.modalComment.trim().length !== 0 && this.approvalEffectiveDate.length > 0) || (this.modalComment.length > 0 && this.hideEffectiveDateOnReject != true)) {
                    this.processStepApexCall(modalStates.REJECT.action);
                    break;
                } else if (this.modalComment.length === 0 && this.modalComment.trim().length === 0 && this.approvalEffectiveDate.length > 0) {
                    alert("Please enter the comments");
                    return;
                } else if (this.approvalEffectiveDate.length === 0 && this.modalComment.length > 0) {
                    alert("Please enter the effective date");
                    return;
                } else {
                    alert("Please enter the required fields");
                    return;
                }
            default:
                break;
        }
    }

    processStepApexCall(action) {
        hideModal(this);
        processStep({
                recordId: this.recordId,
                comments: this.modalComment + '\n' + this.approvalEffectiveDate,
                action: action,
                effectiveDate: this.approvalEffectiveDate,
            })
            .then(result => {
                let jsonResult = JSON.parse(result);
                if (jsonResult.success) {
                    //displayToast(this, ShowToastEvent, "SUCCESS");
                    //window.location.reload();
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: jsonResult.instanceWorkItemId,
                            actionName: 'view'
                        }
                    });
                } else {
                    displayToast(this, ShowToastEvent, ERROR);
                }
                clearModalState(this);
            })
            .catch(error => {
                if (error.body && error.body.pageErrors) {
                    if (verifyIfNextApproverWasNeeded(error.body.pageErrors)) {
                        if (this.data.objectLabel === "Alation Article" || this.data.objectLabel === "Data Assets") {
                            setApproversForStep2({
                                recordId: this.recordId,
                                comments: this.modalComment + '\n' + this.approvalEffectiveDate,
                                action: action,
                                effectiveDate: this.approvalEffectiveDate
                            }).then(result2 => {
                                let jsonResult = JSON.parse(result2);
                                this[NavigationMixin.Navigate]({
                                    type: 'standard__recordPage',
                                    attributes: {
                                        recordId: jsonResult.instanceWorkItemId,
                                        actionName: 'view'
                                    }
                                });
                            })
                        } else {
                            showGetNextApproverModal(this, modalStates.GET_NEXT_APPROVER_SUBMIT.state);
                        }

                    } else {
                        let errorMessage = extractErrorMessage(error.body.pageErrors);
                        displayToast(this, ShowToastEvent, ERROR, errorMessage);
                        clearModalState(this);
                    }
                }
            });
    }



}