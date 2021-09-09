import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import vkStyles from '@salesforce/resourceUrl/dcmgt_customDatatableStyle';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

const DELAY = 300;
const SHOWIT = 'visibility:visible';
const HIDEIT = 'visibility:hidden';
const TEXT_OPERATOR = [
    {label: 'equals', value: 'equals'},
    {label: 'not equal to', value: 'not equal to'},
    {label: 'contains', value: 'contains'},
    {label: 'does not contains', value: 'does not contains'},
    {label: 'start with', value: 'start with'},
];
const PICKLIST_OPERATOR = [
    {label: 'equals', value: 'equals'},
    {label: 'not equal to', value: 'not equal to'},
    {label: 'contains', value: 'contains'},
    {label: 'does not contains', value: 'does not contains'},
];

const MULTISELECT_PICKLIST_OPERATOR = [
    {label: 'equals', value: 'equals'},
    {label: 'not equal to', value: 'not equal to'},
    {label: 'includes', value: 'includes'},
    {label: 'excludes', value: 'excludes'},
];
const NUMBER_DATE_OPERATOR = [
    {label: 'equals', value: 'equals'},
    {label: 'not equal to', value: 'not equal to'},
    {label: 'less than', value: 'less than'},
    {label: 'greater than', value: 'greater than'},
    {label: 'less or equal', value: 'less or equal'},
    {label: 'greater or equal', value: 'greater or equal'}
];

const DEFAULT_OPERATOR = [
    {label: 'equals', value: 'equals'},
    {label: 'not equal to', value: 'not equal to'}
];

export default class dcmgt_CustomTable extends LightningElement {
    @api columns;
    @api
    set records(value){
        this._records = value ? [...value] : [];
        if(this.isConnected) this.setupTable();
    }
    get records(){
        return this._records;
    }
    @api showCheckbox = false;
    @api showRowNumber = false;
    @api sortedBy;
    @api sortedDirection = 'desc';
    @api requesttype;
    //PAGINATION VARIABLES
    @api showPagination = false;
    @api pageSizeOptions = [5,10,20,30,50,75,100];
    @api showSearchBox = false;
    @api buttonName = 'Save'
    @api placeHolder = 'Search Table...';
    @api changeType
    @api 
    set tableLayout(value){
        this._tableLayout = value ? value : 'fixed';
        this.template.querySelector('#custTable').style = `table-layout:${this._tableLayout}`
        //this.tableStyle = 'table-layout:'+this._tableLayout;
    }
    get tableLayout(){
        return this._tableLayout;
    }

    get isDeleteButtonVisible() {
        return this.isRowSelected && this.isDelete
    }
    pageSize = '10'; 
    
    value = '20';

    get options() {
        return [
            { label: 10, value: '10' },
            { label: 20, value: '20' },
            { label: 30, value: '30' },
        ];
    }

    //LOCAL VARIABLES
    showTable = false;
    isLoading = false;
    spinnerMsg = 'Loading...';
    _records; //Clone of Original records
    tableData; //Records modified according to table data structure
    tableData2Display; //Table data structured records available to display
    tableDataAfterFilter; //Table data after filter
    pageData; //Records displayed on a page
    pageDataLength
    
    totalPages;
    pageNumber = 1;
    searchKey;
    controlPagination = 'show-block'//SHOWIT;
    controlPrevious = 'hide-block'//HIDEIT;
    controlNext = 'show-block'//SHOWIT;
    isAscending = false;
    isEdited = false;
    isConnected = false;
    _tableLayout = 'fixed';
    tableStyle = 'table-layout:'+this._tableLayout;

    delayTimeout;
    initialLoad = true;
    stylesLoaded = false;
    selectedTotal = 0;
    selectedPerPage = 0;
    selRowsMap = new Map();
    currentElement;
    currentWidth;
    mousePosition;
    //resizerStyle;
    recsEdited = new Map();
    isRowSelected = false
    @api isDelete = false
    isFilterSectionVisible = false
    tableContentClass = 'vk-data-table slds-col slds-size_4-of-4'
    tableContentsize = 12
    filterIconText = 'Show Filter'
    filterFields = []
    filterOperator = []
    selectedField
    selectedOperator
    selectedFieldValue
    selectedType
    isTypeIsPicklist = false
    isTypeIsDate = false
    isTypeCheckbox = false
    picklistOptions
    selectedValue
    isDoneDisabled = true
    selectedOption
    selectedFieldLabel
    filtersList = []
    filterId = 1
    filterClass = 'slds-hide'
    columnsStyle = 'min-width: 140px; max-width:140px'
    connectedCallback(){
        this.isConnected = true;
        this.setupTable();
        this.tableContentsize = 12
        //this.filterClickHandler()
        console.log('changeType', this.changeType);
        
    }

    disconnectedCallback() {
        this.isConnected = false;
    }

    renderedCallback(){
        if(!this.stylesLoaded){
            Promise.all([
                loadStyle(this, vkStyles)
            ]).then(() => {
                this.stylesLoaded = true;
            }).catch(error => {
                console.log('Error loading styles**'+JSON.stringify(error));
                this.stylesLoaded = false;
            });
        }

        let table = this.template.querySelector('.vk-data-table');
        //this.resizerStyle = 'height:'+table.offsetHeight+'px';
        let cols = this.template.querySelectorAll('TH');
        cols.forEach(col=>{
            col.style.width = col.style.width ? col.style.width : col.offsetWidth+'px';
            col.style.minWidth = col.style.minWidth ? col.style.minWidth : '50px';
        });
    }

