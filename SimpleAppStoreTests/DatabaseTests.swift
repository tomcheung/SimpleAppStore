//
//  DatabaseTests.swift
//  SimpleAppStoreTests
//
//  Created by Cheung Chun Hung on 14/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import XCTest
import Nimble
import ReactiveSwift

@testable import SimpleAppStore

class DatabaseTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        try! DatabaseStorage.shared.clearAllRecords(inBackground: false)
    }

    func testSaveAndReadRecord() {
        let db = DatabaseStorage.shared
        let appDetailResposne = try! TestHelper.loadSampleResponse(jsonFile: "MockResponse")
        
        expect {
            try db.saveData(appList: appDetailResposne.results, type: .appListing, clearPreviousRecords: true, inBackground: false, offset: 0)
        }.notTo(throwError())
        
        expect { () -> String? in
            let dbAppListing = try db.fetchData(type: .appListing, inBackground: false)
            return dbAppListing.first?.name
        }.to(equal(appDetailResposne.results.first?.appName))
    }
    
    func testDbModelMapping() {
        let appDetailResposne = try! TestHelper.loadSampleResponse(jsonFile: "MockResponse")
        assert(!appDetailResposne.results.isEmpty)
        
        for mockAppDetail in appDetailResposne.results {
            let appEntity = AppEntity(context: DatabaseStorage.shared.viewContext)
            
            appEntity.updateValue(from: mockAppDetail)
            expect(appEntity.appId).to(equal(mockAppDetail.appId))
            expect(appEntity.appName).to(equal(mockAppDetail.appName))
            expect(appEntity.appCategory).to(equal(mockAppDetail.appCategory))
            if mockAppDetail.appRating == nil {
                expect(appEntity.appRating).to(beNil())
                expect(appEntity.appUserRatingCount).to(beNil())
            } else {
                expect(appEntity.appRating).to(equal(mockAppDetail.appRating))
                expect(appEntity.appUserRatingCount).to(equal(mockAppDetail.appUserRatingCount))
            }
            expect(appEntity.appImageURL).to(equal(mockAppDetail.appImageURL))
        }
    }

}
