//
//  AppRecommendationTableViewCell.swift
//  SimpleAppStore
//
//  Created by Cheung Chun Hung on 10/5/2019.
//  Copyright © 2019 Cheung Chun Hung. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveDataSource

class AppRecommendationTableViewCell: ReactiveTableViewCell<AppListItem> {
    @IBOutlet var recommendationCollectionView: UICollectionView!
    private let recommendationDataSrouce = ReactiveCollectionViewDataSource<AppListSection>()
    private var collectionFlowLayout: UICollectionViewFlowLayout?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupCollectionView()
    }
    
    private func setupCollectionView() {
        self.recommendationDataSrouce.reuseIdentifier = { _ in "appCell" }
        self.recommendationCollectionView.reactive.setReactiveDataSource(self.recommendationDataSrouce)
        self.collectionFlowLayout = self.recommendationCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        
        self.collectionFlowLayout?.itemSize = CGSize(width: 100, height: 165)
    }
    
    override func bind(viewModel: AppListItem, disposable: CompositeDisposable) {
        guard case let AppListItem.list(appRecommendations) = viewModel else {
            return
        }
        
        let items = appRecommendations.map { AppListItem.item($0) }
        
        self.recommendationDataSrouce.sections.value = [AppListSection(sectionIdentifier: "recommendation", items: items, headerItem: "")]
    }
}
