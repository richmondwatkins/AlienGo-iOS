//
//  NRCategorySelectionViewController.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/13/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class NRCategorySelectionViewController: UIViewController {
    
    let cellClassName: String = String(describing: CategoryCollectionViewCell.self)
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(UINib(nibName: cellClassName, bundle: Bundle.main), forCellWithReuseIdentifier: cellClassName)
        }
    }
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            self.doneButton.isEnabled = false
        }
    }
    var viewModel: NRCategorySelectionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NRCategorySelectionViewModel(displayDelegate: self)
        
        self.doneButton.layer.borderWidth = 1
        self.doneButton.layer.borderColor = UIColor(ColorConstants.appBlue).cgColor
    }
    
    @IBAction func didSelectDone(_ sender: UIButton) {
        
    }
}

extension NRCategorySelectionViewController: NRCategorySelectionViewModelDisplayDelegate {
    
    func enabledDoneButton() {
        self.doneButton.isEnabled = true
    }
    
    func disableDoneButton() {
        self.doneButton.isEnabled = false
    }
}

extension NRCategorySelectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var cellSpacing: CGFloat {
        return 9
    }
    
    var cellHeight: CGFloat {
        return 65
    }
    
    var margins: CGFloat {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CategoryCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellClassName, for: indexPath) as! CategoryCollectionViewCell
        
        cell.configure(cateogry: viewModel.categories[indexPath.row], delegate: viewModel)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: margins, bottom: 0, right: margins)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 2 - cellSpacing - margins, height: cellHeight)
    }
}
