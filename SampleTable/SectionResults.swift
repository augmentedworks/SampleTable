//
//  SectionRealm.swift
//  SampleTable
//
//  Created by Davide Vincenzi on 11.11.15.
//  Copyright © 2015 AugmentedWorks. All rights reserved.
//

import UIKit
import DTModelStorage
import RealmSwift

protocol SectionObjects {
    func objectAtIndex(index: Int) -> Any?
}

class SectionResults<T: Object>: Section, SectionObjects {
    var results: Results<T>?
    
    var viewModel: ((object: T, index: Int) -> ViewModel)?
    
    init(results: Results<T>?) {
        self.results = results
    }
    
    var objects: [Any] {
        get {
            return [""]
        }
    }
    
    func objectAtIndex(index: Int) -> Any? {
        if viewModel != nil {
            return viewModel!(object: results![index], index: index)
        }
        return results?[index]
    }
    
    var numberOfObjects: Int {
        get {
            return results!.count
        }
    }
    
    private var supplementaries = [String:Any]()
    
    /// Retrieve supplementaryModel of specific kind
    /// - Parameter: kind - kind of supplementary
    /// - Returns: supplementary model or nil, if there are no model
    func supplementaryModelOfKind(kind: String) -> Any?
    {
        return self.supplementaries[kind]
    }
    
    /// Set supplementary model of specific kind
    /// - Parameter model: model to set
    /// - Parameter forKind: kind of supplementary
    func setSupplementaryModel(model : Any?, forKind kind: String)
    {
        self.supplementaries[kind] = model
    }
}
