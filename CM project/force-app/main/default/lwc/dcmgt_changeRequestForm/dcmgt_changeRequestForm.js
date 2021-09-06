import { api, LightningElement, track, wire } from 'lwc';
import CHANGE_SET_OBJECT from '@salesforce/schema/dcmgt_Change_Request__c';
import CHANGE_REQUEST_TYPE from '@salesforce/schema/dcmgt_Change_Request__c.dcmgt_Change_Request_Type__c';
import REQUEST_TYPE from '@salesforce/schema/dcmgt_Change_Request__c.dcmgt_Request_Type__c'
import DATA_DICTIONARY from '@salesforce/schema/dcmgt_Change_Request__c.dcmgt_Alation_Data_Dictionary__c'
import GLOSSARY from '@salesforce/schema/dcmgt_Change_Request__c.dcmgt_Alation_Glossary__c'
import EFFECTIVE_DATA from '@salesforce/schema/dcmgt_Change_Request__c.dcmgt_Request_Effective_Date__c'
import SUBMITTED_BY from '@salesforce/schema/dcmgt_Change_Request__c.dcmgt_Submitted_By__c'
import CHANGE_TYPE from '@salesforce/schema/dcmgt_Change_Request__c.dcmgt_Change_Type__c'
import PRIORITY from '@salesforce/schema/dcmgt_Change_Request__c.dcmgt_Priority__c'
import getDictionaryList from '@salesforce/apex/dcmgt_Exportdatadictionary.getDictionary';
import getGlossaryList from '@salesforce/apex/dcmgt_LWCExampleController.getGlossary';
import storeStageData from '@salesforce/apex/dcmgt_changeRequestFormController.storeStageRecord'
import getMapOfUserIdAndName from '@salesforce/apex/dcmgt_changeRequestFormController.getMapOfUserIdAndName'
import getTemplateFields from '@salesforce/apex/dcmgt_changeRequestFormController.getTemplateFields'
import getAllDataAsserts from '@salesforce/apex/dcmgt_changeRequestFormController.getAllDataAsserts'
import getArticleByGlossary from '@salesforce/apex/dcmgt_changeRequestFormController.getArticleByGlossary'
import getDataAssertByDictionary from '@salesforce/apex/dcmgt_changeRequestFormController.getDataAssertByDictionary'
import getMapOfUserEmailAndName from '@salesforce/apex/dcmgt_changeRequestFormController.getMapOfUserEmailAndName'
import getAllActiveDataDictionary from '@salesforce/apex/dcmgt_changeRequestFormController.getAllActiveDataDictionary'
//import getPickListValues from '@salesforce/apex/dcmgt_changeRequestFormController.getPickListValues'

import getAllActiveSchema from '@salesforce/apex/dcmgt_changeRequestFormController.getAllActiveSchema'


import getListOfDataAssetsByDictionaryId  from '@salesforce/apex/dcmgt_changeRequestFormController.getListOfDataAssetsByDictionaryId';
import getAlationArticleDataByGlossaryId from '@salesforce/apex/dcmgt_changeRequestFormController.getAlationArticleDataByGlossaryId';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {getRecord,getFieldDisplayValue} from 'lightning/uiRecordApi'
import Id from '@salesforce/user/Id'
import NAME_FIELD from '@salesforce/schema/User.Name'
import getRequestName from '@salesforce/apex/dcmgt_changeRequestFormController.getRequestTypeName'
import { NavigationMixin } from 'lightning/navigation'
import styleCSS from '@salesforce/resourceUrl/dcmgt_styleCSS';
import { loadStyle } from 'lightning/platformResourceLoader';


const TYPEOPTIONS = [
    {value: 'Table', label: 'Table'},
    {value: 'Column', label: 'Column'}
];

const OPTIONS = [
    {value: 'Demo 1', label: 'Demo 1'},
    {value: 'Demo 2', label: 'Demo 2'},
    {value: 'Demo 3', label: 'Demo 3'}
];

const SUBJECT_AREA = [
    {value: 'Customer', label: 'Customer'},
    {value: 'Order', label: 'Order'},
    {value: 'Infrastructure', label: 'Infrastructure'},
    {value: 'Operations', label: 'Operations'},
    {value: 'Product', label: 'Product'},
    {value: 'Marketing', label: 'Marketing'},
    {value: 'Sales', label: 'Sales'},
    {value: 'Partner', label: 'Partner'},
    {value: 'Support', label: 'Support'},
    {value: 'Finance', label: 'Finance'},
    {value: 'Real Estate', label: 'Real Estate'},
    {value: 'Legal', label: 'Legal'},
    {value: 'Security', label: 'Security'}
];

const TERM_TYPE = [
    {value: 'Business Term', label: 'Business Term'},
    {value: 'Metric', label: 'Metric'},
    {value: 'KPI', label: 'KPI'}
];

const CLASSIFICATION = [
    {value: 'Internal', label: 'Internal'},
    {value: 'Public', label: 'Public'},
    {value: 'Restricted', label: 'Restricted'},
    {value: 'Critical', label: 'Critical'}
];

const LIFE_CYLE_STATUS = [
    {value: 'New', label: 'New'},
    {value: 'Certified', label: 'Certified'},
    {value: 'Deprecated', label: 'Deprecated'},
    {value: 'Active', label: 'Active'},
    {value: 'Deprecate Candidate', label: 'Deprecate Candidate'},
    {value: 'Under Business Review', label: 'Under Business Review'}
];

const INDICATION_METRIC = [
    {value: 'Yes', label: 'Yes'},
    {value: 'No', label: 'No'}
];

const REFRESH_FREQUENCY = [
    {value: 'daily', label: 'daily'},
    {value: 'weekly', label: 'weekly'},
    {value: 'monthly', label: 'monthly'},
    {value: 'quarterly', label: 'quarterly'}
];


const dataAssertColumns = [
    { label: 'Name', fieldName: 'Name', type: 'text',  sortable: true, hidden : true}, 
    {label: 'Schema', fieldName: 'dcmgt_Schema__c', type: 'lookup', linkLabel: 'schema',sortable: true, sortBy: 'schema', hidden : true},
    { label: 'Full Name', fieldName: 'dcmgt_Full_name__c', type: 'text', sortable: true,hidden : true }, 
    { label: 'Type', fieldName: 'dcmgt_Type__c',editable: true, type: 'picklist', options: TYPEOPTIONS,  sortable: true, hidden : true }, 
    { label: 'Description', fieldName: 'dcmgt_Description__c', editable: true, type: 'text', sortable: true, hidden : true  },
    {label: 'Data Assets', fieldName: 'dcmgt_Data_Assets__c', type: 'lookup', linkLabel: 'dataAssert',  sortable: true, sortBy: 'dataAssert', hidden : true},
    { label: 'Business Process', fieldName: 'dcmgt_Business_Process__c', editable: true, type: 'text', sortable: true,hidden : true  },
    { label: 'Business Rules', fieldName: 'dcmgt_Business_Rules__c', editable: true, type: 'text',  sortable: true ,hidden : true },
    { label: 'Data Category', fieldName: 'dcmgt_Data_category__c', editable: true, type: 'text',  sortable: true, hidden : true  },
    { label: 'Data Consumer', fieldName: 'dcmgt_Data_Consumer__c', editable: true, type: 'text', sortable: true, hidden : true  },
    { label: 'Data Dictionary Field', fieldName: 'dcmgt_Data_Dictionary_Field__c', editable: true, type: 'text', sortable: true, hidden : true   },
    {label: 'Service Owners', fieldName: 'dcmgt_Service_Owners__c', type: 'multiselect-picklist', sortable: true,editable: true, hidden : true },
    {label: 'Data Stewards', fieldName: 'dcmgt_Data_Stewards__c', type: 'multiselect-picklist', sortable: true,editable: true, hidden : true },
    { label: 'Derived logic/Business Calculation', fieldName: 'dcmgt_Derived_logic_Business_Calculation__c', editable: true, type: 'text', sortable: true, hidden : true   },
    { label: 'Dimensions', fieldName: 'dcmgt_Dimensions__c', editable: true, type: 'text', sortable: true, hidden : true   },
    { label: 'Indication Metric', fieldName: 'dcmgt_Indication_Metric__c',editable: true, type: 'picklist', options: INDICATION_METRIC, sortable: true, hidden : true  }, 
    { label: 'Refresh Frequency', fieldName: 'dcmgt_Refresh_Frequency__c',editable: true, type: 'picklist', options: REFRESH_FREQUENCY, sortable: true, hidden : true  }, 
    { label: 'Subject Area', fieldName: 'dcmgt_Subject_Area__c', editable: true, type: 'text', sortable: true, hidden : true   },
    { label: 'Tenant', fieldName: 'dcmgt_Tenant__c', editable: true, type: 'text',  sortable: true , hidden : true  },
    { label: 'Value Update', fieldName: 'dcmgt_Value_Update__c', editable: true, type: 'text', sortable: true , hidden : true  },
]

