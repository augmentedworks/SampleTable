//
//  MasterViewController.swift
//  SampleTable
//
//  Created by Davide Vincenzi on 27.09.15.
//  Copyright © 2015 AugmentedWorks. All rights reserved.
//

import UIKit
import DTTableViewManager
import RealmSwift

class Dog: Object {
    dynamic var name = ""
    dynamic var age = 0
    var owners: [Person] {
        // Realm doesn't persist this property because it only has a getter defined
        // Define "owners" as the inverse relationship to Person.dogs
        return linkingObjects(Person.self, forProperty: "dogs")
    }
}

class Person: Object {
    dynamic var name = ""
    let dogs = List<Dog>()
}

class MasterViewController: UITableViewController, DTTableViewManageable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        
        try! realm.write {
            for i in 0...50 {
                realm.create(Person.self, value: ["John", [["Fido", 1]]])
                realm.create(Person.self, value: ["Mary", [["Rex", 2]]])
                print(i)
            }
        }
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        manager.startManagingWithDelegate(self)

        manager.registerCellClass(MultilineTableViewCell.self) { (cell, viewModel, indexPath) -> Void in
            if let dog = viewModel.model as? Dog {
                print(dog.name)
            }
            
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        let results = realm.objects(Dog).filter("name contains 'Fido'")
        manager.realmStorage.addSection(withResults: results) { (object, index: Int) -> ViewModel in
            return MultilineViewModel(dog: object)
        }
        
        let results2 = realm.objects(Dog).filter("name contains 'Rex'")
        manager.realmStorage.addSection(withResults: results2) { (object, index: Int) -> ViewModel in
            return MultilineViewModel(dog: object)
        }
    }
}
