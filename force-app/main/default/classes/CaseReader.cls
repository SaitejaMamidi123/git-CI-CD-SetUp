public with sharing class CaseReader {
    
    @InvocableMethod (label='get User with share Cases')
    public static List<List<Case>> getCases(){
        List<case> caseList = [Select id, CaseNumber,Subject,Status, Createddate from Case order by Createddate desc limit 10];
        
        return new List<List<Case>> { caseList };
    }

}