const articleColumns = [
    { label: 'Name', fieldName: 'Name',sortable: true,hidden : true }, 
    { label: 'Description', fieldName: 'dcmgt_Description__c', editable: true, sortable: true,hidden : true}, 
    { label: 'Acronynm/Synonym', fieldName: 'dcmgt_Acronynm_Synonym__c' , sortable: true,hidden : true}, 
    { label: 'Last Review Date', fieldName: 'dcmgt_Last_Review_Date__c', type: 'date', sortable: true,hidden : true}, 
    { label: 'Term Type', fieldName: 'dcmgt_Term_Type__c', type: 'picklist', options: TERM_TYPE, editable: true, sortable: true,hidden : true }, 
    { label: 'Life Cycle Status', fieldName: 'dcmgt_Life_Cycle_Status__c', type: 'picklist', options: LIFE_CYLE_STATUS, sortable: true, editable: true,hidden : true}, 
    // { label: 'Subject Area', fieldName: 'dcmgt_Subject_Area__c', type: 'picklist', options: SUBJECT_AREA, editable: true, sortable: true,hidden : true},
    { label: 'Classification', fieldName: 'dcmgt_Classification__c', type: 'picklist', options: CLASSIFICATION, editable: true, sortable: true,hidden : true },
    {label: 'Data Owners', fieldName: 'dcmgt_Data_Owners__c', type: 'multiselect-picklist', sortable: true,editable: true,hidden : true},
    {label: 'Data Stewards', fieldName: 'dcmgt_DataStewards__c', type: 'multiselect-picklist', sortable: true,editable: true,hidden : true},
    {label: 'Alation Article', fieldName: 'dcmgt_Alation_Article__c', type: 'lookup', linkLabel: 'parentArticle', sortable: true, sortBy: 'parentArticle',hidden : true},
    {label: 'Alation Data Dictionary', fieldName: 'dcmgt_Alation_Data_Dictionary__c', type: 'lookup', linkLabel: 'dataDictionary', sortable: true, sortBy: 'dataDictionary',hidden : true},
    { label: 'Approval date', fieldName: 'dcmgt_Approval_date__c', type: 'date', sortable: true,hidden : true}, 
    { label: 'Governed Flag', fieldName: 'dcmgt_Governed_Flag__c', type: 'checkbox', sortable: true,hidden : true}, 
    { label: 'Subject Area', fieldName: 'dcmgt_Multi_Subject_Area__c', type: 'multiselect-picklist', options: SUBJECT_AREA, editable: true,resizable: true, sortable: true,hidden : true}
]

export default class dcmgt_ChangeRequestForm extends NavigationMixin(LightningElement) {
    objectName = CHANGE_SET_OBJECT
    changeRequestType = CHANGE_REQUEST_TYPE
    requestType = REQUEST_TYPE
    dataDictionary = DATA_DICTIONARY
    glossary = GLOSSARY
    effectiveDate = EFFECTIVE_DATA
    submittedBy = SUBMITTED_BY
    changeType = CHANGE_TYPE
    priority = PRIORITY
    userId = Id
    downloadBtnLabel = 'DownLoad'
    @track currentUserName
    @track currentDate
    @track currentDateToSave
    @api placeHolder = 'Search Article...';
    isGlossary
    isDataDictionary
    requestTypeValue
    selectedRequestType
    //////////////////////////////////
    formglossary=false;
    formdatadic=false;
    bulkupload=false;
    isNonEditable = true
    @track isLoading = false
    @track fieldsList = []
    datadictonaryUploadMode = false;
    businessUploadMode = false;
    processButtonsMode = true;
    dictionaryDownloadMode = false;
    businessDownloadMode = false;
    ////////////////////////////////////
    @track requestTypeOptions = []
    changeRequestTypeValue
    glossaryId
    dictionaryId
    @track tableData
    @track columns
    @track downloadData
    showCustomTable = false
    showDeleteCustomTable = false
    showCheckbox = false
    selectedChangeType
    changeRequestId
    @track tableJSONData
    isSingleSelectedValue = false
    isTableVisble = false
    radioOptions = [
        { label: 'Single', value: 'Single' },
        { label: 'Bulk', value: 'Bulk' },
    ];
    self = this;
    isSubmitButtonDisable = true
    isSelectedDownloadModelOpen = false
    buttonName = 'Submit'
    priorityValue
    isPriorityVisible = false;
    isChangeRequestTypeVisible = false
    isChangeTypeVisible = false
    isChangeTypeDisabled = false
    @track dataAssertsOptions = []
    @track articleOptions = []
    @track requiredFields = []
    @track usersOptions = []
    //isSingleAdd = false
    mapOfUserIdAndName
    mapOfUserEmailAndName

    @track dataDictionaryOptions = [];
    @track activeSchemaOptions = [];

    @track aliationArticleColumns = [
        { label: 'Name', fieldName: 'Name',sortable: true}, 
        { label: 'Description', fieldName: 'Description', editable: true, sortable: true,hidden : true }, 
        { label: 'Acronynm/Synonym', fieldName: 'Acronym / Synonym' , sortable: true, editable: true,hidden : true}, 
        { label: 'Last Review Date', fieldName: 'Last Review Date', type: 'date', sortable: true, editable: true,hidden : true}, 
        { label: 'Term Type', fieldName: 'Term Type', type: 'picklist',  sortable: true ,hidden : true}, 
        { label: 'Life Cycle Status', fieldName: 'Life Cycle Status', type: 'picklist', sortable: true, editable: true,hidden : true}, 
        { label: 'Classification', fieldName: 'Classification', type: 'picklist', editable: true, sortable: true ,hidden : true},
        {label: 'Data Owners', fieldName: 'Business Owner', type: 'multiselect-picklist', sortable: true,  editable: true,hidden : true},
        {label: 'Data Stewards', fieldName: 'Steward', type: 'multiselect-picklist', sortable: true,  editable: true,hidden : true},
        {label: 'Alation Article', fieldName: 'Alation Article', type: 'multiselect-picklist',  sortable: true, hidden : true},
        {label: 'Alation Data Dictionary', fieldName: 'datadictionary',type: 'picklist', sortable: true, hidden : true},
        { label: 'Approval date', fieldName: 'Approval date', type: 'date', sortable: true, editable: true,hidden : true}, 
        { label: 'Governed Flag', fieldName: 'Governed Flag', type: 'checkbox', sortable: true, hidden : true, editable: true,hidden : true}, 
        { label: 'Subject Area', fieldName: 'Subject area', type: 'multiselect-picklist', editable: true,resizable: true, sortable: true,hidden : true}
    ]
    
    /*mapOfFieldAndPicklistValue
    @wire(getPickListValues)
    getPickListOptions({data, error}) {
        if(data) {
            console.log('getPickListOptions data:-',data)
            this.mapOfFieldAndPicklistValue = data
        }  else if(error) {
            console.log('getPickListOptions error',error)
        }
    }*/


