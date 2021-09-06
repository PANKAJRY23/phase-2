import { LightningElement, track, api } from 'lwc';

export default class MutliSelectPicklist extends LightningElement {

    @api
    values = [];

    @api
    selectedvalues = [];
    @api
    multiselectedvalues

    @api
    picklistlabel = 'Status';

    @api
    isSelectedPillsSectionVisible = false


    showdropdown;

    handleleave() {
        
        let sddcheck= this.showdropdown;

        if(sddcheck){
            this.showdropdown = false;
            this.fetchSelectedValues();
        }
    }

    connectedCallback(){
        console.log('values', JSON.stringify(this.values));
        console.log('values', JSON.stringify(this.selectedvalues));
        if (this.multiselectedvalues) {
            this.selectedvalues=this.multiselectedvalues.split(';')
    }
        // this.values.forEach(element => element.selected 
        //                     ? this.selectedvalues.push(element.value) : '');
        console.log(this.selectedvalues);
        this.refreshOrginalList();
    }

    fetchSelectedValues() {
        
        this.selectedvalues = [];

        //get all the selected values
        this.template.querySelectorAll('c-dcmgt_picklist-value').forEach(
            element => {
                if(element.selected){
                    console.log(element.value);
                    this.selectedvalues.push(element.value);
                }
            }
        );

        //refresh original list
        this.refreshOrginalList();
    }

    refreshOrginalList() {
        //update the original value array to shown after close

        const picklistvalues = this.values.map(eachvalue => ({...eachvalue}));

        picklistvalues.forEach((element, index) => {
            if(this.selectedvalues.includes(element.value)){
                picklistvalues[index].selected = true;
            }else{
                picklistvalues[index].selected = false;
            }
        });

        this.values = picklistvalues;
        console.log('picklistvalues',this.values)
        console.log('selectedvalues',JSON.stringify(this.selectedvalues))
        this.dispatchEvent(new CustomEvent('selectedvalues', {
            detail : this.selectedvalues
        }));
    }

    handleShowdropdown(){
        let sdd = this.showdropdown;
        if(sdd){
            //this.showdropdown = false;
            this.fetchSelectedValues();
        }else{
            this.showdropdown = true;
        }
    }

    closePill(event){
        console.log(event.target.dataset.value);
        let selection = event.target.dataset.value;
        let selectedpills = this.selectedvalues;
        console.log(selectedpills);
        let pillIndex = selectedpills.indexOf(selection);
        console.log(pillIndex);
        this.selectedvalues.splice(pillIndex, 1);
        this.selectedvalues = [...this.selectedvalues]
        this.refreshOrginalList();
    }

    get selectedmessage() {
        return this.selectedvalues.length+ ' values are selected';
    }
}