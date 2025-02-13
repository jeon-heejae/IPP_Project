({
	init : function(component, event, helper) {
		helper.getNotice(component);
		$A.util.addClass(component.find("notice-modal"), "active");
		let isEnglish = event.getParam('isEnglish')
		isEnglish ? component.set('v.isEnglish', isEnglish) :
			component.set('v.isEnglish', false)

		if (['iPad Simulator',
			'iPhone Simulator',
			'iPod Simulator',
			'iPad',
			'iPhone',
			'iPod'].includes(navigator.platform) || (navigator.userAgent.includes("Mac"))) {
			$A.util.addClass(component.find("video"), "ios");
			$A.util.addClass(component.find("iOSVideo"), "ios");
		}
	},
	// showNoticeModal: function (component, event, helper) {
	//     helper.getRecordById(component, event.target.id);
	//     $A.util.addClass(component.find("modal"), "active");
	// },
	hideNoticeModal: function (component, event) {
		if (event.target == event.currentTarget) {
			component.set("v.noticeShow", false);
		}
	},
	showNoticeModal: function (component, event) {
		console.log("showNoticeModal", event.target.id);
		let idxValue = event.target.id.split("-");
		let objNoticeItem = component.get("v.listNoticeItem")[parseInt(idxValue[1])];
		console.log('Selected objNoticeItem', objNoticeItem);
		component.set("v.noticeItem", objNoticeItem);
		component.set("v.noticeShow", true);
	}
})