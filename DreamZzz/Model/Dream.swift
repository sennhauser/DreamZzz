//
//  Dream.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 11/27/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import Foundation

struct Dream: Codable, Equatable {
    
    var title: String
    var description: String?
    var isLucid: Bool
    var date: Date
    var mood: Int
    var categoryId: Int?
    var voiceMemoName: String?
    
    static func ==(lhs: Dream, rhs: Dream) -> Bool {
        return lhs.date == rhs.date
    }
}

