public with sharing class TEST_TestUnlockedPackages implements Database.Batchable<SObject> {
    public Database.QueryLocator start(Database.BatchableContext objBc) {
        String query = 'Select Id,Status,Origin from  Case WHERE Status = \'Resolved\' AND Origin!=\'Email\'';
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext objBc, List<Case> lstCase){
        for(Case obj : lstCase){
            obj.Origin = 'Email';
        }
        Database.update(lstCase,false);
    }
    public void finish(Database.BatchableContext objBc){
        
    }
}
