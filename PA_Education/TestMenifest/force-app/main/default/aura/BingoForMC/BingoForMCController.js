/*
 * Created by skdus on 2023-11-07.
 */
({
    doInit: function(component, event, helper) {
        component.set("v.button", "CLICK");
        helper.getAwards(component);
        helper.getPopularMembers(component);
        //helper.resetGame(component);

        var action = component.get("c.getSelectedMembers");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.selectedMembers", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    handleClick: function (component, event, helper) {
        var action = component.get("c.getAvailableMembers");
        var selectedMembers = component.get("v.selectedMembers");
        var button = component.get("v.button");

        if (button == "초기화") {
            console.log("button status::: reset");
            helper.resetGame(component);
        } else {
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log('Button Clicked::: ' + state);
                    var availableMembers = response.getReturnValue();
                    if (availableMembers.length > 0) {
                        var randomIndex = Math.floor(Math.random() * availableMembers.length);
                        var randomMember = availableMembers[randomIndex];

                        console.log("randomMember::::" + randomMember.Name);
                        console.log("push전 ::" + selectedMembers);
                        selectedMembers.push(randomMember);

                        component.set("v.selectedMembers", selectedMembers);
                        component.set("v.selectedMember", randomMember.Name);

                        var updateAction = component.get("c.updateBingoCell");
                        updateAction.setParams({
                            memberId: randomMember.Id
                        });

                        helper.getAwards(component);
                        $A.enqueueAction(updateAction);
                    } else {
                        component.set("v.button", "초기화");
                    }
                } else {
                    console.error("Error fetching available members: " + state);
                }
            });
            $A.enqueueAction(action);
            helper.openModal(component,"v.modalVisible");

        }
    },

    awardClick: function(component, event) {
        component.set("v.awardVisible", true);
    },

    closeModal: function(component, event, helper) {
        component.set("v.modalVisible", false);
    },

    getBingoBoard: function(component, event, helper) {
        component.set('v.bingoWinnerName',event.currentTarget.dataset.award);
        helper.openModal(component,"v.bingoModalVisible");
    }
});