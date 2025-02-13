({
    fnInit:function(component,event,helper){
        
    },

    fnSave:function(component,event,helper){
        helper.handleSave(component,event,helper);
    },

    fnCancel:function(component,event,helper){
        $A.get("e.force:closeQuickAction").fire();
    },

    fnClick:function(component,event,helper){
        let textareaValue=component.get("v.textValue")
        console.log('value: '+textareaValue);

        let strSplit=textareaValue.split('\n');
        var step;
        let size=strSplit.length;
        var datas=[];

        for(step=0;step<size;step++){
            console.log(step+': ' +strSplit[step]);
            let splitWord=strSplit[step].split('\t');
           
            datas.push({
                ContactNo:splitWord[0],
                LastName:splitWord[1],
                Birthdate:splitWord[2],
                Address:splitWord[3],
                ParentPhone:splitWord[4],
                MobilePhone:splitWord[5]
            });
        }

        console.log('datas:'+datas);
        component.set("v.tableData",datas);
        component.set("v.ShowSpinner",true);
    }
})