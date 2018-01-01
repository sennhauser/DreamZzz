//
//  DreamCategory.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 12/6/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import Foundation

struct DreamCategory: Codable, Equatable {
    
    var id: Int
    var name: String
    
    static let DocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("DreamCategories").appendingPathExtension("plist")
    
    static func saveCategories(_ categories: [DreamCategory]) {
        let propertyListEncoder = PropertyListEncoder()
        let codedDreams = try? propertyListEncoder.encode(categories)
        try? codedDreams?.write(to: ArchiveURL, options: .noFileProtection)
    }
    
    static func loadCategories() -> [DreamCategory]? {
        guard let codedCategories = try? Data(contentsOf: ArchiveURL) else { return nil }
        let propertyListDecoder = PropertyListDecoder()
        return try? propertyListDecoder.decode(Array<DreamCategory>.self, from: codedCategories)
    }
    
    static func loadSampleCategories() -> [DreamCategory] {
        return [DreamCategory(id: 1, name: NSLocalizedString("Action", comment: "")),
                DreamCategory(id: 2, name: NSLocalizedString("Childhood", comment: "")),
                DreamCategory(id: 3, name: NSLocalizedString("Family", comment: "")),
                DreamCategory(id: 4, name: NSLocalizedString("Fantasy", comment: "")),
                DreamCategory(id: 5, name: NSLocalizedString("Fun", comment: "")),
                DreamCategory(id: 6, name: NSLocalizedString("Health", comment: "")),
                DreamCategory(id: 7, name: NSLocalizedString("Nightmare", comment: "")),
                DreamCategory(id: 8, name: NSLocalizedString("Relationship", comment: "")),
                DreamCategory(id: 9, name: NSLocalizedString("Romance", comment: "")),
                DreamCategory(id: 10, name: NSLocalizedString("Spiritual", comment: "")),
                DreamCategory(id: 11, name: NSLocalizedString("Violence", comment: "")),
                DreamCategory(id: 12, name: NSLocalizedString("Work", comment: ""))]
    }
    
    static func ==(lhs: DreamCategory, rhs: DreamCategory) -> Bool {
        return lhs.id == rhs.id
    }
}
