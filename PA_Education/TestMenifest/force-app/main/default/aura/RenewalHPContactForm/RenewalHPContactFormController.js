/**
 * Created by kentakang on 2022/01/14.
 */

({
    fnInit : function(component, event, helper) {
        helper.getPicklist(component);
    },

    fnPhoneMasking: function (component, event, helper) {
        event.target.value = event.target.value.replace(/^(\d{3})(\d{4})(\d{4})$/, `$1-$2-$3`);
    },

    fnChangeEmail: function (component, event, helper) {
        var email = component.get("v.Email");

        if (email) {
            var provider = email.split('@')[1];

            if (provider) {
                component.set("v.Email", event.target.value + '@' + provider);
            } else {
                component.set("v.Email", event.target.value + '@naver.com');
            }
        } else {
            component.set("v.Email", event.target.value + '@naver.com');
        }
    },

    fnChangeEmailProvider: function (component, event, helper) {
        if (event.target.value === 'self') {
            component.set("v.emailSelf", true);
            return;
        }

        var provider = event.target.value;
        var email = component.get("v.Email");

        if (email) {
            component.set("v.Email", email.split("@")[0] + "@" + provider);
        } else {
            component.set("v.Email", "@" + provider);
        }
    },

    fnChangeLeadType: function (component, event, helper) {
        console.log('Change Lead Type', event.target.value);
        component.set("v.LeadType", event.target.value);
        console.log('Lead Type', component.get("v.LeadType"));
    },

    fnTermsOpen: function (component) {
        component.set("v.termsOpen", true);
    },

    fnTermsClose: function (component) {
        component.set("v.termsOpen", false);
    },

    fnSave: function (component, event, helper) {
        helper.doSave(component);
    }
});