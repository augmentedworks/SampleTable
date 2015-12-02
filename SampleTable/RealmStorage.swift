//
//  RealmStorage.swift
//  SampleTable
//
//  Created by Davide Vincenzi on 11.11.15.
//  Copyright © 2015 AugmentedWorks. All rights reserved.
//

import UIKit
import DTModelStorage
import DTTableViewManager
import RealmSwift

extension DTTableViewManager {
    var realmStorage : RealmStorage!
        {
            if !(storage is RealmStorage) {
                storage = RealmStorage()
            }
            return storage as! RealmStorage
    }
}

class RealmStorage: BaseStorage, StorageProtocol
{
    var sections: [Section] = [Section]()
    
    func objectAtIndexPath(path: NSIndexPath) -> Any? {
        if path.section >= self.sections.count {
            return nil
        } else {
            let sectionModel = self.sections[path.section] as? SectionObjects
            
            return sectionModel?.objectAtIndex(path.row)
        }

    }
    
    func setSectionHeaderModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling setSectionHeaderModel: forSectionIndex: method")
        (sectionAtIndex(sectionIndex) as! SectionResults).setSupplementaryModel(model, forKind: self.supplementaryHeaderKind!)
    }
    
    func setSectionFooterModel<T>(model: T?, forSectionIndex sectionIndex: Int)
    {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling setSectionFooterModel: forSectionIndex: method")
        (self.sectionAtIndex(sectionIndex) as! SectionResults).setSupplementaryModel(model, forKind: self.supplementaryFooterKind!)
    }
    
    func setSupplementaries<T>(models : [T], forKind kind: String)
    {
        self.startUpdate()
        
        if models.count == 0 {
            for index in 0..<self.sections.count {
                let section = self.sections[index] as! SectionModel
                section.setSupplementaryModel(nil, forKind: kind)
            }
            return
        }
        
        assert(sections.count < models.count - 1, "The section should be set before setting supplementaries")
        
        for index in 0..<models.count {
            let section = self.sections[index] as! SectionModel
            section.setSupplementaryModel(models[index], forKind: kind)
        }
        
        finishUpdate()
    }
    
    /// Set section header models.
    /// - Note: `supplementaryHeaderKind` property should be set before calling this method.
    /// - Parameter models: section header models
    func setSectionHeaderModels<T>(models : [T])
    {
        assert(self.supplementaryHeaderKind != nil, "Please set supplementaryHeaderKind property before setting section header models")
        self.setSupplementaries(models, forKind: self.supplementaryHeaderKind!)
    }
    
    /// Set section footer models.
    /// - Note: `supplementaryFooterKind` property should be set before calling this method.
    /// - Parameter models: section footer models
    func setSectionFooterModels<T>(models : [T])
    {
        assert(self.supplementaryFooterKind != nil, "Please set supplementaryFooterKind property before setting section header models")
        self.setSupplementaries(models, forKind: self.supplementaryFooterKind!)
    }
    
    /// Set items for specific section. This will reload UI after updating.
    /// - Parameter items: items to set for section
    /// - Parameter forSectionIndex: index of section to update
    func addSection<O: Object>(withResults results: Results<O>, viewModel: ((object: O, index: Int) -> ViewModel)?)
    {
        let section = SectionResults<O>(results: results)
        section.viewModel = viewModel
        sections.append(section)
        
        self.delegate?.storageNeedsReloading()
    }
    
    /// Delete sections in indexSet
    /// - Parameter sections: sections to delete
    func deleteSections(sections : NSIndexSet)
    {
        self.startUpdate()
        
        for var i = sections.lastIndex; i != NSNotFound; i = sections.indexLessThanIndex(i) {
            self.sections.removeAtIndex(i)
        }
        self.currentUpdate?.deletedSectionIndexes.addIndexes(sections)
        
        self.finishUpdate()
    }
}

// MARK: - Searching in storage
extension RealmStorage
{
    func itemAtIndexPath(indexPath: NSIndexPath) -> Any?
    {
        return self.objectAtIndexPath(indexPath)
    }
    
    func indexPathForItem<T: Equatable>(searchableItem : T) -> NSIndexPath?
    {
        for sectionIndex in 0..<self.sections.count
        {
            let rows = self.sections[sectionIndex].objects
            
            for rowIndex in 0..<rows.count {
                if let item = rows[rowIndex] as? T {
                    if item == searchableItem {
                        return NSIndexPath(forItem: rowIndex, inSection: sectionIndex)
                    }
                }
            }
            
        }
        return nil
    }
    
    /// Retrieve section model for specific section.
    /// - Parameter sectionIndex: index of section
    /// - Note: if section did not exist prior to calling this, it will be created, and UI updated.
    func sectionAtIndex(sectionIndex : Int) -> Section?
    {
        self.startUpdate()
        if sectionIndex < sections.count {
            let section = sections[sectionIndex]
            self.finishUpdate()
            return section
        }
        self.finishUpdate()
        return nil
    }
    
    /// Index path array for items
    func indexPathArrayForItems<T:Equatable>(items:[T]) -> [NSIndexPath]
    {
        var indexPaths = [NSIndexPath]()
        
        for index in 0..<items.count {
            if let indexPath = self.indexPathForItem(items[index])
            {
                indexPaths.append(indexPath)
            }
        }
        return indexPaths
    }
    
    /// Sorted array of index paths - useful for deletion.
    class func sortedArrayOfIndexPaths(indexPaths: [NSIndexPath], ascending: Bool) -> [NSIndexPath]
    {
        let unsorted = NSMutableArray(array: indexPaths)
        let descriptor = NSSortDescriptor(key: "self", ascending: ascending)
        return unsorted.sortedArrayUsingDescriptors([descriptor]) as! [NSIndexPath]
    }
}

// MARK: - HeaderFooterStorageProtocol
extension RealmStorage :HeaderFooterStorageProtocol
{
    /// Header model for section.
    /// - Requires: supplementaryHeaderKind to be set prior to calling this method
    /// - Parameter index: index of section
    /// - Returns: header model for section, or nil if there are no model
    func headerModelForSectionIndex(index: Int) -> Any? {
        assert(self.supplementaryHeaderKind != nil, "supplementaryHeaderKind property was not set before calling headerModelForSectionIndex: method")
        return self.supplementaryModelOfKind(self.supplementaryHeaderKind!, sectionIndex: index)
    }
    
    /// Footer model for section.
    /// - Requires: supplementaryFooterKind to be set prior to calling this method
    /// - Parameter index: index of section
    /// - Returns: footer model for section, or nil if there are no model
    func footerModelForSectionIndex(index: Int) -> Any? {
        assert(self.supplementaryFooterKind != nil, "supplementaryFooterKind property was not set before calling footerModelForSectionIndex: method")
        return self.supplementaryModelOfKind(self.supplementaryFooterKind!, sectionIndex: index)
    }
}

// MARK: - SupplementaryStorageProtocol
extension RealmStorage : SupplementaryStorageProtocol
{
    /// Retrieve supplementary model of specific kind for section.
    /// - Parameter kind: kind of supplementary model
    /// - Parameter sectionIndex: index of section
    /// - SeeAlso: `headerModelForSectionIndex`
    /// - SeeAlso: `footerModelForSectionIndex`
    func supplementaryModelOfKind(kind: String, sectionIndex: Int) -> Any? {
        if let section = sections[sectionIndex] as? SectionResults {
            return section.supplementaryModelOfKind(kind)
        }
        
        return nil
    }
}