@RestResource(urlMapping='/Project/*')
global class ProjectRESTService {
    @HttpPost
    global static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId, Date StartDate, Date EndDate, Double Amount, String Status){
        String str_return = 'OK';
        Savepoint savep = Database.setSavepoint();
        
        try {
            List<Opportunity> opps = [SELECT Id, DeliveryInstallationStatus__c FROM Opportunity WHERE Id = :OpportunityId];
            if (opps.size() == 0) {
                str_return = 'No related Opportunity';
            } else {
                opps[0].DeliveryInstallationStatus__c = 'In Progress';    
            }
            update opps;
                        
            Project__c proj = New Project__c();
            proj.Name = ProjectName;
            proj.ProjectRef__c = ProjectRef;
            proj.Start_Date__c = StartDate;
            proj.End_Date__c = EndDate;
            proj.Billable_Amount__c = Amount;
            proj.Status__c = Status;
            proj.Opportunity__c = OpportunityId;
            
			List<Project__c> list_proj = new List<Project__c>();
			list_proj.add(proj);
            upsert list_proj;
            
        } catch (Exception ex) {
            str_return = ex.getMessage();
        }
        
        if (str_return != 'OK'){ 
            Database.rollback(savep);
        }
        
        return str_return;
    }
}