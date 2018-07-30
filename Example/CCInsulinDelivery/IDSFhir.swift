//
//  BGMFhir.swift
//  GlucoseOnFhir
//
//  Created by Kevin Tallevi on 7/11/17.
//  Copyright © 2017 eHealth Innovation. All rights reserved.
//

// swiftlint:disable function_body_length
// swiftlint:disable line_length
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable file_length

import Foundation
import SMART
import CCInsulinDelivery

public class IDSFhir {
    static let IDSFhirInstance: IDSFhir = IDSFhir()
    var patient: Patient?
    var device: Device?
    var deviceComponent: DeviceComponent?
    
    var givenName: FHIRString = "Lisa"
    var familyName: FHIRString = "Simpson"
    
    public func createPatient(callback: @escaping (_ patient: Patient, _ error: Error?) -> Void) {
        let patientName = HumanName()
        patientName.family = self.familyName
        patientName.given = [self.givenName]
        patientName.use = NameUse(rawValue: "official")
        
        let patientTelecom = ContactPoint()
        patientTelecom.use = ContactPointUse(rawValue: "work")
        patientTelecom.value = "4163404800"
        patientTelecom.system = ContactPointSystem(rawValue: "phone")
        
        let patientAddress = Address()
        patientAddress.city = "Toronto"
        patientAddress.country = "Canada"
        patientAddress.postalCode = "M5G2C4"
        patientAddress.line = ["585 University Ave"]
        
        let patientBirthDate = FHIRDate(string: DateTime.now.date.description)
        
        let patient = Patient()
        patient.active = true
        patient.name = [patientName]
        patient.telecom = [patientTelecom]
        patient.address = [patientAddress]
        patient.birthDate = patientBirthDate
        
        FHIR.fhirInstance.createPatient(patient: patient) { patient, error in
            if let error = error {
                print("error creating patient: \(error)")
            } else {
                self.patient = patient
            }
            callback(patient, error)
        }
    }
    
    public func searchForPatient(given: String, family: String, callback: @escaping FHIRSearchBundleErrorCallback) {
        print("IDSFhir: searchForPatient")
        let searchDict: [String:Any] = [
            "given": given,
            "family": family
        ]
        
        FHIR.fhirInstance.searchForPatient(searchParameters: searchDict) { (bundle, error) -> Void in
            if let error = error {
                print("error searching for patient: \(error)")
            }
            
            if bundle?.entry != nil {
                let patients = bundle?.entry?
                    .filter { return $0.resource is Patient }
                    .map { return $0.resource as! Patient }
                    
                self.patient = patients?[0]
            }
            
            callback(bundle, error)
        }
    }
    
    func searchForDevice(callback: @escaping FHIRSearchBundleErrorCallback) {
        let modelNumber = IDS.sharedInstance().modelNumber!.replacingOccurrences(of: "\0", with: "")
        let manufacturer = IDS.sharedInstance().manufacturerName!.replacingOccurrences(of: "\0", with: "")
        
        let encodedModelNumber: String = modelNumber.replacingOccurrences(of: " ", with: "+")
        let encodedMmanufacturer: String = manufacturer.replacingOccurrences(of: " ", with: "+")
        
        let searchDict: [String:Any] = [
            "model": encodedModelNumber,
            "manufacturer": encodedMmanufacturer,
            "identifier": IDS.sharedInstance().serialNumber!
        ]
        
        FHIR.fhirInstance.searchForDevice(searchParameters: searchDict) { (bundle, error) -> Void in
            if let error = error {
                print("error searching for device: \(error)")
            }
            
            if bundle?.entry == nil {
                print("device not found")
            } else {
                print("device found")
                
                if bundle?.entry != nil {
                    let devices = bundle?.entry?
                        .filter { return $0.resource is Device }
                        .map { return $0.resource as! Device }
                    
                    self.device = devices?[0]
                }
            }
            callback(bundle, error)
        }
    }
    
