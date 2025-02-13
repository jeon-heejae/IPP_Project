import { LightningElement } from 'lwc';

export default class childEducationSearch extends LightningElement {

    category='';
    program='';
    employee='';

    handleCategory(event) {
        this.category = event.target.value;
        if (!this.category) {
            this.handleRefresh(); 
        }
    }

    handleProgram(event) {
        this.program = event.target.value;
        if (!this.program) {
            this.handleRefresh(); 
        }
    }

    handleEmployee(event) {
        this.employee = event.target.value;
        if (!this.employee) {
            this.handleRefresh(); 
        }
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
    
    handleKeyDown(event) {
        if (event.key === 'Enter') {
            this.handleSearch();
        }
    }
}