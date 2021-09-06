import { api, LightningElement, track } from 'lwc';

export default class Dcmgt_createNewRecordComp extends LightningElement {
    @api objectName
    @api fieldList
    @api isModalOpen
    @api title
    @track fields

    connectedCallback() {
        console.log('fieldList', JSON.stringify(this.fieldList));
    }

    cancelClickHandler() {
        this.dispatchEvent(new CustomEvent('close', 
            {
                detail: {message : 'Cancel'}
            }
        ))
    }

    handleSave(){
        let result = this.template.querySelector('lightning-record-edit-form').submit(this.fields);
    }

    submitHandler(event) {
        console.log('fields', event.detail.fields)
        event.preventDefault(); 
        this.fields = event.detail.fields;
        console.log('fields', this.fields)
        console.log(JSON.stringify(event.detail))
    }

    handleSuccess(event) {
        let newRecordId = event.detail.id
        console.log(`${this.title} Id`, newRecordId)
        console.log('fields', this.fields)
        this.dispatchEvent(new CustomEvent('close',
            {
                detail: {message : 'Save', newRecordId:newRecordId }
            }
        ))
    }
}