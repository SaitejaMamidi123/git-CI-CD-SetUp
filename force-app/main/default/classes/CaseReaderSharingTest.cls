@isTest
public class CaseReaderSharingTest {
   @isTest
   static void testCaseVisibilityForUsers() {
       Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

       User user1 = new User(
           Alias = 'u1',
           Email = 'user1.caseviewer@example.com',
           EmailEncodingKey = 'UTF-8',
           LastName = 'UserOne',
           LanguageLocaleKey = 'en_US',
           LocaleSidKey = 'en_US',
           ProfileId = standardProfile.Id,
           TimeZoneSidKey = 'America/Los_Angeles',
           UserName = 'user1.caseviewer.' + System.currentTimeMillis() + '@example.com'
       );

       User user2 = new User(
           Alias = 'u2',
           Email = 'user2.caseviewer@example.com',
           EmailEncodingKey = 'UTF-8',
           LastName = 'UserTwo',
           LanguageLocaleKey = 'en_US',
           LocaleSidKey = 'en_US',
           ProfileId = standardProfile.Id,
           TimeZoneSidKey = 'America/Los_Angeles',
           UserName = 'user2.caseviewer.' + System.currentTimeMillis() + '@example.com'
       );

       insert new List<User>{ user1, user2 };

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