//
//  MultilineTableViewCell.swift
//  SampleTable
//
//  Created by Davide Vincenzi on 27.09.15.
//  Copyright © 2015 AugmentedWorks. All rights reserved.
//

import UIKit
import DTModelStorage
import Bond

class ViewModel {
    var model: AnyObject!
    
    init(model: AnyObject) {
        self.model = model
    }
}

class MultilineViewModel: ViewModel {
    var firstText: String?
    var secondText: String?
    
    init(model: AnyObject, firstText: String, secondText: String) {
        super.init(model: model)
        self.firstText = firstText
        self.secondText = secondText
    }
}

class MultilineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
}

extension MultilineTableViewCell: ModelTransfer {
    
    func updateWithModel(model: MultilineViewModel) {
        firstLabel?.text = model.firstText
        secondLabel?.text = model.secondText
    }
}

extension MultilineViewModel {
    convenience init(dog: Dog) {
        self.init(model: dog, firstText: "Dog name: \(dog.name)", secondText: "Owner: Test")
    }
}
