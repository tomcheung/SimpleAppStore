//
//  DemoTableViewController.swift
//  ReactiveDataSourceDemo
//
//  Created by Tom Cheung on 7/1/2019.
//  Copyright © 2019 Tom Cheung. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveDataSource

struct IntArrayHeaderSection: ReactiveDataSourceTabeViewSection {
	typealias HeaderItem = String
	typealias FooterItem = HeaderItem

	let headerItem: String?
	let footerItem: String?

	func headerIdentifier(section: Int) -> String {
		return "header"
	}

	var uniqueIdentifier: String

	var items: [Int]
    
    func hash(into hasher: inout Hasher) {
        let sum = self.items.reduce(0, +)
        hasher.combine(sum)
    }

	static func == (lhs: IntArrayHeaderSection, rhs: IntArrayHeaderSection) -> Bool {
		return lhs.items == rhs.items
		&& lhs.headerItem == rhs.headerItem
		&& lhs.footerItem == rhs.footerItem
	}
}


class DemoTableViewController: UITableViewController {

	private let dataSource: ReactiveHeaderFooterTableViewDataSource = ReactiveHeaderFooterTableViewDataSource<IntArrayHeaderSection>()
	private let numberSections = MutableProperty<[IntArrayHeaderSection]>([
		IntArrayHeaderSection(
			headerItem: "Header 1",
			footerItem: nil,
			uniqueIdentifier: "A", items: Array(0...10)
		)
	])

    override func viewDidLoad() {
        super.viewDidLoad()

		self.tableView.reactive.setReactiveDataSource(dataSource)
		self.tableView.register(UINib(nibName: "DemoTableViewHeader", bundle: Bundle(for: DemoTableViewController.self)), forHeaderFooterViewReuseIdentifier: "header")

		self.dataSource.headerIdentifier = { _ in "header" }
		self.dataSource.footerIdentifier = { _ in "header" }
		self.dataSource.headerHeight = { _ in 30 }
		self.dataSource.footerHeight = { _ in 60 }

		self.dataSource.reuseIdentifier = { _ in "cell" }
		self.dataSource.sections <~ numberSections.producer

    }

	@IBAction func suffleNumber(_ sender: Any) {
		let randSections = [
			IntArrayHeaderSection(
				headerItem: "Header 1",
				footerItem: nil,
				uniqueIdentifier: "A",
				items: Array(0...5).map { _ in Int(arc4random_uniform(5)) }
			),
			IntArrayHeaderSection(
				headerItem: "Header 2",
				footerItem: "Footer",
				uniqueIdentifier: "B",
				items: Array(0...10).map { _ in Int(arc4random_uniform(10) + 10) }
			)
		]

		self.numberSections.value = randSections
	}

	@IBAction func addNumber(_ sender: Any) {
		self.numberSections.modify { (sections) in
			sections[1].items.insert(Int(arc4random_uniform(10) + 10), at: 0)
		}
	}

	@IBAction func removeNumber(_ sender: Any) {
		self.numberSections.modify { (sections) in
			if sections[1].items.first != nil {
				sections[1].items.removeFirst()
			}
		}
	}

	@IBAction func sort(_ sender: Any) {
		self.numberSections.modify { (sections) in
			for (index, section) in sections.enumerated() {
				sections[index].items = section.items.sorted()
			}
		}
	}

}
