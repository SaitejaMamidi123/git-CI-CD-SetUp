public without sharing class CaseReaderWithoutShare {
    
    @InvocableMethod (label='get User without sharing Cases')
    public static List<List<Case>> getCases(){
        List<Case> caseList = Database.query('SELECT Id, CaseNumber, Subject, Status, CreatedDate FROM Case ORDER BY CreatedDate DESC LIMIT 10', AccessLevel.SYSTEM_MODE);
      
        return new List<List<Case>> { caseList };
    }
}