import { LightningElement, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

const LISTCLASS = 'slds-list slds-border_bottom';
export default class FormElement extends LightningElement {
    _mode;
    _type;
    _label;
    _value;
    _options;
    _size;
    _variant;
    _helpText;
    href;
    editMode = false;
    isRequired = false;
    isReadOnly = false;
    isConnected = false;

    isText;
    isPicklist;
    isCheckbox;
    isLink;
    isLookup;
    isDate;
    isDateTime;
    isNumber;
    isCurrency;
    isPercent;
    isLinkAction;
    isImageAction;
    isButtonIcon;
    isMultiselectPicklist
    listClass = 'slds-list_stacked '+LISTCLASS;
    detailClass = 'slds-item_detail vk-form-font';
    helpTextClass = '';
    editIconClass = 'slds-button slds-button_icon';
    isTableElement = false;

    @api rowIndex;
    @api colIndex;
    @api name;
    @api title;
    @api placeHolder;    

    @api linkLabel;
    @api actionName;
    @api changeType
    @api numberFormat;
    @api currencyCode;
    @api maxFractionDigits;
    @api minFractionDigits;
    @api minValue;
    @api maxValue;

    @api iconName;
    @api iconSize;
    @api iconVariant = 'bare';
    @api imageSource;
    @api readOnlyValue
    
    isBulkUpdate = false
    numberOfRowSelected = 0
    dropdownAlignment=false

    @api setIsBulkUpdate(obj) {
       // console.log('setIsBulkUpdate',JSON.stringify(obj))
        this.numberOfRowSelected = obj.numberOfRowSelected
        this.isBulkUpdate = obj.value
    }

    @api set mode(value){
        this._mode = value ? value : 'view';
        this.editMode = value === 'edit';
        this.handleElementClass();
    }
    get mode(){
        return this._mode;
    }
    @api set type(value){
        value = value ? value : 'text';
        this._type = value;
        this.isText = value.toLowerCase() === 'text' || value.toLowerCase() === 'string';
        this.isPicklist = value.toLowerCase() === 'picklist';
        this.isCheckbox = value.toLowerCase() === 'checkbox' || value.toLowerCase() === 'boolean';
        this.isLookup = value.toLowerCase() === 'lookup' || value.toLowerCase() === 'reference';
        this.isDate = value.toLowerCase() === 'date';
        this.isDateTime = value.toLowerCase() === 'date-time' || value.toLowerCase() === 'datetime';
        this.isNumber = value.toLowerCase() === 'number' || value.toLowerCase() === 'integer';
        this.isCurrency = value.toLowerCase() === 'currency';
        this.isPercent = value.toLowerCase() === 'percent';
        this.isLink = value.toLowerCase() === 'link';
        this.isLinkAction = value.toLowerCase() === 'link-action';
        this.isImageAction = value.toLowerCase() === 'image-action';
        this.isButtonIcon = value.toLowerCase() === 'button-icon';
        this.isMultiselectPicklist = value.toLowerCase() === 'multiselect-picklist';
    }
    get type(){
        return this._type;
    }
    @api set label(value){
        this._label = value ? value : '';
    }
    get label(){
        return this._label;
    }
    @api set value(value){
        this._value = value ? value : '';
        if(this.isLookup && this.isConnected) this.populateLookupValue(this._value);
    }
    get value(){
        return this._value;
    }
    updatedOptions
    @api set options(value){
        this.updatedOptions = []
        this._options = value ? value : [];
        this.updatedOptions = this._options.map(option => {
            if(option.value == this._value){
                return {...option, isSelectedValue: true}
            } else  {
                return {...option, isSelectedValue: false}
            }
        })
        
    }
    get options(){
        return this._options;
    }
    @api set required(value){
        this.isRequired = value ? value : false;
    }
    get required(){
        return this.isRequired;
    }
    _tableRowIndex;
    @api set tableRowIndex(value) {
        this._tableRowIndex = value
    }
    get tableRowIndex() {
        return this._tableRowIndex;
    }
    @api set readOnly(value){
        this.isReadOnly = value ? value : false;
    }
    get readOnly(){
        return this.isReadOnly;
    }    
    @api set size(value){
        this._size = value ? value : '';
    }
    get size(){
        return this._size;
    }
    @api set target(value){
        this._target = value ? value : '_blank';
    }
    get target(){
        return this._target;
    }
    @api set variant(value){ //label-inline, label-hidden, and label-stacked
        this._variant = value ? value : 'label-stacked';
    }
    get variant(){
        return this._variant;
    }
    @api set helpText(value){
        this._helpText = value ? value : '';
    }
    get helpText(){
        return this._helpText;
    }
    @api set tableElement(value){
        this.isTableElement = value ? value : false;
        this.handleElementClass();
    }
    get tableElement(){
        return this.isTableElement;
    }
    className
    inputFieldClass
    rowAndColumn
    connectedCallback(){
        this.dispatchEvent(new CustomEvent('connected', {detail: this.rowIndex}));
        this.isConnected = true;
        //this.isBulkUpdate = false
        this.href = this.isLink && this._value ? '/'+this._value : '';
        this.readOnly = this.isLink;
        if(this.isLookup) this.populateLookupValue(this._value);
        this.rowAndColumn = `${this.rowIndex}-${this.colIndex}`
        this.className = `row-${this.rowAndColumn}`
        this.inputFieldClass =`rowinput-${this.rowAndColumn}`
        
        // this.dropdownAlignment = this.tableRowIndex > 5 ? 'bottom-left' : 'left'; 
    }

    get dropdownAlignmentValue(){
        return  this.tableRowIndex > 5 ? 'bottom-left' : 'left'; 
    }
        
    disconnectedCallback() {
        this.isConnected = false;
    }

    populateLookupValue(value){
        if(this._options){
            this._options.forEach(opt => {
                if(value && value === opt.value){
                    this.linkLabel = opt.label;
                    this.href = '/'+value;
                }
            });
        }else{
            this.linkLabel = value;
            this.href = '/'+value;
        }
    }

    handleElementClass(){
        this.listClass = this.editMode ? 'slds-list' : LISTCLASS;
        if(!this.isTableElement){
            this.listClass += this._variant === 'label-inline' ? ' slds-list_horizontal' : ' slds-list_stacked';
            this.helpTextClass = this._variant === 'label-inline' ? 'slds-col_bump-left' : '';
        }else{
            this.editIconClass += ' table-edit-icon';
            this.listClass = 'slds-list_stacked';
            this.detailClass = 'slds-item_detail';
        }
    }

    handleEditing(){
        if(!this.isReadOnly) this.editElement();
    }

    isBulkEdit = false
    isDisplayEditPopup = true
    get iseditMode() {
        if(this.slectedCell) {
            let slectedRowColumn = this.slectedCell.split('-')
            console.log('slectedRowColumn',slectedRowColumn)
            // let obj = {};
            // if(this.isTableElement){
            //     obj = {rowIndex: this.rowIndex, colIndex: this.colIndex};
            // }else{
            //     this.template.querySelector('.slds-list').classList.remove('slds-border_bottom');
            // }
            // console.log(obj)
            //this.dispatchEvent(new CustomEvent('edit', {detail: obj}));
            return  this.isBulkUpdate === true && 
                this.rowIndex == slectedRowColumn[0] 
                && this.colIndex == slectedRowColumn[1]
                && this.isDisplayEditPopup
        }
        
        return false
       // 
    }

    handleApply(event) {
        console.log('numberOfRowSelected', this.numberOfRowSelected)
        let obj = {};
        if(this.isTableElement){
            obj = {rowIndex: this.rowIndex, colIndex: this.colIndex, name:this.name};
        }else{
            this.template.querySelector('.slds-list').classList.remove('slds-border_bottom');
        }

        
        
        obj.isBulkUpdate
        console.log(`.row-${this.rowIndex}-${this.colIndex}`, obj)
        let checkBoxRef = this.template.querySelector(`.row-${this.rowIndex}-${this.colIndex}`)
        
        console.log('checkBoxRef v',checkBoxRef.checked)
        let isUpdateAll = checkBoxRef.checked
        obj.isBulkUpdate = isUpdateAll
        if(this.isMultiselectPicklist == true) {
            console.log('handleApply multiselectedValue',this.multiselectedValue)
            obj.value = this.multiselectedValue
        } else {
            let inputFieldRef = this.template.querySelector(`.rowinput-${this.rowIndex}-${this.colIndex}`)
            console.log('inputFieldRef v',inputFieldRef.value)
            obj.value = inputFieldRef.value;
        }
        
        obj.isSingleUpdate = false
        this.isDisplayEditPopup = false
        this.dispatchEvent(new CustomEvent('edit', {detail: obj}));
        
        // this.dispatchEvent(new CustomEvent('edit', {detail: obj}));
    }

    @api cancelChanges() {
        console.log('cancelChanges')
        this.isDisplayEditPopup = false
    }

    slectedCell
    @api
    editElement(event){
        this.dispatchEvent(new CustomEvent('closesection'));
        this.isDisplayEditPopup = false
        console.log('btn name',event.target.name)
        this.slectedCell = event.target.name
        console.log('isBulkUpdate val', this.isBulkUpdate)
        console.log('numberOfRowSelected', this.numberOfRowSelected)
        // let slectedRowColumn = this.slectedCell.split('-')
        // console.log('slectedRowColumn',slectedRowColumn)
        // this.editMode =  this.rowIndex == slectedRowColumn[0] && this.colIndex == slectedRowColumn[1]
        if(this.isBulkUpdate === false) {
            console.log('isBulkUpdate No', this.isDisplayEditPopup)
            if(this.changeType === 'Single') {
                this.editMode = true;
                
            } else if(this.changeType === 'Bulk') {
                // alert('No Update'+this.changeType)
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'ERROR!', 
                        message: 'Please select records before clicking on edit button', 
                        variant: 'error'
                    }),
                );
            }
        } else {
            console.log('isBulkUpdate Yes', this.isDisplayEditPopup)
            this.editMode = false;
            this.isDisplayEditPopup = true
            //this.updateEditMode();
            return
        }
        
        // console.log('row-index', this.rowIndex)
        // console.log('col-index', this.colIndex)
        // console.log('label', this.label)
        // console.log('name', this.name)
        // console.log('title', this.title)
        // console.log('link-label', this.linkLabel)
        let obj = {};
        if(this.isTableElement){
            obj = {rowIndex: this.rowIndex, colIndex: this.colIndex, isBulkUpdate: false, isSingleUpdate: true};
        }else{
            this.template.querySelector('.slds-list').classList.remove('slds-border_bottom');
        }
        console.log()
        this.dispatchEvent(new CustomEvent('edit', {detail: obj}));
    }

   // updatedRows = []
    sendValue(event){
        console.log('sendValue')
        let obj = {};
        if(this.isMultiselectPicklist === true) {
            let multiselectValue = event.detail;
            console.log('multiselectValue',multiselectValue.join(";") )
            obj.value = multiselectValue.join(";")
        } else {
            obj.value = event.target.value;
        }
        console.log('sendValue 1')
        if(this.isTableElement){
            obj.rowIndex = this.rowIndex;
            obj.colIndex = this.colIndex; 
            obj.name = this.name;
        }
        console.log('sendValue 2')
        //this.updatedRows.push(obj)
        
        console.log('sendValue 3', obj)
        //console.log('updatedRows', this.updatedRows)
        this.dispatchEvent(new CustomEvent('valuechange', {detail: obj}));
    }
    
    @api
    closeEditMode(){
        this.editMode = false;
        if(!this.isTableElement) this.template.querySelector('.slds-list').classList.add('slds-border_bottom');
    }

    handleLookupChange(event){
        this.linkLabel = event.detail.label;

        let obj = {rowIndex: this.rowIndex, colIndex: this.colIndex, name: this.name, value: event.detail.value, label: event.detail.label};
        this.dispatchEvent(new CustomEvent('valuechange', {detail: obj}));
    }

    handleAction(event){
        let currentNode = event.target;
        if(!currentNode.name) currentNode = currentNode.parentNode;
        let actionName = currentNode.name;
        let obj ={rowIndex: this.rowIndex, colIndex: this.colIndex, actionName: actionName};
        this.dispatchEvent(new CustomEvent('action', {detail: obj}));
    }

    multiselectedValue
    selectedvaluesHandler(event) {
        console.log('selectedvaluesHandler', JSON.stringify(event.detail))
        this.multiselectedValue = event.detail.join(";")
    }
}