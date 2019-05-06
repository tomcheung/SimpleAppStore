//
//  DemoTableViewHeader.swift
//  ReactiveDataSourceDemo
//
//  Created by Tom Cheung on 17/1/2019.
//  Copyright © 2019 Tom Cheung. All rights reserved.
//

import UIKit
import ReactiveDataSource

class DemoTableViewHeader: ReactiveTableHeaderFooterView<String> {
	@IBOutlet var text: UILabel?

	override func bind(item: String?) {
		text?.text = item
	}

}
