//
//  Purchase+CoreDataProperties.swift
//  ExportingCoreData
//
//  Created by Juan Carlos Catagña Tipantuña on 6/8/23.
//
//

import Foundation
import CoreData


extension Purchase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Purchase> {
        return NSFetchRequest<Purchase>(entityName: "Purchase")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var dateOfPurchase: Date?
    @NSManaged public var amountSpent: Double

}

extension Purchase : Identifiable {

}