    @wire(getMapOfUserEmailAndName)
    getUserDetailsEmail({data, error}) {
        if(data) {
            console.log('email value'+data);
            this.mapOfUserEmailAndName = data
            // Object.entries(this.mapOfUserEmailAndName).forEach(item => {
            //     console.log(item)
            //   })
            for (let key in this.mapOfUserEmailAndName) {
                let option = {
                    value: this.mapOfUserEmailAndName[key], label: this.mapOfUserEmailAndName[key]
                }
                this.usersOptions.push(option)
            }
            // this.mapOfUserEmailAndName.forEach(user => {
            //     console.log('user',user);
            //     
            // }) 
            console.log('getUserDetails Email data', data)
            console.log('getUserDetails Email data', this.usersOptions)
            console.log('getUserDetails Email data', JSON.stringify(this.usersOptions))
        }  else if(error) {
            console.log('getUserDetails error',error)
        }
    }
    
    aliationDataAssertColumns = [
        { label: 'Name', fieldName: 'name', type: 'text',  sortable: true}, 
        {label: 'Schema', fieldName: 'schema_name', type: 'picklist', sortable: true, hidden : true},
        { label: 'Full Name', fieldName: 'Full_Name', type: 'text', sortable: true, hidden : true}, 
        { label: 'Type', fieldName: 'Type', type: 'picklist', sortable: true ,hidden : true}, 
        { label: 'Description', fieldName: 'description', editable: true, type: 'text', sortable: true,hidden : true  },
        {label: 'Data Assets', fieldName: 'Data_Asset', type: 'picklist', sortable: true,hidden : true},
        { label: 'Business Process', fieldName: 'Business Process', editable: true, type: 'picklist', sortable: true ,hidden : true },
        { label: 'Business Rules', fieldName: 'Business Rules', editable: true, type: 'text',  sortable: true ,hidden : true },
        { label: 'Data Category', fieldName: 'Data Category', editable: true, type: 'picklist',  sortable: true ,hidden : true },
        { label: 'Data Consumer', fieldName: 'Data Consumer', editable: true, type: 'multiselect-picklist', sortable: true ,hidden : true },
        { label: 'Data Dictionary Field', fieldName: 'Data Dictionary', type: 'text', sortable: true,hidden : true  },
        {label: 'Data Stewards', fieldName: 'Steward', type: 'multiselect-picklist', sortable: true, editable: true,hidden : true},
        {label: 'Service Owners', fieldName: 'Business Owner', type: 'multiselect-picklist', sortable: true, editable: true,hidden : true},
        { label: 'Derived logic/Business Calculation', fieldName: 'Business Calculation', editable: true, type: 'text', sortable: true,hidden : true  },
        { label: 'Dimensions', fieldName: 'Dimensions', editable: true, type: 'text', sortable: true ,hidden : true },
        { label: 'Indication Metric', fieldName: 'Indication Metric',editable: true, type: 'picklist', sortable: true ,hidden : true}, 
        { label: 'Refresh Frequency', fieldName: 'Refresh Frequency',editable: true, type: 'picklist',  sortable: true,hidden : true }, 
        { label: 'Subject Area', fieldName: 'Subject Area', editable: true, type: 'multiselect-picklist', sortable: true ,hidden : true },
        { label: 'Tenant', fieldName: 'Tenant', editable: true, type: 'multiselect-picklist',  sortable: true,hidden : true  },
        { label: 'Value Update', fieldName: 'Value Update', editable: true, type: 'picklist', sortable: true ,hidden : true },
        { label: 'Data Retention', fieldName: 'Data Retention', editable: true, type: 'picklist', sortable: true ,hidden : true },
        //Data Rentation
    ]
   /* @wire(getMapOfUserIdAndName)
    getUserDetails({data, error}) { 
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
            console.log('getUserDetails data', data)
            console.log('getUserDetails data', this.usersOptions)
            console.log('getUserDetails data', JSON.stringify(this.usersOptions))
        }  else if(error) {
            console.log('getUserDetails error',error)
        }
    } */
    
    // @wire(getAllDataAsserts)
    // dataAssertList({error,data}){
    //     if(data){
    //         let dataAsserts = [];
    //         for(let i=0; i<data.length; i++){
    //             let obj = {value: data[i].Id, label: data[i].Name};
    //             dataAsserts.push(obj);
    //         }
    //         this.dataAssertsOptions = dataAsserts;
    //     }else{
    //         console.error(error);
    //     }       
    // }
    // @wire(getAllArticle)
    // articleList({error,data}){
    //     if(data){
    //         let articles = [];
    //         for(let i=0; i<data.length; i++){
    //             let obj = {value: data[i].Id, label: data[i].Name};
    //             articles.push(obj);
    //         }
    //         this.articleOptions = articles;
    //     }else{
    //         console.error(error);
    //     }       
    // }
    

    @wire(getAllActiveSchema)
    getWireDetails({data,error}){
        console.log('-------326---',data);
        for(var key in data){
            this.activeSchemaOptions.push({value:data[key], label:data[key]}); //Here we are creating the array to show on UI.
        }

        console.log('-------this.activeSchemaOptions---',this.activeSchemaOptions);
    }

    @wire(getAllActiveDataDictionary)
    getDetails({data, error}){
        if(data) {
            console.log('-------201---',data);

            for(var key in data){
                this.dataDictionaryOptions.push({value:key, label:data[key]}); //Here we are creating the array to show on UI.
            }

            console.log('---this.dataDictionaryOptions1---',this.dataDictionaryOptions);
        }
    }

    priorityChangeHandler(event) {
        this.priorityValue = event.target.value
        //this.changeRequestTypeValue = null
        //this.isChangeTypeVisible = false
        //this.selectedChangeType = null
        // this.showCustomTable = false
        // this.showDeleteCustomTable = false
        // this.isDataUploaded = false
        if(this.priorityValue != '') {
            this.isChangeRequestTypeVisible = true
        } else {
            this.isChangeRequestTypeVisible = false
            this.changeRequestTypeValue = null
            this.selectedChangeType = null
            this.isChangeTypeVisible = false
            this.showCustomTable = false
            this.showDeleteCustomTable = false
            this.isDataUploaded = false
        }
    }
    // @track singleAddAtributesOptions = [
    //     { label: 'Description', value: 'dcmgt_Description__c' }
    // ]
    // selectedSingleAddAtributes

    // get isRecordSelected() {
    //     return this.glossaryId || this.dictionaryId
    // }

    // get isSingleSelected() {
    //     this.isSingleSelectedValue =  ((this.changeRequestTypeValue === 'Single' && (this.selectedChangeType === 'Update' || 
    //         this.selectedChangeType === 'Delete')) || (this.changeRequestTypeValue === 'Bulk' && this.selectedChangeType === 'Delete'))
    //     console.log('isShow', this.isSingleSelectedValue)
    //     //this.isTableVisble = this.isSingleSelectedValue
    //     return this.isSingleSelectedValue && this.isTableVisble
    // }
    constructor(){
        debugger;
        super();
        console.log('**styleCSS'+styleCSS);
        loadStyle(this, styleCSS).then(result => {
            console.log('Loaded Successfully');
            // Possibly do something when load is complete.
        })
        .catch(reason => {
            // Checkout why it went wrong.
        });
    }

    get isBulkSelected() {
        this.isSingleSelectedValue =  (this.changeRequestTypeValue === 'Bulk' && (this.selectedChangeType === 'Add' || this.selectedChangeType === 'Update'))
        return this.isSingleSelectedValue
        //return true
    }

    // attributeChangeHandler(event) {
    //     this.selectedSingleAddAtributes = event.target.value
    //     this.showDeleteCustomTable = false
    //     this.isDataUploaded = false
    //     this.tableData =  this.tempTableData
    //     console.log('attributeChangeHandler')
    //     this.columns = this.tempColumns.map(element => {
    //         console.log(this.selectedSingleAddAtributes)
    //         console.log(element.fieldName)
    //         if(element.fieldName == this.selectedSingleAddAtributes) {
    //             return {...element, editable: true}
    //         } else {
    //             return {...element, editable: false}
    //         }
    //     })
    //     console.log('attributeChangeHandler 2')
    //     this.showCustomTable = true
    //     console.log('this.tableData', this.tableData)
    //     console.log('this.columns', this.columns)
    // }
    
    

