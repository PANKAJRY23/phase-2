import { LightningElement, api, track } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

export default class dcmgt_DownloadPopup extends LightningElement {
    @api isModalOpen
    @api displayMessage
    @api changeRequestType //add,delete,update
    @api selectedRequestType
    @api changeType
    @api csvData
    businessData
    @api glossaryId
    @api dictionaryId;
    @api requiredFields
    @api columns
    csvHeader = ''
    dictionaryTableData
    @track updatedCSVData = []
    submitDetails() {
        this.dispatchEvent(new CustomEvent('close'))
        
    }

    createCSVDataForDataAssert() {
        this.csvData.forEach(element => {
                let rowData = {}
                if(this.requiredFields.includes('Name')) {
                    rowData['Name'] = element['name']
                }
                if(this.requiredFields.includes('Schema')) {
                    rowData['Schema'] = element['schema_name']
                }
                if(this.requiredFields.includes('Full Name')) {
                    rowData['Full Name'] = element['Full_Name']
                }
                if(this.requiredFields.includes('Type')) {
                    rowData['Type'] = element['Type']
                }
                if(this.requiredFields.includes('Description')) {
                    rowData['Description'] = element['description']
                }
                if(this.requiredFields.includes('Data Assets')) {
                    rowData['Data Assets'] = element['Data_Asset']
                }
                if(this.requiredFields.includes('Business Process')) {
                    rowData['Business Process'] = element['Business Process']
                }
                if(this.requiredFields.includes('Business Rules')) {
                    rowData['Business Rules'] = element['Business Rules']
                }
                if(this.requiredFields.includes('Data Category')) {
                    rowData['Data Category'] = element['Data Category']
                }
                if(this.requiredFields.includes('Data Classification')) {
                    rowData['Data Classification'] = element['Data Classification']
                }
                if(this.requiredFields.includes('Data Consumer')) {
                    rowData['Data Consumer'] = element['Data Consumer']
                }
                if(this.requiredFields.includes('Data Dictionary Field')) {
                    rowData['Data Dictionary Field'] = element['Data Dictionary']
                }
                if(this.requiredFields.includes('Data Steward')) {
                    rowData['Data Steward'] = element['Steward']
                }
                if(this.requiredFields.includes('Data Owner')) {
                    rowData['Data Owner'] = element['Business Owner']
                }
                if(this.requiredFields.includes('Derived logic/Business Calculation')) {
                    rowData['Derived logic/Business Calculation'] = element['Business Calculation']
                }
                if(this.requiredFields.includes('Dimensions')) {
                    rowData['Dimensions'] = element['Dimensions']
                }
                if(this.requiredFields.includes('Indication Metric')) {
                    rowData['Indication Metric'] = element['Indication Metric']
                }
                if(this.requiredFields.includes('Refresh Frequency')) {
                    rowData['Refresh Frequency'] = element['Refresh Frequency']
                }
                if(this.requiredFields.includes('Subject Area')) {
                    rowData['Subject Area'] = element['Subject Area']
                }
                if(this.requiredFields.includes('Tenant')) {
                    rowData['Tenant'] = element['Tenant']
                }
                if(this.requiredFields.includes('Value Update')) {
                    rowData['Value Update'] = element['Value Update']
                }
                if(this.requiredFields.includes('Data Retention')) {
                    rowData['Data Retention'] = element['Data Retention']
                } 
                this.updatedCSVData.push(rowData)
        });
        
    }