    setupTable(){
        this.showTable = false;
        this.isEdited = false;
        this.totalRecords = this._records.length;
        if(this.totalRecords === 0){
            this.showPagination = false;
            return;
        }
        if(this.sortedBy) this._records = this.sortData(this._records,this.sortedBy,this.sortedDirection);

        this.setupColumns();
        this.setupPagination();
        this.setupData();
        this.showTable = true;
        this.initialLoad = false;
    }

    setupColumns(){
        let tempCols = [], i=0;
        //set col values
        console.log('this.columns',this.columns)
        this.columns.forEach(val => {
            let col = {...val};
            col.index = i++;
            col.thClass = 'slds-truncate';
            col.hidden = val.hidden ? val.hidden : false
            col.thClass += val.resizable ? ' vk-is-resizable' : '';
            col.style = col.width ? 'width:'+col.width+'px;' : '';
            col.style += col.minWidth ? 'min-width:'+col.minWidth+'px;' : '';
            col.style += col.maxWidth ? 'max-width:'+col.maxWidth+'px;' : '';
            if(col.sortable === true){
                col.thClass += ' vk-is-sortable';
                col.sortBy = col.sortBy ? col.sortBy : col.fieldName;
                col.sortByTitle = 'Sort By: '+col.label;
                let sortIconClass = this.sortedDirection === 'asc' ? 'vk-sort_desc' : 'vk-sort_asc';
                col.sortIconStyle = 'visibility:hidden;';
                if(col.sortBy === this.sortedBy){
                    sortIconClass = this.sortedDirection === 'asc' ? 'vk-sort_asc' : 'vk-sort_desc';
                    col.sortIconStyle = 'visibility:visible;';
                }
                col.sortIconClass = 'vk-sort-icon-div '+sortIconClass;
            }
            tempCols.push(col);
        });
        this.columns = tempCols;
    }

    setupData(){
        let recs = [], i=0;
        this._records.forEach(value => {
            let row = {}, fields = [], j=0;
            this.columns.forEach(col => {
                //set data values
                let field = {};
                field.name = col.fieldName;
                field.value = value[col.fieldName];
                field.type = col.type;
                field.required = col.required;
                field.options = col.options;
                field.linkLabel = col.type === 'link' || col.type === 'lookup' ? value[col.linkLabel] : col.linkLabel;
                field.imageSource = col.type === 'image-action' ? col.src : '#';
                field.target = col.target;
                field.minValue = col.minValue;
                field.maxValue = col.maxValue;
                field.minFractionDigits = col.minFractionDigits;
                field.maxFractionDigits = col.maxFractionDigits;
                field.currencyCode = col.currencyCode;

                field.iconName = col.iconName;
                field.iconSize = 'xx-small';
                field.actionName = col.actionName;
                field.iconVariant = col.iconVariant;
                field.title = col.title;
                
                field.readOnly = !col.editable;
                field.tdClass = col.editable ? 'vk-cell-edit' : '';
                field.hidden = col.hidden
                field.index = j++;
                fields.push(field);
            });
            if(value.Id) {
                row.id = value.Id ;
            } else {
                row.id = value.id ;
            }
            row.index = i++;
            row.rowNumber = i;
            row.isSelected = false;
            row.mode = 'view';
            row.fields = fields;
            row.class = 'row'+row.index
            recs.push(row);
        });
        this.tableData = recs;
        this.tableData2Display = JSON.parse(JSON.stringify(recs));
        this.tableDataAfterFilter = JSON.parse(JSON.stringify(recs));
        this.setupPages();
    }

    setupPagination(){
        console.log('--this.pageSizeOptions-271-',this.pageSizeOptions);
        if(!this.showPagination){
            this.pageSize = this.totalRecords;
            this.value = this.pageSize;
        } 
        else{
            this.showSearchBox = true;
            this.pageSize = this.pageSizeOptions ? this.pageSizeOptions[0] : '10';
            this.value = this.pageSize;
            if(this.pageSize >= this.totalRecords){
                this.pageSize = this.totalRecords;
                this.value = this.pageSize;
                this.showPagination = false;
                this.showSearchBox = false;
            }
            this.totalPages = Math.ceil(this.totalRecords/this.pageSize);
        }
        if(this.pageSizeOptions){
            this.value = '10';
        }
    }
    
