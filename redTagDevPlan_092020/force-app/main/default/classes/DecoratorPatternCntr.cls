public with sharing class DecoratorPatternCntr {
    
    public Map<ID, LeadWrapper> Id2LeadWrapperMap {get;set;}
    public List<Lead> leadsToContact {get;set;}
    public List<LeadWrapper> leadWrapList{get;set;}
    public Map<Id,LeadWrapper> Id2SelectedContactMap{get;set;}
    
    public DecoratorPatternCntr() { 

        Id currentUserId = UserInfo.getUserId();
        Id2LeadWrapperMap = new Map<ID, LeadWrapper>();
        leadWrapList = new List<LeadWrapper>();
        for (Lead leadRecord : [SELECT Id, Name, Phone, City, Last_Activity_Date__c, OwnerId,
                                (SELECT CreatedDate FROM Tasks
                                ORDER BY CreatedDate LIMIT 1) 
                                FROM Lead
                                WHERE Last_Activity_Date__c = LAST_N_MONTHS:6
                                AND OwnerId = :currentUserId
                                ORDER BY Name]) {
            if (leadRecord.Tasks.isEmpty() || leadRecord.Tasks[0].CreatedDate.date() != Date.today()) {
                System.debug('today ==>> ' + Date.today());
                leadWrapList.add(new LeadWrapper(leadRecord, false));
            }
        }

    }
    
    
    public PageReference createTasks() {

        Map<Id,LeadWrapper> Id2SelectedContactMap = new Map<Id, LeadWrapper>();
        System.debug('list -->> ' + leadWrapList);
        for (LeadWrapper wrp : leadWrapList) {
            if (wrp.isChecked) {
                Id2SelectedContactMap.put(wrp.leadRecord.ID, wrp);
            }
            if (wrp.isChecked == false && Id2SelectedContactMap.containsKey(wrp.leadRecord.ID)) {
                Id2SelectedContactMap.remove(wrp.leadRecord.ID);
            }
        }
        List<Task> newTasksToInsert = new List<Task>();
        for (LeadWrapper wrapper : Id2SelectedContactMap.values()) {
            if (wrapper.isChecked) {
                newTasksToInsert.add(new Task(
                    Status = 'In progress',
                    WhoID = wrapper.leadRecord.ID,
                    Subject = 'DecoratorPatternPage',
                    Type = 'Call',
                    OwnerID = wrapper.leadRecord.OwnerId,
                    ActivityDate = Date.today().addDays(5)
                ));
            }
        }
        try {
            insert newTasksToInsert;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The tasks were created successfully!'));
        } catch (Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was a problem with your request. please contact your admin.'));
            System.debug('Exception occured -->> ' + e.getStackTraceString());
            System.debug('Exception message -->> ' + e.getMessage());
        }
        return null;

    }
    
    public class LeadWrapper {
        public Boolean isChecked {get;set;}
        public Lead leadRecord {get;set;}
        
        public LeadWrapper(Lead leadRec, Boolean isSelected) {
            this.leadRecord = leadRec;
            this.isChecked = isSelected;
        }
    }
}