    func createDevice(callback: @escaping (_ device: Device, _ error: Error?) -> Void) {
        let modelNumber = IDS.sharedInstance().modelNumber!.replacingOccurrences(of: "\0", with: "")
        let manufacturer = IDS.sharedInstance().manufacturerName!.replacingOccurrences(of: "\0", with: "")
        let serialNumber = IDS.sharedInstance().serialNumber!.replacingOccurrences(of: "\0", with: "")
        
        let deviceCoding = Coding()
        deviceCoding.code = "4432"
        deviceCoding.system = FHIRURL.init("urn:iso:std:iso:11073:10101")
        deviceCoding.display = "MDC_DEV_PUMP"
        
        let deviceType = CodeableConcept()
        deviceType.coding = [deviceCoding]
        deviceType.text = "Infusion Pump"
        
        let deviceIdentifierTypeCoding = Coding()
        deviceIdentifierTypeCoding.system = FHIRURL.init("http://hl7.org/fhir/identifier-type")
        deviceIdentifierTypeCoding.code = "SNO"
        
        let deviceIdentifierType = CodeableConcept()
        deviceIdentifierType.coding = [deviceIdentifierTypeCoding]
        
        let deviceIdentifier = Identifier()
        deviceIdentifier.value = FHIRString.init(serialNumber)
        deviceIdentifier.type = deviceIdentifierType
        deviceIdentifier.system = FHIRURL.init("http://www.company.com/products/product/serial")
        
        let device = Device()
        device.status = FHIRDeviceStatus(rawValue: "available")
        device.manufacturer = FHIRString.init(manufacturer)
        device.model = FHIRString.init(modelNumber)
        device.type = deviceType
        device.identifier = [deviceIdentifier]
        
        FHIR.fhirInstance.createDevice(device: device) { device, error in
            if let error = error {
                print("error creating device: \(error)")
            } else {
                self.device = device
            }
            callback(device, error)
        }
    }
    
    public func createDeviceComponent(callback: @escaping (_ error: Error?) -> Void) {
        let deviceComponent = DeviceComponent()
        
        var productSpec = [DeviceComponentProductionSpecification]()
        var codingArray = [Coding]()
        
        //hardware revision
        if IDS.sharedInstance().hardwareVersion != nil {
            let hardwareRevision = DeviceComponentProductionSpecification()
            hardwareRevision.productionSpec = FHIRString.init(IDS.sharedInstance().hardwareVersion!)
        
            let hardwareRevisionCoding = Coding()
            hardwareRevisionCoding.code = "hardware-revision"
            hardwareRevisionCoding.display = "Hardware Revision"
            hardwareRevisionCoding.system = FHIRURL.init("http://hl7.org/fhir/codesystem-specification-type.html")!
            codingArray.append(hardwareRevisionCoding)
        
            let hardwareRevisionCodableConcept = CodeableConcept()
            hardwareRevisionCodableConcept.coding = codingArray
        
            hardwareRevision.specType = hardwareRevisionCodableConcept
            productSpec.append(hardwareRevision)
        }
        
        //software revision
        if IDS.sharedInstance().softwareVersion != nil {
            let softwareRevision = DeviceComponentProductionSpecification()
            softwareRevision.productionSpec = FHIRString.init(IDS.sharedInstance().softwareVersion!)
        
            let softwareRevisionCoding = Coding()
            softwareRevisionCoding.code = "software-revision"
            softwareRevisionCoding.display = "Software Revision"
            softwareRevisionCoding.system = FHIRURL.init("http://hl7.org/fhir/codesystem-specification-type.html")!
            codingArray.removeAll()
            codingArray.append(softwareRevisionCoding)
        
            let softwareRevisionCodableConcept = CodeableConcept()
            softwareRevisionCodableConcept.coding = codingArray
        
            softwareRevision.specType = softwareRevisionCodableConcept
            productSpec.append(softwareRevision)
        }
        
        //firmware revision
        if IDS.sharedInstance().firmwareVersion != nil {
            let firmwareRevision = DeviceComponentProductionSpecification()
            firmwareRevision.productionSpec = FHIRString.init(IDS.sharedInstance().firmwareVersion!.replacingOccurrences(of: "\0", with: ""))
            
            let firmwareRevisionCoding = Coding()
            firmwareRevisionCoding.code = "firmware-revision"
            firmwareRevisionCoding.display = "Firmware Revision"
            firmwareRevisionCoding.system = FHIRURL.init("http://hl7.org/fhir/codesystem-specification-type.html")!
            codingArray.removeAll()
            codingArray.append(firmwareRevisionCoding)
        
            let firmwareRevisionCodableConcept = CodeableConcept()
            firmwareRevisionCodableConcept.coding = codingArray
        
            firmwareRevision.specType = firmwareRevisionCodableConcept
            productSpec.append(firmwareRevision)
        }
        
        deviceComponent.productionSpecification = productSpec
        
        let deviceReference = Reference()
        deviceReference.reference = FHIRString.init("Device/\(String(describing: self.device!.id!))")
        deviceComponent.source = deviceReference
        
        // device identifier (serial number)
        let deviceIdentifier = Identifier()
        deviceIdentifier.value = FHIRString.init(IDS.sharedInstance().serialNumber!)
        
        var deviceIdentifierCodingArray = [Coding]()
        let deviceIdentifierCoding = Coding()
        deviceIdentifierCoding.code = FHIRString.init("serial-number")
        deviceIdentifierCoding.display = FHIRString.init("Serial Number")
        deviceIdentifierCoding.system = FHIRURL.init("http://hl7.org/fhir/codesystem-specification-type.html")!
        deviceIdentifierCodingArray.append(deviceIdentifierCoding)
        
        let deviceIdentifierType = CodeableConcept()
        deviceIdentifierType.coding = deviceIdentifierCodingArray
        deviceIdentifier.type = deviceIdentifierType
        deviceComponent.identifier = deviceIdentifier
        
        // type
        var deviceCodingArray = [Coding]()
        let deviceCoding = Coding()
        deviceCoding.code = FHIRString.init("69805005")
        deviceCoding.display = FHIRString.init("Insulin pump, device (physical object)")
        deviceCoding.system = FHIRURL.init("http://snomed.info/sct")!
        deviceCodingArray.append(deviceCoding)
        
        let deviceType = CodeableConcept()
        deviceType.coding = deviceCodingArray
        deviceComponent.type = deviceType
        
        FHIR.fhirInstance.createDeviceComponent(deviceComponent: deviceComponent) { deviceComponent, error in
            if let error = error {
                print("error creating device: \(error)")
            } else {
                self.deviceComponent = deviceComponent
            }
            callback(error)
        }
    }
    
