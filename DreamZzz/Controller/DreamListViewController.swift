//
//  DreamListViewController.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 11/27/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import UIKit

class DreamListViewController: UITableViewController, UISearchBarDelegate {
    
    var dataModel: DataModel!
    var filteredDreams = [Dream]()
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchControllerIsHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.scopeButtonTitles = [NSLocalizedString("All", comment: ""),
                                                        NSLocalizedString("Lucid", comment: ""),
                                                        NSLocalizedString("Non-Lucid", comment: "")]
        searchController.searchBar.delegate = self
                
        if let data = UserDefaults.standard.value(forKey:"temporaryDream") as? Data {
            if let dream = try? PropertyListDecoder().decode(Dream.self, from: data) {
                performSegue(withIdentifier: "EditDream", sender: dream)
                UserDefaults.standard.set(nil, forKey: "temporaryDream")
            }
        } else {
            UserDefaults.standard.set(-1, forKey: "dreamIndex")
        }
    }
    
    // MARK: - Search Bar
    @IBAction func searchBarButtonTapped(_ sender: UIBarButtonItem) {
        if searchControllerIsHidden {
            searchController.searchBar.tintColor = (navigationController?.navigationBar.tintColor)!
            searchController.searchResultsUpdater = self
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = NSLocalizedString("Search Dreams", comment: "")
            searchController.searchBar.delegate = self
            navigationItem.searchController = searchController
            navigationItem.hidesSearchBarWhenScrolling = false
            definesPresentationContext = true
            searchControllerIsHidden = false
            delay(0.1) { self.searchController.searchBar.becomeFirstResponder() }
        } else {
            navigationItem.searchController = nil
            searchControllerIsHidden = true
        }
    }
    
    func delay(_ delay: Double, closure: @escaping ()->()) {
        let when = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.searchController = nil
        searchControllerIsHidden = true
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: Int) {
        filteredDreams = dataModel.dreams.filter({( dream : Dream) -> Bool in
            
            var isLucid = false
            if scope == 1 {
                isLucid = true
            }
            
            let doesLucidityMatch = (scope == 0) || (dream.isLucid == isLucid)
            
            if searchBarIsEmpty() {
                return doesLucidityMatch
            } else {
                let titleContainsSearchTerm = dream.title.lowercased().contains(searchText.lowercased())
                var descriptionContainsSearchTerm = false
                if let dreamDescription = dream.description {
                    descriptionContainsSearchTerm = dreamDescription.lowercased().contains(searchText.lowercased())
                }
                var categoryContainsSearchTerm = false
                if let categoryId = dream.categoryId, let categories = DreamCategory.loadCategories() {
                    for category in categories {
                        if category.id == categoryId {
                            if let index = categories.index(of: category) {
                                categoryContainsSearchTerm = categories[index].name.lowercased().contains(searchText.lowercased())
                            }
                        }
                    }
                }
                let dreamContainsSearchTerm = titleContainsSearchTerm || descriptionContainsSearchTerm || categoryContainsSearchTerm
                return doesLucidityMatch && dreamContainsSearchTerm
            }
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.selectedScopeButtonIndex)
    }
    
    // MARK: - Table View Delegates
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredDreams.count
        }
        return dataModel.dreams.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 82
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DreamCell") as? DreamTableViewCell else {
            fatalError(NSLocalizedString("Could not dequeue DreamCell.", comment: ""))
        }
        let dream: Dream
        if isFiltering() {
            dream = filteredDreams[indexPath.row]
        } else {
            dream = dataModel.dreams[indexPath.row]
        }
        cell.configure(for: dream)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let voiceMemoName = dataModel.dreams[indexPath.row].voiceMemoName {
                AudioManager.deleteVoiceMemo(withName: voiceMemoName)
            }
            dataModel.dreams.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // MARK: - Navigation
    @IBAction func unwindToDreamList(segue: UIStoryboardSegue) {
        guard let sourceViewController = segue.source as? EditDreamViewController else { return }
        
        let existingDreamIndex = UserDefaults.standard.integer(forKey: "dreamIndex")
        
        if let dream = sourceViewController.dream {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                if sourceViewController.deleteDream {
                    dataModel.dreams.remove(at: selectedIndexPath.row)
                    tableView.deleteRows(at: [selectedIndexPath], with: .fade)
                    if let voiceMemoName = dream.voiceMemoName {
                        AudioManager.deleteVoiceMemo(withName: voiceMemoName)
                    }
                } else {
                    dataModel.dreams[selectedIndexPath.row] = dream
                }
            } else if existingDreamIndex != -1 {
                let indexPath = IndexPath(row: existingDreamIndex, section: 0)
                dataModel.dreams[indexPath.row] = dream
                UserDefaults.standard.set(-1, forKey: "dreamIndex")
            }  else {
                dataModel.dreams.append(dream)
            }
            dataModel.dreams = dataModel.dreams.sorted(by: { $0.date.compare($1.date) == .orderedDescending })
            tableView.reloadData()
        } else if let voiceMemoName = sourceViewController.voiceMemoName {
            AudioManager.deleteVoiceMemo(withName: voiceMemoName)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if segue.identifier == "ShowDream" {
            guard let showDreamViewController = segue.destination as? ShowDreamViewController else { return }
            
            if let indexPath = tableView.indexPathForSelectedRow {
                let dream: Dream
                if isFiltering() {
                    dream = filteredDreams[indexPath.row]
                } else {
                    dream = dataModel.dreams[indexPath.row]
                }
                showDreamViewController.dream = dream
            }
        } else if segue.identifier == "EditDream" {
            if let navigationViewController = segue.destination as? UINavigationController,
                let editDreamViewController = navigationViewController.viewControllers.last as? EditDreamViewController,
                let dream = sender as? Dream {
                editDreamViewController.dream = dream
            }
        }
    }
}


// MARK: -
extension DreamListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.selectedScopeButtonIndex
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

