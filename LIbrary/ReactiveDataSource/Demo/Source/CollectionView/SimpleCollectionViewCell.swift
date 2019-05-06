//
//  SimpleCollectionViewCell.swift
//  ReactiveDataSourceDemo
//
//  Created by Tom Cheung on 2/8/2018.
//  Copyright © 2018 Tom Cheung. All rights reserved.
//

import UIKit
import ReactiveDataSource
import ReactiveSwift

class SimpleCollectionViewCell: UICollectionViewCell, ReactiveBindableCell {

	typealias ViewModel = String

	@IBOutlet weak var label: UILabel!

	func bind(viewModel: String, disposable: CompositeDisposable) {
		self.label.text = viewModel
		self.backgroundColor = UIColor(hue: CGFloat(abs(viewModel.hashValue % 200)) / 200, saturation: 0.7, brightness: 0.8, alpha: 1)
	}
	
}
