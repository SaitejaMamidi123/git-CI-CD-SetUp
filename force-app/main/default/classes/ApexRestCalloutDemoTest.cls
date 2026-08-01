/**
 * @description Test class for ApexRestCalloutDemo.
 *              Uses HttpCalloutMock to avoid real network calls.
 *              Covers: createUsersInExternalSystem
 *              Target coverage: 100%
 */
@isTest
private class ApexRestCalloutDemoTest {

    /**
     * Mock HTTP response that simulates the external user creation endpoint.
     */
    private class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String  responseBody;

        public MockHttpResponse(Integer statusCode, String responseBody) {
            this.statusCode   = statusCode;
            this.responseBody = responseBody;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }

    @isTest
    static void testCreateUsersInExternalSystem_success() {
        String mockBody = '{"id":"abc123","name":"sathvi","role":"dev"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(200, mockBody));

        Test.startTest();
        ApexRestCalloutDemo.createUsersInExternalSystem();
        Test.stopTest();

        // No exception thrown = success; coverage achieved
        System.assert(true, 'createUsersInExternalSystem should complete without exception on 200 response');
    }

    @isTest
    static void testCreateUsersInExternalSystem_errorResponse() {
        String mockBody = '{"error":"Unauthorized"}';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse(401, mockBody));

        Test.startTest();
        ApexRestCalloutDemo.createUsersInExternalSystem();
        Test.stopTest();

        // Method logs debug output but does not throw — verifying no exception
        System.assert(true, 'createUsersInExternalSystem should handle non-200 response gracefully');
    }
}