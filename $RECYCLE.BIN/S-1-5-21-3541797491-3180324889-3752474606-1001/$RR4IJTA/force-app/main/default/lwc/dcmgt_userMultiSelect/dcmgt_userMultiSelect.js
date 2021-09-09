import { LightningElement,api,wire } from 'lwc';
import getOptions from '@salesforce/apex/dcmgt_UsersSelectionController.getAllUsers';
import getUsers from '@salesforce/apex/dcmgt_UsersSelectionController.getSelectedUsers';
import saveRecord from '@salesforce/apex/dcmgt_UsersSelectionController.saveRecord';
import getUsersMap from '@salesforce/apex/dcmgt_UsersSelectionController.getUsers';
import checkIfUserHasAssignedPermissionSet from '@salesforce/apex/dcmgt_UsersSelectionController.checkIfUserHasAssignedPermissionSet';



export default class Dcmgt_userMultiSelect extends LightningElement {
    @api recid;
    @api objname;
    @api fieldname;
    @api label;
    listOptions;
    selectedUsers=[];
    selectedUserNames;
    @api edit;
    readmode = false;
    isButtonVisible = false;
    isLoading = true;
    columns = [
        { label: 'Name', fieldName: 'name' },
    ];

    // get isButtonVisible()
    // {
    //     return (!this.readmode) && (!this.edit)
    // }

    // set isButtonVisible(readmode)
    // {

    // }


    @wire(checkIfUserHasAssignedPermissionSet)
    wiredcheckIfUserHasAssignedPermissionSet({ error, data }) {
        if (data!= null && data!=undefined) {
            this.readmode = data;
            this.isButtonVisible = (!this.readmode) && (!this.edit);
            this.error = undefined; 
        } else if (error) {
            this.error = error;
            this.checkIfUserHasAssignedPermissionSet = undefined;
        }
    }
    
    connectedCallback(){

       this.getDetails();
    }


    getDetails(){
        let usersMap = new Map();
        getOptions().then(result =>{
            this.listOptions = result;
        })
            getUsersMap().then(result2 =>{
                usersMap = result2;           
                getUsers({recordID:this.recid,fieldName:this.fieldname}).then(result1 =>{
                    this.selectedUsers = result1;
                    let tempList =[];
                    for(var i=0;i<this.selectedUsers.length;i++){
                        console.log('selected users',this.selectedUsers[i]);
                        tempList.push({name:usersMap[this.selectedUsers[i]]});
                    }
                    this.selectedUserNames = tempList;
                    console.log('selectedUserNames',this.selectedUserNames);
                    this.isLoading = false
                }).catch(getUsersError => {
                    this.isLoading = false
                    console.error('getUsers'+getUsersError)
                })         
            }) .catch(getUsersMapError => {
                this.isLoading = false
                console.error('getUsers'+getUsersMapError)
            })    
    }

    handleChange(event){
       this.selectedUsers = event.detail.value;
    }

    handleEdit(event){
        this.edit = true;
        this.isButtonVisible = (!this.readmode) && (!this.edit);
    }

    handleSave(event){
        saveRecord({recordID:this.recid,userIds:this.selectedUsers,objectName:this.objname,fieldName:this.fieldname}).then(result =>{
          this.getDetails();
          this.edit = false;  
          this.isButtonVisible = (!this.readmode) && (!this.edit);
        })
    }

    handleCancel(event){
        this.edit = false;
        this.isButtonVisible = (!this.readmode) && (!this.edit);
    }

}