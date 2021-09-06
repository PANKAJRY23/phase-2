import { api, LightningElement, track, wire } from 'lwc';
import getArticles from '@salesforce/apex/dcmgt_RelatedListController.getArticleByChangeRequestId'
import processStep from "@salesforce/apex/dcmgt_ApprovalHistoryController.processStep";
import processStepInBulk from "@salesforce/apex/dcmgt_ApprovalHistoryController.processStepInBulk";
import setApproversForStep2 from "@salesforce/apex/dcmgt_ApprovalHistoryController.setApproversForStep2";
import methodForCheckingJobId from "@salesforce/apex/dcmgt_ApprovalHistoryController.methodForCheckingJobId";
import timeZone from '@salesforce/i18n/timeZone';
import { NavigationMixin } from 'lightning/navigation';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import approvalHistoryUtil from 'c/dcmgt_approvalHistoryUtil'

const ERROR = "error";
const SUCCESS = "success";


export default class Dcmgt_alationArticleRelatedList extends NavigationMixin(LightningElement) {
    @api recordId
    @track data = []
    dataLength = 0
    isRecordsAvailable = false
    wiredApprovalHistory;
    isLoading = true
    todaydate
    showBulkApproveRejectButton = false;
    isCheckedRows = false
    isBulkCheckedRows = false
    isBulkApproveReject = false
    hideEffectiveDateOnReject = true
    selectedRecordIds = []
    @api isViewAllClicked = false
    columns = [{
            label: 'Name',
            fieldName: 'recordLink',
            type: 'url',
            typeAttributes: {
                label: { fieldName: 'name' },
                target: '_blank'
            }
        },
        {
            label: 'Action',
            type: 'button-icon',
            typeAttributes: {
                iconName: 'utility:preview',
                title: 'View',
                variant: 'border-filled',
                alternativeText: 'View'
            }
        }
    ]

    renderedCallback() {
        const style = document.createElement('style');
        style.innerText = '.column-action-button .slds-button{min-width: 90px;}';
        if (this.template.querySelector('.custom-table-container')) {
            this.template.querySelector('.custom-table-container').appendChild(style);
        }

        var today = new Date();
        var dd = String(today.getDate()).padStart(2, '0');
        var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
        var yyyy = today.getFullYear();
        today = yyyy + '-' + mm + '-' + dd;
        this.todaydate = today;
    }

    get modalsubmitLabel() {
        if (this.currentModalState && approvalHistoryUtil.modalStates[this.currentModalState])
            return approvalHistoryUtil.modalStates[this.currentModalState].submitLabel;
        return "";
    }

    get modalTitle() {
        if (this.currentModalState && approvalHistoryUtil.modalStates[this.currentModalState])
            return approvalHistoryUtil.modalStates[this.currentModalState].title;
        return "";
    }

    handleChange(event) {
        var checkforSelectedRows = this.template.querySelectorAll('[data-id="checkbox"]');
        for (var i = 0; i < checkforSelectedRows.length; i++) {
            if (checkforSelectedRows[i].checked == true && checkforSelectedRows[i].name != 'Approved' && checkforSelectedRows[i].name != 'Rejected' && checkforSelectedRows[i].name != 'Completed' && checkforSelectedRows[i].name != 'Under Processing') {
                this.isCheckedRows = true
                break;
            } else {
                this.isCheckedRows = false
            }
        }
        if (this.isCheckedRows == true) {
            //this.showApproveRejectColumn = false
            this.showBulkApproveRejectButton = true
        } else {
            //this.showApproveRejectColumn = true
            this.showBulkApproveRejectButton = false
        }

    }

    selectAllCheckboxes(event) {
        var checkboxes = this.template.querySelectorAll('[data-id="checkbox"]')
        let i;
        for (i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = event.target.checked;
        }
        for (i = 0; i < checkboxes.length; i++) {
            if (event.target.checked == true && checkboxes[i].name != 'Approved' && checkboxes[i].name != 'Rejected' && checkboxes[i].name != 'Completed' && checkboxes[i].name != 'Under Processing') {
                this.isBulkCheckedRows = true
                break;
            } else {
                this.isBulkCheckedRows = false
            }
        }
        if (this.isBulkCheckedRows == true) {
            this.showBulkApproveRejectButton = true
        } else {
            this.showBulkApproveRejectButton = false
        }

    }
    UpdateAllCheckboxesAndSetToFalse() {
        var checkboxes = this.template.querySelectorAll('[data-id="checkbox"]')
        var mainCheckboxes = this.template.querySelectorAll('[data-id="mainCheckBox"]')
        mainCheckboxes[0].checked = false;
        let i;
        for (i = 0; i < checkboxes.length; i++) {
            checkboxes[i].checked = false;
            //this.showApproveRejectColumn = true
            this.showBulkApproveRejectButton = false


        }

    }

