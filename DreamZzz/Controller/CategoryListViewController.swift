//
//  CategoryListViewController.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 12/3/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import UIKit

class CategoryListViewController: UITableViewController {
    
    var dreamCategories = [DreamCategory]()
    var selectedCategoryId: Int?
    
    override func viewDidLoad() {
        if let savedCategories = DreamCategory.loadCategories() {
            dreamCategories = savedCategories
        } else {
            dreamCategories = DreamCategory.loadSampleCategories()
            let sortedCategories = dreamCategories.sorted(by: { $0.name.caseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending })
            dreamCategories = sortedCategories
            DreamCategory.saveCategories(dreamCategories)
        }
    }
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dreamCategories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") else {
            fatalError(NSLocalizedString("Could not dequeue CategoryCell.", comment: ""))
        }
        if let dreamCategoryId = selectedCategoryId {
            if dreamCategoryId == dreamCategories[indexPath.row].id {
                cell.backgroundColor = UIColor(red: 0.851, green: 0.851, blue: 0.851, alpha: 1.0)
            } else {
                cell.backgroundColor = tableView.backgroundColor
            }
        }
        cell.tintColor = UIColor.lightGray
        cell.textLabel?.text = dreamCategories[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            dreamCategories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            DreamCategory.saveCategories(dreamCategories)
            selectedCategoryId = nil
        }
    }
    
    // MARK: - Navigation
    @IBAction func unwindToCategoryListViewController(segue: UIStoryboardSegue) {
        guard segue.identifier == "saveUnwind" else { return }
        guard let sourceViewController = segue.source as? CategoryViewController else { return }
        
        if let category = sourceViewController.dreamCategory {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if sourceViewController.deleteDreamCategory {
                    dreamCategories.remove(at: selectedIndexPath.row)
                    tableView.deleteRows(at: [selectedIndexPath], with: .fade)
                    DreamCategory.saveCategories(dreamCategories)
                    selectedCategoryId = nil
                } else {
                    dreamCategories[selectedIndexPath.row] = category
                    selectedCategoryId = category.id
                }
            } else {
                dreamCategories.sort { $0.id < $1.id }
                var newCategory = category
                if let lastCategory = dreamCategories.last {
                    newCategory.id = lastCategory.id + 1
                    dreamCategories.append(newCategory)
                }
            }
            let sortedCategories = dreamCategories.sorted(by: { $0.name.caseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending })
            dreamCategories = sortedCategories
            tableView.reloadData()
        }
        DreamCategory.saveCategories(dreamCategories)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditCategory" {
            guard let categoryViewController = segue.destination as? CategoryViewController else { return }
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                categoryViewController.dreamCategory = dreamCategories[indexPath.row]
                selectedCategoryId = nil
            }
        } else if segue.identifier == "categorySelectedUnwind" {
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                selectedCategoryId = dreamCategories[indexPath.row].id
            }
        }
    }
}
