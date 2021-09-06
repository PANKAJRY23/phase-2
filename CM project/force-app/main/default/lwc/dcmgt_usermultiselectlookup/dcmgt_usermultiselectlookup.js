import { LightningElement,api,track,wire } from 'lwc';
import getResults from '@salesforce/apex/dcmgt_MultiLookUpController.getResults';
import getUsersDetails from '@salesforce/apex/dcmgt_UsersSelectionController.getUserDetails';
export default class dcmgt_usermultiselectlookup extends LightningElement {
    @api requesttype
    @api objectName = 'User';
    @api fieldName = 'Name';
    @api filterField = ''; //used to provide filter field in where clause
    @api filterFieldValue= '';//used to provide filter field value in where clause
    @api useFilterCriteria = false; // used to toggle the where clause in soql query
    @api singleSelection = false; // used to toggle between single select and multi select
    @track disableInputField = false;
    @track disableuserInputField = false;
    @api roleType = false;
    @api roleType2 = false;
    @api Label = 'Select Users';
    //@api requestType = 'Data Dictionary';
    @api newRole = false;
    @api uservalue = false;
    @track searchRecords = [];
    @track selectedIds = [];
    @track selectedRecords=[];
    @track searchuserRecords = [];
    @track selecteduserIds = [];
    @track selecteduserRecords=[];
    @api selectedFromParent = [];
    @api required = false;
    @track bShowModal = false;
    @api iconName = 'action:new_user'
    @api LoadingText = false;
    @api LoadinguserText = false;
    @track dynamiClassname = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
    @track messageFlag = false;
    @track messageuserFlag = false;
    @api glossary = false;
    @api dictionary = false;
    role
    role2
    mapOfUserIdAndName
     usersData =[];
     @track usersOptions = [];
    @wire(getUsersDetails)
    getUserNameDetails({data, error}) {
        if(data) {
            this.mapOfUserIdAndName = data
            // Object.entries(this.mapOfUserIdAndName).forEach(item => {
            //     console.log(item)
            //   })
            for (let key in this.mapOfUserIdAndName) {
                let option = {
                    value:  this.mapOfUserIdAndName[key], label: this.mapOfUserIdAndName[key]
                }
                this.usersOptions.push(option)
            }
            // this.mapOfUserIdAndName.forEach(user => {
            //     console.log('user',user);
            //     
            // }) 
            console.log('getUsermultiDetails data', data)
            console.log('getUsermultiDetails data', this.usersOptions)
            console.log('getUsermultiDetails data', JSON.stringify(this.usersOptions))
        }  else if(error) {
            console.log('getUserDetails error',error)
        }
    }
    
    get glossaryOptions() {
        return [
            { label: 'Data Steward', value: 'datasteward',value2: 'datasteward'},
            { label: 'Data Owner', value: 'dataowner',value2: 'dataowner' },
              ];
    }
    get dictionaryOptions() {
        return [
            { label: 'Service Owner', value: 'serviceowner',value2: 'serviceowner'},
            { label: 'Data Steward', value: 'datasteward',value2: 'datasteward'},
        ];
    }
    openModal() {    
        // to open modal window set 'bShowModal' tarck value as true
        console.log("request type:"+this.requesttype);
        this.bShowModal = true;
        if(this.requesttype == 'Business Glossary'){
            this.glossary = true;
         }else if(this.requesttype == 'Data Dictionary') {
             this.dictionary = true;
         }
    }
 
    closeModal() {    
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
    }
    handlesave(){
        this.bShowModal = false;
        let role1 = [];
        let role2 =[];
        this.selectedIds.forEach(user => {
        if(this.mapOfUserIdAndName[user]) {
            role1.push(user)
        }
    })           
    this.selecteduserIds.forEach(user => {
       if(this.mapOfUserIdAndName[user]) {
        role2.push(user)
          }
              })   
              console.log('role1:'+role1);
              console.log('role2:'+role2);
               if(this.glossary = true){
                if(this.role == 'datasteward'){
                    const selectedEvent = new CustomEvent("datasteward", { 
                        detail: role1
                    });
                    this.dispatchEvent(selectedEvent);

                }else {
                    const selectedEvent = new CustomEvent("dataowner", { 
                        detail: role1
                    });
                    this.dispatchEvent(selectedEvent);
                }

               } else if(this.dictionary = true){
                if(this.role2 == 'datasteward'){
                    const selectedEvent2 = new CustomEvent("datasteward", { 
                        detail: role2
                    });      
                    this.dispatchEvent(selectedEvent2);
               }else{
                const selectedEvent2 = new CustomEvent("serviceowner", { 
                    detail: role2
                });      
                this.dispatchEvent(selectedEvent2);
              }              
                    }
         }        
    handleChange(event) {
        console.log("role type >>>>> :"+event.detail.value);
        this.value = event.detail.value;
        this.roleType = true;
        this.role = event.detail.value;
    }
    handleChange2(event) {
        console.log("role type 2 >>>>> :"+event.detail.value);
        this.value = event.detail.value;
        this.uservalue = true;
        this.role2 = event.detail.value;
    }

    connectedCallback() {
        console.log('LookuoComponentinserted')
        console.log(this.selectedFromParent);
        if(this.selectedFromParent != undefined){
            this.selectedRecords = [...this.selectedFromParent];
            this.selecteduserRecords = [...this.selectedFromParent];
            if(this.singleSelection){
                this.disableInputField = true;
            }
        }
    }

