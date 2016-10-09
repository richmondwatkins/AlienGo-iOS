//
//  DetailViewController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var viewModel: DetailViewModel! {
        didSet {
             viewModel.getInfo()
        }
    }
    var disappearFromCommentPopover: Bool = false
    var childVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let commentTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didDoubletap))
        commentTapGesture.numberOfTapsRequired = 2
        
        view.addGestureRecognizer(commentTapGesture)
    }
    
    func didDoubletap() {
        disappearFromCommentPopover = true
        viewModel.didDoubletap()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        childVC?.view.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if disappearFromCommentPopover {
            disappearFromCommentPopover = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let childVC = childVC, !disappearFromCommentPopover {
            childVC.willMove(toParentViewController: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParentViewController()
        }
        
        viewModel.viewDidDisappear()
    }
}

extension DetailViewController: DetailViewModelDelegate {
    
    func display(childVC: UIViewController) {
        DispatchQueue.main.async {
            self.childVC = childVC
            
            self.addChildViewController(childVC)
            childVC.view.frame = self.view.bounds
            self.view.addSubview(childVC.view)
            childVC.didMove(toParentViewController: self)
        }
    }
    
    func present(vc: UIViewController) {
        present(vc, animated: true, completion: nil)
    }
}
