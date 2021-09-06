import { LightningElement,api } from 'lwc';

export default class Dcmgt_dataPublishApproval extends LightningElement {
    @api recordId;
    objectName = 'dcmgt_Data_Pub_Request__c';
    fieldNameforDataStewards = 'dcmgt_Data_Steward__c';
    fieldNameforDataOwners = 'dcmgt_Data_Owner__c';

}