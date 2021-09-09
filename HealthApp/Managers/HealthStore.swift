
// NOTE: Creating this file so that I can wrap around all the features of HKHealthStore inside the HealthStore class

import Foundation
import HealthKit
import UIKit
import UserNotifications


class HealthStore {

    var healthStore: HKHealthStore?
    var query: HKStatisticsCollectionQuery?
    var sampleQuery: HKSampleQuery?

    static let shared = HealthStore()

    private init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        }
    }

    // MARK: - REQUEST AUTHORISATION FROM USER TO ACCESS HEALTH DATA
    func requestAuthorization(completion: @escaping (Bool) -> Void) {

        // stepType: gets a stepCount data
        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!

        // heartRateType: gets a heart rate data
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!

        // healthStore: get access to HealthStore
        guard let healthStore = self.healthStore else { return completion(false) }

        // Request permission to read stepType & heartRateType
        // passing an empty array for toShare because this app does not need to share.
        healthStore.requestAuthorization(toShare: [], read: [heartRateType, stepType]) { (success, _) in
            completion(success)
        }
    }

    // MARK: - CALCULATE STEPCOUNTS OVER THE PAST 7 DAYS
    func calculateSteps(completion: @escaping (HKStatisticsCollection?) -> Void) {

        // stepType: gets the step count data from HealthKit
        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!

        // startDate: defines the past 2 years (730 days)
        let startDate = Calendar.current.date(byAdding: .day, value: -730, to: Date())

        // anchorDate: defines what time a day actually starts at. mondayAt12AM() is my func, defined above.
        let anchorDate = Date.mondayAt12AM()

        // daily: defines how a date should be considered (i.e. 1 date = 1 day in this app)
        let daily = DateComponents(day: 1)

        // predicate: defines that the sample's start time and end time must fall within the desirable period
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        // query = create a statistics collection query that would include what I want, as defined above.
        // NOTE: HKStatisticsCollectionQuery is useful for graphs; but HKStatisticsQuery, not as much.
        query = HKStatisticsCollectionQuery(quantityType: stepType, quantitySamplePredicate: predicate,
                                            options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: daily)

//        // outputs the result of the query
        query!.initialResultsHandler = {_, statisticsCollection, _ in
            completion(statisticsCollection)
        }

//        // if health data is available & query contains value, then execute the query
        if let healthStore = healthStore, let query =
            self.query {
            healthStore.execute(query)
        }

    }

        // MARK: - CALCULATE HEART RATE OVER THE PAST 7 DAYS
    func calculateHeartRate(completion: @escaping ([HKSample]) -> Void) {

        // heartRateType: gets a heart rate data
        let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        print(heartRateType)

        // startDate: defines the past 1 year (365 days)
        let startDate = Calendar.current.date(byAdding: .day, value: -365, to: Date())

        // anchorDate: defines what time a day actually starts at. mondayAt12AM() is my func, defined above.
        let anchorDate = Date.mondayAt12AM()

        // daily: defines how a date should be considered (i.e. 1 date = 1 day in this app)
        let daily = DateComponents(day: 1)

        // predicate: defines that the sample's start time and end time must fall within the desirable period
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        // query = create a statistics collection query that would include what I want, as defined above.
        // NOTE: HKStatisticsCollectionQuery is useful for graphs; but HKStatisticsQuery, not as much.
        sampleQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: -1, sortDescriptors: nil, resultsHandler: { (_: HKSampleQuery, samples: [HKSample]?, _: Error?) in
            completion(Array(samples!))
        })

//        sampleQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: -1, sortDescriptors: nil, resultsHandler: { (_: HKSampleQuery, samples: [HKSample]?, _: Error?) in
//            completion(Array(samples?.prefix(1000) ?? []))
//        })

        // if health data is available & query contains value, then execute the query
        if let healthStore = healthStore, let query =
            self.sampleQuery {
            healthStore.execute(query)
        }
