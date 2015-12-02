//
//  BaseStorage.swift
//  DTModelStorageTests
//
//  Created by Denys Telezhkin on 06.07.15.
//  Copyright (c) 2015 Denys Telezhkin. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import UIKit

/// Suggested supplementary kind for UITableView header
public let DTTableViewElementSectionHeader = "DTTableViewElementSectionHeader"
/// Suggested supplementary kind for UITableView footer
public let DTTableViewElementSectionFooter = "DTTableViewElementSectionFooter"

/// Base class for MemoryStorage and CoreDataStorage
public class BaseStorage : NSObject
{
    /// Supplementary kind for header in current storage
    public var supplementaryHeaderKind : String?
    
    /// Supplementary kind for footer in current storage
    public var supplementaryFooterKind : String?
    
    /// Current update
    public var currentUpdate: StorageUpdate?
    
    /// Delegate for storage updates
    public weak var delegate : StorageUpdating?
}

extension BaseStorage
{
    public func startUpdate(){
        self.currentUpdate = StorageUpdate()
    }
    
    public func finishUpdate()
    {
        defer { self.currentUpdate = nil }
        
        if self.currentUpdate != nil
        {
            if self.currentUpdate!.isEmpty() {
                return
            }
            self.delegate?.storageDidPerformUpdate(self.currentUpdate!)
        }
    }
    
    /// This method will configure storage for using with UITableView
    public func configureForTableViewUsage()
    {
        self.supplementaryHeaderKind = DTTableViewElementSectionHeader
        self.supplementaryFooterKind = DTTableViewElementSectionFooter
    }
    
    /// This method will configure storage for using with UICollectionViewFlowLayout
    public func configureForCollectionViewFlowLayoutUsage()
    {
        self.supplementaryHeaderKind = UICollectionElementKindSectionHeader
        self.supplementaryFooterKind = UICollectionElementKindSectionFooter
    }
}