//
//  WaterLog+CoreDataProperties.swift
//  GOQiiAssessment
//
//  Created by MacBook on 8/12/24.
//
//

import Foundation
import CoreData


extension WaterLog {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WaterLog> {
        return NSFetchRequest<WaterLog>(entityName: "WaterLog")
    }

    @NSManaged public var date: Date?
    @NSManaged public var amount: Int16
    @NSManaged public var measure: String?

}

extension WaterLog : Identifiable {

}
