trigger BulkStateTransitionOpportunityTrigger on Opportunity (before insert, before update, before delete, 
                                           after insert, after update, after delete, after undelete)  {
										
    if (Trigger.isBefore && Trigger.isUpdate) {
	    EventService.createEventWithVIPOppManager(Trigger.newMap, Trigger.oldMap);
	}								
}