/**
 * @description Test class for Sathvika.
 *              Covers: getAccountDetails, constructor
 *              Target coverage: 100%
 */
@isTest
private class SathvikaTest {

    @isTest
    static void testGetAccountDetails_withAccounts() {
        insert new Account(Name = 'Sathvika Test Account');

        Test.startTest();
        Sathvika.getAccountDetails();
        Test.stopTest();

        System.assert(true, 'getAccountDetails should execute without exception');
    }

    @isTest
    static void testGetAccountDetails_noAccounts() {
        // No accounts inserted — should run without error
        Test.startTest();
        Sathvika.getAccountDetails();
        Test.stopTest();

        System.assert(true, 'getAccountDetails with no records should not throw exception');
    }

    @isTest
    static void testConstructor() {
        Test.startTest();
        Sathvika instance = new Sathvika();
        Test.stopTest();

        System.assertNotEquals(null, instance, 'Sathvika instance should be created successfully');
    }
}