    //START: PAGINATION
    handleRecordsPerPage(event){
        this.pageSize = event.target.value;
        this.value = this.pageSize;
        console.log('pagesize1 '+this.pageSize);
        this.setupPages();
    }
    handlePageNumberChange(event){
        if(event.keyCode === 13){
            this.pageNumber = event.target.value;
            this.setupPages();
        }
    }
    connectedHandler(event) {
        let index = event.detail
        if(this.selRowsMap.has(index)) {
            let rowRef = this.template.querySelectorAll(`.row${index}`)
            let rowCount =  Array.from(this.selRowsMap.values()).length
           // console.log('rowRef', this.selRowsMap.keys())
            //console.log('rowRef', JSON.stringify(this.selRowsMap))
            let obj = {numberOfRowSelected: rowCount, value: true}
            Array.from(rowRef).forEach(element => {
                element.setIsBulkUpdate(obj)
            })
        }
    }
    previousPage(){
        this.pageNumber = this.pageNumber-1;
        this.setupPages();
    }
    nextPage(){
        this.pageNumber = this.pageNumber+1;
        this.setupPages();
    }
    setupPages(){
        this.totalRecords = this.tableData2Display.length;
        //this.totalRecords = this.tableDataAfterFilter.length;
        
        this.setPaginationControls();

        let pageRecs = [];
        for(let i=(this.pageNumber-1)*this.pageSize; i<this.pageNumber*this.pageSize; i++){
            if(i === this.totalRecords) break;
            pageRecs.push(this.tableData2Display[i]);
            //pageRecs.push(this.tableDataAfterFilter[i]);
        }
        this.setupPageData(pageRecs);
    }
    setupPageData(recs){
        this.pageData = [];
        this.selectedPerPage = 0;  
        let index = 0   
        recs.forEach(rec=>{
            let row = {...rec};
            row.rowClass = row.isSelected ? 'vk-is-selected' : '';
            this.selectedPerPage = Number(this.selectedPerPage) + 1;
            if(row.isSelected){
                this.selRowsMap.set(row.index, this._records[row.index]);                
            }else{
                this.selectedPerPage = Number(this.selectedPerPage) - 1;
                if(this.selRowsMap.has(row.index))
                    this.selRowsMap.delete(row.index);
            }
            row.tableRowIndex = index;
            this.selectedTotal = this.selRowsMap.size;
            this.pageData.push(row);
            index++
        });
        this.pageDataLength = this.pageData.length
        if(!this.initialLoad) this.manageSelectAllStyle();
    }
    setPaginationControls(){
        if(!this.pageSize){
            this.pageSize = this.totalRecords;
            this.value = this.pageSize;
        } 
        this.totalPages = Math.ceil(this.totalRecords/this.pageSize);

        //Control Pre/Next buttons visibility by Total pages
        if(this.totalPages === 1){
            this.controlPrevious = 'hide-block'//HIDEIT;
            this.controlNext = 'hide-block'//HIDEIT;
        }else if(this.totalPages > 1){
           this.controlPrevious = 'show-block'//SHOWIT;
           this.controlNext = 'show-block'//SHOWIT;
        }
        //Control Pre/Next buttons visibility by Page number
        if(this.pageNumber <= 1){
            this.pageNumber = 1;
            this.controlPrevious = 'hide-block'//HIDEIT;
        }else if(this.pageNumber >= this.totalPages){
            this.pageNumber = this.totalPages;
            this.controlNext = 'hide-block'//HIDEIT;
        }
        //Control Pre/Next buttons visibility by Pagination visibility
        // if(this.controlPagination === HIDEIT){
            if(this.controlPagination === 'hide-block'){
            
            this.controlPrevious = 'hide-block'//HIDEIT;
            this.controlNext = 'hide-block'//HIDEIT;
        }
    }
    //END: PAGINATION

