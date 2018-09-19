//
//  AudioManager.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 12/17/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import Foundation
import AVFoundation

struct AudioManager {
    
    static var settings: [String:Any] = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                                         AVSampleRateKey: 44100.0,
                                         AVNumberOfChannelsKey: 2]
    
    static func configureSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .duckOthers])
        try? session.overrideOutputAudioPort(.speaker)
        try? session.setActive(true)
    }
    
    static func getVoiceMemoDirectory() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let voiceMemoDirectory = "VoiceMemos"
        let fileURL = documentsDirectory.appendingPathComponent(voiceMemoDirectory)
        let fileURLString = fileURL.path
        
        do {
            try FileManager.default.createDirectory(atPath: fileURLString, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            NSLog("\(error.localizedDescription)")
        }

        return fileURL
    }
    
    static func getVoiceMemoName(existingVoiceMemoName: String?) -> String {
        var voiceMemoName: String
        
        if existingVoiceMemoName == nil {
            voiceMemoName = "DreamVoiceMemo-" + NSUUID().uuidString
        } else {
            voiceMemoName = existingVoiceMemoName!
        }
        
        return voiceMemoName
    }
    
    static func deleteVoiceMemo(withName voiceMemoName: String) {
        let voiceMemoURL = getVoiceMemoDirectory().appendingPathComponent(voiceMemoName).appendingPathExtension("m4a")
        do {
            try FileManager.default.removeItem(atPath: voiceMemoURL.path)
        } catch let error as NSError {
            NSLog("Could not delete voice memo. Error: \(error.localizedDescription)")
        }
    }
    
    static func configureAudioRecorder(url: URL) -> AVAudioRecorder? {
        var audioRecorder: AVAudioRecorder?
        
        do {
            try audioRecorder = AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.prepareToRecord()
        } catch let error as NSError {
            NSLog("\(error.localizedDescription)")
        }
        
        return audioRecorder
    }
    
    static func configureAudioPlayer(url: URL, audioPlayerDelegate: VoiceRecorderViewController) -> AVAudioPlayer? {
        var audioPlayer: AVAudioPlayer?

        do {
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.delegate = audioPlayerDelegate
        } catch let error as NSError {
            NSLog("\(error.localizedDescription)")
        }
        
        return audioPlayer
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