    createCSVDataForArticle() {
        this.csvData.forEach(element => {
                let rowData = {}
                if(this.requiredFields.includes('Business Term Name')) {
                    rowData['Business Term Name'] = element['Name']
                }
                if(this.requiredFields.includes('Business Term Definition')) {
                    rowData['Business Term Definition'] = element['Description']
                }
                if(this.requiredFields.includes('Acronym/Synonym')) {
                    rowData['Acronym/Synonym'] = element['Acronym / Synonym']
                }
                if(this.requiredFields.includes('Term Type')) {
                    rowData['Term Type'] = element['Term Type']
                }
                if(this.requiredFields.includes('Lifecycle Status')) {
                    rowData['Lifecycle Status'] = element['Life Cycle Status']
                }
                if(this.requiredFields.includes('Data Subject Area')) {
                    rowData['Data Subject Area'] = element['Subject Area']
                }
                if(this.requiredFields.includes('Data Classification')) {
                    rowData['Data Classification'] = element['Classification']
                }
                if(this.requiredFields.includes('Data Steward')) {
                    rowData['Data Steward'] = element['Steward']
                }
                if(this.requiredFields.includes('Data Owner')) {
                    rowData['Data Owner'] = element['Business Owner']
                }
                if(this.requiredFields.includes('Alation Article')) {
                    rowData['Alation Article'] = element['Alation Article']
                }
                if(this.requiredFields.includes('Children/Data Dictionary Reference')) {
                    rowData['Children/Data Dictionary Reference'] = element['datadictionary']
                }
                if(this.requiredFields.includes('Governed Flag')) {
                    rowData['Governed Flag'] = element['Governed Flag']
                }
				if(this.requiredFields.includes('Approved On')) {
                    rowData['Approved On'] = element['Approval date']
                    if(element['Approval date']) {
                        let dateList = element['Approval date'].split('-')
                        if(dateList.length >= 3) {
                            rowData['Approved On'] = dateList[1]+'/'+dateList[2]+'/'+dateList[0]
                        }
                    }
                    console.log('Approved On',rowData['Approved On']);
                }
				if(this.requiredFields.includes('Last Review Date')) {
                    rowData['Last Review Date'] = element['Last Review Date']
                    if(element['Last Review Date']) {
                        let dateList = element['Last Review Date'].split('-')
                        if(dateList.length >= 3) {
                            rowData['Last Review Date'] = dateList[1]+'/'+dateList[2]+'/'+dateList[0]
                        }
                    }
                    console.log('Last Review Date',rowData['Last Review Date']);
                }
                // rowData['Last Review Date'] = element['dcmgt_Last_Review_Date__c']
                //rowData['Approval date'] = element['dcmgt_Approval_date__c']
                this.updatedCSVData.push(rowData)
        });
    }
    // createCSVDataForDataAssert() {
    //     this.csvData.forEach(element => {
    //            let rowData = {}
    //            rowData['Name'] = element['name']
    //            rowData['Schema'] = element['schema_name']
    //            rowData['Full Name'] = element['Full_Name']
    //            rowData['Type'] = element['Type']
    //            rowData['Description'] = element['description']
    //            rowData['Data Assets'] = element['Data_Asset']
    //            rowData['Business Process'] = element['Business process']
    //            rowData['Business Rules'] = element['Business rules']
    //            rowData['Data Category'] = element['Data category']
    //            rowData['Data Consumer'] = element['Data consumer']
    //            rowData['Data Dictionary Field'] = element['Data dictionary']
    //            rowData['Data Steward'] = element['Steward']
    //            rowData['Derived logic/Business Calculation'] = element['Buisness Calculaqtion']
    //            rowData['Dimensions'] = element['Dimensions']
    //            rowData['Indication Metric'] = element['Indication Metric']
    //            rowData['Refresh Frequency'] = element['Refresh Frequency']
    //            rowData['Service Owner'] = element['Business Owner']
    //            rowData['Subject Area'] = element['Subject Area']
    //            rowData['Tenant'] = element['Tenant']
    //            rowData['Value Update'] = element['Value update']
    //            this.updatedCSVData.push(rowData)
    //     });
        
    // }

    // createCSVDataForArticle() {
    //     this.csvData.forEach(element => {
    //            let rowData = {}
    //            rowData['Name'] = element['Name']
    //            rowData['Description'] = element['Description']
    //            rowData['Acronynm/Synonym'] = element['Acronym / Synonym']
    //           // rowData['Last Review Date'] = element['Last Review Date']
    //            rowData['Term Type'] = element['Term Type']
    //            rowData['Life Cycle Status'] = element['Life Cycle Status']
    //            rowData['Subject Area'] = element['Subject area']
    //            rowData['Classification'] = element['Classification']
    //            rowData['Data Owner'] = element['Business Owner']
    //            rowData['Data Steward'] = element['Steward']
    //            rowData['Alation Article'] = element['Alation Article']
    //            rowData['Alation Data Dictionary'] = element['datadictionary']
    //            //rowData['Approval date'] = element['Approval date']
    //            rowData['Governed Flag'] = element['Governed Flag']
    //            this.updatedCSVData.push(rowData)
    //     });
    // }

