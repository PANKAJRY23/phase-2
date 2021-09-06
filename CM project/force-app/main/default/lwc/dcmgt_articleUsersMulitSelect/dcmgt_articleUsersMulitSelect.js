import { LightningElement,api } from 'lwc';

export default class Dcmgt_articleUsersMulitSelect extends LightningElement {

    @api recordId;
    objectName = 'dcmgt_Alation_Article__c';
    fieldNameforDataStewards = 'dcmgt_DataStewards__c';
    fieldNameforDataOwners = 'dcmgt_Data_Owners__c';


}