    //START: ROW SELECTION
    handleRowSelection(event){
        console.log('handleRowSelection', event.target.id)
        let index = Number(event.target.id.split('-')[0]);
        console.log('handleRowSelection index', index)
        let isSelected = event.target.checked;        
        

        this.pageData.forEach(rec => {
            //console.log('handleRowSelection rec', JSON.stringify(rec))
            if(rec.rowNumber === index+1){
                //console.log('handleRowSelection rec', rec)
                rec.isSelected = isSelected;
                let recId = rec.id
                //console.log('handleRowSelection tableData2Display', JSON.stringify(this.tableData2Display))
                //console.log('handleRowSelection tableData2Display', this.tableData2Display.length)
                this.tableData2Display.forEach(tableDate => {
                    if(tableDate.id == recId) {
                        tableDate.isSelected = isSelected
                    }
                })
                // this.tableData2Display[index].isSelected = isSelected;
            }
        });
        //console.log('index', index)
        //console.log('isSelected', isSelected)
        this.setupPageData(this.pageData);
        this.isRowSelected = true

        let rowRef = this.template.querySelectorAll(`.row${index}`)
        let rowCount =  Array.from(this.selRowsMap.values()).length
        //console.log('rowRef', this.selRowsMap.keys())
        //console.log('rowRef', JSON.stringify(this.selRowsMap))
        let obj = {numberOfRowSelected: rowCount, value: isSelected}
        Array.from(rowRef).forEach(element => {
            element.setIsBulkUpdate(obj)
        })
        //rowRef.setIsBulkUpdate(true)
        this.dispatchEvent(new CustomEvent('rowselection', {detail: Array.from(this.selRowsMap.values())}));        
    }
    handlePageRowsSelection(event){
        console.log('pagesize '+this.pageSize);
        let isSelected = event.target.checked;
        //Raj, update the header checkbox to false
        let anyselected=false;
        this.pageData.forEach(rec => {
            if(rec.isSelected){
                anyselected =true;
            }
        });
        if(anyselected && isSelected){
            isSelected=false;
        }
        this.isRowSelected = isSelected
        //End here
        this.pageData.forEach(rec => {
            rec.isSelected = isSelected;
            this.tableData2Display[rec.index].isSelected = isSelected;
            this.tableDataAfterFilter[rec.index].isSelected = isSelected;
        });
        this.setupPageData(this.pageData);
        if(this.isDelete == false) {
            let rowRef = this.template.querySelectorAll(`.row${index}`)
            let rowCount =  Array.from(this.selRowsMap.values()).length
            //console.log('rowRef', this.selRowsMap.keys())
            //console.log('rowRef', JSON.stringify(this.selRowsMap))
            let obj = {numberOfRowSelected: rowCount, value: isSelected}
            Array.from(rowRef).forEach(element => {
                element.setIsBulkUpdate(obj)
            })
        }
        console.log('pageSize458 '+this.pageSize);
        this.dispatchEvent(new CustomEvent('rowselection', {detail: Array.from(this.selRowsMap.values())}));
        
    }
    handleAllRowsSelection(event){
        let isSelected = event.target.checked;

        this.tableData2Display.forEach(rec=>{
            rec.isSelected = isSelected;
            if(isSelected)
                this.selRowsMap.set(rec.index, this._records[rec.index]);
                
            else if(this.selRowsMap.has(rec.index))
                this.selRowsMap.delete(rec.index);
        });
        this.selectedTotal = this.selRowsMap.size;
        this.setupPages();
        this.dispatchEvent(new CustomEvent('rowselection', {detail: Array.from(this.selRowsMap.values())}));
    }
    manageSelectAllStyle(){
        //Select Rows per Page
        let pageCheckbox = this.template.querySelector('.page-checkbox');
        if(!pageCheckbox) return;        
        if(this.selectedPerPage === 0){
            pageCheckbox.checked = false;
            pageCheckbox.indeterminate = false;
        }else if(this.selectedPerPage === this.pageData.length){
            pageCheckbox.checked = true;
            pageCheckbox.indeterminate = false;
        }else{
            pageCheckbox.checked = false;
            pageCheckbox.indeterminate = true;
        }
        
        //Select All Rows
        let allCheckbox = this.template.querySelector('.x');
        if(!allCheckbox) return;
        if(this.selectedTotal === 0){
            allCheckbox.checked = false;
            allCheckbox.indeterminate = false;
        }else if(this.selectedTotal === this._records.length){
            allCheckbox.checked = true;
            allCheckbox.indeterminate = false;
        }else{
            allCheckbox.checked = false;
            allCheckbox.indeterminate = true;
        }
    }
    //END: ROW SELECTION

    //START: SORTING
    handleSorting(event){
        this.isLoading = true;
        let childElm = event.target;
        let parentElm = childElm.parentNode;
        while(parentElm.nodeName != 'TH') parentElm = parentElm.parentNode;
        let sortBy = parentElm.id.split('-')[0];
        setTimeout(() => {
            let sortDirection = this.sortedDirection === 'asc' ? 'desc' : 'asc';
            this._records = this.sortData(this._records,sortBy,sortDirection);
            this.setupColumns();
            this.setupData();
            this.isLoading = false;
        }, 0);
    }
    sortData(data, sortBy, sortDirection){
        let clonedData = [...data];
        clonedData.sort(this.sortDataBy(sortBy, sortDirection === 'asc' ? 1 : -1));
        this.sortedDirection = sortDirection;
        this.sortedBy = sortBy;
        return clonedData;
    }
    sortDataBy(field, reverse, primer) {
        const key = primer
            ? function(x) { return primer(x[field]) }
            : function(x) { return x[field] };

        return function (a, b) {
            let A, B;
            if(isNaN(key(a)) === true)
                A = key(a) ? key(a).toLowerCase() : '';
            else A = key(a) ? key(a) : -Infinity;
            
            if(isNaN(key(b)) === true)
                B = key(b) ? key(b).toLowerCase() : '';
            else B = key(b) ? key(b) : -Infinity;

            return reverse * ((A > B) - (B > A));
        };
    }
    //END: SORTING

    //START: SEARCH
    handleSearch(event){
        window.clearTimeout(this.delayTimeout);
        let searchKey = ''+event.target.value;
        this.isLoading = true;
        if(searchKey){
            if(this.changeType == 'Bulk'){
            this.delayTimeout = setTimeout(() => { 
                this.searchKey = searchKey.toLowerCase();
                let recs = this.tableData.filter(row=>this.searchRow(row,this.searchKey));
                this.pageData = recs;
                console.log('pagedatalen',pageData.length);
                this.tableData2Display = recs;
                this.tableDataAfterFilter = recs;
                //this.setupPages();
                this.isLoading = false;
            }, DELAY);
        }else if(this.changeType == 'Single'){
            this.delayTimeout = setTimeout(() => {
                this.searchKey = searchKey.toLowerCase();
                let recs = this.tableData.filter(row=>this.searchRow(row,this.searchKey));
                //this.pageData = recs;
                //console.log('pagedata'+pageData);
                this.tableData2Display = recs;
                this.tableDataAfterFilter = recs;
                this.setupPages();
                this.isLoading = false;
            }, DELAY);
        }
        }else{
            this.tableData2Display = JSON.parse(JSON.stringify(this.tableData));
            this.tableDataAfterFilter = JSON.parse(JSON.stringify(this.tableData));
            this.setupPages();
            this.isLoading = false;
        }
    }
    searchRow(row,searchKey){
        let fields = row.fields.filter(f => {
            let fieldVal = f.type === 'link' || f.type === 'lookup' ? ''+f.linkLabel : ''+f.value;
            let fieldValue = fieldVal.toLowerCase();
            return fieldValue && fieldValue.includes(searchKey) ? true : false;
        });
        return fields.length > 0;
    }
    //END: SEARCH

