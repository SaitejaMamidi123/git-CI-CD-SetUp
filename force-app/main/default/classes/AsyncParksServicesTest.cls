/**
 * @description Test class for AsyncParksServices (WSDL-generated async SOAP service).
 *              Covers: AsyncParksImplPort constructor and property assignment.
 *              Actual async web-service callouts require a Continuation context
 *              and cannot execute in Apex tests; structural coverage is provided here.
 *              Target coverage: 95%+
 */
@isTest
private class AsyncParksServicesTest {

    @isTest
    static void testAsyncParksImplPort_defaultEndpoint() {
        Test.startTest();
        AsyncParksServices.AsyncParksImplPort port = new AsyncParksServices.AsyncParksImplPort();
        Test.stopTest();

        System.assertNotEquals(null, port.endpoint_x, 'Default endpoint should be populated');
        System.assert(port.endpoint_x.startsWith('https://'), 'Endpoint should use HTTPS');
    }

    @isTest
    static void testAsyncParksImplPort_overrideProperties() {
        Test.startTest();
        AsyncParksServices.AsyncParksImplPort port = new AsyncParksServices.AsyncParksImplPort();
        port.timeout_x         = 60000;
        port.clientCertName_x  = 'TestCert';
        port.inputHttpHeaders_x = new Map<String, String>{'X-Custom' => 'value'};
        Test.stopTest();

        System.assertEquals(60000, port.timeout_x, 'Timeout should be assignable');
        System.assertEquals('TestCert', port.clientCertName_x, 'Cert name should be assignable');
        System.assertEquals('value', port.inputHttpHeaders_x.get('X-Custom'));
    }
}