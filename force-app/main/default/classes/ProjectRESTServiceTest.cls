@IsTest
public with sharing class ProjectRESTServiceTest {
    @TestSetup
    static void createSetupData(){
        Account acc = new Account(Name='Test Acc');
        insert acc;

        Opportunity opp1 = new Opportunity();
        opp1.AccountId = acc.Id;
        opp1.Name = 'Test Opp1';
        opp1.Type = 'New Project';
        opp1.Amount = 100;
        opp1.CloseDate = Date.today();
        opp1.StageName = 'Prospecting';
        insert opp1;
    }
    @IsTest
    public static void testRestResourceOk(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/ProjectRESTService/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        String opportunityId = [Select Id, Name From Opportunity LIMIT 1].Id;
        Test.startTest();
        String returnStatus = ProjectRESTService.postProjectData('','Test CLass Project', opportunityId , Date.Today(), Date.Today()+10,100, 'Billable');
        Test.stopTest();
        System.assertEquals('OK', returnStatus);

    }
    @IsTest
    public static void testRestResourceOther(){
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();             
        req.requestURI = '/services/apexrest/ProjectRESTService/';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;
        String opportunityId = '';
        Test.startTest();
        String returnStatus = ProjectRESTService.postProjectData('','Test CLass Project', opportunityId , Date.Today(), Date.Today()+10,100, 'Billable');
        Test.stopTest();
        System.assertNotEquals('OK', returnStatus);

    }
}