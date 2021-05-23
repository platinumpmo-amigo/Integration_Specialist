public with sharing class ProjectCalloutService {
    public static String opportunityId;
    @InvocableMethod
    public static void PostOpportunityToPMS(List<Id> opportinityIds){
        opportunityId = opportinityIds.get(0);
        Opportunity opp = [SELECT Id, Name, CloseDate, Amount, Account.Name, StageName  FROM Opportunity WHERE Id =: opportunityId];
        ID jobID = System.enqueueJob(new QueueablePMSCall(opp));
    }
    public class QueueablePMSCall implements Queueable,Database.AllowsCallouts{
        private String jsonOpp;
        private Opportunity opportunityObject;
        public QueueablePMSCall(Opportunity opp)
        {
            opportunityObject=opp;
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('opportunityId', opp.Id);
            gen.writeStringField('opportunityName', opp.Name);
            gen.writeStringField('accountName', opp.account.Name);
            gen.writeDateField('closeDate', opp.closeDate);
            gen.writeNumberField('amount', opp.amount);
            
            gen.writeEndObject();            
            
            jsonOpp= gen.getAsString();
            System.debug('jsonOpp: ' + jsonOpp);
            
        }
        public void execute(QueueableContext context) {
            ServiceTokens__c token= ServiceTokens__c.getValues('ProjectServiceToken');
            System.debug(token.Token__c);
            
            // create an HTTPrequest object    
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint('callout:ProjectService/'+ token.Token__c);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(jsonOpp);    
            
            // create a new HTTP object
            Http http = new Http();
            HTTPResponse res = http.send(req);
            if (res.getStatusCode() != 201) {
                System.debug('Error from ' + req.getEndpoint() + ' : ' +res.getStatusCode() + ' ' + res.getStatus());
                
                Opportunity opportunity1=[Select Id, StageName FROM Opportunity Where Id =: opportunityObject.Id];
                opportunity1.StageName='Resubmit Project';
                update opportunity1;
                
            }
            else {
                Opportunity opportunity2=[Select Id, StageName FROM Opportunity Where Id =: opportunityObject.Id];
                opportunity2.StageName='Submitted Project';
                update opportunity2;
            }  
        }
    }
}