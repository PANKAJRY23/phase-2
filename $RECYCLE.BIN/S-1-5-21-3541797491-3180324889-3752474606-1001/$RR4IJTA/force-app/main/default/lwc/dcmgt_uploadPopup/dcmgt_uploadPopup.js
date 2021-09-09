import { LightningElement, api, track } from 'lwc';
import getFieldMap from '@salesforce/apex/dcmgt_changeRequestFormController.getMapOfFieldNameWithAPIName'
import uploadData from '@salesforce/apex/dcmgt_UploadValidation.uploadData'
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
// import requestType from '@salesforce/apex/UploadValidation.requestType'
export default class dcmgt_UploadPopup extends LightningElement {
    @api isModalOpen
    @api displayMessage
    @api requestType
    //requestType = 'Business glossary' //'Data Dictionary'
    @api changeType
    //@api orignalData
    //@api data
    fileName
    @track requestType
    @track fileContents
    @track filesUploaded = [];
    @track file
    @api requiredFields
    fileReader
    fileColumnsName
    @track columns = [];
    @track data = [];
    isShowTable = false
    objectAPIName
    @track mapOfFieldNameAndAPIName
    isUploadDisable = true
    isDisableUpload = true
    @track isLoading = false
    fileContentErrors = [];
    errormessage;
    // @track mapOfIdWithName = {}
    // @track mapOfUserNameAndId
    // @track setOfUserName = new Set()
    // @track setOfDataDictionary = new Set()
    // @track setOfAliationArticle = new Set()
    // @track setOfSchema = new Set()
    // @track setOfDataAssert = new Set()
    // listOfUsersField = [
    //     'dcmgt_Data_Steward__c', 'dcmgt_Service_Owner__c', 'dcmgt_Data_Owner__c'
    // ]
    // listOfDataDictionaryField = [
    //     'dcmgt_Alation_Data_Dictionary__c'
    // ]
    // listOfAliationArticleField = [
    //     'dcmgt_Alation_Article__c'
    // ]
    // listOfDataAssertField = [
    //     'dcmgt_Data_Assets__c'
    // ]
    // listOfSchemaField = [
    //     'dcmgt_Schema__c'
    // ]
    connectedCallback() {
        //console.log('orignalData', JSON.stringify(this.orignalData))
        console.log('this.requiredFields', JSON.stringify(this.requiredFields))
        console.log('requestType', this.requestType)
        console.log('changeType', this.changeType)
        if(this.requestType === 'Data Dictionary') {
            this.objectAPIName = 'dcmgt_Data_Assets__c'
        } else if(this.requestType === 'Business Glossary') {
            this.objectAPIName = 'dcmgt_Alation_Article__c'
        }
        if(this.changeType === 'Update') {
            //this.createMapOfIdByName()
        }
        //  else if(this.changeType === 'Add') {
        //     this.getUserInfo()
        // }
        this.getFieldMapByObjetc()
    }
    
    getFieldMapByObjetc() {
        getFieldMap({objectName:this.objectAPIName})
        .then(data => {
            this.mapOfFieldNameAndAPIName = data
            console.log('data', data)
        }).catch(error => {
            console.error('error', error)
        })
    }

    showToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error while Uploading', 
                message: 'Please upload correct file', 
                variant: 'error'
            }),
        );
    }

    // createMapOfIdByName() {
    //     this.orignalData.forEach(element => {
    //         // let obj = {}
    //         // console.log(element)
    //         // console.log(JSON.stringify(element))
    //         // obj[element.Name]= element.Id
    //         this.mapOfIdWithName[element.Name]= element.Id
    //     });
    //     console.log('mapOfIdWithName',JSON.stringify(this.mapOfIdWithName))
        
    // }

    submitDetails() {
        // this.dispatchEvent(new CustomEvent('close', {
        //     detail: {columns: this.columns,
        //             data: this.data}}
        // ))
        console.log('submitDetails')
        this.dispatchEvent(new CustomEvent('close', {
            detail: {message : 'Fail'}}
        ))
    }
    

    handleFilesChange(event) {
        this.isLoading = true
        this.fileName = '';
        this.filesUploaded = null;
        this.fileContents = null;
        this.errormessage = null
        console.log(event.target.files)
        if(event.target.files.length > 0) {
            console.log('>>'+event.target.files[0].name+' '+event.target.files[0].type);
            this.fileName = event.target.files[0].name;
            if(this.fileName.endsWith('.csv')) {
                this.isUploadDisable = false
                this.filesUploaded = event.target.files;
                this.fileName = this.fileName;
                this.uploadHelper()

                // this.fileReader= new FileReader();
                // this.fileReader.onloadend = (() => {
        
                //     uploadData(JSON.stringify(this.fileReader.result))
                //         .then(result => {
                //             this.fileContents = result
                //             console.log('filesContents:: ', result)
                //         }).catch(error => {
                //             console.error('error', error)
                //         });
                    
                //     console.log('fileContents type',typeof this.fileContents);
                //     console.log('fileContents',this.fileContents);
                //     console.log('fileContents length',this.fileContents.length);
                //     this.fileColumnsName = this.fileContents.split(/\r?\n/)[0];
                //     console.log('1: '+this.fileColumnsName);
                //     this.fileColumnsName = this.fileColumnsName.split(',');
                //     console.log('2: '+this.fileColumnsName);
                //     //this.saveToFile();
                // });
                

            } else {
                this.isUploadDisable = true
                this.fileName = 'Please select a CSV file to upload!!';
            }
        }
        console.log('fileName',this.fileName)
        console.log('filesUploaded',this.filesUploaded)
        console.log('fileContents',this.fileContents)
        this.isLoading = false
        //this.getDataByCSV()
    }

    uploadHelper() {
        this.file = this.filesUploaded[0];
        console.log('filesUploaded', this.filesUploaded);
        // if(this.file.size > this.MAX_FILE_SIZE) {
        //     window.console.log('File Size is to long');
        //     return ;
        // }
        this.fileReader= new FileReader();
        this.fileReader.onloadend = (() => {
            this.fileContents = this.fileReader.result;
            console.log('fileContents type',typeof this.fileContents);
            console.log('fileContents',this.fileContents);
            console.log('@@@@@@############^^^^^^^^^^^',this.isDisableUpload);
            console.log('fileContents length',this.fileContents.length);
            this.fileColumnsName = this.fileContents.split(/\r?\n/)[0];
            console.log('1: '+this.fileColumnsName);
            this.fileColumnsName = this.fileColumnsName.split(',');
            console.log('2: '+this.fileColumnsName);
            console.log('uploadData.fileContents',JSON.stringify(this.fileContents))
            let isWrongTemplate = false
            
            if(this.fileColumnsName.length != this.requiredFields.length) {
                console.log('this.requiredFields if', JSON.stringify(this.requiredFields))
                isWrongTemplate = true
                this.showToast();
            } else {
                console.log('this.requiredFields else', JSON.stringify(this.requiredFields))
                console.log('this.fileColumnsName else', this.fileColumnsName)
                isWrongTemplate = this.fileColumnsName.some(data => {
                    if(!this.requiredFields.includes(data)) {
                        return true
                    } else {
                        return false
                    }
                })
                console.log('isWrongTemplate', isWrongTemplate)
                if(isWrongTemplate) {
                    this.showToast();
                }
            }
            console.log('isWrongTemplate', isWrongTemplate)
             if(isWrongTemplate === false) {
                this.isLoading = true;
                uploadData({filesContent:JSON.stringify(this.fileContents),requestType:(this.requestType)})
                        .then(data => {
                           this.fileContentErrors = data;
                           console.log('uploadData len:- ',this.fileContentErrors.length);
                          
                           if(this.fileContentErrors.length>0){
                                this.errormessage = 'While Uploading your data there are few errors, Please download to check errors-->'
                                this.isDisableUpload = true
                            } else {
                                this.isDisableUpload = false
                            }
                            console.log('isDisableUpload len:- ',this.isDisableUpload);
                            console.log('filesContents_errors:: ', data);
                            console.log('@@@@@@############^^^^^^^^^^^',this.isDisableUpload);
                            this.isLoading = false;
                        }).catch(error => {
                            this.isLoading = false;
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error in file Validation', 
                                    message: error.body, 
                                    variant: 'error'
                                }),
                            );
                            console.error('error', error)
                        });
                    }
            //this.saveToFile();
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

    showSpinner() {
        console.log('showSpinner')
        // Setting boolean variable to true, this will show the Spinner
        this.isLoading = true;
    }

    downloaderrorsClick() {
        let downloadElement = document.createElement('a');
        downloadElement.download = 'errors.txt';
        let today = new Date();
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(today+' Started Uploading your Data'+this.fileContentErrors);
        // downloadElement.href = 'fileContentErrors:text';
        downloadElement.target = '_self';
        // downloadElement.download = 'download.txt';
        document.body.appendChild(downloadElement);
        downloadElement.click();
        
    }

    handleUpdate() {
        this.isLoading = false;
        this.dispatchEvent(new CustomEvent('close', {
            detail: {message : 'Success',
                fileContents: this.fileContents,
                fileColumnsName: this.fileColumnsName,
                mapOfFieldNameAndAPIName: this.mapOfFieldNameAndAPIName}}
        ))
        this.isLoading = true;
    }

    //will remove it
    handleUpdateToRenove() {
        this.showSpinner()
        console.log('getDataByCSV')
        let fileRow = this.fileContents.split(/\r?\n/);
        console.log('Row data',  fileRow)
        console.log('Row data 1',  this.fileContents.split(/\n/))
        let fileCoumnData =  this.fileColumnsName;
        for(let row = 0; row < fileRow.length ; row ++ ){
            let fileData = fileRow[row].split(',');
            console.log('len:-'+fileData.length)
            if(fileData.length === 1) {
                console.log('fileData.length === 0')
                continue
            }
            let rowData = {};
            for(let column = 0; column < fileData.length; column ++ ){
                let typeOfColumn = 'text'
                if(row === 0){
                    // if(fileData[column].indexOf("Date") > 0) {
                    //     typeOfColumn = 'date' 
                    // }
                    // let columnName = fileData[column].replaceAll('dcmgt_', '')
                    // columnName = columnName.replaceAll('__c', '')
                    // columnName = columnName.replaceAll('_', ' ')
                    // console.log(columnName +typeOfColumn)
                    let columnName = fileData[column].trim()
                    // if(columnName === 'Data Steward' || columnName === 'Data Owner' || columnName === 'Service Owner') {
                    //     this.columns.push({
                    //         label:columnName, fieldName:this.mapOfFieldNameAndAPIName[columnName], type: 'lookup', linkLabel: columnName.replaceAll(' ','')
                    //     });
                    //     //{label: 'Alation Article', fieldName: 'dcmgt_Alation_Article__c', type: 'lookup', linkLabel: 'parentArticle', resizable: true},
                    // }else {
                        this.columns.push({
                            label:columnName, fieldName:this.mapOfFieldNameAndAPIName[columnName], type: typeOfColumn, resizable: true, sortable: true 
                        });
                    // }
                    // this.columns.push({
                    //     label:columnName, fieldName:this.mapOfFieldNameAndAPIName[columnName], type: typeOfColumn
                    // });
                } else {
                    let rowDataValue = fileData[column]
                    rowDataValue = rowDataValue.replaceAll('"', '')
                    let columnName = this.fileColumnsName[column]
                    console.log('rowDataValue',rowDataValue)
                    console.log('columnName',columnName)
                    if(columnName.indexOf("_Date") > 0 || columnName.indexOf("_date") > 0 ) {
                        console.log('columnName1',columnName)
                        let dateValue  = rowDataValue.split('-') 
                        if(dateValue.length >= 3) {
                            rowDataValue = `${dateValue[2]}-${dateValue[1]}-${dateValue[0]}`
                            console.log('rowDataValue', rowDataValue)
                        }
                        // 
                        // 
                        console.log('dateValue', dateValue)
                    }
                    rowData[this.mapOfFieldNameAndAPIName[columnName]]= rowDataValue;
                }
            }
            if(row != 0){
                // if(this.changeType === 'Update') {
                //     console.log('record name1',rowData['Name'])
                //     console.log('record name',this.mapOfIdWithName[rowData['Name']])
                //     rowData['Id'] = this.mapOfIdWithName[rowData['Name']]
                // }
                //this.addLookupField(rowData)
                // if(this.changeType === 'Add') {
                //     if(rowData['dcmgt_Data_Steward__c']) {
                //         let owner = rowData['dcmgt_Data_Steward__c']
                //         rowData['dcmgt_Data_Steward__c'] = this.mapOfUserNameAndId[owner]
                //         rowData['DataSteward'] = owner
                //     }
                //     if(rowData['dcmgt_Data_Owner__c']) {
                //         let owner = rowData['dcmgt_Data_Owner__c']
                //         rowData['dcmgt_Data_Owner__c'] = this.mapOfUserNameAndId[owner]
                //         rowData['DataOwner'] = owner
                //     }
                //     if(rowData['dcmgt_Service_Owner__c']) {
                //         let owner = rowData['dcmgt_Service_Owner__c']
                //         rowData['dcmgt_Service_Owner__c'] = this.mapOfUserNameAndId[owner]
                //         rowData['ServiceOwner'] = owner
                //     }
                // }
                this.data.push(rowData);
            }
        }
        console.log('columns', JSON.stringify(this.columns));
        console.log('data', JSON.stringify(this.data));
        //this.isShowTable = true
        //this.isLoading = false
        this.dispatchEvent(new CustomEvent('close', {
                detail: {message : 'Success',
                    columns: this.columns,
                        data: this.data}}
            ))
        //this.submitDetails()
    }

    // addLookupField(rowData) {
    //     this.listOfUsersField.forEach(element => {
    //         if(rowData[element]) {
    //             this.setOfUserName.add(rowData[element])
    //         }
    //     });
    //     this.listOfAliationArticleField.forEach(element => {
    //         if(rowData[element]) {
    //             this.setOfAliationArticle.add(rowData[element])
    //         }
    //     });
    //     this.listOfDataAssertField.forEach(element => {
    //         if(rowData[element]) {
    //             this.setOfDataAssert.add(rowData[element])
    //         }
    //     });
    //     this.listOfDataDictionaryField.forEach(element => {
    //         if(rowData[element]) {
    //             this.setOfDataDictionary.add(rowData[element])
    //         }
    //     });
    //     this.listOfSchemaField.forEach(element => {
    //         if(rowData[element]) {
    //             this.setOfSchema.add(rowData[element])
    //         }
    //     });
    //     console.log('setOfSchema', this.setOfSchema)
    //     console.log('setOfDataDictionary', this.setOfDataDictionary)
    //     console.log('setOfUserName', this.setOfUserName)
    //     console.log('setOfAliationArticle', this.setOfAliationArticle)
    //     console.log('setOfDataAssert', this.setOfDataAssert)
    //     // if(rowData['dcmgt_Data_Steward__c']) {
    //     //     let owner = rowData['dcmgt_Data_Steward__c']
    //     //     rowData['dcmgt_Data_Steward__c'] = this.mapOfUserNameAndId[owner]
    //     //     rowData['DataSteward'] = owner
    //     // }
    //     // if(rowData['dcmgt_Data_Owner__c']) {
    //     //     let owner = rowData['dcmgt_Data_Owner__c']
    //     //     rowData['dcmgt_Data_Owner__c'] = this.mapOfUserNameAndId[owner]
    //     //     rowData['DataOwner'] = owner
    //     // }
    //     // if(rowData['dcmgt_Service_Owner__c']) {
    //     //     let owner = rowData['dcmgt_Service_Owner__c']
    //     //     rowData['dcmgt_Service_Owner__c'] = this.mapOfUserNameAndId[owner]
    //     //     rowData['ServiceOwner'] = owner
    //     // }

    // }
}