    downloadCSVFile() {
        let rowEnd = '\n';
        let csvString;
        // this.csvHeader = this.requiredFields.join(',')
        if(this.selectedRequestType  === 'Data Dictionary') {
            csvString = 'Name,Schema,Full Name,Type,Description,Data Assets,Business Process,Business Rules,Data Category,Data Consumer,Data Classification,Data Dictionary Field,Data Steward,Data Owner,Derived logic/Business Calculation,Dimensions,Indication Metric,Refresh Frequency,Subject Area,Tenant,Value Update,Data Retention'
        } else if(this.selectedRequestType === 'Business Glossary') {
            // csvString = 'Business Term Name,Business Term Definition,Acronym/Synonym,Term Type,Lifecycle Status,Data Subject Area,Classification,Data Owner,Data Steward,Alation Article,Children/Data Dictionary Reference,Governed Flag,Approved On,Last Review Date'
            csvString = 'Business Term Name,Business Term Definition,Acronym/Synonym,Term Type,Lifecycle Status,Data Subject Area,Data Classification,Data Steward,Data Owner,Alation Article,Children/Data Dictionary Reference,Governed Flag,Approved On,Last Review Date'
        }
        csvString = csvString.split(',')
        this.csvHeader = csvString.filter(data => {
            if(this.requiredFields.includes(data)) {
                return true
            }
            return false
        })
        this.csvHeader = this.csvHeader.join(',')
       // Creating anchor element to download
       let downloadElement = document.createElement('a');
       if(this.selectedRequestType  === 'Data Dictionary' && this.changeRequestType === "Update") {
           this.createCSVDataForDataAssert()
           //this.getDataAssets();
           downloadElement.download = 'data Dictionary.csv';
           //csvString += 'Name,Full name,Type,Description,Data Assets,Business Process,Business Rules,Data Category,Data Consumer,Data Dictionary Field,Data Stewards,Derived logic/Business Calculation,Dimensions,Indication Metric,Refresh Frequency,Schema,Service Owners,Subject Area,Tenant,Value Update';
           //csvString = 'Name,Schema,Full Name,Type,Description,Data Assets,Business Process,Business Rules,Data Category,Data Consumer,Data Dictionary Field,Data Stewards,Derived logic/Business Calculation,Dimensions,Indication Metric,Refresh Frequency,Service Owners,Subject Area,Tenant,Value Update,Data Retention'
           csvString = this.csvHeader
           //this.csvData = this.dictionaryTableData;
        } else if(this.selectedRequestType === 'Business Glossary' && this.changeRequestType === "Update") {
            this.createCSVDataForArticle()
            //this.getGlossaryArticles();
           // csvString += 'Name,Description,Acronynm/Synonym,Last Review Date,Term Type,Life Cycle Status,Subject Area,Classification,Data Owners,Data Stewards,Alation Article,Alation Data Dictionary,Approval date,Governed Flag'
        //    csvString += 'Name,Description,Acronynm/Synonym,Term Type,Life Cycle Status,Subject Area,Classification,Data Owners,Data Stewards,Alation Article,Alation Data Dictionary,Governed Flag'
        csvString = this.csvHeader
            downloadElement.download = 'Business Glossary.csv';
            //this.csvData = this.businessData;
            
       }

       
        console.log("finalCSVdata:::::::"+this.updatedCSVData)
        
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data
        this.updatedCSVData.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        
        // splitting using ','
       // csvString += rowData.join(',');
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for(let i=0; i < this.updatedCSVData.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {
                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = this.updatedCSVData[i][rowKey] === undefined ? '' : this.updatedCSVData[i][rowKey];
                    csvString += '"'+ value +'"';
                    colValue++;
                }

            
            }
            csvString += rowEnd;
        }

