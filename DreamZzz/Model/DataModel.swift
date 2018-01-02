//
//  DataModel.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 12/13/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import Foundation

class DataModel {
    var dreams = [Dream]()
    
    init() {
        loadDreams()
    }
    
    func documentsDirectory() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func archiveURL() -> URL {
        return documentsDirectory().appendingPathComponent("DreamZzz").appendingPathExtension("plist")
    }

    func saveDreams() {
        let propertyListEncoder = PropertyListEncoder()
        let codedDreams = try? propertyListEncoder.encode(dreams)
        do {
            try codedDreams?.write(to: archiveURL(), options: .noFileProtection)
        } catch let error as NSError {
            NSLog("Error encoding dreams: \(error.localizedDescription)")
        }
    }
    
    func loadDreams() {
        guard let codedDreams = try? Data(contentsOf: archiveURL()) else { return  }
        let propertyListDecoder = PropertyListDecoder()
        do {
            dreams = try propertyListDecoder.decode(Array<Dream>.self, from: codedDreams)
        } catch let error as NSError {
            NSLog("Error decoding dreams: \(error.localizedDescription)")
        }
    }
}
