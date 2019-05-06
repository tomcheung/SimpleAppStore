//
//  AppReuseView.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 11/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import UIKit
import SkeletonView

protocol AppReuseView {
    var appImageView: UIImageView! { get }
    var titleLabel: UILabel! { get }
    var categoryLabel: UILabel! { get }
}

extension AppReuseView where Self: UIView {
    func updateUI(appCellViewModel: AppCellViewModel) {
        if appCellViewModel.isSkeletion, !self.isSkeletonActive {
            self.showAnimatedGradientSkeleton()
        } else if self.isSkeletonActive {
            self.hideSkeleton()
        }
        
        self.titleLabel.text = appCellViewModel.title
        self.categoryLabel.text = appCellViewModel.subtitle
        self.appImageView.kf.setImage(with: appCellViewModel.imageURL, placeholder: #imageLiteral(resourceName: "AppPlaceholder"))
    }
}