    //START: COL RESIZING
    calculateWidth(event){
        this.currentElement = event.target;
        let parentElm = this.currentElement.parentNode;
        while(parentElm.tagName != 'TH') parentElm = parentElm.parentNode;
        this.currentWidth = parentElm.offsetWidth;
        this.mousePosition = event.clientX; //Get current mouse position

        //Stop text selection event so mouse move event works perfectlly.
        if(event.stopPropagation) event.stopPropagation();
        if(event.preventDefault) event.preventDefault();
        event.cancelBubble = true;
        event.returnValue = false;
    }
    setNewWidth(event){
        if(!this.currentElement) return;

        let parentElm = this.currentElement.parentNode;
        while(parentElm.tagName != 'TH') parentElm = parentElm.parentNode;
        let movedWidth = event.clientX - this.mousePosition;
        let newWidth = this.currentWidth + movedWidth;
        parentElm.style.width = newWidth+'px';
    }
    stopColumnResizing(){
        this.currentElement = undefined;
    }
    //END: COL RESIZING

    //START: ROW ACTION
    handleRowAction(event){
        let rowIndex = event.detail.rowIndex;
        let actionName = event.detail.actionName;
        let obj ={row: this._records[rowIndex], action: {name: actionName}};
        this.dispatchEvent(new CustomEvent('rowaction', {detail: obj}));
    }
    //END: ROW ACTION

    //START: CELL EDITING
    handleCellEdit(event){
        this.isEdited = true;
       // this.isRowSelected = false
        let resp = event.detail;
        console.log('handleCellEdit', JSON.stringify(resp))
        if(resp.isSingleUpdate == false) {
            if(resp.isBulkUpdate) {
                console.log('handleCellEdit BulkUpdate')
                Array.from(this.selRowsMap.keys()).forEach(rowIndex => {
                    console.log('handleCellEdit row index',rowIndex )
                    //this.tableData2Display[rowIndex].mode = 'edit';
                    this.handleCellChangeHelper(resp, rowIndex)
                })
            } else {
                console.log('handleCellEdit NO BulkUpdate')
                //this.tableData2Display[resp.rowIndex].mode = 'edit';
                this.handleCellChangeHelper(resp, resp.rowIndex)
            }
        }
        this.setupPages();
    }
    handleCellChange(event){
        // console.log('handleCellChange', this.isRowSelected)
        // console.log('handleCellChange key', this.selRowsMap.keys())
        let resp = event.detail;
        console.log('handleCellChange resp', JSON.stringify(resp))
        this.handleCellChangeHelper(resp, resp.rowIndex)
        // if(resp.isBulkUpdate) {
        //     Array.from(this.selRowsMap.keys()).forEach(rowIndex => {
        //         console.log('handleCellChange row index',rowIndex )
        //         this.handleCellChangeHelper(resp, rowIndex)
        //     })
            
        // } else {
        //     this.handleCellChangeHelper(resp, resp.rowIndex)
        // } 
        
    }

    handleCellChangeHelper(resp, rowIndex) {
        let rec = {...this._records[rowIndex]};
        console.log('rec',rec)
        let selectedTableData;
        this.tableData2Display.forEach(tableDate => {
            if(tableDate.id == rec.Id || tableDate.id == rec.id) {
                console.log('Ids:- ', tableDate.id);
                console.log('rec Ids:- ', rec.id);
                selectedTableData = tableDate
            }
        })
        console.log('selectedTableData', selectedTableData);
        if(selectedTableData) {
            if(resp.value !== this._records[rowIndex][resp.name]){
                // this.tableData2Display.forEach(tableDate => {
                //     if(tableDate.id == rec.Id) {
                //         tableDate.fields[resp.colIndex].tdClass = 'vk-cell-edit vk-cell-edited';
                //         tableDate.fields[resp.colIndex].value = resp.value;
                //         tableDataFields = tableDate.fields
                //     }
                // })

                selectedTableData.fields[resp.colIndex].tdClass = 'vk-cell-edit vk-cell-edited';
                selectedTableData.fields[resp.colIndex].value = resp.value;

                // this.tableData2Display[rowIndex].fields[resp.colIndex].tdClass = 'vk-cell-edit vk-cell-edited';
                // this.tableData2Display[rowIndex].fields[resp.colIndex].value = resp.value;
                rec[resp.name] = resp.value;
            }else{
                // this.tableData2Display.forEach(tableDate => {
                //     if(tableDate.id == rec.Id) {
                //         tableDate.fields[resp.colIndex].tdClass = 'vk-cell-edit';
                //         tableDate.fields[resp.colIndex].value = resp.value;
                //     }
                // })

                selectedTableData.fields[resp.colIndex].tdClass = 'vk-cell-edit';
                selectedTableData.fields[resp.colIndex].value = resp.value;
                

                // this.tableData2Display[rowIndex].fields[resp.colIndex].tdClass = 'vk-cell-edit';
                // this.tableData2Display[rowIndex].fields[resp.colIndex].value = resp.value;
            }
            //let changedFields = this.tableData2Display[rowIndex].fields.filter(field=>field.tdClass.includes('vk-cell-edited'));
            let changedFields = selectedTableData.fields.filter(field=>field.tdClass.includes('vk-cell-edited'));
            console.log('changedFields',changedFields)
            if(changedFields.length > 0){
                //this.tableData2Display[rowIndex].isSelected = true;
                selectedTableData.originalRecord = this._records[rowIndex]
                this.recsEdited.set(rowIndex,selectedTableData);
                // this.tableDataAfterFilter[rowIndex].isSelected = true;
                // this.recsEdited.set(rowIndex,this.tableDataAfterFilter[rowIndex]);
            }else{
                //this.tableData2Display[rowIndex].isSelected = false;
                // this.tableDataAfterFilter[rowIndex].isSelected = false;
                if(this.recsEdited.has(rowIndex))
                    this.recsEdited.delete(rowIndex);
            }
            console.log('this.tableData2Display',selectedTableData)
            console.log('this.recsEdited',this.recsEdited)
            this.setupPages();
        } else {
            console.log('No selectedTableData found')
        }
    }