    userDetails
    @wire(getRecord, {recordId:'$userId', fields:[NAME_FIELD]})
    userDetailsHandler({data, error}) {
        if(data) {
            this.currentUserName = data.fields.Name.value
            this.currentDateToSave = new Date()
            var months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
            this.currentDate = this.currentDateToSave.getFullYear()+'-'+months[this.currentDateToSave.getMonth()]+'-'+this.currentDateToSave.getDate()
            console.log(data)
        } if(error) {
            console.error(error)
        }
    }

    getTemplateDetails() {
        getTemplateFields({requestTypeId:this.requestTypeId})
        .then(data=>{
            console.log('getTemplateDetails',data);
            this.fieldsList = data.split(',')
        }).catch(error=>{
            console.error();('getTemplateDetails',error);
        })
    }

    glossaryChangeHandler(event) {
        this.glossaryId = event.target.value
        console.log('glossaryId:- ',event.target.value)
        this.isSubmitButtonDisable = true
        this.selectedChangeType = null
        this.showCustomTable = false
        this.showDeleteCustomTable = false
        this.isDataUploaded = false
        this.showCheckbox = false
        this.priorityValue = null
        this.isChangeRequestTypeVisible = false
        this.changeRequestTypeValue = null
        this.isChangeTypeVisible = false
        this.selectedChangeType = null
        if(this.glossaryId != '') {
            // this.getGlossaryArticles()
            this.isLoading = true
            this.getArticleDetailsByGlossary()
            this.isPriorityVisible = true
            console.log('this.glossaryId Len',this.glossaryId.length)
        } else {
            this.isPriorityVisible = false
        }
        
    }

