//
//  CategoryViewController.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 12/3/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import UIKit

class CategoryViewController: UITableViewController {
    
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var deleteButton: UIButton!
    
    var dreamCategory: DreamCategory?
    var deleteDreamCategory = false
    
    let deleteCellIndex = IndexPath(row: 0, section: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let category = dreamCategory {
            categoryTextField.text = category.name
            title = NSLocalizedString("Edit Category", comment: "")
            deleteButton.isHidden = false
        }
        updateSaveButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        categoryTextField.becomeFirstResponder()
        
        let deleteCell = tableView(tableView, cellForRowAt: deleteCellIndex)
        let tableBackgroundColor = tableView.backgroundColor
        deleteCell.backgroundColor = tableBackgroundColor
        tableView.separatorColor = tableBackgroundColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        categoryTextField.resignFirstResponder()
    }
    
    // MARK: - Actions
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: NSLocalizedString("Delete Category", comment: ""), message: NSLocalizedString("Are you sure you want to delete this category?", comment: ""), preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .destructive) { (_) in
            self.deleteDreamCategory = true
            self.performSegue(withIdentifier: "saveUnwind", sender: self.dreamCategory)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        updateSaveButtonState()
    }
    
    @IBAction func returnPressed(_ sender: UITextField) {
        performSegue(withIdentifier: "saveUnwind", sender: dreamCategory)
    }
    
    func updateSaveButtonState() {
        let text = categoryTextField.text ?? ""
        doneBarButton.isEnabled = !text.isEmpty
    }
        
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == "saveUnwind" else { return }
        
        if dreamCategory != nil {
            dreamCategory?.name = categoryTextField.text!
        } else {
            dreamCategory = DreamCategory(id: 0, name: categoryTextField.text!)
        }
     }
}
