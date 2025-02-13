trigger Opportunity_Remark_Update on task ( before insert, 	before update, 	after insert, 	after update, 	after delete, 	after undelete ) {

		if (Trigger.isBefore) {
	    	Opportunity_Remark_Update_tr.DoOpportunityRemarkUpdate(Trigger.new);
		} else if (Trigger.isAfter) {
	    	//call handler.after method
	    
		}
}