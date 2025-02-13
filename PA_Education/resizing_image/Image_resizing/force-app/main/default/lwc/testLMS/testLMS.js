import { LightningElement,wire } from 'lwc';
import { publish,subscribe,unsubscribe,MessageContext } from 'lightning/messageService';
import msgChannel from '@salesforce/messageChannel/msgChannel__c';

export default class TestLMS extends LightningElement {
    contents;
    subscription=null;

    @wire(MessageContext)
    messageContext;

    handleInput(event){
        this.contents=event.target.value;
    }

    publishAction(){
        const payload={
            contents:this.contents
        };

        publish(this.messageContext,msgChannel,payload);
    }

    subscribeAction(){
        if(!this.subscription){
            this.subscription=subscribe(this.messageContext,msgChannel, (payload) =>{
                this.contents=payload.contents;
            })
        }
    }

    connectedCallback(){
        this.subscribeAction();
    }

    
    unsubscribe(event){
        if(this.subscription){
            unsubscribe(this.subscription);
            this.subscription=null;
        }
    }
}