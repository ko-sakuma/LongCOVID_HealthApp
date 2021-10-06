//
//  HealthStoreProtocol.swift
//  HealthApp
//
//  Created by Ko Sakuma on 09/09/2021.
//

import Foundation
import HealthKit

protocol HealthStoreProtocol {

    
    /**
     @method        isHealthDataAvailable
     @abstract      Returns YES if HealthKit is supported on the device.
     @discussion    HealthKit is not supported on all iOS devices.  Using HKHealthStore APIs on devices which are not
                    supported will result in errors with the HKErrorHealthDataUnavailable code.  Call isHealthDataAvailable
                    before attempting to use other parts of the framework.
     */
    static func isHealthDataAvailable() -> Bool

    
    /**
     @method        supportsHealthRecords
     @abstract      Returns YES if the Health Records feature is available.
     @discussion    The Health Records feature is not available in all regions but may be present in unsupported regions
                    if accounts have already been configured. This can change as accounts are modified during device
                    restore or synchronization.
                    Call supportsHealthRecords before attempting to request authorization for any clinical types.
     */
    @available(iOS 12.0, *)
    func supportsHealthRecords() -> Bool

    
    /**
     @method        authorizationStatusForType:
     @abstract      Returns the application's authorization status for the given object type.
     */
    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus

    
    /**
     @method        requestAuthorizationToShareTypes:readTypes:completion:
     @abstract      Prompts the user to authorize the application for reading and saving objects of the given types.
     @discussion    Before attempting to execute queries or save objects, the application should first request authorization
                    from the user to read and share every type of object for which the application may require access.
     
                    The request is performed asynchronously and its completion will be executed on an arbitrary background
                    queue after the user has responded.  If the user has already chosen whether to grant the application
                    access to all of the types provided, then the completion will be called without prompting the user.
                    The success parameter of the completion indicates whether prompting the user, if necessary, completed
                    successfully and was not cancelled by the user.  It does NOT indicate whether the application was
                    granted authorization.
     
                    To customize the messages displayed on the authorization sheet, set the following keys in your app's
                    Info.plist file. Set the NSHealthShareUsageDescription key to customize the message for reading data.
                    Set the NSHealthUpdateUsageDescription key to customize the message for writing data.
     */
    func requestAuthorization(toShare typesToShare: Set<HKSampleType>?, read typesToRead: Set<HKObjectType>?, completion: @escaping (Bool, Error?) -> Void)

    
    /**
     @method        getRequestStatusForAuthorizationToShareTypes:readTypes:completion:
     @abstract      Determines whether requesting authorization for the given types is necessary.
     @discussion    Applications may call this method to determine whether the user would be prompted for authorization if
                    the same collections of types are passed to requestAuthorizationToShareTypes:readTypes:completion:.
                    This determination is performed asynchronously and its completion will be executed on an arbitrary
                    background queue.
     */
    @available(iOS 12.0, *)
    func getRequestStatusForAuthorization(toShare typesToShare: Set<HKSampleType>, read typesToRead: Set<HKObjectType>, completion: @escaping (HKAuthorizationRequestStatus, Error?) -> Void)

    
    /**
     @method        handleAuthorizationForExtensionWithCompletion:
     @abstract      Prompts the user to authorize the application for reading and saving objects.
     @discussion    When an app extension calls requestAuthorizationToShareTypes:readTypes:completion:, the parent application
                    is responsible for calling this method to prompt the user to authorize the app and its extensions for the
                    types that the extension requested access to.
     
                    The request is performed asynchronously and its completion will be executed on an arbitrary background
                    queue after the user has responded.  The success parameter of the completion indicates whether prompting
                    the user, if necessary, completed successfully and was not cancelled by the user.  It does NOT indicate
                    whether the application was granted authorization.
     */
//    @available(iOS 9.0, *)
//    func handleAuthorizationForExtension(completion: @escaping (Bool, Error?) -> Void)
//
//
//    /**
//     @method        earliestPermittedSampleDate
//     @abstract      Samples prior to the earliestPermittedSampleDate cannot be saved or queried.
//     @discussion    On some platforms, only samples with end dates newer than the value returned by earliestPermittedSampleDate
//                    may be saved or retrieved.
//     */
//    @available(iOS 9.0, *)
//    func earliestPermittedSampleDate() -> Date
//
//
//    /**
//     @method        saveObject:withCompletion:
//     @abstract      Saves an HKObject.
//     @discussion    After an object is saved, on subsequent retrievals the sourceRevision property of the object will be set
//                    to the HKSourceRevision representing the version of the application that saved it.
//
//                    If the object has an HKObjectType property, then in order to save an object successfully the application
//                    must first request authorization to share objects with that type.  Saving an object with the same unique
//                    identifier as another object that has already been saved will fail.  When the application attempts to
//                    save multiple objects, if any single object cannot be saved then none of the objects will be saved.
//                    The operation will fail if the objects array contains samples with endDates that are older than the date
//                    returned by earliestPermittedSampleDate.
//
//                    This operation is performed asynchronously and the completion will be executed on an arbitrary
//                    background queue.
//     */
//    func save(_ object: HKObject, withCompletion completion: @escaping (Bool, Error?) -> Void)
//
//
//    /**
//     @method        saveObjects:withCompletion:
//     @abstract      Saves an array of HKObjects.
//     @discussion    See discussion of saveObject:withCompletion:.
//     */
//    func save(_ objects: [HKObject], withCompletion completion: @escaping (Bool, Error?) -> Void)
//
//
//    /**
//     @method        deleteObject:withCompletion:
//     @abstract      Deletes a single HKObject from the HealthKit database.
//     @discussion    See deleteObjects:withCompletion:.
//     */
//    func delete(_ object: HKObject, withCompletion completion: @escaping (Bool, Error?) -> Void)
//
//
//    /**
//     @method        deleteObjects:withCompletion:
//     @abstract      Deletes multiple HKObjects from the HealthKit database.
//     @discussion    An application may only delete objects that it previously saved.  This operation is performed
//                    asynchronously and the completion will be executed on an arbitrary background queue.
//     */
//    @available(iOS 9.0, *)
//    func delete(_ objects: [HKObject], withCompletion completion: @escaping (Bool, Error?) -> Void)
//
//
//    /**
//     @method        deleteObjectsOfType:predicate:withCompletion:
//     @abstract      Deletes all objects matching the given predicate from the HealthKit database.
//     @discussion    An application may only delete objects that it previously saved.  This operation is performed
//                    asynchronously and the completion will be executed on an arbitrary background queue.
//     */
//    @available(iOS 9.0, *)
//    func deleteObjects(of objectType: HKObjectType, predicate: NSPredicate, withCompletion completion: @escaping (Bool, Int, Error?) -> Void)
//
//
//    /**
//     @method        executeQuery:
//     @abstract      Begins executing the given query.
//     @discussion    After executing a query, the completion, update, and/or results handlers of that query will be invoked
//                    asynchronously on an arbitrary background queue as results become available.  Errors that prevent a
//                    query from executing will be delivered to one of the query's handlers.  Which handler the error will be
//                    delivered to is defined by the HKQuery subclass.
//
//                    Each HKQuery instance may only be executed once and calling this method with a currently executing query
//                    or one that was previously executed will result in an exception.
//
//                    If a query would retrieve objects with an HKObjectType property, then the application must request
//                    authorization to access objects of that type before executing the query.
//     */
    func execute(_ query: HKQuery)
//
//
//    /**
//     @method        stopQuery:
//     @abstract      Stops a query that is executing from continuing to run.
//     @discussion    Calling this method will prevent the handlers of the query from being invoked in the future.  If the
//                    query is already stopped, this method does nothing.
//     */
//    func stop(_ query: HKQuery)
//
//
//    /**
//     @method        splitTotalEnergy:startDate:endDate:resultsHandler:
//     @abstract      For the time period specified, this method calculates the resting and active energy parts of the total
//                    energy provided.
//     @discussion    This method uses the user's metrics like age, biological sex, body mass and height to determine
//                    their basal metabolic rate. If the application does not have authorization to access these characteristics
//                    or if the user has not entered their data then this method uses builtin default values.
//     */
//    @available(iOS, introduced: 9.0, deprecated: 11.0, message: "No longer supported")
//    func splitTotalEnergy(_ totalEnergy: HKQuantity, start startDate: Date, end endDate: Date, resultsHandler: @escaping (HKQuantity?, HKQuantity?, Error?) -> Void)
//
//
//    @available(iOS, introduced: 8.0, deprecated: 10.0)
//    func dateOfBirth() throws -> Date
//
//
//    /**
//     @method        dateOfBirthComponentsWithError:
//     @abstract      Returns the user's date of birth in the Gregorian calendar.
//     @discussion    Before calling this method, the application should request authorization to access objects with the
//                    HKCharacteristicType identified by HKCharacteristicTypeIdentifierDateOfBirth.
//     */
//    @available(iOS 10.0, *)
//    func dateOfBirthComponents() throws -> DateComponents
//
//
//    /**
//     @method        biologicalSexWithError:
//     @abstract      Returns an object encapsulating the user's biological sex.
//     @discussion    Before calling this method, the application should request authorization to access objects with the
//                    HKCharacteristicType identified by HKCharacteristicTypeIdentifierBiologicalSex.
//     */
//    func biologicalSex() throws -> HKBiologicalSexObject
//
//
//    /**
//     @method        bloodTypeWithError:
//     @abstract      Returns an object encapsulating the user's blood type.
//     @discussion    Before calling this method, the application should request authorization to access objects with the
//                    HKCharacteristicType identified by HKCharacteristicTypeIdentifierBloodType.
//     */
//    func bloodType() throws -> HKBloodTypeObject
//
//
//    /**
//     @method        fitzpatrickSkinTypeWithError:
//     @abstract      Returns an object encapsulating the user's Fitzpatrick skin type.
//     @discussion    Before calling this method, the application should request authorization to access objects with the
//                    HKCharacteristicType identified by HKCharacteristicTypeIdentifierFitzpatrickSkinType.
//     */
//    @available(iOS 9.0, *)
//    func fitzpatrickSkinType() throws -> HKFitzpatrickSkinTypeObject
//
//
//    /**
//     @method        wheelchairUseWithError:
//     @abstract      Returns an object encapsulating the user's wheelchair use.
//     @discussion    Before calling this method, the application should request authorization to access objects with the
//                    HKCharacteristicType identified by HKCharacteristicTypeIdentifierWheelchairUse.
//     */
//    @available(iOS 10.0, *)
//    func wheelchairUse() throws -> HKWheelchairUseObject
//
//
//    /**
//     @method        activityMoveModeWithError:
//     @abstract      Returns an object encapsulating the user's activity move mode
//     @discussion    Before calling this method, the application should request authorization to access objects with the
//                    HKCharacteristicType identified by HKCharacteristicTypeIdentifierActivityMoveMode.
//     */
//    @available(iOS 14.0, *)
//    func activityMoveMode() throws -> HKActivityMoveModeObject
//
//
//    /**
//     @method        addSamples:toWorkout:completion:
//     @abstract      Associates samples with a given workout.
//     @discussion    This will associate the given samples with the given workout. These samples will then be returned by a
//                    query that contains this workout as a predicate. If a sample is added that is not saved yet, then it will
//                    be saved for you. Note that the sample will be saved without an HKDevice.
//
//                    The workout provided must be one that has already been saved to HealthKit.
//     */
//    func add(_ samples: [HKSample], to workout: HKWorkout, completion: @escaping (Bool, Error?) -> Void)
//
//
//    /**
//     @method        startWatchAppWithWorkoutConfiguration:completion:
//     @abstract      Launches or wakes up the WatchKit app on the watch
//     @discussion    This method will launch the WatchKit app corresponding to the calling iOS application on the currently
//                    active Apple Watch. After launching, the handleWorkoutConfiguration: method on the WKExtensionDelegate
//                    protocol will be called with the HKWorkoutConfiguration as a parameter. The receiving Watch app can use
//                    this configuration object to create an HKWorkoutSession and start it with -startWorkoutSession:.
//     */
//    @available(iOS 10.0, *)
//    func startWatchApp(with workoutConfiguration: HKWorkoutConfiguration, completion: @escaping (Bool, Error?) -> Void)
//
//
//
//    /**
//     @method        enableBackgroundDeliveryForType:frequency:withCompletion:
//     @abstract      This method enables activation of your app when data of the type is recorded at the cadence specified.
//     @discussion    When an app has subscribed to a certain data type it will get activated at the cadence that is specified
//                    with the frequency parameter. The app is still responsible for creating an HKObserverQuery to know which
//                    data types have been updated and the corresponding fetch queries. Note that certain data types (such as
//                    HKQuantityTypeIdentifierStepCount) have a minimum frequency of HKUpdateFrequencyHourly. This is enforced
//                    transparently to the caller.
//     */
//    func enableBackgroundDelivery(for type: HKObjectType, frequency: HKUpdateFrequency, withCompletion completion: @escaping (Bool, Error?) -> Void)
//
//
//    func disableBackgroundDelivery(for type: HKObjectType, withCompletion completion: @escaping (Bool, Error?) -> Void)
//
//
//    func disableAllBackgroundDelivery(completion: @escaping (Bool, Error?) -> Void)
}

extension HKHealthStore: HealthStoreProtocol {}
