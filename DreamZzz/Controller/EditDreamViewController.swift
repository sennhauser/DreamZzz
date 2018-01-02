//
//  EditDreamViewController.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 11/27/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import UIKit
import AVFoundation

class EditDreamViewController: UITableViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var dreamDateLabel: UILabel!
    @IBOutlet weak var dreamDatePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var voiceMemoLabel: UILabel!
    @IBOutlet weak var isLucidSwitch: UISwitch!
    @IBOutlet weak var moodSegementedController: UISegmentedControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    
    var dream: Dream?
    var selectedCategoryId: Int?
    var voiceMemoName: String?
    var deleteDream = false
    
    var isDreamDatePickerHidden = true
    let dreamTitleCell = IndexPath(row: 0, section: 0)
    let descriptionCell = IndexPath(row: 0, section: 1)
    let dreamDateCell = IndexPath(row: 0, section: 2)
    let deleteCellIndex = IndexPath(row: 0, section: 3)
    let voiceMemoCell = IndexPath(row: 4, section: 2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        isLucidSwitch.onTintColor = (navigationController?.navigationBar.tintColor)!
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
        
        tableView.rowHeight = 44.0
        
        let moodAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white]
        moodSegementedController.setTitleTextAttributes(moodAttributes, for: .selected)
        moodSegementedController.tintColor = UIColor.gray
        
        updateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let deleteCell = tableView(tableView, cellForRowAt: deleteCellIndex)
        let tableBackgroundColor = tableView.backgroundColor
        deleteCell.backgroundColor = tableBackgroundColor
        tableView.separatorColor = tableBackgroundColor
    }
    
    func updateUI() {
        if let selectedDream = dream {
            navigationItem.title = NSLocalizedString("Edit Dream", comment: "")
            deleteButton.isHidden = false
            titleTextField.text = selectedDream.title
            dreamDatePicker.date = selectedDream.date
            descriptionTextField.text = selectedDream.description
            isLucidSwitch.isOn = selectedDream.isLucid
            moodSegementedController.selectedSegmentIndex = selectedDream.mood
            
            if selectedDream.voiceMemoName != nil {
                voiceMemoLabel.text = NSLocalizedString("Listen", comment: "")
                voiceMemoName = selectedDream.voiceMemoName
            }
            
            if let categoryId = selectedDream.categoryId, let categories = DreamCategory.loadCategories() {
                for category in categories {
                    if category.id == categoryId {
                        categoryLabel.text = category.name
                        selectedCategoryId = category.id
                        break
                    }
                }
            } else {
                categoryLabel.text = NSLocalizedString("Not Set", comment: "")
            }
            
            if UserDefaults.standard.integer(forKey: "dreamIndex") == -1 {
                deleteButton.isHidden = true
            }
        } else {
            dreamDatePicker.date = Date()
        }
        updateDreamDateLabel(date: dreamDatePicker.date)
        updateSaveButtonState()
    }
    
    func updateSaveButtonState() {
        let text = titleTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    func updateDreamDateLabel(date: Date) {
        dreamDateLabel.text = DateTimeFormatter.dreamDateTime.string(from: date)
    }
    
    // MARK: - Actions
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        titleTextField.resignFirstResponder()
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        updateDreamDateLabel(date: dreamDatePicker.date)
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        showDeleteDreamAlert()
    }
    
    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        if indexPath != nil && (indexPath == dreamTitleCell || indexPath == dreamDateCell) {
            return
        }
        titleTextField.resignFirstResponder()
        descriptionTextField.resignFirstResponder()
        
        if !isDreamDatePickerHidden {
            isDreamDatePickerHidden = !isDreamDatePickerHidden
            dreamDateLabel.textColor = isDreamDatePickerHidden ? .black : tableView.tintColor
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    func showDeleteDreamAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Delete Dream", comment: ""),
                                      message: NSLocalizedString("Are you sure you want to delete this dream?", comment: ""),
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive) { (_) in
            self.deleteDream = true
            self.performSegue(withIdentifier: "saveUnwind", sender: self.dream)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let normalCellHeight = CGFloat(44)
        var largeCellHeight = CGFloat(200)
        
        switch indexPath {
        case dreamDateCell:
            if Device.IS_IPHONE_5 {
                largeCellHeight = largeCellHeight - 24
            }
            if Device.IS_IPHONE_6 {
                largeCellHeight = largeCellHeight - 44
            }
            return isDreamDatePickerHidden ? normalCellHeight : largeCellHeight
        case descriptionCell:
            if Device.IS_IPHONE_5 {
                largeCellHeight = largeCellHeight - 132
            }
            if Device.IS_IPHONE_6 {
                largeCellHeight = largeCellHeight - 44
            }
            return largeCellHeight
        default:
            return normalCellHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch(indexPath) {
        case dreamDateCell:
            isDreamDatePickerHidden = !isDreamDatePickerHidden
            dreamDateLabel.textColor = isDreamDatePickerHidden ? .black : tableView.tintColor
            tableView.beginUpdates()
            tableView.endUpdates()
            
        default:
            break
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        
        if indexPath == voiceMemoCell {
            let session = AVAudioSession.sharedInstance()
            if session.recordPermission() == .undetermined {
                session.requestRecordPermission({ (granted: Bool) -> Void in })
                return nil
            } else if session.recordPermission() == .denied {
                showMicrophoneAccessDeniedAlert()
                return nil
            }
        }
        return indexPath
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if dream != nil {
            return 4
        } else {
            return 3
        }
    }
    
    func showMicrophoneAccessDeniedAlert() {
        let alert = UIAlertController(title: NSLocalizedString("Microphone Access Disabled", comment: ""),
                                      message: NSLocalizedString("To record voice memos, please allow access to the microphone for DreamZzz in Settings.", comment: ""),
                                      preferredStyle: .alert)
            let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "cancelUnwind" {
            dream = nil
        } else if segue.identifier == "saveUnwind" {
            var title = titleTextField.text!
            let description = descriptionTextField.text
            let isLucid = isLucidSwitch.isOn
            let dreamDate = dreamDatePicker.date
            let mood = moodSegementedController.selectedSegmentIndex
            let categoryId: Int?
            let voiceMemo: String?
            
            if title.isEmpty {
                title = NSLocalizedString("New Dream", comment: "")
            }
            if let selectedCategoryId = selectedCategoryId {
                categoryId = selectedCategoryId
            } else {
                categoryId = nil
            }
            if let voiceMemoName = voiceMemoName {
                voiceMemo = voiceMemoName
            } else {
                voiceMemo = nil
            }
            dream = Dream(title: title,
                          description: description,
                          isLucid: isLucid,
                          date: dreamDate,
                          mood: mood,
                          categoryId: categoryId,
                          voiceMemoName: voiceMemo)
        } else if segue.identifier == "SelectCategory" {
            guard let destination = segue.destination as? CategoryListViewController else { return }
            
            if let selectedCategoryId = selectedCategoryId {
                destination.selectedCategoryId = selectedCategoryId
            }
        } else if segue.identifier == "RecordVoiceMemo" {
            guard let destination = segue.destination as? VoiceRecorderViewController else { return }
            
            if let voiceMemoName = voiceMemoName {
                destination.voiceMemoName = voiceMemoName
            }
        }
    }
    
    @IBAction func unwindToDreamViewController(segue: UIStoryboardSegue) {

        if let sourceViewController = segue.source as? CategoryListViewController {
            if let categoryId = sourceViewController.selectedCategoryId {
                selectedCategoryId = categoryId
                
                guard let categories = DreamCategory.loadCategories() else { return }
                
                for category in categories {
                    if category.id == selectedCategoryId {
                        if let index = categories.index(of: category) {
                            categoryLabel.text = categories[index].name
                            return
                        }
                    }
                }
            }
            categoryLabel.text = NSLocalizedString("Not Set", comment: "")
        }
        
        if let sourceViewController = segue.source as? VoiceRecorderViewController {
            if let voiceMemo = sourceViewController.voiceMemoName {
                voiceMemoName = voiceMemo
                voiceMemoLabel.text = NSLocalizedString("Listen", comment: "")
            } else {
                if dream != nil {
                    dream!.voiceMemoName = nil
                }
                voiceMemoName = nil
                voiceMemoLabel.text = NSLocalizedString("Record", comment: "")
            }
        }
    }
}
