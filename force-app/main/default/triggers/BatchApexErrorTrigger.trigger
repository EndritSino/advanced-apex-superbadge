trigger BatchApexErrorTrigger on BatchApexErrorEvent (after insert) {

    List<BatchLeadConvertErrors__c> batchErrorList = new List<BatchLeadConvertErrors__c>();
    
    for (BatchApexErrorEvent batchEvent: Trigger.new) {
        batchErrorList.add(
        	new BatchLeadConvertErrors__c(
            	AsyncApexJobId__c = batchEvent.AsyncApexJobId,
                Records__c = batchEvent.JobScope,
                Stacktrace__c = batchEvent.StackTrace
            )
        );
    }
    
    insert batchErrorList;
}