import { LightningElement, api, track,wire } from 'lwc';
import getCsvTemplateData from '@salesforce/apex/dcmgt_csvtemplate.getCsvTemplateData';

export default class Csvdowlonad extends LightningElement {   
    @api displayMessage;
    @api isModalOpen 
    @api selectedRequestType; 
    @api recordId;
    @track getCsvTemplateData;  
    @api csvData;
    businessData;
    dictionaryTableData;
    @track updatedCSVData = [];
    @wire(getCsvTemplateData, { recordId: '$recordId' }) traceData
    ({ error, data }) {
    if (data) {
      console.log("apex csv datasssssssssssssssssss:"+data);
      data.map((name) =>{
          console.log("sf request name:"+name.dcmgt_Request_Type__r.Name);
          this.selectedRequestType=name.dcmgt_Request_Type__r.Name;
      })
      this.error = undefined;
     // this.callback();
    } else if (error) {
      this.error = error;
    }
}
 submitDetails() {
     console.log("close evnetttt:");
   this.isModalOpen = false;       
}
exportCSVFile(){
    console.log("export csvvvvv");
    this.isModalOpen = true;
    if(this.selectedRequestType  === 'Data Dictionary' ) {
        this.displayMessage = 'Download Data Assets Template';
    }   else if(this.selectedRequestType === 'Business Glossary') {
        this.displayMessage = 'Download Articles Template';
    }
}
downloadCSVFile() {
    console.log('csvData:-',JSON.stringify(this.csvData))
    let rowEnd = '\n';
    let csvString = '';

   let downloadElement = document.createElement('a');     
    let rowData = new Set();
    this.updatedCSVData.forEach(function (record) {
        Object.keys(record).forEach(function (key) {
            rowData.add(key);
        });
    });

    rowData = Array.from(rowData);    
    // splitting using ','
   // csvString += rowData.join(',');
    csvString += rowEnd;

    // main for loop to get the data based on key value
    

    if(this.selectedRequestType  === 'Data Dictionary' ) {
        //csvString =  'Name,Full name,Type,Description,Data Assets,Business Process,Business Rules,Data Category,Data Consumer,Data Dictionary Field,Data Steward,Derived logic/Business Calculation,Dimensions,Indication Metric,Refresh Frequency,Schema,Service Owner,Subject Area,Tenant,Value Update';
        csvString = 'Name\nSchema\nFull Name\nType\nDescription\nData Assets\nBusiness Process\nBusiness Rules\nData Category\nData Consumer\nData Dictionary Field\nData Steward\nDerived logic/Business Calculation\nDimensions\nIndication Metric\nRefresh Frequency\nData Owner\nSubject Area\nTenant\nValue Update'
        downloadElement.download = 'data Dictionary.csv';
    } else if(this.selectedRequestType === 'Business Glossary') {
        //csvString = 'Name,Description,Acronynm/Synonym,Last Review Date,Term Type,Life Cycle Status,Subject Area,Classification,Data Owner,Data Steward,Alation Article,Alation Data Dictionary,Approval date,Governed Flag'
        //csvString = 'Name\nDescription\nAcronynm/Synonym\nTerm Type\nLife Cycle Status\nSubject Area\nClassification\nData Owners\nData Stewards\nAlation Article\nAlation Data Dictionary\nGoverned Flag'
        csvString = 'Business Term Name\nBusiness Term Definition\nAcronym/Synonym\nTerm Type\nLifecycle Status\nData Subject Area\nData Classification\nData Owner\nData Steward\nAlation Article\nChildren/Data Dictionary Reference\nGoverned Flag\nApproved On\nLast Review Date'
        downloadElement.download = 'Business Glossary.csv';
    }
    // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
    downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
    downloadElement.target = '_self';
    // CSV File Name
    //downloadElement.download = 'glossary Data.csv';
    // below statement is required if you are using firefox browser
    document.body.appendChild(downloadElement);
    console.log("finalCSVdata:::::::"+this.updatedCSVData)

    // click() Javascript function to download CSV file
    downloadElement.click();
    this.submitDetails()

}
}