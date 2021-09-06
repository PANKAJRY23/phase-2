/*
        Name            :     dcmgt_SchedulerForCallEmailBatchCls 
        Date            :     17 Aug 2021
        Author          :     IA
        Description     :     We are creating this class to Email notification Batch classes.
*/
public class dcmgt_SchedulerForCallEmailBatchCls implements Schedulable{
    
    public void execute(SchedulableContext sc){
        
        Database.executeBatch(new dcmgt_BatchToSendEmailPendingImplement(), 1);
        
        Database.executeBatch(new dcmgt_BatchToSendEmailAfterImplement(), 1);
        
        Database.executeBatch(new dcmgt_BatchToSendRejectEmail(), 1);
        
        Database.executeBatch(new dcmgt_secondApproverEmailsBatchArticle(), 500);

        Database.executeBatch(new dcmgt_secondApproverEmailsBatchDataAsset(), 500);
    }
}