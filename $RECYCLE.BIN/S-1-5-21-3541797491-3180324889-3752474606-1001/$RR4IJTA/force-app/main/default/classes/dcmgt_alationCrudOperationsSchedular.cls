public with sharing class dcmgt_alationCrudOperationsSchedular implements Schedulable {
    
    public void execute(SchedulableContext sc)
    {
        Database.executeBatch((Database.Batchable<SObject>) 
        Type.forName('dcmgt_alationCrudOperations').newInstance(), 50);
        Database.executeBatch((Database.Batchable<SObject>) 
        Type.forName('dcmgt_alation_dataAsset_batchUpdate').newInstance(), 50);
    }
}