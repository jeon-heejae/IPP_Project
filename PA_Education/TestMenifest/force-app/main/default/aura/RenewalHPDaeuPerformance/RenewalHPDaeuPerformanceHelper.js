({
    getPerformances : function(component) {
        const action = component.get("c.getPerformances");


        action.setCallback(this, function(response) {
            const state = response.getState();

            if (state === "SUCCESS") {
                try{
                    const returnValue = response.getReturnValue();

                    if(returnValue) {
                        console.log(returnValue);

                        const el = component.find("chart").getElement();
                        const ctx = el.getContext("2d");
                        const labels = returnValue.map(function (item) {
                            return item.fm_Year__c;
                        });
                        const salesData = returnValue.map(function (item) {
                            return item.Sales__c / 1000000;
                        });
                        const headData = returnValue.map(function (item) {
                            return item.HeadCount__c;
                        })

                        new Chart(ctx, {
                            type: 'bar',
                            data: {
                                labels: labels,
                                datasets: [
                                    {
                                        label: '매출 (억)',
                                        backgroundColor: '#58C3F5',
                                        data: salesData,
                                        borderRadius: 4
                                    },
                                    {
                                        label: '조직원 수 (명)',
                                        backgroundColor: '#EFEFEF',
                                        data: headData,
                                        borderRadius: 4
                                    }
                                ]
                            }
                        });
                    }
                }catch(e){
                    component.set("v.isReady", true);
                    console.log('error : ' + e.message);
                }
            } else if(state === "ERROR") {
                const errors = response.getError();

                if(errors) {
                    if(errors[0] && errors[0].message) {
                        console.log("error", errors[0].message);
                    }
                } else {
                    console.log("error", "Unknown error");
                }
            }
        });

        $A.enqueueAction(action);
    }
});