//        print(self.sampleQuery) // it returns nothing at the moment

    }

    // MARK: - BACKGROUND TASK, GETTING THE HEART RATE DATA
    private var backgroundHeartRateMonitoringTask: UIBackgroundTaskIdentifier?
    private var backgroundHeartRateMonitoringTaskRefreshTimer: Timer?
    private var continuousHeartRateMonitoringQuery: HKAnchoredObjectQuery?
    var maximumBPM = 100  // SETTING THIS VALUE AS DEFAULT. IT IS @Observable from CreateTaskView.swift
    private let notificationExpirationDuration: TimeInterval = 60 // 1 min

    func startBackgroundHeartRateMonitoring() {

        endBackgroundHeartRateMonitoringIfNeeded()
        backgroundHeartRateMonitoringTask = UIApplication.shared.beginBackgroundTask(withName: "backgroundHeartRateMonitoringTask",
                 expirationHandler: {
                    self.endBackgroundHeartRateMonitoringIfNeeded()
                 })

        backgroundHeartRateMonitoringTaskRefreshTimer?.invalidate()
        backgroundHeartRateMonitoringTaskRefreshTimer = Timer.scheduledTimer(withTimeInterval: 2.8,
                                                         repeats: false,
                                                         block: { (_: Timer) in
                                                            self.startBackgroundHeartRateMonitoring()
                                                         })

        if continuousHeartRateMonitoringQuery == nil {

            let heartRateType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!

            let predicate = HKQuery.predicateForSamples(withStart: Date().addingTimeInterval(-20), end: nil, options: .strictStartDate)// Starts a new query with the samples 20 seconds old and newer

            continuousHeartRateMonitoringQuery = HKAnchoredObjectQuery(type: heartRateType,
               predicate: predicate,
               anchor: nil,
               limit: HKObjectQueryNoLimit,
               resultsHandler: { (_: HKAnchoredObjectQuery,
                                  samples: [HKSample]?,
                                  _: [HKDeletedObject]?,
                                  _: HKQueryAnchor?,
                                  _: Error?) in
                self.handleHeartRateMonitoringQueryResponse(samples: samples)
               })

            continuousHeartRateMonitoringQuery?.updateHandler = { (_: HKAnchoredObjectQuery,
                                                                   samples: [HKSample]?,
                                                                   _: [HKDeletedObject]?,
                                                                   _: HKQueryAnchor?,
                                                                   _: Error?) in
              self.handleHeartRateMonitoringQueryResponse(samples: samples)
            }

            healthStore?.execute(continuousHeartRateMonitoringQuery!)
        }
    }

    private func handleHeartRateMonitoringQueryResponse(samples: [HKSample]?) {
        if let samples = samples {
            if self.shouldScheduleHeartRateMonitoringNotification() {
                let heartRates = samples.compactMap { HeartRate(sample: $0) }
                for heartRate in heartRates {
                    if heartRate.count >= self.maximumBPM {
                        // Schedule the notification
                        self.scheduleHeartRateMonitoringNotification()
                        break // No need to check the other samples
                    }
                }
            }
        }
    }

    func scheduleHeartRateMonitoringNotification() {
        NotificationManager.shared.scheduleNotification(task: Task(name: "Your heart rate is too high!", reminder: Reminder(reminderType: .heartRateCeiling)))

        // Mark the expiration in the UserDefaults
        let oneMinuteInFuture = Date().addingTimeInterval(notificationExpirationDuration)
        UserDefaults.standard.setDate(oneMinuteInFuture, key: .heartRateMonitoringNotificationTriggerTimestamp)
    }

    func shouldScheduleHeartRateMonitoringNotification() -> Bool {
//        if let date = UserDefaults.standard.date(key: .heartRateMonitoringNotificationTriggerTimestamp),
//           date.compare(Date()) == .orderedAscending {
//            return false
//        } else {
            // No unexpired notification exists at the time
            return true
//        }
    }

    func endBackgroundHeartRateMonitoringIfNeeded() {
        if let task = backgroundHeartRateMonitoringTask {
            UIApplication.shared.endBackgroundTask(task)
        }
    }

}

extension Date {
    // using iso8601 format because it is most appropriate for JSON.
    // this aligns the timestamp on heartRate & stepcount data (HealthStore class) below with Symptom data (JSON)
    static func mondayAt12AM() -> Date {
        return Calendar(identifier: .iso8601)
            .date(from: Calendar(identifier: .iso8601)
                    .dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }
}
