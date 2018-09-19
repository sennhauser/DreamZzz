//
//  AppDelegate.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 11/27/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataModel = DataModel()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let navigationController = window!.rootViewController as! UINavigationController
        let controller = navigationController.viewControllers.first as! DreamListViewController
        
        controller.dataModel = dataModel
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        dataModel.saveDreams()
        saveAppState()
    }
    
    func saveAppState() {
        let navigationController = window!.rootViewController as! UINavigationController
        let currentViewController = navigationController.viewControllers.last!
        
        if let editDreamViewController = currentViewController as? EditDreamViewController {
            saveDream(from: editDreamViewController)
        } else if let dreamListViewController = currentViewController as? DreamListViewController,
            let navigationController = dreamListViewController.presentedViewController as? UINavigationController,
            let editDreamViewController = navigationController.viewControllers.last as? EditDreamViewController {
            saveDream(from: editDreamViewController)
        }
    }
    
    func saveDream(from viewController: EditDreamViewController) {
        let title = viewController.titleTextField.text!
        let description = viewController.descriptionTextField.text
        let isLucid = viewController.isLucidSwitch.isOn
        let dreamDate = viewController.dreamDatePicker.date
        let mood = viewController.moodSegementedController.selectedSegmentIndex
        let categoryId: Int?
        let voiceMemo: String?

        if let selectedCategoryId = viewController.selectedCategoryId {
            categoryId = selectedCategoryId
        } else {
            categoryId = nil
        }
        if let voiceMemoName = viewController.voiceMemoName {
            voiceMemo = voiceMemoName
        } else {
            voiceMemo = nil
        }

        let dream = Dream(title: title,
                          description: description,
                          isLucid: isLucid,
                          date: dreamDate,
                          mood: mood,
                          categoryId: categoryId,
                          voiceMemoName: voiceMemo)
        
        if let existingDream = viewController.dream, let indexOfExistingDream = dataModel.dreams.index(of: existingDream) {
            UserDefaults.standard.set(indexOfExistingDream, forKey: "dreamIndex")
        } else {
            UserDefaults.standard.set(-1, forKey: "dreamIndex")
        }
        
        UserDefaults.standard.set(try? PropertyListEncoder().encode(dream), forKey: "temporaryDream")
    }
}

