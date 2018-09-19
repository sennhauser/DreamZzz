//
//  ShowDreamViewController.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 12/8/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import UIKit
import AVFoundation

class ShowDreamViewController: UIViewController, AVAudioPlayerDelegate {
    
    var dream: Dream?
    var audioPlayer: AVAudioPlayer?
    var audioURL: URL?

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dreamTitleLabel: UILabel!
    @IBOutlet weak var dreamDescriptionTextView: UITextView!
    @IBOutlet weak var playVoiceMailButton: UIButton!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var lucidLabel: UILabel!
    @IBOutlet weak var titleView: UIView!
    
    @IBOutlet weak var moodStackView: UIStackView!
    @IBOutlet weak var lucidStackView: UIStackView!
    @IBOutlet weak var categoryStackView: UIStackView!
    @IBOutlet weak var statusView: UIView!
    
    let moods = ["☹️", "😐", "😀"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let voiceMemoDirectory = "VoiceMemos"
        let fileURL = documentsDirectory.appendingPathComponent(voiceMemoDirectory)
        
        if let dream = dream {
            dateLabel.text = DateTimeFormatter.dreamDateTimeMedium.string(from: dream.date)
            dreamTitleLabel.text = dream.title
            dreamTitleLabel.textColor =  (navigationController?.navigationBar.tintColor)!
            dreamDescriptionTextView.text = dream.description
            if let voiceMemoName = dream.voiceMemoName {
                audioURL = fileURL.appendingPathComponent(voiceMemoName).appendingPathExtension("m4a")
                playVoiceMailButton.isHidden = false
            } else {
                playVoiceMailButton.isHidden = true
            }
            
            if dream.mood != UISegmentedControl.noSegment {
                moodLabel.text = moods[dream.mood]
            } else {
                moodStackView.isHidden = true
            }
            
            if let categoryId = dream.categoryId, let categories = DreamCategory.loadCategories() {
                for category in categories {
                    if category.id == categoryId {
                        categoryLabel.text = category.name
                        break
                    }
                }
            } else {
                categoryStackView.isHidden = true
            }
            
            if dream.isLucid {
                lucidLabel.text = "✓"
            } else {
                lucidStackView.isHidden = true
            }
            
            if playVoiceMailButton.isHidden == true && moodStackView.isHidden == true &&
               categoryStackView.isHidden == true && lucidStackView.isHidden == true {
                statusView.isHidden = true
            }
        }
    }
        
    @IBAction func playVoiceMemoButtonTapped(_ sender: UIButton) {
        if let url = audioURL {
            if audioPlayer == nil {
                do {
                    try audioPlayer = AVAudioPlayer(contentsOf: url)
                    audioPlayer!.delegate = self
                    audioPlayer!.prepareToPlay()
                    audioPlayer?.play()
                    playVoiceMailButton.setTitle("⏸", for: .normal)
                } catch let error as NSError {
                    NSLog("Couldn't play the voice memo. Error: \(error)")
                }
            } else {
                if audioPlayer!.isPlaying {
                    audioPlayer?.pause()
                    playVoiceMailButton.setTitle("▶️", for: .normal)
                } else {
                    audioPlayer?.play()
                    playVoiceMailButton.setTitle("⏸", for: .normal)
                }
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playVoiceMailButton.setTitle("▶️", for: .normal)
    }
    
    @IBAction func shareButtonTapped(_ sender: UIBarButtonItem) {

        let date = dateLabel.text!
        let title = dreamTitleLabel.text!
        let description = dreamDescriptionTextView.text!
        var mood = "-"
        var category = "-"
        var lucid = "-"
        
        if !moodStackView.isHidden {
            mood = moodLabel.text!
        }
        
        if !categoryStackView.isHidden {
            category = categoryLabel.text!
        }
        
        if !lucidStackView.isHidden {
            lucid = lucidLabel.text!
        }
        
        let dreamToShare: String = """
        \(title)
        
        \(description)
        
        \(NSLocalizedString("Mood", comment: "")): \(mood)
        \(NSLocalizedString("Category", comment: "")): \(category)
        \(NSLocalizedString("Lucid", comment: "")): \(lucid)
        
        \(NSLocalizedString("Dream Date", comment: "")): \(date)
        
        
        *** \(NSLocalizedString("Shared from DreamZzz - my personal dream journal.", comment: "")) ***
        """
        
        let activityViewController = UIActivityViewController(activityItems: [dreamToShare], applicationActivities: [])
        present(activityViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
        if segue.identifier == "EditDream" {
            guard let editDreamViewController = segue.destination as? EditDreamViewController else { return }
            
            if let dream = dream {
                editDreamViewController.dream = dream
                editDreamViewController.isDeleteButtonHidden = false
            }
        }
    }

}