        if(this.selectedRequestType  === 'Data Dictionary' && this.changeRequestType === "Add") {
            //csvString =  'Name,Full name,Type,Description,Data Assets,Business Process,Business Rules,Data Category,Data Consumer,Data Dictionary Field,Data Stewards,Derived logic/Business Calculation,Dimensions,Indication Metric,Refresh Frequency,Schema,Service Owners,Subject Area,Tenant,Value Update';
            // csvString = 'Name,Schema,Full Name,Type,Description,Data Assets,Business Process,Business Rules,Data Category,Data Consumer,Data Dictionary Field,Data Stewards,Derived logic/Business Calculation,Dimensions,Indication Metric,Refresh Frequency,Service Owners,Subject Area,Tenant,Value Update'
            csvString = this.csvHeader
            downloadElement.download = 'data Dictionary.csv';
        } else if(this.selectedRequestType === 'Business Glossary' && this.changeRequestType === "Add") {
            //csvString = 'Name,Description,Acronynm/Synonym,Last Review Date,Term Type,Life Cycle Status,Subject Area,Classification,Data Owners,Data Stewards,Alation Article,Alation Data Dictionary,Approval date,Governed Flag'
            // csvString = 'Name,Description,Acronynm/Synonym,Term Type,Life Cycle Status,Subject Area,Classification,Data Owners,Data Stewards,Alation Article,Alation Data Dictionary,Governed Flag'
            csvString = this.csvHeader
            downloadElement.download = 'Business Glossary.csv';
        }
        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        //downloadElement.download = 'glossary Data.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click();
        this.submitDetails()

    }
   
    // fetching Dictionary from server
//     getDataAssets() {
//         console.log(":::::"+this.dictionaryId)
//         getListOfDataAssetsByDictionaryId({dictionaryId:this.dictionaryId})
//         .then(result => {
//             console.log('getListOfDataAssetsByDictionaryId::::::::',result)
//             //this.tempTableData = result;
//             this.dictionaryTableData = [];
//             for(let i=0; i<result.length; i++){
//                 let obj = {...result[i]};
//                 if(result[i].dcmgt_Data_Assets__c) {
//                     obj.dataAssert = result[i].dcmgt_Data_Assets__r.Name;
//                 }
//                 if(result[i].dcmgt_Data_Steward__c) {
//                     obj.dataSteward = result[i].dcmgt_Data_Steward__r.Name;
//                 }
//                 if(result[i].dcmgt_Schema__c) {
//                     obj.schema = result[i].dcmgt_Schema__r.Name;
//                 }
//                 if(result[i].dcmgt_Service_Owner__c) {
//                     obj.serviceOwner = result[i].dcmgt_Service_Owner__r.Name;
//                 }
                
//                 this.dictionaryTableData.push(obj);
//             }

//         }).catch(error => {
//             console.error('getListOfDataAssetsByDictionaryId',error)
//             this.dispatchEvent(
//                 new ShowToastEvent({
//                     title: 'Error while getting Data Asserts', 
//                     message: error.body.message, 
//                     variant: 'error'
//                 }),
//             );
//             this.dictionaryTableData = null;
//         })
//     }

