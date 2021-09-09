import { LightningElement,api } from 'lwc';

export default class Dcmgt_dataAssetsUsersMultiSelect extends LightningElement {
    @api recordId;
    objectName = 'dcmgt_Data_Assets__c';
    fieldNameforDataStewards = 'dcmgt_Data_Stewards__c';
    fieldNameforDataOwners = 'dcmgt_Service_Owners__c';

}