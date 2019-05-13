//
//  AppTableViewCell.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 6/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveDataSource
import Cosmos
import Kingfisher

class AppTableViewCell: ReactiveTableViewCell<AppListItem>, AppReuseView {
    
    @IBOutlet var appOrderLabel: UILabel?
    @IBOutlet var appImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var numOfRatingLabel: UILabel!
    
    private var useCircleCorner: Bool = false {
        didSet {
            if oldValue == self.useCircleCorner {
                return
            }

            self.contentView.setNeedsLayout()
            self.contentView.layoutIfNeeded()
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.useCircleCorner {
            self.appImageView.layer.cornerRadius = self.appImageView.bounds.size.height / 2
        } else {
            self.appImageView.layer.cornerRadius = 20
        }
    }
    
    override func bind(viewModel: AppListItem, disposable: CompositeDisposable) {
        guard case .item(let appCellModel) = viewModel else {
            print("item mismatch: \(viewModel)")
            return
        }
        
        self.useCircleCorner = appCellModel.order % 2 == 0
        self.appOrderLabel?.text = String(appCellModel.order)
        self.updateUI(appCellViewModel: appCellModel)
        self.ratingView.rating = appCellModel.rating ?? 0
        if let ratingCount = appCellModel.ratingCount {
            self.numOfRatingLabel.text = "(\(ratingCount))"
        } else {
            self.numOfRatingLabel.text = "(--)"
        }
    }
    
}
