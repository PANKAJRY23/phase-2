import { LightningElement, track, wire } from 'lwc';
import pubSubMessageChannel from '@salesforce/messageChannel/dcmgt_SubMessageChannel__c'
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import getAllCurrentSubscriptionRec from '@salesforce/apex/dcmgt_DataSourceSubscriptionController.getAllCurrentSubscriptionRec'
import getSubRequest from '@salesforce/apex/dcmgt_DataSourceSubscriptionController.getSubRequest'
import upsertDataAssetSubRequestList from '@salesforce/apex/dcmgt_DataSourceSubscriptionController.upsertDataAssetSubRequestList'
import upsertDataSubRequestList from '@salesforce/apex/dcmgt_DataSourceSubscriptionController.upsertDataSubRequestList'

const REFRESH_FREQUENCY = [
    {value: 'Hourly', label: 'Hourly'},
    {value: 'Daily', label: 'Daily'},
    {value: 'Weekly', label: 'Weekly'},
    {value: 'Monthly', label: 'Monthly'}    
];

const Data_Load	= [
    {value: 'Full Load', label: 'Full Load'},
    {value: 'Delta Load', label: 'Delta Load'},
    {value: 'Push', label: 'Push'},
    {value: 'Pull', label: 'Pull'}
];

const Access_Layer = [
    {value: 'DB', label: 'DB'},
    {value: 'API', label: 'API'},
    {value: 'Stream', label: 'Stream'},
    {value: 'File Server', label: 'File Server'},
    {value: 'Data Lake', label: 'Data Lake'}
];

const Comunication_Email_Chatter = [
    {value: 'Horilizon Chatter', label: 'Horilizon Chatter'}
];


const dataAssertColumns = [
    // { label: 'Id', fieldName: 'Id', type: 'text' }, 
    { label: 'Data Source', fieldName: 'DataSource', type: 'text'}, 
    { label: 'Data Asset', fieldName: 'DataAsset', type: 'text'}, 
    { label: 'Data Classification', fieldName: 'DataClassification', type: 'text'}, 
    { label: 'Data Load', fieldName: 'DataLoad', editable: true, type: 'picklist', options: Data_Load}, 
    { label: 'Access Layer', fieldName: 'AccessLayer', editable: true, type: 'picklist', options: Access_Layer}, 
    { label: 'Refresh Frequency', fieldName: 'RefershFrequency', editable: true, type: 'picklist', options: REFRESH_FREQUENCY}, 
    { label: 'Data Load', fieldName: 'DataLoad', editable: true, type: 'picklist', options: Data_Load}, 
    { label: 'SLA', fieldName: 'SLA', type: 'text', editable: true}, 
    { label: 'Communication', fieldName: 'Communication', editable: true, type: 'picklist', options: Comunication_Email_Chatter, sortable: true }
]


export default class Dcmgt_dataAssetsDetails extends LightningElement {

    

    SelecttenantId
    SubscriptionRecord
    @track data
    @track dataLoadOptions = Data_Load
    @track AccessLayerOptions = Access_Layer
    @track RefershFrequencyOptions = REFRESH_FREQUENCY
    @track CommunicationOptions = Comunication_Email_Chatter
    businessJustification

    @wire(MessageContext)
    context

    

    connectedCallback() {
        if(!this.subscription) {
            this.subscribeTenant()
        }


    }

    subscribeTenant() {
        this.subscription = subscribe(this.context, pubSubMessageChannel,  (message) => {this.handleMessage(message)}, {scope:APPLICATION_SCOPE} )
    }

    handleMessage(message) { 
        
        
        console.log('Data Source 83 Tenant Id', message.tenantId.value)
      //  console.log('Data Source tenant name', message.tenantId.name)
        
        this.getSubscriptionRecordDetails(message.tenantId.value)
        this.getDataAssetsDetails(message.tenantId.value)
    }
    
    getSubscriptionRecordDetails(teamId){
        getSubRequest({tenantId: teamId})
        .then(result => {
         //   console.log('==result=42=',result)
           this.SubscriptionRecord = result;
           this.businessJustification = result.dcmgt_Business_Justification__c
            
        })
        .catch(error => {
            console.log('error--',error);
        });
    }

    getDataAssetsDetails(teamId){
        console.log('teamId=====104==',teamId)
        getAllCurrentSubscriptionRec({tenantId: teamId})
        .then(result => {
            console.log('==result=86=',result)
            this.data = result
            
        })
        .catch(error => {
            console.log('error--',error);
        });
    }

   SaveHandler(event){
    console.log('==event.target.value=='+event.target.value)
        upsertDataAssetSubRequestList({ value: event.target.value , RecordId: event.target.dataset.id , FieldName: event.target.name })
		.then(result => {
			// console.log('result--',result);
			
		})
		.catch(error => {
			console.log('error-121-',error);
		});

    }

    updateRichTextFunction(event){
        
        this.businessJustification = event.target.value;

        let bussinessjustFieldApiName = 'dcmgt_Business_Justification__c'

        upsertDataSubRequestList({ value: event.target.value , RecordId: this.SubscriptionRecord.Id , FieldName: bussinessjustFieldApiName })
		.then(result => {
			// console.log('result--',result);
			
		})
		.catch(error => {
			console.log('error-121-',error);
		});
    }
     
}