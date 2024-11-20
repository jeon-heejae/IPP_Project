import { LightningElement } from 'lwc';

export default class childEducationSearch extends LightningElement {

    category='';
    program='';
    employee='';

    handleCategory(event) {
        this.category = event.target.value;
    }

    handleProgram(event) {
        this.program = event.target.value;
    }

    handleEmployee(event) {
        this.employee = event.target.value;
    }

    handleSearch() {
        const event=new CustomEvent(
            'getinfo',{
                detail:{
                    category:this.category,
                    program:this.program,
                    employee:this.employee
                }
            }
        );
        this.dispatchEvent(event);
    }

    handleRefresh(){
        this.category='';
        this.program='';
        this.employee='';

        const event=new CustomEvent(
            'refresh',{
                detail:{}
            }
        );

        this.dispatchEvent(event);

        this.clearInput();
    }

    clearInput(){
        this.category='';
        this.program='';
        this.employee='';
    }
}