//     // fetching Glossary from server
//     getGlossaryArticles() {
//         console.log('glossaryId data',this.glossaryId )
//         getAlationArticleDataByGlossaryId({glossaryId:this.glossaryId})
//         .then(result => {
//            // this.tempTableData = result;
//             this.businessData = [];
//             for(let i=0; i<result.length; i++){
//                 let obj = {...result[i]};
//                 if(result[i].dcmgt_Data_Owner__c) {
//                     obj.dataOwner = result[i].dcmgt_Data_Owner__r.Name;
//                 }
//                 if(result[i].dcmgt_Data_Steward__c) {
//                     obj.dataSteward = result[i].dcmgt_Data_Steward__r.Name;
//                 }
//                 if(result[i].dcmgt_Alation_Article__c) {
//                     obj.parentArticle = result[i].dcmgt_Alation_Article__r.Name;
//                 }
//                 if(result[i].dcmgt_Alation_Data_Dictionary__c) {
//                     obj.dataDictionary = result[i].dcmgt_Alation_Data_Dictionary__r.Name;
//                 }
//                 console.log("+++++++++++++++++++++++obj"+obj)
//                 this.businessData.push(obj);
//             }
//             console.log('getGlossaryArticles data:::',this.businessData )
//         })
//         .catch(error => {
//             console.error('getGlossaryArticles error',error)
//             this.dispatchEvent(
//                 new ShowToastEvent({
//                     title: 'Error while getting Articles', 
//                     message: error.message, 
//                     variant: 'error'
//                 }),
//             );
//             console.log(error)
//             this.businessData = null;
//         });
//     }


    

    
        
                
//                 // downloadCSVFile() {
//                 //     //console.log(this.selectedRequestType)
//                 //    // if(this.selectedRequestType === 'Business glossary') {
//                 //     let csvString = 'Name,dcmgt_Description__c,dcmgt_Acronynm_Synonym__c,dcmgt_Last_Review_Date__c,dcmgt_Life_Cycle_Status__c,dcmgt_Subject_Area__c';
//                         // }

//                 //    else if(this.selectedRequestType === 'Data Dictionary') {
//                 //             let csvString = 'Name,dcmgt_Full_name__c,dcmgt_Type__c,dcmgt_Description__c';
//                 //            // Creating anchor element to download
//                 //             let downloadElement = document.createElement('a');
                                                
//                 //               // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
//                 //              downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
//                 //              downloadElement.target = '_self';
//                 //               // CSV File Name
//                 //              downloadElement.download = 'dictionary Data.csv';
//                 //              // below statement is required if you are using firefox browser
//                 //              document.body.appendChild(downloadElement);
//                 //              // click() Javascript function to download CSV file
//                 //              downloadElement.click();
//                 //             this.submitDetails()
//                 //         }
//     }










// // import { LightningElement, api } from 'lwc';

// // export default class DownloadPopup extends LightningElement {
// //     @api isModalOpen
// //     @api displayMessage
// //     @api changeRequestType
// //     @api selectedRequestType
// //     submitDetails() {
// //         this.dispatchEvent(new CustomEvent('close'))
        
// //     }
        
                
// //                 downloadCSVFile() {
// //                     //console.log(this.selectedRequestType)
// //                    // if(this.selectedRequestType === 'Business glossary') {
// //                     let csvString = 'Name,dcmgt_Description__c,dcmgt_Acronynm_Synonym__c,dcmgt_Last_Review_Date__c,dcmgt_Life_Cycle_Status__c,dcmgt_Subject_Area__c';
// //                     // Creating anchor element to download
// //                     let downloadElement = document.createElement('a');
            
// //                     // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
// //                     downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
// //                     downloadElement.target = '_self';
// //                     // CSV File Name
// //                     downloadElement.download = 'glossary Data.csv';
// //                     // below statement is required if you are using firefox browser
// //                     document.body.appendChild(downloadElement);
// //                     // click() Javascript function to download CSV file
// //                     downloadElement.click();
// //                     this.submitDetails()
// //                 }

// //                 //    else if(this.selectedRequestType === 'Data Dictionary') {
// //                 //             let csvString = 'Name,dcmgt_Full_name__c,dcmgt_Type__c,dcmgt_Description__c';
// //                 //            // Creating anchor element to download
// //                 //             let downloadElement = document.createElement('a');
                                                
// //                 //               // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
// //                 //              downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
// //                 //              downloadElement.target = '_self';
// //                 //               // CSV File Name
// //                 //              downloadElement.download = 'dictionary Data.csv';
// //                 //              // below statement is required if you are using firefox browser
// //                 //              document.body.appendChild(downloadElement);
// //                 //              // click() Javascript function to download CSV file
// //                 //              downloadElement.click();
// //                 //             this.submitDetails()
// //                 //         }
     }