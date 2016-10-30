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
    var childVC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let commentLongPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showComments(press:)))
        view.addGestureRecognizer(commentLongPress)
        
        let exitTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pop))
        exitTap.numberOfTapsRequired = 2
        exitTap.delegate = self
        view.addGestureRecognizer(exitTap)
    }
    
    func showComments(press: UILongPressGestureRecognizer) {
        viewModel.showComments(press: press)
    }
    
    func pop() {
        viewModel.navBack()
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        childVC?.view.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel.disappearFromSettings {
            viewModel.disappearFromSettings = false
        } else if viewModel.disappearFromCommentPopover {
            viewModel.disappearFromCommentPopover = false
            
            if StateProvider.isAuto {
                pop()
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeChildVCIfNeeded()
        
        viewModel.viewDidDisappear()
    }
    
    func removeChildVCIfNeeded() {
        
        if let childVC = childVC, !viewModel.disappearFromCommentPopover, !viewModel.disappearFromSettings {
            childVC.willMove(toParentViewController: nil)
            childVC.view.removeFromSuperview()
            childVC.removeFromParentViewController()
        }
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
        if vc is CommentViewController && !UserAppState.hasSeenOnboarding {
            (vc as! CommentViewController).tableYConstraintVal = 100
            vc.modalPresentationStyle = .overCurrentContext
        }
        
        present(vc, animated: true, completion: nil)
    }
}
