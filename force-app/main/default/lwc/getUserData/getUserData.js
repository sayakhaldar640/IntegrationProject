import { LightningElement, track } from 'lwc';
import getUserData from '@salesforce/apex/RandomUserUtil.getUserData';

export default class GetUserData extends LightningElement {

    @track userdata;
    picture;
    name;
    email;
    phone;

    connectedCallback(){
        getUserData()
        .then((result) => {
            this.userdata = JSON.parse(JSON.stringify(result.results[0]));
            console.log(this.userdata);
            this.picture = this.userdata.Picture.large;
            this.name = this.userdata.Name.first + ' ' + this.userdata.Name.last;
            this.email = this.userdata.email;
            this.phone = this.userdata.phone;
        })
        .catch((error)=>{
            console.log('Error Message: ');
        })
    }

}