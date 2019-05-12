//
//  AppListViewController.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 6/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import ReactiveDataSource

class AppListViewController: UIViewController, UITableViewDelegate {
    
    struct Style {
        static let headerRowHeight: CGFloat = 50
        static let appListingRowHeight: CGFloat = 80
        static let appRecommendationRowHeight: CGFloat = 170
    }
    
    // MARK: - Interface builder
    @IBOutlet weak var mainAppTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var errorContainerView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var hideErrorContainerConstraint: NSLayoutConstraint!
    
    private let mainListDataSource = ReactiveHeaderFooterTableViewDataSource<AppListSection>()
    private let viewModel = AppListViewModel()
    private var lastScrollingIndexPath = IndexPath(row: 0, section: 0)
    
    // Default is appear in storyboard, so set default value it true
    var showErrorMessage: Bool = true {
        didSet {
            if oldValue == self.showErrorMessage {
                return
            }
            
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                self.errorContainerView.alpha = self.showErrorMessage ? 1 : 0
                self.hideErrorContainerConstraint.priority = self.showErrorMessage ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
                self.view.layoutIfNeeded()
            })
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupDatasource()
        self.showErrorMessage = false
        self.bindUI()
        self.viewModel.fetchAppList()
        
        //FIXME: Dismiss keyboard
    }
    
    @IBAction func retryDidTap(_ sender: Any) {
        self.viewModel.fetchAppList()
    }
    
    private func bindUI() {
        self.viewModel.serchKeyword <~ self.searchBar.reactive.continuousTextValues.debounce(0.3, on: QueueScheduler.main)
        self.viewModel.error.throttle(0.5, on: QueueScheduler.main)
            .observeValues { [weak self] (apiError) in
                guard let strongSelf = self else { return }
                
                strongSelf.showErrorMessage = apiError != nil
                if let apiError = apiError {
                    strongSelf.errorLabel.text = apiError.message
                }
            }
    }
    
    private func setupDatasource() {
        self.mainListDataSource.headerHeight = { _ in Style.headerRowHeight }
        self.mainListDataSource.headerIdentifier = { _ in "header" }
        
        self.mainListDataSource.reuseIdentifier = { viewModel in
            switch viewModel {
            case .item:
                return "appCell"
            case .list:
                return "appListCell"
            case .message:
                return "errorMessage"
            }
        }
        
        self.mainAppTableView.reactive.setReactiveDataSource(self.mainListDataSource)
        self.mainListDataSource.sections <~ self.viewModel.sections
        self.mainListDataSource.tableViewDelegate = self
        
        self.mainAppTableView.isSkeletonable = true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let cellViewModel = self.mainListDataSource.item(at: indexPath) else {
            return 100
        }
        
        switch cellViewModel {
        case .message(let errorCellModel):
            return errorCellModel.cellHeight
        case .item:
            return Style.appListingRowHeight
        case .list:
            return Style.appRecommendationRowHeight
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard cell is AppTableViewCell else {
            return
        }
        
        guard indexPath.section >= self.lastScrollingIndexPath.section, indexPath.row >= self.lastScrollingIndexPath.row else {
            return
        }
        
        cell.alpha = 0
        cell.transform = CGAffineTransform(translationX: 0, y: 100)
        
        UIView.animate(withDuration: 0.4) {
            cell.alpha = 1
            cell.transform = .identity
        }
        
        self.lastScrollingIndexPath = indexPath
    }

}

