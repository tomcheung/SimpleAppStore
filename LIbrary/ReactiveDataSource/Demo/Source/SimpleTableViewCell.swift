//
//  SimpleTableViewCell.swift
//  ReactiveDataSourceDemo
//
//  Created by Tom Cheung on 7/1/2019.
//  Copyright © 2019 Tom Cheung. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveDataSource

class SimpleTableViewCell: UITableViewCell, ReactiveBindableCell {
	static let maxNumberRange = 30

	typealias ViewModel = Int

	func bind(viewModel: ViewModel, disposable: CompositeDisposable) {
		self.textLabel?.text = String(viewModel)
		self.backgroundColor = UIColor(hue: CGFloat(abs(viewModel % SimpleTableViewCell.maxNumberRange)) / CGFloat(SimpleTableViewCell.maxNumberRange), saturation: 0.7, brightness: 0.8, alpha: 1)
	}

}
