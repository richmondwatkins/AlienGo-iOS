//
//  NRCategorySelectionViewModel.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/13/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol NRCategorySelectionViewModelDisplayDelegate {
    func enabledDoneButton()
    func disableDoneButton()
}

class NRCategorySelectionViewModel {

    var categories: [Category] = CategoryDataSourceBuilder.build()
    let displayDelegate: NRCategorySelectionViewModelDisplayDelegate
    
    init(displayDelegate: NRCategorySelectionViewModelDisplayDelegate) {
        self.displayDelegate = displayDelegate
    }
    
    func didSelectDone() {
        //Save selected categories and setup NYT api
    }
}

extension NRCategorySelectionViewModel: CategoryCollectionViewCellDelegate {
    
    func didSelect(category: Category) {
        let catIndex = categories.index(of: category)!
        
        categories.remove(at: categories.index(of: category)!)
        categories.insert(category, at: catIndex)
        
        if self.categories.filter({ $0.getSubscribed() }).count > 0 {
            self.displayDelegate.enabledDoneButton()
        } else {
            self.displayDelegate.disableDoneButton()
        }
    }
}
