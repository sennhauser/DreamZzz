//
//  DreamTableViewCell.swift
//  DreamZzz
//
//  Created by Claudio Sennhauser on 12/4/17.
//  Copyright © 2017 Claudio Sennhauser. All rights reserved.
//

import UIKit

class DreamTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var moodLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    let moods = ["☹️", "😐", "😀"]
    
    let appTintColor = UIColor(red: -0.0127815, green: 0.37506, blue: 0.366638, alpha: 1)
    
    func configure(for dream: Dream) {
        let dateTextAttributes = [NSAttributedStringKey.foregroundColor: appTintColor]
        let descriptionTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.gray]
        
        let attributedDescriptionString = NSMutableAttributedString(string: DateTimeFormatter.dreamDateShort.string(from: dream.date), attributes: dateTextAttributes)
        
        if let dreamDescription = dream.description {
            attributedDescriptionString.append(NSMutableAttributedString(string: "  " +  dreamDescription, attributes:  descriptionTextAttributes))
        }
        
        titleLabel.text = dream.title
        descriptionLabel.attributedText = attributedDescriptionString
        
        if dream.mood != UISegmentedControlNoSegment {
            moodLabel.text = moods[dream.mood]
        } else {
            moodLabel.text = "-"
        }
        
        if let categoryId = dream.categoryId, let categories = DreamCategory.loadCategories() {
            for category in categories {
                if category.id == categoryId {
                    categoryLabel.text = category.name
                    break
                }
            }
        } else {
            categoryLabel.text = ""
        }
    }
}
