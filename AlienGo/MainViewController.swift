//
//  ViewController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet var viewModel: RedditPostListingViewModel! {
        didSet {
            viewModel.navigationDelegate = self
        }
    }
    fileprivate lazy var swipeInteractionController = SwipeToShowInteractionController()
    fileprivate var swipeAnimationController: SwipeToShowAnimationController!
    fileprivate var detailViewController: DetailViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavAnimations()
        
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        tapGesture.numberOfTapsRequired = 2
        
        view.addGestureRecognizer(tapGesture)
    }
    
    func didTap() {
//        setupDetailVC()
//        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func setupDetailVC() {
        self.detailViewController = storyboard!.instantiateViewController(withIdentifier: String(describing: DetailViewController.self)) as! DetailViewController
        
        swipeInteractionController.detailViewController = detailViewController
        swipeInteractionController.mainViewController = self
        swipeInteractionController.attachToViewController(viewController: self)
    }
    
    private func setUpNavAnimations() {
        swipeAnimationController = SwipeToShowAnimationController(percentDrivenController: self.swipeInteractionController)
        
        setupDetailVC()
        
        navigationController?.delegate = self
    }
}

extension MainViewController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if operation == .push {
            detailViewController.viewModel = viewModel.getDetailViewModel(detailViewController: detailViewController)
        }
        
        return swipeAnimationController
    }
    
    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        
        return swipeInteractionController
    }
}

extension MainViewController: RedditPostListingNavigationDelegate {
    
    func display(vc: DetailViewController) {
        //swipeInteractionController.toViewController = vc
    }
}
