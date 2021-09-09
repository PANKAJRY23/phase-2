import { LightningElement, api, track,wire } from 'lwc';
import getCsvTemplateData from '@salesforce/apex/dcmgt_csvtemplate.getCsvTemplateData'
import updateCsvTemplateData from '@salesforce/apex/dcmgt_CsvTemplateForUpload.updateCsvTemplateData'
import getFieldMap from '@salesforce/apex/dcmgt_changeRequestFormController.getMapOfFieldNameWithAPIName'

export default class Csvupload extends LightningElement {
    @api isModalOpen
    @api displayMessage
    @api requestType
    @api recordId;
    fileName
    @track requestType
    @track fileContents
    @track filesUploaded = [];
    @track file
    fileReader
    fileColumnsName
    @track columns = [];
    @track data = [];
    isShowTable = false
    objectAPIName
    @track mapOfFieldNameAndAPIName
    isUploadDisable = true
    @track isLoading = false
    fileContentErrors = [];
    errormessage = [];
    @wire(getCsvTemplateData, { recordId: '$recordId' }) traceData
    ({ error, data }) {
    if (data) {
      console.log("apex csv datasssssssssssssssssss:"+data);
      data.map((name) =>{
          console.log("sf request name:"+name.dcmgt_Request_Type__r.Name);
          this.requestType=name.dcmgt_Request_Type__r.Name;
      })
      this.error = undefined;
    } else if (error) {
      this.error = error;
    }
}    
   

    submitDetails() {
         console.log('submitDetails')
       this.isModalOpen = false;
    }
    

    handleFilesChange(event) {
        this.isLoading = true
        this.fileName = '';
        this.filesUploaded = null;
        this.fileContents = null;
        console.log(event.target.files)
        if(event.target.files.length > 0) {
            console.log('>>'+event.target.files[0].name+' '+event.target.files[0].type);
            this.fileName = event.target.files[0].name;
            if(this.fileName.endsWith('.csv')) {
                this.isUploadDisable = false
                this.filesUploaded = event.target.files;
                this.fileName = this.fileName;
                this.uploadHelper()               

            } else {
                this.isUploadDisable = true
                this.fileName = 'Please select a CSV file to upload!!';
            }
        }
        console.log('fileName',this.fileName)
        console.log('filesUploaded',this.filesUploaded)
        console.log('fileContents',this.fileContents)
        this.isLoading = false
       
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
        console.log('filesUploaded', this.filesUploaded);
      
        this.fileReader= new FileReader();
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            console.log('fileContents type',typeof this.fileContents);
            console.log('fileContents',this.fileContents);
            console.log('fileContents length',this.fileContents.length);
            this.fileColumnsName = this.fileContents.split(/\r?\n/);
            this.fileColumnsName = this.fileColumnsName.join(',');
            console.log('1: '+this.fileColumnsName);
            // this.fileColumnsName = this.fileColumnsName.split(',');
            console.log('2: '+this.fileColumnsName);
            console.log('uploadData.fileContents',JSON.stringify(this.fileContents))
            });
        console.log('fileReader.readAsText1')
        this.fileReader.readAsText(this.file);
        console.log('fileReader.readAsText2')
        console.log('file', this.file)
        console.log('fileReader', this.fileReader)
        console.log('fileContents', this.fileContents)
        console.log('fileColumnsName', this.fileColumnsName)
        this.isLoading = false
        
    }
 

    handleUpdate() {
      this.isModalOpen = false;
      console.log("passing values: record ID :"+this.recordId + "   fieldname xxxxxxxxxxxxx : "+ this.fileColumnsName);
    //   updateCsvTemplateData(this.recordId,this.fileColumnsName);
        this.updateData()
    }

    updateData(){
        console.log('updateData method1', JSON.stringify(this.fileColumnsName));
        updateCsvTemplateData({recordId:this.recordId, fieldNames : this.fileColumnsName}) 
        .then(data => {
            console.log('data',JSON.stringify(data));
          window.open(`/${this.recordId}`, "_self");
        }).catch(error => {
            console.error(error);
        })
    }

    importCSVFile(){
        console.log("import csvvvvv");
        this.isModalOpen = true;
        if(this.requestType  === 'Data Dictionary' ) {
            this.displayMessage = 'Upload Data Assets Template';
        }   else if(this.requestType === 'Business Glossary') {
            this.displayMessage = 'Upload Articles Template';
        }
    }   
}