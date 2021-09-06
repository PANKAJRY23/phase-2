import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class Dcmgt_pubSubHomeComp extends NavigationMixin(LightningElement) {
    publiactionHandler(event) {
        console.log('publiactionHandler');
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Data_Marketplace'
            },
        });
    }

    subscriptionHandler(event) {
        this[NavigationMixin.Navigate]({
            type: 'standard__navItemPage',
            attributes: {
                apiName: 'Data_Assets'
            },
        });
    }
}