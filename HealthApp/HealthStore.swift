//
//  HealthStore.swift
//  HealthApp
//
//  Created by Ko Sakuma on 21/06/2021.
//

// Creating this file so that I can wrap around all the features of HKHealthStore inside the HealthStore class

import Foundation
import HealthKit

extension Date {
    static func mondayAt12AM() -> Date {
        return Calendar(identifier: .iso8601)
            .date(from: Calendar(identifier: .iso8601)
                    .dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
    }
}

class HealthStore {

    var healthStore: HKHealthStore?
    var query: HKStatisticsCollectionQuery?
    var sampleQuery: HKSampleQuery?

    init() {
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

        // startDate: defines the past 7 days
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())

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
//        // NOTE: if let ... is called "Optional Binding"
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

        // startDate: defines the past 7 days
        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: Date())

        // anchorDate: defines what time a day actually starts at. mondayAt12AM() is my func, defined above.
        let anchorDate = Date.mondayAt12AM()

        // daily: defines how a date should be considered (i.e. 1 date = 1 day in this app)
        let daily = DateComponents(day: 1)

        // predicate: defines that the sample's start time and end time must fall within the desirable period
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictStartDate)

        // query = create a statistics collection query that would include what I want, as defined above.
        // NOTE: HKStatisticsCollectionQuery is useful for graphs; but HKStatisticsQuery, not as much.
        sampleQuery = HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: -1, sortDescriptors: nil, resultsHandler: { (_: HKSampleQuery, samples: [HKSample]?, _: Error?) in
            completion(samples ?? [])
        })

        // if health data is available & query contains value, then execute the query
        // NOTE: if let ... is called "Optional Binding"
        if let healthStore = healthStore, let query =
            self.sampleQuery {
            healthStore.execute(query)
        }
//        print(self.sampleQuery) // it returns nothing at the moment

    }
    
    
    // MARK: - 
}