    public func createMedicationRequest(amount: Float, duration: Int, onDate: Date, callback: @escaping (_ medicationRequest: MedicationRequest, _ error: Error?) -> Void) {
        let medicationRequest = MedicationRequest()

        medicationRequest.intent = MedicationRequestIntent.order
        
        let medicationCodeableConcept = CodeableConcept()
        let medicationCoding = Coding()
        medicationCoding.system = FHIRURL.init("http://snomed.info/sct")
        medicationCoding.code = FHIRString.init("25305005")
        medicationCoding.display = FHIRString.init("Long-acting insulin")
        medicationCodeableConcept.coding = [medicationCoding]
        medicationRequest.medicationCodeableConcept = medicationCodeableConcept
        
        let subjectReference = Reference()
        subjectReference.reference = FHIRString.init("Patient/\(String(describing: self.patient!.id!))")
        medicationRequest.subject = subjectReference
        
        let reasonCodeCodeableConcept = CodeableConcept()
        let reasonCodeCoding = Coding()
        reasonCodeCoding.system = FHIRURL.init("http://snomed.info/sct")
        reasonCodeCoding.code = FHIRString.init("473189005")
        reasonCodeCoding.display = FHIRString.init("On subcutaneous insulin for diabetes mellitus (finding)")
        reasonCodeCodeableConcept.coding = [reasonCodeCoding]
        medicationRequest.reasonCode = [reasonCodeCodeableConcept]
        
        let medicationRequestDispenseRequest = MedicationRequestDispenseRequest()
        
        let endDate = onDate.addingTimeInterval(Double(duration) * 60.0)
        let validityPeriod = Period()
        validityPeriod.start = DateTime(string: (onDate.iso8601))
        validityPeriod.end = DateTime(string: (endDate.iso8601))
        medicationRequestDispenseRequest.validityPeriod = validityPeriod
        
        medicationRequest.dispenseRequest = medicationRequestDispenseRequest
        medicationRequestDispenseRequest.numberOfRepeatsAllowed = 0
       
        let decimalRoundingBehaviour = NSDecimalNumberHandler(roundingMode:.plain,
                                                              scale: 2, raiseOnExactness: false,
                                                              raiseOnOverflow: false, raiseOnUnderflow:
                                                              false, raiseOnDivideByZero: false)
        
        let deliveryAmount = NSDecimalNumber(value: (amount.truncate(numberOfDigits: 2)))
        let quantity = Quantity.init()
        quantity.value = FHIRDecimal.init(String(describing: deliveryAmount.rounding(accordingToBehavior: decimalRoundingBehaviour)))
        quantity.unit = FHIRString.init("IU")
        quantity.system = FHIRURL.init("http://unitsofmeasure.org")
        quantity.code = FHIRString.init("IU")
        medicationRequestDispenseRequest.quantity = quantity
        
        let expectedDuration = Duration.init()
        expectedDuration.value = FHIRDecimal.init(String(describing: duration))
        expectedDuration.unit = FHIRString.init("min")
        expectedDuration.system = FHIRURL.init("http://unitsofmeasure.org")
        expectedDuration.code = FHIRString.init("min")
        medicationRequestDispenseRequest.expectedSupplyDuration = expectedDuration
        
        medicationRequest.dispenseRequest = medicationRequestDispenseRequest
        
        FHIR.fhirInstance.createMedicationRequest(medicationRequest: medicationRequest) { medicationRequest, error in
            if let error = error {
                print("error creating medication request: \(error)")
            } else {
                print(medicationRequest)
            }
            callback(medicationRequest, error)
        }
    }
    
