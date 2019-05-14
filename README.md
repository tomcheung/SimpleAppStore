# A simple Appstore listing app

## Requirement
- Xcode 10.2.1 (swift 5)
- Cocoapods [Optional] (pod dependency already included this repository)
- iOS 10 or above

To run the project, simply open `SimpleAppStore.xcworkspace` with Xcode, and click **Product -> Run** (CMD+R) 

## Model
It use Core Data for data persistence, and used caching data for offline usage .  `AppsRepository` will coordinate the network response and database storage, and use Codable for api JSON mapping  

## Architectural
It use MVVM pattern and Reactive functional programming (ReactiveSwift) as core architectural. It divided to four parts:

    View <===> ViewModel <===> Repository <=+=> Database
                                            | 
                                            +=> Network

ViewModel: Contain the app logic and interact with repository and model, and drive the View / ViewController to perform UI update                     
View / ViewController: Control the UIView and the actual UI update, base on the ViewModel
Model: A data class to hold the database entities / network response


## Testcase
Test case is included in this project, coverage is about 80% (main app target only, library is not included).
To run test case, simply open Xcode and click **Product -> Test** (CMD+U) 
