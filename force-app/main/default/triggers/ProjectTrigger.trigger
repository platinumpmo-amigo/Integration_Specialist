trigger ProjectTrigger on Project__c (after update) {
    //Call Apex Method
    if(trigger.isAfter && trigger.isUpdate){
        BillingCalloutService.callBillingService(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
    }
}