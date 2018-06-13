# CCInsulinDelivery

CCInsulinDelivery is an iOS library designed to collect data from an insulin pump that complies with the insulin delivery service v1.0 specification. A sample sensor implementation is provided in the BLEIDSSim project (https://github.com/ehealthinnovation/BLEIDSSim)

A sample collector application is included to show usage of the CCInsulinDelivery library, which consists of data collection, a sample insulin delivery session, and optional uploading of data to a FHIR (DSTU3) server.

##### Uploading records to a FHIR server
Records can be uploaded to a FHIR server from within the CCInsulinDelivery application. Selecting a FHIR server from the main screen, and then starting a session will automatically begin uploading records as they are generated.

##### Discovery of local FHIR server

Data can be uploaded to either the UHN 'fhirtest' server, or a FHIR server running on the same network as the iOS device. On the initial screen, tap "Select FHIR Server", and select from the list of discovered FHIR servers.

To run your own FHIR server, download hapi-fhir-cli from http://hapifhir.io/doc_cli.html. Extract the archive and run the server from a terminal window using the command 'hapi-fhir-cli run-server'

The FHIR server must advertise itself on the network to be discovered by the sample application. From a terminal window run the following command 'dns-sd -R "fhir" _http._tcp . 8080'

## Author

ktallevi, ktallevi@ehealthinnovation.org
