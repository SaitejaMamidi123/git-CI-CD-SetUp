/**
 * @description Test class for MovieSearchController.
 *              Covers: searchMovies - blank/null guard, valid search, LIMIT, bind-variable safety.
 *              Target coverage: 100%
 */
@isTest
private class MovieSearchControllerTest {

    @TestSetup
    static void setupTestData() {
        List<Movie__c> movies = new List<Movie__c>{
            new Movie__c(Name = 'Avatar'),
            new Movie__c(Name = 'Avatar 2'),
            new Movie__c(Name = 'Avengers'),
            new Movie__c(Name = 'Inception'),
            new Movie__c(Name = 'Interstellar')
        };
        insert movies;
    }

    // --- Blank / null guard ---

    @isTest
    static void testSearchMovies_blankInput_returnsEmpty() {
        Test.startTest();
        List<Movie__c> results = MovieSearchController.searchMovies('');
        Test.stopTest();
        System.assertNotEquals(null, results, 'Should return empty list, not null');
        System.assertEquals(0, results.size(), 'Blank search should return no results');
    }

    @isTest
    static void testSearchMovies_nullInput_returnsEmpty() {
        Test.startTest();
        List<Movie__c> results = MovieSearchController.searchMovies(null);
        Test.stopTest();
        System.assertNotEquals(null, results, 'Should return empty list, not null');
        System.assertEquals(0, results.size(), 'Null search should return no results');
    }

    @isTest
    static void testSearchMovies_whitespaceOnly_returnsEmpty() {
        Test.startTest();
        List<Movie__c> results = MovieSearchController.searchMovies('   ');
        Test.stopTest();
        System.assertEquals(0, results.size(), 'Whitespace-only search should return no results');
    }

    // --- Valid search ---

    @isTest
    static void testSearchMovies_validTerm_returnsMatches() {
        Test.startTest();
        List<Movie__c> results = MovieSearchController.searchMovies('Avatar');
        Test.stopTest();
        System.assertNotEquals(null, results, 'Results should not be null');
        System.assert(results.size() >= 1, 'Should find at least one Avatar movie');
    }

    @isTest
    static void testSearchMovies_partialMatch_returnsResults() {
        Test.startTest();
        List<Movie__c> results = MovieSearchController.searchMovies('ven');
        Test.stopTest();
        System.assert(results.size() >= 1, 'Partial match should find Avengers');
    }

    @isTest
    static void testSearchMovies_noMatch_returnsEmpty() {
        Test.startTest();
        List<Movie__c> results = MovieSearchController.searchMovies('ZZZNoMatchXXX');
        Test.stopTest();
        System.assertEquals(0, results.size(), 'Should return empty list when nothing matches');
    }

    // --- LIMIT enforcement ---

    @isTest
    static void testSearchMovies_respectsLimit10() {
        List<Movie__c> bulkMovies = new List<Movie__c>();
        for (Integer i = 0; i < 20; i++) {
            bulkMovies.add(new Movie__c(Name = 'LimitTest ' + i));
        }
        insert bulkMovies;
        Test.startTest();
        List<Movie__c> results = MovieSearchController.searchMovies('LimitTest');
        Test.stopTest();
        System.assert(results.size() <= 10, 'Results should be capped at LIMIT 10');
    }

    // --- SOQL injection safety ---

    @isTest
    static void testSearchMovies_soqlInjectionAttempt_treatedAsLiteral() {
        String injectionAttempt = 'xyz OR Name LIKE ' + '%';
        Test.startTest();
        List<Movie__c> results = MovieSearchController.searchMovies(injectionAttempt);
        Test.stopTest();
        System.assertEquals(0, results.size(), 'Injection-like string should return no results');
    }

    // --- Consistency ---

    @isTest
    static void testSearchMovies_repeatedCalls_consistentResults() {
        Test.startTest();
        List<Movie__c> r1 = MovieSearchController.searchMovies('Inception');
        List<Movie__c> r2 = MovieSearchController.searchMovies('Inception');
        Test.stopTest();
        System.assertEquals(r1.size(), r2.size(), 'Repeated calls with same term should return same count');
    }
}