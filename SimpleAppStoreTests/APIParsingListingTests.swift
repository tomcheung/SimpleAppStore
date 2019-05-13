//
//  APIParsingListingTests.swift
//  SimpleAppStoreTests
//
//  Created by Cheung Chun Hung on 8/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import XCTest
import Nimble
@testable import SimpleAppStore

class APIParsingListingTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAppListJSONParsing() {
        let sampleJSON = TestHelper.loadJSONSampleFile(filename: "TopAppListingSampleResponse")
        expect(try APIClient.mapResponse(json: sampleJSON) as AppEntityResponse).notTo(throwError())
    }
    
    func testLoadInvalidJSON() {
        let sampleJSON = TestHelper.loadJSONSampleFile(filename: "InvalidSampleResponse")
        expect(try APIClient.mapResponse(json: sampleJSON) as AppEntityResponse).to(throwError(errorType: DecodingError.self))
    }
    
    func testFetchAppListing() {
        let appListing = APIClient.appListing(count: 10)
        let resultObserver = TestObserver<AppEntityResponse, APIError>()
        appListing.start(resultObserver.observer)
        
        expect(resultObserver.lastValue?.feed.entry.count).toEventually(equal(10), timeout: 1)
        expect(resultObserver.failedError).toEventually(beNil(), timeout: 1)
    }

}
