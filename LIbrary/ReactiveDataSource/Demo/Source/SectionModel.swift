//
//  SectionModel.swift
//  ReactiveDataSourceDemo
//
//  Created by Tom Cheung on 7/1/2019.
//  Copyright © 2019 Tom Cheung. All rights reserved.
//

import Foundation
import ReactiveDataSource

struct StringArraySection: ReactiveDataSourceSection {
	var uniqueIdentifier: String

	var items: [String]

	var hashValue: Int {
		return uniqueIdentifier.hashValue
	}

	static func == (lhs: StringArraySection, rhs: StringArraySection) -> Bool {
		return lhs.items == rhs.items
	}
}

struct IntArraySection: ReactiveDataSourceSection {
	var uniqueIdentifier: String

	var items: [Int]

	var hashValue: Int {
		return self.items.reduce(0, +) % 1000000
	}

	static func == (lhs: IntArraySection, rhs: IntArraySection) -> Bool {
		return lhs.items == rhs.items
	}
}
