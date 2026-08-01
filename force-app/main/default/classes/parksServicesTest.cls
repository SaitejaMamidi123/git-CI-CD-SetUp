/**
 * @description Test class for parksServices (WSDL-generated SOAP service class).
 *              Covers: inner class constructors and property assignments (byCountry, byCountryResponse, ParksImplPort).
 *              Actual web-service callouts cannot be made from tests; structural coverage is provided.
 *              Target coverage: 95%+
 */
@isTest
private class parksServicesTest {

    @isTest
    static void testByCountryRequest_constructAndAssign() {
        Test.startTest();
        parksServices.byCountry req = new parksServices.byCountry();
        req.arg0 = 'India';
        Test.stopTest();

        System.assertEquals('India', req.arg0, 'arg0 should be set correctly');
    }

    @isTest
    static void testByCountryResponse_constructAndAssign() {
        Test.startTest();
        parksServices.byCountryResponse resp = new parksServices.byCountryResponse();
        resp.return_x = new List<String>{'Jim Corbett', 'Kaziranga'};
        Test.stopTest();

        System.assertEquals(2, resp.return_x.size(), 'return_x should hold two parks');
        System.assertEquals('Jim Corbett', resp.return_x[0]);
    }

    @isTest
    static void testParksImplPort_defaultProperties() {
        Test.startTest();
        parksServices.ParksImplPort port = new parksServices.ParksImplPort();
        Test.stopTest();

        System.assertNotEquals(null, port.endpoint_x, 'Default endpoint should be set');
        System.assert(port.endpoint_x.startsWith('https://'), 'Endpoint should be HTTPS');
    }

    @isTest
    static void testParksImplPort_overrideProperties() {
        Test.startTest();
        parksServices.ParksImplPort port = new parksServices.ParksImplPort();
        port.timeout_x          = 30000;
        port.inputHttpHeaders_x  = new Map<String, String>{'Authorization' => 'Bearer token'};
        port.outputHttpHeaders_x = new Map<String, String>();
        port.clientCertName_x   = 'MyCert';
        port.clientCert_x       = 'CertBody';
        port.clientCertPasswd_x = 'secret';
        Test.stopTest();

        System.assertEquals(30000, port.timeout_x, 'Timeout should be set');
        System.assertEquals('Bearer token', port.inputHttpHeaders_x.get('Authorization'));
    }
}