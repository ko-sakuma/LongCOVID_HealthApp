//
//  HealthStoreTests.swift
//  HealthAppTests
//
//  Created by Ko Sakuma on 09/09/2021.
//

import XCTest
@testable import HealthApp

class HealthStoreTests: XCTestCase {

    private var healthStore: HealthStore!
    private var fakeHealthStore: FakeHealthStore!
    
    override func setUpWithError() throws {
        // It would be nice to completely recreate the HealthStore for the sake of testing
        fakeHealthStore = FakeHealthStore()
        healthStore = HealthStore(healthStore: fakeHealthStore)
    }

    override func tearDownWithError() throws {
        healthStore = nil
        fakeHealthStore = nil
    }

    // MARK: - requestAuthorization()
    
    func testRequestAuthorizationTrue() throws {
        try requestAuthorization(expectedResult: true)
    }
    
    func testRequestAuthorizationFalse() throws {
        try requestAuthorization(expectedResult: false)
    }
    
    func requestAuthorization(expectedResult: Bool) throws {
        let expectation = XCTestExpectation()
        fakeHealthStore._requestAuthorization = expectedResult
        healthStore.requestAuthorization { (granted: Bool) in
            XCTAssertTrue(granted == expectedResult)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 0.5)
    }
    
}