    public func createMedicationAdministration(administeredAmount: Float, duration: Int, onDate: Date, prescriptionID: Int?, callback: @escaping (_ medicationAdministration: MedicationAdministration, _ error: Error?) -> Void) {
        let medicationAdministration = MedicationAdministration()
        
        let medicationCodeableConcept = CodeableConcept()
        let medicationCoding = Coding()
        medicationCoding.system = FHIRURL.init("http://snomed.info/sct")
        medicationCoding.code = FHIRString.init("25305005")
        medicationCoding.display = FHIRString.init("Long-acting insulin")
        medicationCodeableConcept.coding = [medicationCoding]
        medicationAdministration.medicationCodeableConcept = medicationCodeableConcept
        
        let subjectReference = Reference()
        subjectReference.reference = FHIRString.init("Patient/\(String(describing: self.patient!.id!))")
        medicationAdministration.subject = subjectReference
        
        let endDate = onDate.addingTimeInterval(Double(duration) * 60.0)
        let effectivePeriod = Period()
        effectivePeriod.start = DateTime(string: (onDate.iso8601))
        effectivePeriod.end = DateTime(string: (endDate.iso8601))
        medicationAdministration.effectivePeriod = effectivePeriod
        
        if let prescriptionID = prescriptionID {
            let prescriptionReference = Reference()
            prescriptionReference.reference = FHIRString.init("MedicationRequest/\(String(describing: prescriptionID))")
            medicationAdministration.prescription = prescriptionReference
        }
        
        let medicationDosage = MedicationAdministrationDosage()
        
        let medicationDosageCodeableConcept = CodeableConcept()
        let medicationDosageCoding = Coding()
        medicationDosageCoding.system = FHIRURL.init("http://snomed.info/sct")
        medicationDosageCoding.code = FHIRString.init("473189005")
        medicationDosageCoding.display = FHIRString.init("On subcutaneous insulin for diabetes mellitus (finding)")
        medicationDosageCodeableConcept.coding = [medicationDosageCoding]
        medicationDosage.route = medicationDosageCodeableConcept
        
        let decimalRoundingBehaviour = NSDecimalNumberHandler(roundingMode:.plain,
                                                              scale: 1, raiseOnExactness: false,
                                                              raiseOnOverflow: false, raiseOnUnderflow:
                                                              false, raiseOnDivideByZero: false)
        
        let dose = Quantity.init()
        let deliveredAmount = NSDecimalNumber(value: (administeredAmount.truncate(numberOfDigits: 2)))
        dose.value = FHIRDecimal.init(String(describing: deliveredAmount.rounding(accordingToBehavior: decimalRoundingBehaviour)))
        dose.unit = FHIRString.init("IU")
        dose.system = FHIRURL.init("http://unitsofmeasure.org")
        dose.code = FHIRString.init("IU")
        medicationDosage.dose = dose
        
        medicationAdministration.dosage = medicationDosage
        
        medicationAdministration.status = MedicationAdministrationStatus.completed

        FHIR.fhirInstance.createMedicationAdministration(medicationAdministration: medicationAdministration) { medicationAdministration, error in
            if let error = error {
                print("error creating medication administration: \(error)")
            } else {
                print(medicationAdministration)
            }
            callback(medicationAdministration, error)
        }
    }
}
