//
//  WeightRecord.swift
//  nutrition-app
//
//  Created by Florian Fourcade on 03/04/2025.
//

import Foundation
import CoreData

@objc(WeightRecord)
public class WeightRecord: NSManagedObject {
    @NSManaged public var date: Date
    @NSManaged public var weight: Double
}

extension WeightRecord {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WeightRecord> {
        return NSFetchRequest<WeightRecord>(entityName: "WeightRecord")
    }
}

