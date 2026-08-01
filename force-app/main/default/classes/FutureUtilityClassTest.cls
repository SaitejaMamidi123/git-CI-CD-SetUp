/**
 * @description Test class for FutureUtilityClass.
 *              Covers: changeUserRoleAsync, changeuserxx (@future methods)
 *
 *              Note: @future methods are executed synchronously within
 *              Test.startTest() / Test.stopTest() boundaries.
 *              A UserRole with a known developerName is required; this test
 *              queries for any existing role in the org to remain environment-agnostic.
 *              Target coverage: 100%
 */
@isTest
private class FutureUtilityClassTest {

    @isTest
    static void testChangeUserRoleAsync_assignsRoleToUser() {
        // Query any existing UserRole in the org
        List<UserRole> roles = [SELECT Id, DeveloperName FROM UserRole LIMIT 1];
        if (roles.isEmpty()) {
            // No roles in the org — create one
            UserRole newRole = new UserRole(Name = 'TestRole', DeveloperName = 'TestRole');
            insert newRole;
            roles = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'TestRole' LIMIT 1];
        }

        String roleDeveloperName = roles[0].DeveloperName;

        // Create a test user to assign the role to
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName          = 'Future',
            LastName           = 'TestUser',
            Alias              = 'ftest',
            Email              = 'futuretest@testorg.com',
            Username           = 'futuretest_' + System.currentTimeMillis() + '@testorg.com',
            ProfileId          = p.Id,
            TimeZoneSidKey     = 'America/New_York',
            LocaleSidKey       = 'en_US',
            EmailEncodingKey   = 'UTF-8',
            LanguageLocaleKey  = 'en_US'
        );
        insert testUser;

        Test.startTest();
        FutureUtilityClass.changeUserRoleAsync(testUser.Id, roleDeveloperName);
        Test.stopTest();

        User updatedUser = [SELECT Id, UserRoleId FROM User WHERE Id = :testUser.Id];
        System.assertEquals(roles[0].Id, updatedUser.UserRoleId,
            'UserRoleId should be updated by changeUserRoleAsync');
    }

    @isTest
    static void testChangeuserxx_assignsRoleToUser() {
        List<UserRole> roles = [SELECT Id, DeveloperName FROM UserRole LIMIT 1];
        if (roles.isEmpty()) {
            UserRole newRole = new UserRole(Name = 'TestRole2', DeveloperName = 'TestRole2');
            insert newRole;
            roles = [SELECT Id, DeveloperName FROM UserRole WHERE DeveloperName = 'TestRole2' LIMIT 1];
        }

        String roleDeveloperName = roles[0].DeveloperName;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            FirstName          = 'Future2',
            LastName           = 'TestUser2',
            Alias              = 'ftest2',
            Email              = 'futuretest2@testorg.com',
            Username           = 'futuretest2_' + System.currentTimeMillis() + '@testorg.com',
            ProfileId          = p.Id,
            TimeZoneSidKey     = 'America/New_York',
            LocaleSidKey       = 'en_US',
            EmailEncodingKey   = 'UTF-8',
            LanguageLocaleKey  = 'en_US'
        );
        insert testUser;

        Test.startTest();
        FutureUtilityClass.changeuserxx(testUser.Id, roleDeveloperName);
        Test.stopTest();

        User updatedUser = [SELECT Id, UserRoleId FROM User WHERE Id = :testUser.Id];
        System.assertEquals(roles[0].Id, updatedUser.UserRoleId,
            'UserRoleId should be updated by changeuserxx');
    }
}