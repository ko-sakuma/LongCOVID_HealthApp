
// NOTE: FakeHealthStore was created for unit testing purpose.

import HealthKit

class FakeHealthStore: HealthStoreProtocol {
    
    
    
    static var _isHealthDataAvailable = true
    static func isHealthDataAvailable() -> Bool {
        _isHealthDataAvailable
    }
    
    var _supportsHealthRecords = true
    func supportsHealthRecords() -> Bool {
        return _supportsHealthRecords
    }
    
    var _authorizationStatus: HKAuthorizationStatus = .notDetermined
    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        return _authorizationStatus
    }
    
    var _requestAuthorization = false
    var _requestAuthorizationError: Error?
    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping (Bool, Error?) -> Void) {
        completion(_requestAuthorization, _requestAuthorizationError)
    }
    
    var _getRequestStatusForAuthorization: HKAuthorizationRequestStatus = .shouldRequest
    var _getRequestStatusForAuthorizationError: Error?
    func getRequestStatusForAuthorization(toShare typesToShare: Set<HKSampleType>, read typesToRead: Set<HKObjectType>, completion: @escaping (HKAuthorizationRequestStatus, Error?) -> Void) {
        completion(_getRequestStatusForAuthorization, _getRequestStatusForAuthorizationError)
    }
    
//    func handleAuthorizationForExtension(completion: @escaping (Bool, Error?) -> Void) {
//        <#code#>
//    }
//
//    func earliestPermittedSampleDate() -> Date {
//        <#code#>
//    }
//
//    func save(_ object: HKObject, withCompletion completion: @escaping (Bool, Error?) -> Void) {
//        <#code#>
//    }
//
//    func save(_ objects: [HKObject], withCompletion completion: @escaping (Bool, Error?) -> Void) {
//        <#code#>
//    }
//
//    func delete(_ object: HKObject, withCompletion completion: @escaping (Bool, Error?) -> Void) {
//        <#code#>
//    }
//
//    func delete(_ objects: [HKObject], withCompletion completion: @escaping (Bool, Error?) -> Void) {
//        <#code#>
//    }
//
//    func deleteObjects(of objectType: HKObjectType, predicate: NSPredicate, withCompletion completion: @escaping (Bool, Int, Error?) -> Void) {
//        <#code#>
//    }
//
    func execute(_ query: HKQuery) {
        fatalError()
    }
//
//    func stop(_ query: HKQuery) {
//        <#code#>
//    }
//
//    func splitTotalEnergy(_ totalEnergy: HKQuantity, start startDate: Date, end endDate: Date, resultsHandler: @escaping (HKQuantity?, HKQuantity?, Error?) -> Void) {
//        <#code#>
//    }
//
//    func dateOfBirth() throws -> Date {
//        <#code#>
//    }
//
//    func dateOfBirthComponents() throws -> DateComponents {
//        <#code#>
//    }
//
//    func biologicalSex() throws -> HKBiologicalSexObject {
//        <#code#>
//    }
//
//    func bloodType() throws -> HKBloodTypeObject {
//        <#code#>
//    }
//
//    func fitzpatrickSkinType() throws -> HKFitzpatrickSkinTypeObject {
//        <#code#>
//    }
//
//    func wheelchairUse() throws -> HKWheelchairUseObject {
//        <#code#>
//    }
//
//    func activityMoveMode() throws -> HKActivityMoveModeObject {
//        <#code#>
//    }
//
//    func add(_ samples: [HKSample], to workout: HKWorkout, completion: @escaping (Bool, Error?) -> Void) {
//        <#code#>
//    }
//
//    func startWatchApp(with workoutConfiguration: HKWorkoutConfiguration, completion: @escaping (Bool, Error?) -> Void) {
//        <#code#>
//    }
//
//    func enableBackgroundDelivery(for type: HKObjectType, frequency: HKUpdateFrequency, withCompletion completion: @escaping (Bool, Error?) -> Void) {
//        <#code#>
//    }
//
//    func disableBackgroundDelivery(for type: HKObjectType, withCompletion completion: @escaping (Bool, Error?) -> Void) {
//        <#code#>
//    }
//
//    func disableAllBackgroundDelivery(completion: @escaping (Bool, Error?) -> Void) {
//        <#code#>
//    }
    
    
}