    cancelChanges(){
        eval("$A.get('e.force:refreshView').fire();");
        // this.isEdited = false;
        // this.tableData2Display = JSON.parse(JSON.stringify(this.tableData));
        // this.setupPages();
    }
    handleSave(){
        let recs2Save = [];
        console.log('CDT handleSave',this.recsEdited)
        for(let [key,value] of this.recsEdited){
            //if(this.selRowsMap.has(key))
                recs2Save.push(value);
        }
        console.log('CDT handleSave',recs2Save)
        let updatedRecords = []
        recs2Save.forEach(element => {
            let tableFields = element.fields
            let rowRecord = {}
            console.log('fields:- ', tableFields)
            console.log('id:- ', element.id)
            rowRecord['Id'] = element.id
            tableFields.forEach(rowItem => {
                rowRecord[rowItem.name] = rowItem.value
            });
            rowRecord['originalRecord'] = element.originalRecord
           // console.log('tableFields orignal', JSON.stringify(element.originalRecord))
            updatedRecords.push(rowRecord)
        });
        console.log('CDT handleSave recs2Save',JSON.stringify(recs2Save))
        console.log('CDT updatedRecords',updatedRecords)
        console.log('save edit', this.isEdited)
        console.log('save edit', this.isRowSelected)
        
        this.dispatchEvent(new CustomEvent('save', {detail: updatedRecords}));
    }

    cellHandler(event) {
        console.log('cellHandler')
        let cellRef = this.template.querySelectorAll('c-dcmgt_form-element')
        Array.from(cellRef).forEach(cell => {
            cell.cancelChanges()
        })
        
    }

    handleSelectedRowSave() {
        console.log('select edit', this.isEdited)
        console.log('select edit', this.isRowSelected)
        this.dispatchEvent(new CustomEvent('saveselectedrow'));
    }

    
    filterClickHandler() {
        this.isFilterSectionVisible = !this.isFilterSectionVisible
        this.tableContentClass = this.isFilterSectionVisible ? 'vk-data-table slds-col slds-size_3-of-4' : 'vk-data-table slds-col slds-size_4-of-4'
        this.tableContentsize = this.isFilterSectionVisible ? 10 : 12
        this.filterClass = this.isFilterSectionVisible ?  ' ': 'slds-hide'
        this.filterIconText = this.isFilterSectionVisible ? 'Hide Filter' : 'Show Filter'
        this.widthChange = this.isFilterSectionVisible ? 'change-width-head-filter' : 'change-width-head'
        console.log('F len',this.filterFields.length)
        if(this.filterFields.length === 0) {
            this.columns.forEach(element => {
                if(element.hidden != true) {
                    let option = {}
                    option['value'] = `${element.fieldName}---${element.type}---${JSON.stringify(element.options)}---${element.label}`  
                    option['label'] = element.label
                    this.filterFields.push(option)
                }
            });
        }
        console.log('F',this.filterFields)
    }
    isFilterSearchVisible= false

    addFilterClickHandler(event) {
        this.selectedField = null
        this.selectedOperator = null
        this.isTypeIsPicklist = false
        this.isTypeIsDate = false
        this.isTypeCheckbox = false
        this.selectedValue = null
        this.selectedOption = null
        this.isFilterSearchVisible =  true
        this.isDoneDisabled = true
    }
    removeAllClickHandler(event) {
        this.isLoading = true;
        this.filtersList = []
        this.filterId = 1
        this.tableData2Display = this.tableData;
        this.tableDataAfterFilter = this.tableData;
        this.setupPages();
        this.isLoading = false;
    }
    closeModalHandler(event) {
        this.isFilterSearchVisible =  false
        event.stopPropagation()
    }

    valueChangeHandler(event) {
        console.log('valueChangeHandler', event.target.value)
        this.selectedValue = event.target.value
        this.updateIsDoneDisabled()
    }
    
