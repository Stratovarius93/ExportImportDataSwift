//
//  Purchase+CoreDataClass.swift
//  ExportingCoreData
//
//  Created by Juan Carlos Catagña Tipantuña on 6/8/23.
//
//

import CoreData
import Foundation

@objc(Purchase)
public class Purchase: NSManagedObject, Codable {
    public required convenience init(from decoder: Decoder) throws {
        /// First we need to extract Managed Object Context to initialize
        guard let context = decoder.userInfo[.context] as? NSManagedObjectContext else {
            throw ContextError.NoContextFound
        }
        self.init(context: context)
        
        /// Decoding Item
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        dateOfPurchase = try values.decode(Date.self, forKey: .dateOfPurchase)
        title = try values.decode(String.self, forKey: .title)
        amountSpent = try values.decode(Double.self, forKey: .amountSpent)
    }
    /// Conforming Encodable
    public func encode(to encoder: Encoder)throws{
        /// Encoding Item
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(id, forKey: .id)
        try values.encode(amountSpent, forKey: .amountSpent)
        try values.encode(title, forKey: .title)
        try values.encode(dateOfPurchase, forKey: .dateOfPurchase)
    }

    enum CodingKeys: CodingKey {
        case id, title, dateOfPurchase, amountSpent
    }
}

extension CodingUserInfoKey {
    static let context = CodingUserInfoKey(rawValue: "manageObjectContext")!
}

enum ContextError: Error {
    case NoContextFound
}
