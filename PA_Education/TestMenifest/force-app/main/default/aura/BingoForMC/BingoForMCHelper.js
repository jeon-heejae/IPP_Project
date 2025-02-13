/*
 * Created by skdus on 2023-11-07.
 */

({
    resetGame: function(component) {
        var isConfirmed = confirm("정말 초기화하시겠습니까?");

        if (isConfirmed) {
            var resetAction = component.get("c.resetGame");

            resetAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    console.log("Reset Game Success");
                } else if (state === "ERROR") {
                    console.log("Reset Game Error:::" + JSON.stringify(response.getError()));
                }
            });

            component.set("v.button", "CLICK");
            component.set("v.selectedMember", " ");
            component.set("v.selectedMembers", []);
            component.set("v.awards", []);
            component.set("v.buttonClicked", false);

            $A.enqueueAction(resetAction);
        }
    },

     getAwards: function(component) {
        var action = component.get("c.getAwards");

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("getAwards state::::" + state);
            if (state === "SUCCESS") {
                console.log("getAwards::::: " + response.getReturnValue());

                var newAwards = response.getReturnValue();
                var oldAwards = component.get("v.awards");

                if (newAwards.length !== oldAwards.length) {
                    this.showToast("success", "빙고!");
                }
                component.set("v.awards", response.getReturnValue());
            }else {
                console.error("Error fetching awards: " + state);
            }
        });

        this.getBingoLine(component);
        $A.enqueueAction(action);
    },

    getBingoLine: function(component) {
        var action = component.get("c.getBingoLine");

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("getBingoLine state::::" + state);
            if (state === "SUCCESS") {
                this.printBingoLine(component, event);
            }else {
                console.error("Error fetching awards: " + state);
            }
        });

        $A.enqueueAction(action);
    },

    printBingoLine: function(component, event) {
        var action = component.get("c.printBingoLine");

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("printBingoLine state::::" + state);

            if (response.getState() === "SUCCESS") {
                component.set("v.bingoLine", response.getReturnValue());
            }else {
                console.error("Error: " + state)
            }
        });

        $A.enqueueAction(action);
    },

    getPopularMembers: function(component) {
        var action = component.get("c.whoIsMostPopular");

        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log("getPopularMembers state::::" + state);

            if (state === "SUCCESS") {
                var popularMembers = response.getReturnValue();
                component.set("v.popular", popularMembers);
            } else {
                console.log("Error fetching popular members: " + state);
            }
        });

        $A.enqueueAction(action);

    },

    openModal : function(component, modal) {
        setTimeout(function() {
            component.set(modal, true);
            var end = Date.now() + (15 * 100);
            (function frame() {
                confetti({
                    particleCount: 10, angle: 60, spread: 50,
                    origin:{ x: 0.15, y : 0.65},
                    });
                confetti({
                    particleCount: 10, angle: 120, spread: 50,
                    origin:{ x: 0.85, y : 0.65},
                    });
                if (Date.now() < end) {
                    requestAnimationFrame(frame);
                }
            }());
        }, 100);
    },

    showToast : function(type, message) {
        var evt = $A.get("e.force:showToast");
        evt.setParams({
            key : "info_alt"
            , type : type
            , message : message
        });
        evt.fire();
    }

});