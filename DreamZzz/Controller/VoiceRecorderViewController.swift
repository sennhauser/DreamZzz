//
//  VoiceRecorderViewController.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 12/7/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceRecorderViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeSlider: UISlider!
    
    var audioURL: URL?
    var audioRecorder: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?

    var voiceMemoName: String?
    var voiceMemoIsNew = true
    
    var timer: Timer?
    var isRecording = false
    var isPlaying = false
    var needToConfirmBeforeRecording = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        if voiceMemoName != nil {
            voiceMemoIsNew = false
        }
        
        AudioManager.configureSession()
        let voiceMemoURL = AudioManager.getVoiceMemoDirectory()
        voiceMemoName = AudioManager.getVoiceMemoName(existingVoiceMemoName: voiceMemoName)
        
        if let voiceMemoName = voiceMemoName {
            audioURL = voiceMemoURL.appendingPathComponent(voiceMemoName).appendingPathExtension("m4a")
        }
        
        guard let url = audioURL else { return }
        
        if voiceMemoIsNew {
            audioRecorder = AudioManager.configureAudioRecorder(url: url)
            playButton.isHidden = true
            deleteBarButton.isEnabled = false
            timeSlider.isHidden = true
        } else {
            audioPlayer = AudioManager.configureAudioPlayer(url: url, audioPlayerDelegate: self)
            if let duration = audioPlayer?.duration {
                timeLabel.text = DateTimeFormatter.time.string(from: duration)
                timeSlider.maximumValue = Float(duration)
            }
            recordButton.isHidden = true
        }
    }

    @objc func updateTimeLabel() {
        if isRecording {
            if let audioRecorder = audioRecorder {
                timeLabel.text = DateTimeFormatter.time.string(from: audioRecorder.currentTime)
            }
        } else if let audioPlayer = audioPlayer {
            timeLabel.text = DateTimeFormatter.time.string(from: audioPlayer.currentTime)
            timeSlider.value = Float(audioPlayer.currentTime)
        }
    }

    // MARK: - Actions
    @IBAction func recordButtonTapped(_ sender: UIButton) {
        if isRecording {
            audioRecorder?.pause()
            timer?.invalidate()
            saveButton.isEnabled = true
            playButton.isEnabled = true
            deleteBarButton.isEnabled = true
            playButton.isHidden = false
            timeSlider.isHidden = false
            recordButton.setImage(UIImage(named: "audioRecord"), for: .normal)
            isRecording = !isRecording
        } else {
            if needToConfirmBeforeRecording {
                let alert = UIAlertController(title: NSLocalizedString("Overwrite Voice Memo", comment: ""), message: NSLocalizedString("This will overwrite the current voice memo. Are you sure you want to re-record it?", comment: ""), preferredStyle: .alert)
                let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive) { (_) in
                    self.startRecording()
                    self.isRecording = !self.isRecording
                }
                let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
                alert.addAction(okAction)
                alert.addAction(cancelAction)
                present(alert, animated: true, completion: nil)
                needToConfirmBeforeRecording = false
            } else {
                startRecording()
                isRecording = !isRecording
            }
        }
    }
    
    func startRecording() {
        audioRecorder?.record()
        playButton.isHidden = true
        timeSlider.isHidden = true
        timer = Timer.scheduledTimer(timeInterval: 0.0167, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
        playButton.isEnabled = false
        recordButton.setImage(UIImage(named: "audioStopRecording"), for: .normal)
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        audioRecorder?.stop()
        if audioPlayer == nil {
            if let url = audioURL {
                audioPlayer = AudioManager.configureAudioPlayer(url: url, audioPlayerDelegate: self)
            }
        }
        
        if let duration = audioPlayer?.duration {
            timeSlider.maximumValue = Float(duration)
        }
        
        if isPlaying {
            audioPlayer?.pause()
            playButton.setImage(UIImage(named: "audioPlay"), for: .normal)
            timer?.invalidate()
        } else {
            if let audioPlayer = audioPlayer {
                timer = Timer.scheduledTimer(timeInterval: 0.0167, target: self, selector: #selector(updateTimeLabel), userInfo: nil, repeats: true)
                audioPlayer.play()
                playButton.setImage(UIImage(named: "audioPause"), for: .normal)
                recordButton.isHidden = true
            }
        }
        isPlaying = !isPlaying
    }
    
    @IBAction func timeSliderChanged(_ sender: UISlider) {
        if let audioPlayer = audioPlayer {
            audioPlayer.currentTime = Double(sender.value)
            updateTimeLabel()
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        timer?.invalidate()
        audioURL = nil
        if voiceMemoIsNew {
            if let voiceMemoName = voiceMemoName {
                AudioManager.deleteVoiceMemo(withName: voiceMemoName)
                self.voiceMemoName = nil
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        timer?.invalidate()
        
        if voiceMemoIsNew {
            recordButton.isHidden = false
        }
        audioPlayer = nil
        isPlaying = !isPlaying
        playButton.setImage(UIImage(named: "audioPlay"), for: .normal)
        needToConfirmBeforeRecording = true
    }
    
    @IBAction func deleteBarButtonTapped(_ sender: UIBarButtonItem) {
        if audioURL != nil {
            let alert = UIAlertController(title: NSLocalizedString("Delete Voice Memo", comment: ""), message: NSLocalizedString("Are you sure you want to delete this voice memo?", comment: ""), preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive) { (_) in
                if let voiceMemoName = self.voiceMemoName {
                    AudioManager.deleteVoiceMemo(withName: voiceMemoName)
                    self.voiceMemoName = nil
                }
                self.performSegue(withIdentifier: "cancelUnwind", sender: nil)
            }
            
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        audioPlayer?.stop()
        if segue.identifier == "cancelUnwind" {
            if voiceMemoIsNew {
                if let voiceMemoName = voiceMemoName {
                    AudioManager.deleteVoiceMemo(withName: voiceMemoName)
                    self.voiceMemoName = nil
                }
            }
        }
    }
}