    navigateToChangeRequestRecordPage() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'dcmgt_Change_Request__c',
                actionName: 'view'
            }
        });
    }

    handleApproveSelectedClick(event) {
        this.isBulkApproveReject = true
        var selectedRecords = [];
        var checkvalue = this.template.querySelectorAll('[data-id="checkbox"]');
        for (var i = 0; i < checkvalue.length; i++) {
            if (checkvalue[i].checked == true) {
                selectedRecords.push(checkvalue[i].value);
            }
        }
        this.selectedRecordIds = selectedRecords
        approvalHistoryUtil.showModal(this);
        this.currentModalState = approvalHistoryUtil.modalStates.APPROVE.state;
        this.hideEffectiveDateOnReject = true;
    }

    handleRejectSelectedClick(event) {
        this.isBulkApproveReject = true
        var selectedRecords = [];
        var checkvalue = this.template.querySelectorAll('[data-id="checkbox"]');
        for (var i = 0; i < checkvalue.length; i++) {
            if (checkvalue[i].checked == true) {
                selectedRecords.push(checkvalue[i].value);
            }
        }
        this.selectedRecordIds = selectedRecords
        approvalHistoryUtil.showModal(this);
        this.currentModalState = approvalHistoryUtil.modalStates.REJECT.state;
        this.hideEffectiveDateOnReject = false;
    }

    @wire(getArticles, { changeRequestId: '$recordId' })
    getArticle(value) {
        this.wiredApprovalHistory = value;
        if (value.data) {
            this.data = []
            if (value.data.length > 0) {
                this.isRecordsAvailable = true
                if (value.data.length <= 3) {
                    this.dataLength = value.data.length;
                } else {
                    this.dataLength = '3+'
                }
            } else {
                this.dataLength = 0;
            }
            if (this.isViewAllClicked === true) {
                this.data = value.data
                this.dataLength = value.data.length;
            } else {
                for (let index = 0; index < value.data.length; index++) {
                    let row = {...value.data[index] }
                    this.data.push(row)
                    if (index == 2) {
                        break;
                    }
                }
            }
            console.log('getArticle data', JSON.stringify(value.data))
            console.log('getArticle data', this.data.length + this.isRecordsAvailable)
            this.isLoading = false
        } else if (value.error) {
            console.error('getArticle error', value.error)
            this.isLoading = false
        }
    }

    refreshApprovalHistory() {
        console.log('refreshing')
        this.isLoading = false
        return refreshApex(this.wiredApprovalHistory);
    }

    handleViewAllClick() {
        var compDefinition = {
            componentDef: "c:dcmgt_alationArticleRelatedList",
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
    }
    currentModalState
    targetRecordId

    handleApproveClick(event) {
        this.isBulkApproveReject = false
        this.targetRecordId = event.target.name
        approvalHistoryUtil.showModal(this);
        this.currentModalState = approvalHistoryUtil.modalStates.APPROVE.state;
        this.hideEffectiveDateOnReject = true;
    }

    handleRejectClick(event) {
        this.isBulkApproveReject = false
        this.targetRecordId = event.target.name
        approvalHistoryUtil.showModal(this);
        this.currentModalState = approvalHistoryUtil.modalStates.REJECT.state;
        this.hideEffectiveDateOnReject = false;
    }

    handleModalCancel() {
        console.log('handleModalCancel');
        approvalHistoryUtil.hideModal(this);
        approvalHistoryUtil.clearModalState(this);
    }

    modalComment
    approvalEffectiveDate
    handleModalSubmit() {
        this.isLoading = true
        this.modalComment = approvalHistoryUtil.getCommentPropertyFromModal(this);
        this.approvalEffectiveDate = approvalHistoryUtil.getEffectiveDateFromModal(this);
        console.log(this.modalComment + this.approvalEffectiveDate)
        if ((this.modalComment.length > 0 && this.modalComment.trim().length !== 0 && this.approvalEffectiveDate.length > 0) || (this.modalComment.length > 0 && this.hideEffectiveDateOnReject != true)) {
            var today = new Date();
            var options = {
                year: 'numeric',
                month: 'numeric',
                day: 'numeric',
                timeZone: timeZone
            };

            var formattedDate = new Intl.DateTimeFormat('en-US', options).format(today);
            var formattedDateTemp = formattedDate.split('/');
            console.log('**' + formattedDateTemp);
            var month = parseInt(formattedDateTemp[0]) - 1;
            var fDate = new Date(formattedDateTemp[2], month, formattedDateTemp[1]);
            debugger;
            if (this.approvalEffectiveDate) {
                debugger;
                var approvalED = this.approvalEffectiveDate.split('-');
                var approvalEDFormatted = new Date(approvalED[0], approvalED[1] - 1, approvalED[2]);
                console.log('approvalEDFormatted', approvalEDFormatted);
                if (approvalEDFormatted < fDate) {
                    alert("Please enter the effective date greater or equal today date.");
                    return;
                }
            }

            if (this.isBulkApproveReject == true) {
                switch (this.currentModalState) {
                    case approvalHistoryUtil.modalStates.APPROVE.state:
                        this.processStepBulkApexCall(approvalHistoryUtil.modalStates.APPROVE.action);
                        break;
                    case approvalHistoryUtil.modalStates.REJECT.state:
                        this.processStepBulkApexCall(approvalHistoryUtil.modalStates.REJECT.action);
                        break;
                    default:
                        break;
                }
            } else {
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
            }

        } else {
            this.isLoading = true
            if (this.modalComment.length === 0 && this.modalComment.trim().length === 0 && this.approvalEffectiveDate.length > 0) {
                alert("Please enter the comments");
            } else if (this.approvalEffectiveDate.length === 0 && this.modalComment.length > 0) {
                alert("Please enter the effective date");
            } else {
                alert("Please enter the required fields");
            }
        }

    }

    checkBatchCompletedOrNot() {
        console.error('--this.recordId--292--', this.recordId);
        methodForCheckingJobId({ recordId: this.recordId })
            .then(result => {
                console.error('--result-295-', result);
                if (result === 'true') {
                    setTimeout(() => {
                        this.checkBatchCompletedOrNot();
                    }, 5000);
                } else {
                    console.log('-- window.location.href--' + window.location.href)
                        // window.location.href = window.location.href;
                    this.UpdateAllCheckboxesAndSetToFalse();
                    this.refreshApprovalHistory();
                }
            }).catch(error => {
                console.log('--error--', error)
            });
    }

    processStepBulkApexCall(action) {
        approvalHistoryUtil.hideModal(this);
        processStepInBulk({
                recordIds: this.selectedRecordIds,
                comments: this.modalComment + '\n' + this.approvalEffectiveDate,
                action: action,
                effectiveDate: this.approvalEffectiveDate
            })
            .then(result => {
                console.log('processStep', result);
                this.checkBatchCompletedOrNot();
                let jsonResult = JSON.parse(result);
                if (jsonResult.success) {
                    approvalHistoryUtil.displayToast(this, ShowToastEvent, SUCCESS);
                    this.refreshApprovalHistory();
                } else {

                    approvalHistoryUtil.displayToast(this, ShowToastEvent, ERROR);
                }
                approvalHistoryUtil.clearModalState(this);
                this.isLoading = true;

            })
            .catch(error => {

                // console.error('processStep error',error);
                // console.error('processStep error body',error.body.pageErrors);
                if (error.body && approvalHistoryUtil.verifyIfNextApproverWasNeeded(error.body.pageErrors)) {
                    setApproversForStep2({
                        recordId: this.targetRecordId,
                        comments: this.modalComment + '\n' + this.approvalEffectiveDate,
                        action: action,
                        effectiveDate: this.approvalEffectiveDate
                    }).then(result2 => {
                        console.log('setApproversForStep2 ', result2);
                        this.refreshApprovalHistory();
                    }).catch(error2 => {
                        console.error('setApproversForStep2 error', error2);
                    })
                } else {
                    if (error.body) {
                        let errorMessage = approvalHistoryUtil.extractErrorMessage(error.body.pageErrors);
                        approvalHistoryUtil.displayToast(this, ShowToastEvent, ERROR, errorMessage);
                        approvalHistoryUtil.clearModalState(this);
                    }
                }

            });
    }

    processStepApexCall(action) {
        approvalHistoryUtil.hideModal(this);
        console.log(this.targetRecordId);
        processStep({
                recordId: this.targetRecordId,
                comments: this.modalComment + '\n' + this.approvalEffectiveDate,
                action: action,
                effectiveDate: this.approvalEffectiveDate
            })
            .then(result => {
                console.log('processStep', result);
                let jsonResult = JSON.parse(result);
                if (jsonResult.success) {
                    approvalHistoryUtil.displayToast(this, ShowToastEvent, SUCCESS);
                    this.refreshApprovalHistory();
                } else {
                    this.isLoading = false
                    approvalHistoryUtil.displayToast(this, ShowToastEvent, ERROR);
                }
                approvalHistoryUtil.clearModalState(this);
            })
            .catch(error => {
                this.isLoading = false
                console.error('processStep error', error);
                // console.error('processStep error body',error.body.pageErrors);
                if (error.body && approvalHistoryUtil.verifyIfNextApproverWasNeeded(error.body.pageErrors)) {
                    setApproversForStep2({
                        recordId: this.targetRecordId,
                        comments: this.modalComment + '\n' + this.approvalEffectiveDate,
                        action: action,
                        effectiveDate: this.approvalEffectiveDate
                    }).then(result2 => {
                        console.log('setApproversForStep2 ', result2);
                        this.refreshApprovalHistory();
                    }).catch(error2 => {
                        console.error('setApproversForStep2 error', error2);
                    })
                } else {
                    if (error.body) {
                        let errorMessage = approvalHistoryUtil.extractErrorMessage(error.body.pageErrors);
                        approvalHistoryUtil.displayToast(this, ShowToastEvent, ERROR, errorMessage);
                        approvalHistoryUtil.clearModalState(this);
                    }
                }

            });
    }

    handlePublicationSubmit() {
        this.modalComment = approvalHistoryUtil.getCommentPropertyFromModal(this);
        if (this.modalComment.length > 0 && this.modalComment.trim().length !== 0) {
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
        } else {
            if (this.modalComment.length === 0 && this.modalComment.trim().length === 0) {
                alert("Please enter the comments");
            } else {
                alert("Please enter the required fields");
            }
        }

    }

}