    dictionaryChangeHandler(event) {
        this.dictionaryId = event.target.value
        console.log('dictionaryId:- ',event.target.value)
        this.isSubmitButtonDisable = true
        this.selectedChangeType = null
        this.showCustomTable = false
        this.showDeleteCustomTable = false
        this.showCheckbox = false
        this.isDataUploaded = false
        this.priorityValue = null
        this.isChangeRequestTypeVisible = false
        this.changeRequestTypeValue = null
        this.isChangeTypeVisible = false
        this.selectedChangeType = null
        if(this.dictionaryId != '') {
            // this.getDataAssets()
            this.isLoading = true
            this.getDataAssertDetailsByDictionary()
            this.isPriorityVisible = true
            console.log('this.dictionaryId Len',this.dictionaryId.length)
        } 
        
    }
    @track tempTableData
    @track tempColumns
    getDataAssets() {
        this.requiredFields = [
            'Name', 'Data Stewards', 'Service Owners'
        ]
        getListOfDataAssetsByDictionaryId({dictionaryId:this.dictionaryId}) 
        .then(result => {
            console.log('getListOfDataAssetsByDictionaryId',JSON.stringify(result))
            //this.tempTableData = result;
            this.tempTableData = [];
            for(let i=0; i<result.length; i++){
                let obj = {...result[i]};
                if(result[i].dcmgt_Data_Assets__c) {
                    obj.dataAssert = result[i].dcmgt_Data_Assets__r.Name;
                }
                if(result[i].dcmgt_Data_Stewards__c) {
                    let userJSON = result[i].dcmgt_Data_Stewards__c
                    userJSON = userJSON.replaceAll('&quot;', '"')
                    userJSON = JSON.parse(userJSON)
                    let map = new Map()  
                    for (let value in userJSON) {  
                        map.set(value,userJSON[value])  
                    } 
                    obj.dcmgt_Data_Stewards__c = Array.from(map.values()).join(';')
                }
                if(result[i].dcmgt_Schema__c) {
                    obj.schema = result[i].dcmgt_Schema__r.Name;
                }
                if(result[i].dcmgt_Service_Owners__c) {
                    let userJSON = result[i].dcmgt_Service_Owners__c
                    userJSON = userJSON.replaceAll('&quot;', '"')
                    userJSON = JSON.parse(userJSON)
                    let map = new Map()  
                    for (let value in userJSON) {  
                        map.set(value,userJSON[value])  
                    } 
                    obj.dcmgt_Service_Owners__c = Array.from(map.values()).join(';')
                }
                this.tempTableData.push(obj);
            }
            console.log('Data Assert data',JSON.stringify(this.tempTableData ))
            this.tempColumns = dataAssertColumns.map(column  => {
                if(column.fieldName == 'dcmgt_Service_Owners__c' || column.fieldName == 'dcmgt_Data_Stewards__c' ) {
                    return {...column, options : this.usersOptions, hidden : false  }
                } else if(this.requiredFields.includes(column.label) || this.fieldsList.includes(column.label)) {
                    return {...column, hidden : false }
                } else {
                    return {...column}
                }
            }) 
        }).catch(error => {
            console.error('getListOfDataAssetsByDictionaryId',error)
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while getting Data Asserts', 
                    message: error.body.message, 
                    variant: 'error'
                }),
            );
            this.tempTableData = null;
        })
    }
    aliationData = []

    getDataAssertDetailsByDictionary(){
        getDataAssertByDictionary({dataDictionaryId: this.dictionaryId})
        .then(result => {
            this.requiredFields = [
                'Name', 'Data Stewards', 'Service Owners'
            ]
            let tablesOptions = []
            console.log('getDataAssertByDictionary',JSON.stringify(result))
            this.tempTableData = [];
            // result = result.replaceAll("'", '"')
            let tableData = JSON.parse(result)
            console.log('aliationData', tableData)
            // console.log('aliationData', tableData[0].tables)
            tableData.forEach(element => {
                element.tables.forEach(tableData => {
                    console.log('DA element',tableData);
                    let tableObj = {...tableData}
                    tablesOptions.push({value: tableObj.name, label: tableObj.name})
                    if(tableData['schema_name']) {
                        tableObj['schema_name'] = tableData['schema_name']
                        tableObj['Full_Name'] = tableData['schema_name']
                    }
                    if(tableData['url']) {
                        tableObj['id'] = tableData['url']
                    }
                    tableObj['aliation_Id'] = tableData['id']
                    if(tableData['Steward']) {
                        let steward = tableData['Steward'].split(',')
                        let dataSteward = []
                        steward.forEach(user1 => {
                            console.log('StewardUser'+user1);
                            for (let user in this.mapOfUserEmailAndName) {
                                if(user1 == user) {
                                    dataSteward.push(this.mapOfUserEmailAndName[user]);
                                }
                                
                            }
                            // if(this.mapOfUserEmailAndName[user]) {
                            //     dataSteward.push(user)
                            // }
                        })
                        tableObj['Steward'] = dataSteward.join(';')
                    }
                    if(tableData['Business Owner']) {
                        let owner = tableData['Business Owner'].split(',')
                        let dataOwner = []
                        owner.forEach(user1 => {
                            console.log('Businessowner'+user1);
                            for (let user in this.mapOfUserEmailAndName) {
                                if(user1 == user) {
                                    dataOwner.push(this.mapOfUserEmailAndName[user]);
                                }
                                
                            }
                            // if(this.mapOfUserEmailAndName[user]) {
                            //     // dataOwner.push(`"${user}":"${this.mapOfUserEmailAndName[user]}"`)
                            //     dataOwner.push(user)
                            // }
                        })
                        tableObj['Business Owner'] = dataOwner.join(';')
                    }
                    if(tableData['Tenant']) {
                        let owner = tableData['Tenant'].split(',')
                        let dataOwner = []
                        owner.forEach(user1 => {
                            console.log('Tenant'+user1);
                            for (let user in this.mapOfUserEmailAndName) {
                                if(user1 == user) {
                                    dataOwner.push(this.mapOfUserEmailAndName[user]);
                                }
                            }
                            // if(this.mapOfUserEmailAndName[user]) {
                            //     // dataOwner.push(`"${user}":"${this.mapOfUserEmailAndName[user]}"`)
                            //     dataOwner.push(user)
                            // }
                        })
                        tableObj['Tenant'] = dataOwner.join(';')
                    }
                    if(tableData['Data Consumer']) {
                        let owner = tableData['Data Consumer'].split(',')
                        let dataOwner = []
                        owner.forEach(user1 => {
                            console.log('Data Consumer'+user1);
                            for (let user in this.mapOfUserEmailAndName) {
                                if(user1 == user) {
                                    dataOwner.push(this.mapOfUserEmailAndName[user]);
                                }
                                
                            }
                            // if(this.mapOfUserEmailAndName[user]) {
                            //     // dataOwner.push(`"${user}":"${this.mapOfUserEmailAndName[user]}"`)
                            //     dataOwner.push(user)
                            // }
                        })
                        tableObj['Data Consumer'] = dataOwner.join(';')
                    }
                    tableObj['Type'] = 'Table'
                    // tableObj['Business Owner'] = ''
                    // tableObj['Steward'] = ''

                    this.tempTableData.push(tableObj)
                    if(tableData['columns']) {
                        let columnData = JSON.parse(tableData.columns)
                        .forEach( columnData => {
                            let columnObj = {...columnData}
                            columnObj['Type'] = 'Column'
                            // columnObj['Business Owner'] = ''
                            // columnObj['Steward'] = ''
                            columnObj['Data_Asset'] = tableData['name']
                            
                            if(columnData['table_name']) { 
                                columnObj['Full_Name'] = columnData['table_name']
                            }
                            if(columnData['url']) {
                                columnObj['id'] = columnData['url']
                            }
                            columnObj['aliation_Id'] = columnData['id']
                            if(columnData['Steward']) {
                                let steward = columnData['Steward'].split(',')
                                let dataSteward = []
                                steward.forEach(user1 => {
                                    console.log('StewardUser'+user1);
                                    for (let user in this.mapOfUserEmailAndName) {
                                        if(user1 == user) {
                                            dataSteward.push(this.mapOfUserEmailAndName[user]);
                                        }
                                    }
                                    // if(this.mapOfUserEmailAndName[user]) {
                                    //     dataSteward.push(user)
                                    // }
                                })
                                columnObj['Steward'] = dataSteward.join(';')
                            }
                            if(columnData['Business Owner']) {
                                let owner = columnData['Business Owner'].split(',')
                                let dataOwner = []
                                owner.forEach(user1 => {
                                    console.log('BusinessOwner'+user1);
                                    for (let user in this.mapOfUserEmailAndName) {
                                        if(user1 == user) {
                                            dataOwner.push(this.mapOfUserEmailAndName[user]);
                                        }
                                    }
                                    // if(this.mapOfUserEmailAndName[user]) {
                                    //     // dataOwner.push(`"${user}":"${this.mapOfUserEmailAndName[user]}"`)
                                    //     dataOwner.push(user)
                                    // }
                                })
                                columnObj['Business Owner'] = dataOwner.join(';')
                            }
                            if(columnData['Data Consumer']) {
                                let owner = columnData['Data Consumer'].split(',')
                                let dataOwner = []
                                owner.forEach(user => {
                                    console.log('Data Consumer'+user);
                                    for (let user in this.mapOfUserEmailAndName) {
                                        dataOwner.push(this.mapOfUserEmailAndName[user]);
                                    }
                                    // if(this.mapOfUserEmailAndName[user]) {
                                    //     // dataOwner.push(`"${user}":"${this.mapOfUserEmailAndName[user]}"`)
                                    //     dataOwner.push(user)
                                    // }
                                })
                                columnObj['Data Consumer'] = dataOwner.join(';')
                            }
                            if(columnData['Tenant']) {
                                let owner = columnData['Tenant'].split(',')
                                let dataOwner = []
                                owner.forEach(user => {
                                    console.log('Tenant'+user);
                                    for (let user in this.mapOfUserEmailAndName) {
                                        dataOwner.push(this.mapOfUserEmailAndName[user]);
                                    }
                                    // if(this.mapOfUserEmailAndName[user]) {
                                    //     // dataOwner.push(`"${user}":"${this.mapOfUserEmailAndName[user]}"`)
                                    //     dataOwner.push(user)
                                    // }
                                })
                                columnObj['Tenant'] = dataOwner.join(';')
                            }
                            this.tempTableData.push(columnObj)
                        })
                    }
                })
            })
            console.log('DA tempTableData', this.tempTableData)
            // this.tempColumns = this.aliationDataAssertColumns
            this.tempColumns = this.aliationDataAssertColumns.map(column  => {
                if(column.fieldName == 'Steward' || column.fieldName == 'Business Owner' ) {
                    return {...column, options : this.usersOptions , hidden : false }
                } else if(column.fieldName == 'Data Consumer' ||  column.fieldName == 'Tenant') {
                    if(this.fieldsList.includes(column.label)) {
                        return {...column, hidden : false, options: this.usersOptions }
                    }else {
                        return {...column, options: this.usersOptions } 
                    }
                } else if(this.mapOfFieldAndPicklistValue[column.fieldName]) {
                    if(this.fieldsList.includes(column.label)) {
                        return {...column, hidden : false, options: this.mapOfFieldAndPicklistValue[column.fieldName] }
                    }else {
                        return {...column, options: this.mapOfFieldAndPicklistValue[column.fieldName] } 
                    }
                } else if(this.requiredFields.includes(column.label) || this.fieldsList.includes(column.label)) {
                    return {...column, hidden : false }
                } else {
                    return {...column}
                }
            }) 
            this.isLoading = false
        }).catch(error => {
            this.isLoading = false
            console.error('data Assert error', error)
        })
    }

    getArticleDetailsByGlossary() {
        getArticleByGlossary({glossaryId: this.glossaryId})
        .then(result => {
            let childArticleOpions = []
            this.requiredFields = [
                'Name', 'Data Stewards', 'Data Owners'
            ]
            console.log('getArticleByGlossary',JSON.stringify(result))
            this.tempTableData = [];
            // result = result.replaceAll("'", '"')
            let tableData = JSON.parse(result)
            console.log('aliationData', tableData)
            tableData.forEach(element => {
                let Obj = {...element}
                if(element['Last Review Date']) {
                   
                    Obj['Last Review Date'] = element['Last Review Date'].replaceAll('/', '-')
                    console.log('Obj[Last Review Date]', Obj['Last Review Date']);
                }
                if(element['Approval date']) {
                    Obj['Approval date'] = element['Approval date'].replaceAll('/', '-')
                } 
                // if(element['Steward']) {
                //     Obj['Steward'] = this.mapOfUserEmailAndName[element['Steward']]
                // } 
                childArticleOpions.push({value: element.Name, label: element.Name})
                if(element['Steward']) {
                    let steward = element['Steward'].split(',')
                    let dataSteward = []
                    steward.forEach(user1 => {
                        for (let user in this.mapOfUserEmailAndName) {
                            if(user1 == user)
                            dataSteward.push(this.mapOfUserEmailAndName[user]);
                        }
                        // if(this.mapOfUserEmailAndName[user]) {
                        //     // dataSteward.push(`"${user}":"${this.mapOfUserEmailAndName[user]}"`)
                        //     dataSteward.push(user)
                        // }
                    })
                    Obj['Steward'] = dataSteward.join(';')
                }
                if(element['Business Owner']) {
                    let owner = element['Business Owner'].split(',')
                    let dataOwner = []
                    owner.forEach(user1 => {
                        for (let user in this.mapOfUserEmailAndName) {
                            if(user1 == user)
                            dataOwner.push(this.mapOfUserEmailAndName[user]);
                        }
                        // if(this.mapOfUserEmailAndName[user]) {
                        //     // dataOwner.push(`"${user}":"${this.mapOfUserEmailAndName[user]}"`)
                        //     dataOwner.push(user)
                        // }
                    })
                    Obj['Business Owner'] = dataOwner.join(';')
                }
                if(element['children']) {
                    let children = JSON.parse(element['children'])
                    console.log('children', children);
                    if(children.length > 0) {
                        let value = []
                        children.forEach(child => {
                            // console.log(child.title);
                            childArticleOpions.push({value: child.title, label: child.title})
                            value.push(child.title)
                        })
                        console.log('c title', children[0].title)
                        Obj['Alation Article'] = value.join(';')
                    } else {
                        Obj['Alation Article'] = null
                    }
                    console.log('children', Obj['Alation Article'])
                }
                if(element['datadictionary']) {
                    Obj['datadictionary'] = element['datadictionary'].name
                }
                console.log('Obj122', Obj);
                //this.aliationData.push(Obj)
                this.tempTableData.push(Obj)
            })
            this.tempColumns = this.aliationArticleColumns.map(user  => {
                if(user.fieldName == 'Steward' || user.fieldName == 'Business Owner' ) {
                    return {...user, options : this.usersOptions , hidden : false }
                } else if(this.mapOfFieldAndPicklistValue[user.fieldName]) {
                    if(this.fieldsList.includes(user.label)) {
                        return {...user, hidden : false, options: this.mapOfFieldAndPicklistValue[user.fieldName] }
                    }else {
                        return {...user, options: this.mapOfFieldAndPicklistValue[user.fieldName] } 
                    }
                } else if(user.label == 'Alation Data Dictionary' ){
                    if(this.fieldsList.includes(user.label)) {
                        return {...user, hidden : false, options: this.dataDictionaryOptions }
                    }else {
                        return {...user, options: this.dataDictionaryOptions }
                    }
                }
                else if(this.requiredFields.includes(user.label) || this.fieldsList.includes(user.label)) {
                    return {...user, hidden : false }
                } else {
                    return {...user}
                }
            }) 
            // this.tempColumns = this.aliationArticleColumns
            console.log('this.tempColumns',this.tempColumns)
            this.isLoading = false
            // this.glossaryAliationId = result.dcmgt_Alation_ID__c
            // this.glossaryName = result.Name
        }).catch(error => {
            this.isLoading = false
            console.error('getGlossaryDetails error', error)
        })
    }

    getGlossaryArticles() {
        this.requiredFields = [
            'Name', 'Data Stewards', 'Data Owners'
        ]
        getAlationArticleDataByGlossaryId({glossaryId:this.glossaryId})
        .then(result => {
           // this.tempTableData = result;
            this.tempTableData = [];
            for(let i=0; i<result.length; i++){
                let obj = {...result[i]};
                if(result[i].dcmgt_Data_Owners__c) {
                    console.log(result[i].dcmgt_DataStewards__c)
                    let userJSON = result[i].dcmgt_DataStewards__c
                    userJSON = userJSON.replaceAll('&quot;', '"')
                    userJSON = JSON.parse(userJSON)
                    let map = new Map()  
                    for (let value in userJSON) {  
                        map.set(value,userJSON[value])  
                    } 
                    obj.dcmgt_Data_Owners__c = Array.from(map.values()).join(';')
                }
                if(result[i].dcmgt_DataStewards__c) {
                    console.log(result[i].dcmgt_DataStewards__c)
                    let userJSON = result[i].dcmgt_DataStewards__c
                    userJSON = userJSON.replaceAll('&quot;', '"')
                    userJSON = JSON.parse(userJSON)
                    let map = new Map()  
                    for (let value in userJSON) {  
                        map.set(value,userJSON[value])  
                    } 
                    obj.dcmgt_DataStewards__c = Array.from(map.values()).join(';')
                }
                if(result[i].dcmgt_Alation_Article__c) {
                    obj.parentArticle = result[i].dcmgt_Alation_Article__r.Name;
                }
                if(result[i].dcmgt_Alation_Data_Dictionary__c) {
                    obj.dataDictionary = result[i].dcmgt_Alation_Data_Dictionary__r.Name;
                }
                this.tempTableData.push(obj);
            }
            console.log('getGlossaryArticles data',JSON.stringify(this.tempTableData ))
            console.log('this.requiredFields',this.requiredFields)
            console.log('this.fieldsList',this.fieldsList)
            this.tempColumns = articleColumns.map(column  => {
                console.log('column.fieldName',column.fieldName)
                if(column.fieldName == 'dcmgt_Data_Owners__c' || column.fieldName == 'dcmgt_DataStewards__c' ) {
                    return {...column, options : this.usersOptions,hidden : false  }
                } else if(this.requiredFields.includes(column.label) || this.fieldsList.includes(column.label)) {
                    console.log('hidden : false')
                    return {...column, hidden : false }
                }
                // else if(column.fieldName == 'dcmgt_Alation_Article__c') {
                //     return {...column, options : this.articleOptions }
                // } else if(column.fieldName == 'dcmgt_Alation_Data_Dictionary__c') {
                //     return {...column, options : this.dataAssertsOptions }
                // } 
                else {
                    return {...column}
                }
            }) 
            // this.tempColumns = articleColumns
        })
        .catch(error => {
            console.error('getGlossaryArticles error',error)
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while getting Articles', 
                    message: error.message, 
                    variant: 'error'
                }),
            );
            console.log(error)
            this.tempTableData = null;
        });
    }

    get isStdDataTable() {
        return this.showCustomTable && this.showCheckbox 
    }
    rowOffset = 0
    changeTypeHandler(event) {
        console.log(event.target.value)
        this.changeRequestTypeValue = event.target.value
        //this.selectedChangeType = null
        this.showCustomTable = false
        this.showDeleteCustomTable = false
        this.showCheckbox = false
        this.isDataUploaded = false
        this.isChangeTypeVisible = true
        if(this.changeRequestTypeValue === 'Single') {
            this.isChangeTypeDisabled = true
            this.selectedChangeType = 'Update'
            this.tableData =  this.tempTableData
            this.columns = this.tempColumns
            this.showCustomTable = true
        } else {
            this.isChangeTypeDisabled = false
            this.selectedChangeType = null
        }
        //this.isSingleAdd = false
        // this.selectedSingleAddAtributes = null
        // if(this.selectedRequestType === 'Data Dictionary') {
        //     this.getDataAssets()
            
        // } else if(this.selectedRequestType === 'Business glossary') {
        //     this.getGlossaryArticles()
        // }
        // if(this.selectedChangeType === 'Update' ||
        //     this.selectedChangeType === 'Delete') {

        //     this.tableData =  this.tempTableData
        //     this.columns = this.tempColumns
        // }
        // if(this.selectedChangeType === 'Delete') {
        //     this.columns = this.columns.map(function(element){
        //             return {...element, editable: false}
        //         })
        // }
        
    }

    isRecodEditModelOpen = false;
    isDictionaryRecodEditModelOpen = false;
    modelMessageforRecordEdit = '';
    modelMessageforDictionaryRecordEdit = '';
    opperationChangeHandler(event) {
        this.buttonName = 'Submit'
        this.showCustomTable = false
        this.showDeleteCustomTable = false
        this.showCheckbox = false
        this.isDataUploaded = false
        console.log('change type change:', event.detail.value+':')
        this.isRecodEditModelOpen = false;
        this.isDictionaryRecodEditModelOpen = false;
        this.isTableVisble = false
        this.selectedChangeType = event.detail.value
        console.log('change type change1:', this.selectedChangeType+':')
        this.isSubmitButtonDisable = true
        //this.isSingleAdd = false
        // this.selectedSingleAddAtributes = null
        
        if(this.selectedChangeType === 'Update' || this.selectedChangeType === 'Delete') {
            // if(this.selectedRequestType === 'Data Dictionary') {
            //     this.getDataAssets()
                
            // } else if(this.selectedRequestType === 'Business glossary') {
            //     this.getGlossaryArticles()
            // }
            
            this.tableData =  this.tempTableData
            this.downloadData = this.tempTableData
            console.log('Table Data',JSON.stringify(this.tableData))
            
        }
        if(this.changeRequestTypeValue === 'Single' && this.selectedChangeType === 'Update' ) {
            this.columns = this.tempColumns
            this.showCustomTable = true
        } else if(this.selectedChangeType === 'Delete' 
            // || (this.changeRequestTypeValue === 'Bulk' && this.selectedChangeType === 'Update')
            ) {
            this.columns = this.tempColumns.map(function(element){
                return {...element, editable: false}
            })
            this.showDeleteCustomTable = true
            this.showCheckbox = true
        } else if(this.changeRequestTypeValue === 'Bulk' && this.selectedChangeType === 'Update') {
            this.columns = this.tempColumns
            this.showCustomTable = true
            this.showCheckbox = true
        }
        // else if(this.changeRequestTypeValue === 'Single' && this.selectedChangeType === 'Add' ) {
        //     this.isSingleAdd = true
        // }
        if(this.selectedChangeType === 'Update') {
            this.downloadBtnLabel = 'DownLoad All'
            if(this.changeRequestTypeValue === 'Bulk') {
                this.buttonName = 'DownLoad'
            }
            
        } else if(this.selectedChangeType === 'Add') {
            this.downloadBtnLabel = 'DownLoad'
            
        }
        
        
        // if(this.selectedChangeType === 'Delete') {
        //     this.isNonEditable = true
           
        // } else if(this.selectedChangeType === 'Update') {
        //     this.isNonEditable = false
        //     console.log('Update opp', this.selectedChangeType)
          
        // }
        // this.isTableVisble = true
        // if(this.selectedChangeType === 'Update' ||
        // this.selectedChangeType === 'Delete') {


        //     this.tableData =  this.tempTableData
        //     this.columns = this.tempColumns
        // }
        // if(this.selectedChangeType === 'Delete') {
        //     this.columns = this.columns.map(function(element){
        //             return {...element, editable: false}
        //         })
        // }
//         if(this.changeRequestTypeValue === 'Single' && this.selectedChangeType === 'Add' && this.selectedRequestType === "Business glossary") {
//             this.isRecodEditModelOpen = true;
//             this.modelMessageforRecordEdit =   `Record Edit for ${this.selectedRequestType}`
        
//        }
//        if(this.changeRequestTypeValue === 'Single' && this.selectedChangeType === 'Add' && this.selectedRequestType === "Data Dictionary") {
//         this.isDictionaryRecodEditModelOpen = true;
//         this.modelMessageforDictionaryRecordEdit =   `Record Edit for ${this.selectedRequestType}`
    
//    }
    }
    datechange(event) {
        console.log(event.target.value)
        console.log(JSON.stringify(event.target))
    }
    handleSuccess(event) {
        this.changeRequestId = event.detail.id;
        console.log(this.changeRequestId)
        if(this.changeRequestId) {
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: "SUCCESS!",
            //         message: "New record has been created.",
            //         variant: 'success',
            //     }),
            // );
          
            this.saveStageData()
            console.log('this.changeRequestId',this.changeRequestId)
            
            console.log('this.changeRequestId22',this.changeRequestId)
            //objectApiName: 'dcmgt_Change_Request__c',
            //eval("$A.get('e.force:refreshView').fire();");
            
        }
        // if(changeRequestId){
        //     
        //     this.saveStageData()
        // }
    }

    preventDefaults(event) {
        event.preventDefault(); 
        this.fields = event.detail.fields;
        //console.log('prevent default', JSON.stringify(this.fields))
        // this.fields = event.detail.fields;
        // let resultData = this.template.querySelector('lightning-record-edit-form').submit(this.fields);
        // console.log('resultData', resultData)
        // event.preventDefault(); 
        
    }

    saveClick() {
        console.log('saveClick')
        console.log('saveClick',this.fields)
        let result = this.template.querySelector('lightning-record-edit-form').submit(this.fields);
        console.log('saveClicke',result)
    }
    
    saveAndNewClick() {
        if(!this.error){
        console.log('saveAndNewClick')
        let result = this.template.querySelector('lightning-record-edit-form').submit(this.fields);
        console.log('saveClick')
        //saveClick();
        //handleReset();
        }
    }
    
    handleReset(event) {
        eval("$A.get('e.force:refreshView').fire();")
    //     console.log('handleReset')
    //    const inputFields = this.template.querySelectorAll(
    //        '.resetField'
    //    );
    //    if (inputFields) {
    //        inputFields.forEach(field => {
    //         console.log(JSON.stringify(field))
    //            field.reset();
    //        });
    //    }
    //    this.isGlossary = false;
    //     this.isDataDictionary = false;
    //     this.changeRequestTypeValue = ''
        
    }
    cancelClickHandler() {
        const fields = this.template.querySelectorAll(
            'lightning-input-field'
        )
        fields.forEach(field =>{
            console.log('field',field)
            field.reset();
        });
        

    }

    submitHandler(event) {
        //console.log(events.detail.fields)
        console.log(JSON.stringify(event.detail.fields))
        
        console.log('resultData', resultData)
        this.cancelClickHandler()
    }

    selectedModelMessageforDownload
    tableSaveHandler(event) {
        // if(this.changeRequestTypeValue === 'Bulk' && this.selectedChangeType === 'Update') {
        //     this.downloadData = event.detail
        //     this.isSelectedDownloadModelOpen = true
        //     this.selectedModelMessageforDownload = `Download selected records for ${this.selectedRequestType}`
        // } else {
            this.tableJSONData = event.detail
            //this.isSubmitButtonDisable = false
            console.log('tableSaveHandler:-',JSON.stringify(this.tableJSONData))
            // this.saveAndNewClick()
            let isRequiredFieldsMissing = this.tableJSONData.some(data => {
                console.log("required fieldss ownersss:"+ data['Business Owner'] + '  data stewarddd '+ data['Steward']  )
                console.log("required fieldss ownersss 2  :"+ data['Business Owner'] + '  data stewarddd 22'+ data['Steward']  )
                 console.log("govered falg: "+ data['Governed Flag']);
                if((this.isDataDictionary &&
                    (! data['Business Owner'] 
                    || !data['Steward'])) ||
                    (this.isGlossary &&
                    (!data['Steward'] 
                    || !data['Business Owner']))) {

                    return true
                } 
                return false
            })
            console.log('isRequiredFieldsMissing',isRequiredFieldsMissing);
            if(isRequiredFieldsMissing) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "ERROR!",
                        message: "Data Owner and Data Steward are required fields",
                        variant: 'error',
                    }),
                );
            } else {
                this.saveAndNewClick()
            }   
        
    }

    saveStageData() {
        this.isLoading = true
        console.log('saveStageData')
        console.log('saveStageData', this.changeRequestId)
        console.log('saveStageData', JSON.stringify(this.tableJSONData))
        console.log('saveStageData', this.selectedChangeType)
        storeStageData({changeRequestId: this.changeRequestId, 
            tableData: JSON.stringify(this.tableJSONData),
            requestType: this.selectedRequestType,
            operation:this.selectedChangeType})
        .then(data => {
            console.log('saveStageData data', data)
                this[NavigationMixin.Navigate]({	
                    type: 'standard__recordPage',	
                    attributes: {	
                        recordId: this.changeRequestId,	
                        actionName: 'view'	
                    }	
                });	
            this.isLoading = false
            
            //eval("$A.get('e.force:refreshView').fire();");
            //window.open(`/${this.changeRequestId}`, "_self")
            // self[NavigationMixin.Navigate]({
            //     type: 'standard__recordPage',
            //     attributes: {
            //         recordId: 'a045g000002ze3dAAA',
            //         actionName: 'view'
            //     },
            // });
        }).catch(error => {
            this.isLoading = false
            let isDuplicateRecord = false
            let objetcType = 'Data Assets'
            if(this.selectedRequestType.toLowerCase() === 'data dictionary') {
                objetcType = 'Data Assets'
                isDuplicateRecord = error.body.message.indexOf('Duplicate DataAsset request') > -1 ? true : false
            } else if(this.selectedRequestType.toLowerCase() === 'business glossary') {
                objetcType = 'Alation Article'
                isDuplicateRecord = error.body.message.indexOf('Duplicate Article request') > -1 ? true : false
            }
            console.log('isDuplicateRecord', isDuplicateRecord)
            if(isDuplicateRecord){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: `Error`,
                        message: `Change request can't be raised as there are ongoing change request for ${objetcType}`,
                        variant: 'error',
                    }),
                );
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: `Error`,
                        message: `Error while updating ${objetcType}`,
                        variant: 'error',
                    }),
                );
            }
            
            console.log('saveStageData error', error.body.message)
        })
    }

    get isUploadVisible() {
        return !this.isSingleSelectedValue && (this.isGlossary || this.isDataDictionary)
    }

    get isDownloadVisible() {
        return !this.isSingleSelectedValue && (this.isGlossary || this.isDataDictionary)
    }

    @track isUploadModelOpen =  false
    @track requiredFieldsForDownload
    modelMessageforUpload
    handleClick(e){
        this.isUploadModelOpen = true
        this.requiredFieldsForDownload =  [...this.fieldsList]
        this.requiredFields.forEach(data => {
            if(!this.requiredFieldsForDownload.includes(data)) {
                this.requiredFieldsForDownload.push(data)
            }
        }) 
        this.modelMessageforUpload =   `Upload ${this.selectedRequestType} Template`
    }
     
    isDownloadModelOpen =  false
    modelMessageforDownload
    handleDownloadClick(e){
        this.isDownloadModelOpen = true
        this.requiredFieldsForDownload = [...this.fieldsList]
        this.requiredFields.forEach(data => {
            if(!this.requiredFieldsForDownload.includes(data)) {
                this.requiredFieldsForDownload.push(data)
            }
        })
        this.modelMessageforDownload =   `Download ${this.selectedRequestType} Template`
    }

    closeHandler(event) {
        console.log('closeHandler')
        
        this.isDownloadModelOpen =  false
        this.isSelectedDownloadModelOpen = false
    }
    isDataUploaded
    closeUploadHandler(event) {
        this.isUploadModelOpen =  false
        this.isLoading = true
        let message = event.detail.message
        console.log('closeUploadHandler')
        if(message === 'Success') {
            this.handleUpdate(event.detail.fileContents, 
                event.detail.fileColumnsName, event.detail.mapOfFieldNameAndAPIName)
            
            this.isDataUploaded = true
            
            this.isSubmitButtonDisable = false
            
            this.isSubmitButtonDisable = false
            this.showCustomTable = false
            this.showDeleteCustomTable = false
            this.showCheckbox = false
        }
        console.log('closeUploadHandler2')
        this.isLoading = false
    }

    splitCSVButIgnoreCommasInDoublequotes(str) {  	
        //split the str first  	
        //then merge the elments between two double quotes  	
        var delimiter = ',';  	
        var quotes = '"';  	
        var elements = str.split(delimiter);  	
        var newElements = [];  	
        for (var i = 0; i < elements.length; ++i) {  	
            if (elements[i].indexOf(quotes) >= 0) {//the left double quotes is found  	
                var indexOfRightQuotes = -1;  	
                var tmp = elements[i];  	
                //find the right double quotes  	
                for (var j = i + 1; j < elements.length; ++j) {  	
                    if (elements[j].indexOf(quotes) >= 0) {  	
                        indexOfRightQuotes = j; 	
                        break;	
                    }  	
                }  	
                //found the right double quotes  	
                //merge all the elements between double quotes  	
                if (-1 != indexOfRightQuotes) {   	
                    for (var j = i + 1; j <= indexOfRightQuotes; ++j) {  	
                        tmp = tmp + delimiter + elements[j];  	
                    }  	
                    newElements.push(tmp);  	
                    i = indexOfRightQuotes;  	
                }  	
                else { //right double quotes is not found  	
                    newElements.push(elements[i]);  	
                }  	
            }  	
            else {//no left double quotes is found  	
                newElements.push(elements[i]);  	
            }  	
        }  	
    	
        return newElements;  	
    }

    handleUpdate(fileContents, fileColumnsName, mapOfFieldNameAndAPIName) {
        console.log('handleUpdate')
        //this.isLoading = true
        let uploadFileColumns = [];
        let uploadFileData = [];
        console.log('getDataByCSV')
        let fileRow = fileContents.split(/\r?\n/);
        let fileCoumnData =  fileColumnsName;
        for(let row = 0; row < fileRow.length ; row ++ ){
            let fileData = this.splitCSVButIgnoreCommasInDoublequotes(fileRow[row]);
            console.log('len:-'+fileData.length)
            if(fileData.length === 1) {
                console.log('fileData.length === 0')
                continue
            }
            let rowData = {};
            for(let column = 0; column < fileData.length; column ++ ){
                let typeOfColumn = 'text'
                if(row === 0){
                    let columnName = fileData[column].trim()
                    uploadFileColumns.push({
                        label:columnName, fieldName:mapOfFieldNameAndAPIName[columnName], type: typeOfColumn,  sortable: true 
                    });
                } else {
                    let rowDataValue = fileData[column]
                    rowDataValue = rowDataValue.replaceAll('"', '')
                    let columnName = fileColumnsName[column]
                    if(columnName && (columnName.indexOf("_Date") > 0 || columnName.indexOf("_date") > 0 )) {
                        let dateValue  = rowDataValue.split('-') 
                        if(dateValue.length >= 3) {
                            rowDataValue = `${dateValue[2]}-${dateValue[1]}-${dateValue[0]}`
                            console.log('rowDataValue', rowDataValue)
                        }
                        console.log('dateValue', dateValue)
                    }
                    rowData[mapOfFieldNameAndAPIName[columnName]]= rowDataValue;
                }
            }
            if(row != 0){
                uploadFileData.push(rowData);
            }
        }
        console.log('uploadFileColumns', JSON.stringify(uploadFileColumns));
        console.log('uploadFileData', JSON.stringify(uploadFileData));
        this.tableData = uploadFileData
        this.columns = uploadFileColumns
        this.tableJSONData = uploadFileData
        //this.isLoading = false
    }

    closeRecordEditHandler(event) {
        this.isRecodEditModelOpen =  false
        //let message = event.detail.message
        console.log('closeRecordEditHandler')
       
        console.log('closeRecordEditHandler2')
    }
    closeDictionaryRecordEditHandler(event) {
        this.isDictionaryRecodEditModelOpen =  false
        console.log('closeDictionaryRecordEditHandler')
       
        console.log('closeDictionaryRecordEditHandler2')
    }

    requestHandling(e){


        console.log("newData:"+ e.target.value)
         
        if(e.target.value.toLowerCase() === "business glossary"){ //glosarry
            console.log("newData2:"+ e.target.value)
           // var glossary= document.getElementById("glossary")
            var dictionary= document.querySelector(".dictionary")
            dictionary.classList.add(' newclass')
            console.log('done');
           
            
            // console.log("Requestname:"+e.target.value)
             formglossary =true;
             formdatadic=false;
        }
        
    
    
         else if(e.target.value.toLowerCase() === "data dictionary"){ //dictionary
            console.log("Requestname1:"+e.target.value)
             formdatadic=true;
            
            formglossary =false;
    
    
        }
    }

    cancelClickHandler() {
        const fields = this.template.querySelectorAll(
            'lightning-input-field'
        )
        fields.forEach(field =>{
            field.reset();
        });
    }

    submitHandler(event) {
        //console.log(events.detail.fields)
        console.log(JSON.stringify(event.detail.fields))
        
        console.log('resultData', resultData)
        this.cancelClickHandler()
    }

    requestTypeId
    handleRequestTypeChange(event) {
        this.isSubmitButtonDisable = true
        this.selectedChangeType = null
        this.showCustomTable = false
        this.showDeleteCustomTable = false
        this.showCheckbox = false
        this.isGlossary = false
        this.isDataDictionary = false
        this.isDataUploaded = false
        this.glossaryId = null
        this.dictionaryId = null
        let recordId = event.target.value;
        this.requestTypeId = recordId
        this.isSubmitButtonDisable = true
        this.isPriorityVisible = false
        this.isChangeRequestTypeVisible = false
        this.changeRequestTypeValue = null
        this.isChangeTypeVisible = false
        if(recordId){
            getRequestName({requestTypeId: recordId})
            .then(data => {
                console.log(data)
                this.selectedRequestType = data;
                if(data.toLowerCase() === 'data dictionary') {
                    this.isDataDictionary = true
                    this.isGlossary = false
                } else if(data.toLowerCase() === 'business glossary') {
                    this.isGlossary = true
                    this.isDataDictionary = false
                }
            }).catch(error => {
                console.error(error)
            })
            this.getTemplateDetails()
        } else {
            this.changeRequestTypeValue =''
        }
    }


    @api recordId; 
    @track error;
    @api businessRecordId;
    @track businessError;
    @track businessColumns = dataAssertColumns;
    @track businessData;

    errorCallback(error, stack) {
        console.log('errorCallback error', JSON.stringify(error))
        console.log('errorCallback stack', stack)
    }
}