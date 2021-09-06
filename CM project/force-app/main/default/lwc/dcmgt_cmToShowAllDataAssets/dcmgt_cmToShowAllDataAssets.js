import { LightningElement,  api, track, wire} from 'lwc';
import getDataassets from '@salesforce/apex/dcmgt_DataAssetsController.getDataAssetsMethod';
import upsertDataSubscriptionRecord from '@salesforce/apex/dcmgt_DataAssetsController.upsertDataSubscriptionRecord';
import { NavigationMixin } from 'lightning/navigation';

export default class Dcmgt_cmToShowAllDataAssets extends NavigationMixin(LightningElement) {
    
    datasets;
    dataSetId;
   
    connectedCallback() {
        getDataassets()
        .then(result => {
            console.log('result---',result);   
            this.datasets = result;
           
        })
        .catch(error => {               
            console.log('error---',error);   
        });
    }

    onCheckBoxSelect(event){
        console.log('==event.target==',event.target.dataset.id) 
        
        if(event.target.checked){
            // this.dataSetId.push({
            //     Id : event.target.dataset.id
            // })
            if(this.dataSetId){
                this.dataSetId = this.dataSetId+','+event.target.dataset.id;
            }else{
                this.dataSetId = event.target.dataset.id;
            }
        }
        console.log('==event.checked==',this.dataSetId)
    }

    navigateNext() {

        
        upsertDataSubscriptionRecord({ Ids: this.dataSetId})
        .then(result => {
            // console.log('result--',result); 
            
        })
        .catch(error => {
            console.log('error-496-',error);           
        
        });

        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Data_Marketplace'
            },
            state: {              
                c__counter: 'Subscription'          
            }
        });
    }

}