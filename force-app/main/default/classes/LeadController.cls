public class LeadController {
    
    public static void leadUpdateOnScore(List<Lead> newLeads){
        
            for(Lead lds : newLeads){
                
                if(lds.Lead_Score__c != 0 &&lds.Lead_Score__c >= 80){
                    lds.Status = 'Qualified';
                }else if(lds.Lead_Score__c < 80) {
                    lds.Status = 'Open - Not Contacted';
                }
            }
        
    }

}