    newRoleType(event){
   console.log("new role type:"+event)
  // this.newRole = true;
   this.roleType2 = true;
    }
    searchField(event) {

        var currentText = event.target.value;
        var selectRecId = [];
        for(let i = 0; i < this.selectedRecords.length; i++){
            selectRecId.push(this.selectedRecords[i].recId);
        }
        this.LoadingText = true;
        getResults({ ObjectName: this.objectName, fieldName: this.fieldName, value: currentText, selectedRecId : selectRecId, useFilterCriteria: this.useFilterCriteria, filterField: this.filterField, filterFieldValue:this.filterFieldValue})
        .then(result => {
            this.searchRecords= result;
            this.LoadingText = false;

            //
            this.dynamiClassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            if(currentText.length > 0 && result.length == 0) {
                this.messageFlag = true;
            }
            else {
                this.messageFlag = false;
            }

            if(this.selectRecordId != null && this.selectRecordId.length > 0) {
                this.iconFlag = false;
                this.clearIconFlag = true;
            }
            else {
                this.iconFlag = true;
                this.clearIconFlag = false;
            }
        })
        .catch(error => {
            console.log('-------error-------------'+error);
            console.log(error);
        });

    }

    searchuserField(event) {

        var currentText = event.target.value;
        var selectRecId = [];
        for(let i = 0; i < this.selecteduserRecords.length; i++){
            selectRecId.push(this.selecteduserRecords[i].recId);
        }
        this.LoadingText = true;
        getResults({ ObjectName: this.objectName, fieldName: this.fieldName, value: currentText, selectedRecId : selectRecId, useFilterCriteria: this.useFilterCriteria, filterField: this.filterField, filterFieldValue:this.filterFieldValue})
        .then(result => {
            this.searchuserRecords= result;
            this.LoadinguserText = false;

            //
            this.dynamiClassname =  result.length > 0 ? 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-is-open' : 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
            if(currentText.length > 0 && result.length == 0) {
                this.messageuserFlag = true;
            }
            else {
                this.messageuserFlag = false;
            }

            if(this.selectRecordId != null && this.selectRecordId.length > 0) {
                this.iconFlag = false;
                this.clearIconFlag = true;
            }
            else {
                this.iconFlag = true;
                this.clearIconFlag = false;
            }
        })
        .catch(error => {
            console.log('-------error-------------'+error);
            console.log(error);
        });

    }

   setSelectedRecord(event) {

        var recId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;
        console.log(recId);
        //console.log(selectName);
        let newsObject = { 'recId' : recId ,'recName' : selectName };
        this.selectedIds.push(recId);
        this.selectedRecords.push(newsObject);
        console.log(this.selectedIds);
        this.dynamiClassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        //let selRecords = this.selectedRecords;
        this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
        console.log('event dispatch');
        //console.log(this.selectedIds);
        let ids = this.selectedIds.toString();
        console.log(ids);
        const selectedEvent = new CustomEvent("userselected", { 
            detail: this.selectedRecords
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        if(this.singleSelection){
            this.disableInputField = true;
        }
    }
    setSelectedUserRecord(event) {

        var recId = event.currentTarget.dataset.id;
        var selectName = event.currentTarget.dataset.name;
        console.log(recId);
        //console.log(selectName);
        let newsObject = { 'recId' : recId ,'recName' : selectName };
        this.selecteduserIds.push(recId);
        this.selecteduserRecords.push(newsObject);
        console.log(this.selecteduserIds);
        this.dynamiClassname =  'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click';
        //let selRecords = this.selectedRecords;
        this.template.querySelectorAll('lightning-input').forEach(each => {
            each.value = '';
        });
        console.log('event dispatch');
        //console.log(this.selectedIds);
        let ids = this.selecteduserIds.toString();
        console.log(ids);
        const selectedEvent = new CustomEvent("selectedusers", { 
            detail: this.selecteduserRecords
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
        if(this.singleSelection){
            this.disableuserInputField = true;
        }
    }

    removeRecord (event){
        let selectRecId = [];
        let selectedIds1 = [];
        for(let i = 0; i < this.selectedRecords.length; i++){
            if(event.detail.name !== this.selectedRecords[i].recId){
                selectRecId.push(this.selectedRecords[i]);
                selectedIds1.push(this.selectedRecords[i].recId)
            }
        }
        this.selectedRecords = [...selectRecId];
        this.selectedIds = [...selectedIds1];
        let selRecords = this.selectedRecords;

        let ids = this.selectedIds.toString();
        if(this.singleSelection && selectRecId.length <=0){
            this.disableInputField = false;
        }
        const selectedEvent = new CustomEvent('userselected', { 
            detail: this.selectedRecords
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    removeuserRecord (event){
        let selectRecId = [];
        let selectedIds1 = [];
        for(let i = 0; i < this.selecteduserRecords.length; i++){
            if(event.detail.name !== this.selecteduserRecords[i].recId){
                selectRecId.push(this.selecteduserRecords[i]);
                selectedIds1.push(this.selecteduserRecords[i].recId)
            }
        }
        this.selecteduserRecords = [...selectRecId];
        this.selecteduserIds = [...selectedIds1];
        let selRecords = this.selecteduserRecords;

        let ids = this.selecteduserIds.toString();
        if(this.singleSelection && selectRecId.length <=0){
            this.disableuserInputField = false;
        }
        const selectedEvent = new CustomEvent('selectedusers', { 
            detail: this.selecteduserRecords
        });
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
}