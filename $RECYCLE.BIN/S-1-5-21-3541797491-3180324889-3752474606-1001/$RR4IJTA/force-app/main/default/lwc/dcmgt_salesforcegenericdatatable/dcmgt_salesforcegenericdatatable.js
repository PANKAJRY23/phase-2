import { LightningElement, api, track } from 'lwc';
const PAGESIZEOPTIONS = [10,15,20];

export default class dcmgt_salesforcegenericdatatable extends LightningElement {
    @api tableData
    @api tableColumn
    @api requesttype
    rowOffset = 0;
    finalChanges;
    error
    opps = []
    pageSizeOptions = PAGESIZEOPTIONS;
    @track selectedRows
    @api showCheckbox = false
    @track isLoading = false
    @track columns
    @api buttonName
    @api isDelete = false
    isDataAvailable = false
    @api changeType

    connectedCallback() {
        console.log('tableData', JSON.stringify(this.tableData))
        console.log('tableColumn', JSON.stringify(this.tableColumn))
        if(this.tableData.length > 0) {
            this.isDataAvailable = true
        }
        console.log('isDataAvailable',this.tableData.length)
        this.isLoading = true
        // if(this.isNonEditable) {
        //     this.columns = this.tableColumn.map(function(currentItem) {
        //         return {...currentItem, editable: false}
        //     })
        //     this.showCheckbox = true
        // } else {
        //     this.columns = this.tableColumn.map(function(currentItem) {
        //         return {...currentItem}
        //     })
        //     this.showCheckbox = false
        // }
        console.log('isLoading false')
        //console.log('isLoading columns', this.columns)
        this.isLoading = false
    }

    @api refreshTable() {
        eval("$A.get('e.force:refreshView').fire();");
    }

    saveHandler(event) {
        console.log('saveHandler')
        console.log(event.detail.draftValues)
        console.log(JSON.stringify(event.detail.draftValues))
        this.finalChanges = event.detail.draftValues;
        const customEvent = new CustomEvent('savetabledata',{
            detail: this.finalChanges
        })
        this.dispatchEvent(customEvent)
        //console.log(event.detail.draftValues[0].Id)

    }

    cellChangeHandler(event) {
        console.log(event)
    }

    
    handleRowSelection(event){
        console.log('Records selected JSON***'+JSON.stringify(event.detail));
        console.log('Records selected***'+event.detail);
        this.selectedRows = event.detail;
    }

    saveSelectedRowHandler() {
        console.log('saveSelectedRowHandler', JSON.stringify(this.selectedRows))
        let selectedRowsArray = JSON.parse(JSON.stringify(this.selectedRows))
        console.log('selectedRowsArray', selectedRowsArray)
        this.dispatchEvent(new CustomEvent('save', {detail: selectedRowsArray}));
    }

    saveRecords(event){
        //this.loadMessage = 'Saving...';
        //this.isLoading = true;
        this.error = '';
        console.log('data:- ', event.detail)
        let data = event.detail
        this.dispatchEvent(new CustomEvent('save', {detail: data}));
        // updateRecords({recsString: JSON.stringify(event.detail)})
        // .then(response=>{
        //     if(response==='success') this.getOpportunities_();
        // })
        // .catch(error=>{
        //     console.log('recs save error***'+error);
        //     this.error = JSON.stringify(error);
        //     this.isLoading = false;
        // });
    }
}