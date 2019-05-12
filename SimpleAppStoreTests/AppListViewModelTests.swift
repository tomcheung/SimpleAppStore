//
//  AppListViewModelTests.swift
//  SimpleAppStoreTests
//
//  Created by Cheung Chun Hung on 12/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import XCTest
import Nimble
import ReactiveSwift

@testable import SimpleAppStore

class AppListViewModelTests: XCTestCase {
    
    var viewModel: AppListViewModel!
    var mockAppsRepository: MockDataAppsRepository!
    var testObserver: TestObserver<[AppListSection], Never>!
    
    override func setUp() {
        self.testObserver = TestObserver<[AppListSection], Never>()
        self.mockAppsRepository = MockDataAppsRepository(mockData: try! TestHelper.loadSampleResponse(jsonFile: "MockResponse"))
        self.viewModel = AppListViewModel(appsRepository: self.mockAppsRepository)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchMockAppListingData() {
        self.viewModel.fetchAppList()
        self.viewModel.sections.signal.observe(self.testObserver.observer)
        
        let expectedCellViewModel = AppCellViewModel(title: "Testing App 1",
                                                     subtitle: "遊戲",
                                                     order: 1,
                                                     imageURL: URL(string: "https://is3-ssl.mzstatic.com/image/thumb/Purple128/v4/5e/90/4a/5e904a82-5707-99e9-7e7e-fcc630ccf4e5/AppIcon-0-1x_U007emarketing-0-85-220-6.png/100x100bb-85.png"),
                                                     isSkeletion: false)
        
        let expectedResult = AppListSection(sectionIdentifier: "listing", items: [.item(expectedCellViewModel)], headerItem: nil)
        self.viewModel.fetchAppList()
        
        // Only compare last section (App Listing)
        expect(self.testObserver.lastValue?.last).toEventually(equal(expectedResult), timeout: 1)
    }
    
    func testFetchAppListingWithNoResult() {
        let emptyResponse = AppEntityResponse.Feed(entry: [])
        self.mockAppsRepository.mockData = AppEntityResponse(feed: emptyResponse)
        
        self.viewModel.sections.signal.observe(self.testObserver.observer)
        let expectedResult = AppListSection(sectionIdentifier: "listing",
                                            items: [.message(ErrorMessageCellViewModel(errorMessage: "No Result", cellHeight: AppListViewController.Style.appListingRowHeight))],
                                            headerItem: nil)

        self.viewModel.fetchAppList()
        expect(self.testObserver.lastValue?.last).toEventually(equal(expectedResult), timeout: 1)
    }
    
    func testFetchAppWithWrongURL() {
        self.viewModel = AppListViewModel(appsRepository: CustomMockAppsRepository(fetchActionClosure: { _ -> SignalProducer<AppEntityResponse, APIError> in
            return APIClient.requestWithModel(url: URL(string: "https://localhost/dummy_url.json")!, method: .get)
        }))
        
        let emptyResponse = AppEntityResponse.Feed(entry: [])
        self.mockAppsRepository.mockData = AppEntityResponse(feed: emptyResponse)
        
        let errorObserver = TestObserver<APIError?, Never>()
        self.viewModel.error.observe(errorObserver.observer)
        
        self.viewModel.fetchAppList()
        
        expect(errorObserver.lastValue??.reason).toEventually(equal(.connectionError))
    }
    
    func testFetchAppWithWrongResponseFormat() {
        self.viewModel = AppListViewModel(appsRepository: CustomMockAppsRepository(fetchActionClosure: { _ -> SignalProducer<AppEntityResponse, APIError> in
            return APIClient.requestWithModel(url: URL(string: "https://itunes.apple.com/hk/rss/topfreeapplications/limit=10/xml")!, method: .get)
        }))
        
        let emptyResponse = AppEntityResponse.Feed(entry: [])
        self.mockAppsRepository.mockData = AppEntityResponse(feed: emptyResponse)
        
        let errorObserver = TestObserver<APIError?, Never>()
        self.viewModel.error.observe(errorObserver.observer)
        
        self.viewModel.fetchAppList()
        
        expect(errorObserver.lastValue??.reason).toEventually(equal(.parseJSONError))
    }

    func testFetchActualAPI() {
        // Do the overall testing by calling the actual server
        let viewModel = AppListViewModel(appsRepository: AppsRepository())
        viewModel.sections.signal.observe(self.testObserver.observer)
        viewModel.fetchAppList()
       
        // Just test if can return data, cannot do futher data validation becuase actual api response alway change
        expect(self.testObserver.lastValue?.last?.items.first).toEventuallyNot(
            equal(AppListItem.item(AppCellViewModel.skeletion(order: 1))),
            timeout: 1)
        
        expect(self.testObserver.lastValue?.last?.items.first).toEventuallyNot(beNil(), timeout: 1)
    }

}