    handleFieldChange(event) {
        this.isTypeIsPicklist = false
        this.isTypeIsDate = false
        this.isTypeCheckbox = false
        this.selectedOperator = null
        this.selectedValue = null
        let value = event.target.value
        let valueAndType = value.split('---')
        this.selectedField = event.target.value
        this.selectedFieldValue = valueAndType[0]
        let type = valueAndType[1]
        this.selectedFieldLabel = valueAndType[3]
        console.log('Label',this.selectedFieldLabel)
        if(type == "undefined") {
            type = 'text'
        }
        type = type.toLowerCase()
        console.log('type',type)
        this.selectedType = type
        if(type === 'text' || type === 'lookup') {
            this.filterOperator = TEXT_OPERATOR
        } else if(type === 'picklist' || type === 'multiselect-picklist') {
            this.filterOperator = PICKLIST_OPERATOR
            this.isTypeIsPicklist = true
            this.picklistOptions = JSON.parse(valueAndType[2]) 
            console.log('picklistOptions', this.picklistOptions)
            if(type === 'multiselect-picklist') {
                this.filterOperator = MULTISELECT_PICKLIST_OPERATOR
            }
        } else if(type === 'number' || type === 'date' || type === 'percent' || type === 'currency'){
            if( type === 'date') {
                this.isTypeIsDate = true
            }
            this.filterOperator = NUMBER_DATE_OPERATOR
        } else {
            if(type === 'checkbox') {
                this.isTypeCheckbox = true
            }
            this.filterOperator = DEFAULT_OPERATOR
        }
        this.updateIsDoneDisabled()
    }

    handleOperatorChange(event) {
        console.log('Operater', event.target.value)
        this.selectedOperator = event.target.value
        this.updateIsDoneDisabled()
    }

    handleOptionChange(event) {
        console.log('option', event.target.value)
        this.selectedOption = event.target.value
        this.updateIsDoneDisabled()
    }

    updateIsDoneDisabled() {
        if(this.selectedField && this.selectedOperator && 
            (this.selectedValue || this.selectedOption)) {

            this.isDoneDisabled = false
        } else {
            this.isDoneDisabled = true
        }
    }

    removeFilterClickHandler(event) {
        this.isLoading = true;
        let closeFilterId = event.target.name
        this.filtersList = this.filtersList.filter(currentItem => {
            return currentItem.id != closeFilterId
        }) 
        let initailTableData = this.tableData
        console.log(this.filtersList)
        console.log(this.filtersList.length)
        if(this.filtersList.length != 0) {
            this.filtersList.forEach(filterItem => {
                initailTableData = initailTableData.filter( element => {
                    return this.filterRow(filterItem.field, filterItem.type,
                        filterItem.value, filterItem.operator, element.fields)
                })
            });
        }
        
        this.tableData2Display = initailTableData;
        this.tableDataAfterFilter = initailTableData
        this.setupPages();
        this.isLoading = false;
        console.log('name',closeFilterId)
    }
    saveFilterHandler(event) {
        this.isLoading = true;
        this.isFilterSearchVisible =  false
        console.log(` selectedField:-${this.selectedFieldValue} type:${this.selectedType} selectedOperator:${this.selectedOperator} selectedValue:${this.selectedValue} selectedOption:${this.selectedOption} `)
        let filterValue = {
            id: this.filterId,
            title: this.selectedFieldLabel,
            field: this.selectedFieldValue,
            type: this.selectedType,
            operator: this.selectedOperator
        }
        let fieldSelectedValue = this.selectedValue ? this.selectedValue : this.selectedOption
        filterValue['value'] = fieldSelectedValue
        console.log('value', filterValue['value'])
        this.filtersList.push(filterValue)
        console.log('filtersList',this.filtersList)
        let recs 
        if(this.filterId == 1) {
            if(this.changeType == 'Bulk'){
            console.log('saveFilterHandler tableData', this.tableData)
            recs = this.tableData.filter( element => {
                return this.filterRow(this.selectedFieldValue, this.selectedType,
                    fieldSelectedValue, this.selectedOperator, element.fields)
            })
            this.pageData = recs;
            console.log('pagedata1'+pageData);
            console.log('saveFilterHandler recs', recs)
        }else if(this.changeType == 'Single'){
            console.log('saveFilterHandler tableData', this.tableData)
            recs = this.tableData.filter( element => {
                return this.filterRow(this.selectedFieldValue, this.selectedType,
                    fieldSelectedValue, this.selectedOperator, element.fields)
            })
            // this.pageData = recs;
            // console.log('pagedata1'+pageData);
            console.log('saveFilterHandler recs', recs)
        }
        }else {
            console.log('saveFilterHandler tableDataAfterFilter', this.tableDataAfterFilter)
            recs = this.tableData2Display.filter( element => {
            //recs = this.tableDataAfterFilter.filter( element => {
                return this.filterRow(this.selectedFieldValue, this.selectedType,
                    fieldSelectedValue, this.selectedOperator, element.fields)
            })
            console.log('saveFilterHandler recs', JSON.stringify(recs))
        }
        //let recs = this.tableData.filter(row => this.searchRow(row,this.searchKey));
        // let recs = this.tableData.filter(element => {
        //     console.log(` selectedField:-${this.selectedFieldValue} type:${this.selectedType}  selectedOperator:${this.selectedOperator} selectedValue:${this.selectedValue} selectedOption:${this.selectedOption}`)
        //     if(this.selectedType === 'lookup') {
        //         console.log('lookup')
        //         if(this.selectedOperator === 'equals') {
        //             console.log('equals1',element.fields)
        //             let fieldAPINAme = this.selectedFieldValue
        //             let value;
        //             for(let index=0; index < element.fields.length; index++) {
        //                 if(element.fields[index].name == fieldAPINAme) {
        //                     value = element.fields[index].linkLabel
        //                     console.log('value', value)
        //                     break
        //                 }
        //             }
        //             // element.fields.forEach(item => {
        //             //     if(item['name'] == fieldAPINAme) {
        //             //         value = item['linkLabel']
        //             //         console.log('value', value)
        //             //         break
        //             //     }
        //             // });
        //             // console.log('equals2',element.fields.this.selectedFieldValue)
        //             // console.log('equals3',element[this.selectedFieldValue].linkLabel)
        //             // console.log('this.selectedValue',this.selectedValue )
        //             return value == this.selectedValue
        //         }
        //     } else if(this.selectedType === 'text') {

        //     } else if(this.selectedType === 'picklist') {

        //     }
        //     return false
        // })

        this.tableData2Display = recs;
        //this.tableDataAfterFilter = recs
        this.setupPages();
        this.isLoading = false;
        this.filterId++
    }

