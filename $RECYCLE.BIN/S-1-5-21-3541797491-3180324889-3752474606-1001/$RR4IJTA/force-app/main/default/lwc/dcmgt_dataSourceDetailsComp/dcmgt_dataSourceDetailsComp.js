import { LightningElement, track, wire } from 'lwc';
import DATA_SOURCE_OBJECT from '@salesforce/schema/dcmgt_Data_Source__c';
import DATA_SOURCE_NAME from '@salesforce/schema/dcmgt_Data_Source__c.Name'
import DATA_SOURCE_CONN_STRING from '@salesforce/schema/dcmgt_Data_Source__c.dcmgt_Connection_String__c'
import DATA_SOURCE_CLASSIFICATION from '@salesforce/schema/dcmgt_Data_Source__c.dcmgt_Data_Classification__c'
import DATA_SOURCE_NAME_OWNER from '@salesforce/schema/dcmgt_Data_Source__c.dcmgt_Data_Owner__c'
import DATA_SOURCE_NAME_RETENTION_POLICY from '@salesforce/schema/dcmgt_Data_Source__c.dcmgt_Data_Retention_Policy__c'
import DATA_SOURCE_NAME_SHARING_POLICY from '@salesforce/schema/dcmgt_Data_Source__c.dcmgt_Data_Sharing_Policy__c'
import DATA_SOURCE_NAME_STEWARD from '@salesforce/schema/dcmgt_Data_Source__c.dcmgt_Data_Steward__c'
import DATA_SOURCE_NAME_SOURCE_OWNER from '@salesforce/schema/dcmgt_Data_Source__c.dcmgt_Data_Source_Owner__c'
import DATA_SOURCE_NAME_SCHEMA_VISIBILITY from '@salesforce/schema/dcmgt_Data_Source__c.dcmgt_Public_Schema_Visibility__c'
import pubSubMessageChannel from '@salesforce/messageChannel/dcmgt_PubSubMessageChannel__c'
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';

export default class Dcmgt_dataSourceDetailsComp extends LightningElement {
    objectName = DATA_SOURCE_OBJECT
    @track fieldList = [DATA_SOURCE_NAME, DATA_SOURCE_CLASSIFICATION, DATA_SOURCE_NAME_OWNER,
        DATA_SOURCE_NAME_RETENTION_POLICY, DATA_SOURCE_NAME_SHARING_POLICY, DATA_SOURCE_NAME_STEWARD,
        DATA_SOURCE_NAME_SOURCE_OWNER, DATA_SOURCE_NAME_SCHEMA_VISIBILITY, DATA_SOURCE_CONN_STRING]
    isCreateModelOpen = false
    title = 'New Data Source'
    subscription

    @wire(MessageContext)
    context

    connectedCallback() {
        this.subscribeTenant()
    }

    subscribeTenant() {
        this.subscription = subscribe(this.context, pubSubMessageChannel,  (message) => {this.handleMessage(message)}, {scope:APPLICATION_SCOPE} )
    }

    handleMessage(message) { 
        console.log('publish message', message.tenantId.value)
    }
    
    newClickHandler() {
        this.isCreateModelOpen = true
    }

    closeHandler(event) {
        this.isCreateModelOpen = false
    }
}