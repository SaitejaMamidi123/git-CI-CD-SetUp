@isTest
public class CaseReaderSharingTest {
   @isTest
   static void testCaseVisibilityForUsers() {
       User user1 = [SELECT Id, Username FROM User WHERE Username = 'sathvikaperuka9088@gmail.com' LIMIT 1];
       User user2 = [SELECT Id, Username FROM User WHERE Username = 'sathvikaperuka12345@gmail.com' LIMIT 1];
       System.runAs(user1) {
           List<List<Case>> withShareResult1 = CaseReader.getCases();
           List<List<Case>> withoutShareResult1 = CaseReaderWithoutShare.getCases();
           Integer withShareCount1 = withShareResult1.isEmpty() ? 0 : withShareResult1[0].size();
           Integer withoutShareCount1 = withoutShareResult1.isEmpty() ? 0 : withoutShareResult1[0].size();
           System.debug('===== USER1 (' + user1.Username + ') =====');
           System.debug('CaseReader (with sharing) record count: ' + withShareCount1);
           System.debug('CaseReaderWithoutShare (without sharing) record count: ' + withoutShareCount1);
       }
       System.runAs(user2) {
           List<List<Case>> withShareResult2 = CaseReader.getCases();
           List<List<Case>> withoutShareResult2 = CaseReaderWithoutShare.getCases();
           Integer withShareCount2 = withShareResult2.isEmpty() ? 0 : withShareResult2[0].size();
           Integer withoutShareCount2 = withoutShareResult2.isEmpty() ? 0 : withoutShareResult2[0].size();
           System.debug('===== USER2 (' + user2.Username + ') =====');
           System.debug('CaseReader (with sharing) record count: ' + withShareCount2);
           System.debug('CaseReaderWithoutShare (without sharing) record count: ' + withoutShareCount2);
       }
   }
}