    selectedvaluesHandler(event) {
        console.log('selectedvaluesHandler'+event.detail)
        // console.log('selectedvaluesHandler'+event.detail.toString())
        
        // console.log('selectedvaluesHandler'+event.detail.toString().split(','))
        this.selectedOption = JSON.stringify(event.detail)
        this.updateIsDoneDisabled()
    }

    filterRow(fieldAPINAme, fieldType, fieldValue, operator, row) {
        // let fieldAPINAme = this.selectedFieldValue
        let value;
        console.log('row12', row)
        for(let index=0; index < row.length; index++) {
            if(row[index].name == fieldAPINAme) {
                if(fieldType === 'lookup') {
                    value = row[index].linkLabel
                } else {
                    value = row[index].value
                }//value
                console.log('value', value)
                break
            }
        }
        console.log('operator', operator)
        if(fieldType === 'picklist') {
            let fieldValues = fieldValue.replaceAll('"', '')
            fieldValues = fieldValues.replaceAll('[', '')
            fieldValues = fieldValues.replaceAll(']', '')
            fieldValues = fieldValues.split(',')
            console.log('currentItem',fieldValues)
            if(operator === 'equals' || operator === 'contains') {
                return fieldValues.includes(value)
            } else if(operator === 'not equal to' || operator === 'does not contains'){
                return (!fieldValues.includes(value))
            }
        } else if(fieldType === 'multiselect-picklist') {
            let fieldValues = fieldValue.replaceAll('"', '')
            fieldValues = fieldValues.replaceAll('[', '')
            fieldValues = fieldValues.replaceAll(']', '')
            let fieldValuesArray = fieldValues.split(',')
            fieldValues = fieldValues.replaceAll(',', ';')
            console.log('currentItem fieldValues',fieldValuesArray)
            if(operator === 'equals') {
                return fieldValues == value
            } else if(operator === 'not equal to'){
                return fieldValues != value
            } else if(operator === 'includes') {
                if(value) {
                    let valueArr = value.split(';')
                    console.log('valueArr', valueArr)
                    return valueArr.some( ai => fieldValuesArray.includes(ai));
                } else {
                    return false
                }
            }  else if(operator === 'excludes') {
                if(value) {
                    let valueArr = value.split(';')
                    console.log('valueArr', valueArr)
                    return !(valueArr.some( ai => fieldValuesArray.includes(ai)))
                } else {
                    return true
                }
            }
        } else if(fieldType === 'number' || fieldType === 'date') {
            if(operator === 'equals') {
                console.log('fieldValue 2', fieldValue)
                console.log('return value', value == fieldValue)
                return value == fieldValue
            } else if(operator === 'not equal to') {
                return value != fieldValue
            } else if(operator === 'less than') {
                return value < fieldValue
            }  else if(operator === 'greater than') {
                return value > fieldValue
            } else if(operator === 'less or equal') {
                return value <= fieldValue
            } else if(operator === 'greater or equal') {
                return value >= fieldValue
            }
        } else {
            if(value) {
                value = value+''
                value = value.toLowerCase()
            }
            fieldValue = fieldValue.toLowerCase()
            if(operator === 'equals') {
                console.log('D value', value)
                console.log('D fieldValue 2', fieldValue)
                console.log('return value', value == fieldValue)
                return value == fieldValue
            } else if(operator === 'not equal to') {
                return value != fieldValue
            } else if(operator === 'contains') {
                if(value) {
                    return value.indexOf(fieldValue) > -1 ? true : false
                } else {
                    return false
                }
            } else if(operator === 'does not contains') {
                if(value) {
                    return value.indexOf(fieldValue) > -1 ? false : true
                } else {
                    return true
                }
            }  else if(operator === 'start with') {
                if(value) {
                    return value.indexOf(fieldValue) == 0 ? true : false
                } else {
                    return false
                }
            }
        }
        
        return value == fieldValue
    }
    //END: CELL EDITING
}