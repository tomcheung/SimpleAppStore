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
        self.viewModel.sections.signal.observe(self.testObserver.observer)
        
        let expectedCellViewModel: [AppCellViewModel] = [
            AppCellViewModel(title: "香港01",
                             subtitle: "新聞",
                             order: 1,
                             imageURL: URL(string: "https://is1-ssl.mzstatic.com/image/thumb/Purple113/v4/f2/78/5f/f2785f53-f618-6126-45dc-1abb46c00ec9/source/100x100bb.jpg"),
                             rating: 4.5,
                             ratingCount: 38710,
                             isSkeletion: false),
            AppCellViewModel(title: "五色學倉頡 ONLINE",
                             subtitle: "教育",
                             order: 2,
                             imageURL: URL(string: "https://is4-ssl.mzstatic.com/image/thumb/Purple123/v4/6a/92/3b/6a923b7a-14e0-fca4-dd68-ecd3a4dc0bec/source/100x100bb.jpg"),
                             rating: nil,
                             ratingCount: nil,
                             isSkeletion: false),
            AppCellViewModel.skeletion(order: 3) // Load more indicator
        ]
        
        let expectedResult = AppListSection(sectionIdentifier: "listing", items: expectedCellViewModel.map { AppListItem.item($0) }, headerItem: nil)
        self.viewModel.fetchAppList()
        
        // Only compare last section (App Listing)
        expect(self.testObserver.lastValue?.last).toEventually(equal(expectedResult), timeout: 1)
    }
    
    func testFetchAppListingWithNoResult() {
        self.mockAppsRepository.mockData = AppDetailResponse(results: [])
        
        self.viewModel.sections.signal.observe(self.testObserver.observer)
        let expectedResult = AppListSection(sectionIdentifier: "listing",
                                            items: [.message(ErrorMessageCellViewModel(errorMessage: "No Result", cellHeight: AppListViewController.Style.appListingRowHeight))],
                                            headerItem: nil)

        self.viewModel.fetchAppList()
        expect(self.testObserver.lastValue?.last).toEventually(equal(expectedResult), timeout: 1)
    }
    
    func testFetchAppWithWrongURL() {
        self.viewModel = AppListViewModel(appsRepository: CustomMockAppsRepository(fetchActionClosure: { _ in
            return APIClient.requestWithModel(url: URL(string: "https://localhost/dummy_url.json")!, method: .get)
        }))

        let errorObserver = TestObserver<APIError?, Never>()
        self.viewModel.error.observe(errorObserver.observer)
        
        self.viewModel.fetchAppList()
        
        expect(errorObserver.lastValue??.reason).toEventually(equal(.connectionError))
    }
    
    func testFetchAppWithWrongResponseFormat() {
        self.viewModel = AppListViewModel(appsRepository: CustomMockAppsRepository(fetchActionClosure: { _  in
            return APIClient.requestWithModel(url: URL(string: "https://itunes.apple.com/hk/rss/topfreeapplications/limit=10/xml")!, method: .get)
        }))
        
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
        
        expect(self.testObserver.lastValue?.last?.items.first).toEventuallyNot(beNil(), timeout: 5)
    }

}
