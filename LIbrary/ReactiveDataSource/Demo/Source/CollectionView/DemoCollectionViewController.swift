//
//  DemoCollectionViewController.swift
//  ReactiveDataSourceDemo
//
//  Created by Tom Cheung on 2/8/2018.
//  Copyright © 2018 Tom Cheung. All rights reserved.
//

import UIKit
import ReactiveDataSource
import ReactiveSwift
import ReactiveCocoa

class DemoCollectionViewController: UIViewController {

	@IBOutlet var collectionView: UICollectionView!
	private let dataSource: ReactiveCollectionViewDataSource = ReactiveCollectionViewDataSource<StringArraySection>()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.collectionView.reactive.setReactiveDataSource(dataSource)
		dataSource.showDeltaLog = true

//        startGeneralTest()
//        startDeltaTest()
//		startConcurrentStressTest()
	}

    @IBAction func suffleNumber(_ sender: Any) {
        var rand = SystemRandomNumberGenerator()
        self.dataSource.sections.value = [
            StringArraySection(uniqueIdentifier: "A", items: Array(0...100).shuffled(using: &rand).map { "A\($0)" }),
            StringArraySection(uniqueIdentifier: "B", items: Array(0...100).shuffled(using: &rand).map { "B\($0)" }),
            StringArraySection(uniqueIdentifier: "C", items: Array(0...100).shuffled(using: &rand).map { "C\($0)" }),
        ]
    }

    @IBAction func startDeltaTest(_ sender: Any) {
		let testDataset:[[StringArraySection]] = [
			[
				StringArraySection(uniqueIdentifier: "A", items: Array(0...5).map { "A\($0)" }),
				StringArraySection(uniqueIdentifier: "B", items: Array(0...2).map { "B\($0)" }),
				StringArraySection(uniqueIdentifier: "C", items: Array(0...4).map { "C\($0)" }),
				StringArraySection(uniqueIdentifier: "D", items: Array(0...12).map { "D\($0)" }),
			],

			[
				StringArraySection(uniqueIdentifier: "B", items: Array(0...2).map { "B\($0)" }),
				StringArraySection(uniqueIdentifier: "A", items: [1,2,5,7,9].map { "A\($0)" }),
				StringArraySection(uniqueIdentifier: "D", items: Array(0...12).map { "D\($0)" }),
				StringArraySection(uniqueIdentifier: "C", items: Array(0...4).map { "C\($0)" }),
			],

			[
				StringArraySection(uniqueIdentifier: "B", items: Array(0...2).reversed().map { "B\($0)" }),
				StringArraySection(uniqueIdentifier: "A", items: [1,2,5,7,9].map { "A\($0)" }),
				StringArraySection(uniqueIdentifier: "D", items: Array(0...12).reversed().map { "D\($0)" }),
				StringArraySection(uniqueIdentifier: "C", items: Array(0...4).map { "C\($0)" }),
			],

			[
				StringArraySection(uniqueIdentifier: "B", items: Array(0...2).reversed().map { "B\($0)" }),
				StringArraySection(uniqueIdentifier: "D", items: Array(0...12).reversed().map { "D\($0)" }),
				StringArraySection(uniqueIdentifier: "C", items: Array(0...4).map { "C\($0)" }),
				StringArraySection(uniqueIdentifier: "E", items: [1,2,5,7,9].map { "E\($0)" }),
			],

			[
				StringArraySection(uniqueIdentifier: "D", items: Array(0...12).map { "D\($0)" }),
				StringArraySection(uniqueIdentifier: "C", items: Array(3...4).map { "C\($0)" }),
				StringArraySection(uniqueIdentifier: "B", items: Array(0...2).map { "B\($0)" }),
				StringArraySection(uniqueIdentifier: "A", items: [1].map { "A\($0)" }),
			],

			[
				StringArraySection(uniqueIdentifier: "A", items: Array(0...5).map { "A\($0)" }),
				StringArraySection(uniqueIdentifier: "B", items: Array(0...2).map { "B\($0)" }),
				StringArraySection(uniqueIdentifier: "D", items: Array(0...12).map { "D\($0)" }),
				StringArraySection(uniqueIdentifier: "C", items: Array(0...4).map { "C\($0)" }),
			],

            [
                StringArraySection(uniqueIdentifier: "R1", items: Array(0...100).map { "R\($0)\(arc4random_uniform(500))" }),
                StringArraySection(uniqueIdentifier: "R2", items: Array(0...200).map { "R\($0)\(arc4random_uniform(500))" }),
                StringArraySection(uniqueIdentifier: "R3", items: Array(0...300).map { "R\($0)\(arc4random_uniform(500))" }),
            ],

            [
                StringArraySection(uniqueIdentifier: "R1", items: Array(0...100).map { "R\($0)\(arc4random_uniform(500))" }),
                StringArraySection(uniqueIdentifier: "R2", items: Array(0...200).map { "R\($0)\(arc4random_uniform(500))" }),
                StringArraySection(uniqueIdentifier: "R3", items: Array(0...300).map { "R\($0)\(arc4random_uniform(500))" }),
            ]
		]

		self.dataSource.sections <~ SignalProducer<[StringArraySection], Never> { (observer, _) in
			DispatchQueue.global().async {
				let testDataset = Array(repeating: testDataset, count: 30).flatMap { $0 }
				for testData in testDataset {
					observer.send(value: testData)
					Thread.sleep(forTimeInterval: 0.5)
				}

				observer.sendCompleted()
			}
		}
	}

    @IBAction func startConcurrentStressTest(_ sender: Any) {
		DispatchQueue.concurrentPerform(iterations: 3) { (i) in

			let randNum = SignalProducer.timer(interval: DispatchTimeInterval.milliseconds(300 * i), on: QueueScheduler())
				.map { _ -> [StringArraySection] in
					var s = [StringArraySection]()
					for sectionIndex in 0 ..< 2 {
						var stringArray = [String]()
						for _ in 0 ..< arc4random_uniform(1000) {
							stringArray.append(String(Int(arc4random_uniform(100)) + sectionIndex * 100))
						}
						s.append(StringArraySection(uniqueIdentifier: String(sectionIndex), items: stringArray))
					}
					return s
				}
				.take(first: 100)

            self.dataSource.sections <~ randNum.on(value: { v in print("Diff in \(Thread.current)") })
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

