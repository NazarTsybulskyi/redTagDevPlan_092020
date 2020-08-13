public class EventService {

	public static void createEventWithVIPOppManager(Map<Id, Opportunity> newOpptyMap, Map<Id, Opportunity> oldOpptyMap) {
	    
		List<Event> eventsToInsert = new List<Event>();
		List<Opportunity> opptyListToManage = new List<Opportunity>();

		Id cfoRoleId = [Select Id, Name FROM UserRole WHERE DeveloperName = 'CFO' LIMIT 1].Id;
		User cfoUser = [Select Id, Name FROM User WHERE UserRoleId = :cfoRoleID LIMIT 1];
		Id vipOppRecTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('VIP').getRecordTypeId();
		
		Time eventStartTime = Time.newInstance(09,0,0,0); 
		
		for (Id oppItemId : newOpptyMap.keySet()) {
			if (newOpptyMap.get(oppItemId).StageName == 'Closed Won' &&
			    oldOpptyMap.get(oppItemId).StageName != 'Closed Won' &&
			    newOpptyMap.get(oppItemId).RecordTypeId == vipOppRecTypeId) {
				    opptyListToManage.add(newOpptyMap.get(oppItemId));
			}
		}

		for (Opportunity oppItem : opptyListToManage) {
			eventsToInsert.add(new Event(
			                             OwnerId = cfoUser.Id,
										 Type = 'Meeting',
			                             ActivityDate = Date.today().addDays(7),
			                             WhatId = oppItem.Id,
			                             Subject = 'Contract Meeting - ' + oppItem.Name,
										 IsAllDayEvent = true,
										 ActivityDateTime = Datetime.newInstanceGmt(Date.valueOf(Date.today().addDays(7)), eventStartTime)
			));		
		}
		insert eventsToInsert;
	}

}