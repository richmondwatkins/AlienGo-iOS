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
    private var disapearFromDetailNav: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        setUpNavAnimations()
        
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(reReadCurrent(press:)))
        view.addGestureRecognizer(longPress)
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if disapearFromDetailNav && StateProvider.isAuto {
            viewModel.readAndShowNextPost()
            disapearFromDetailNav = false
        }
    }
    
    func reReadCurrent(press: UILongPressGestureRecognizer) {
        viewModel.reReadCurrent(press: press)
    }
    
    func didSingleTap() {
        setupDetailVC()
        disapearFromDetailNav = true
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func setupDetailVC() {
        self.detailViewController = storyboard!.instantiateViewController(withIdentifier: String(describing: DetailViewController.self)) as! DetailViewController
        detailViewController.viewModel = viewModel.getDetailViewModel(detailViewController: detailViewController)        
    }
    
    private func setUpNavAnimations() {
        swipeAnimationController = SwipeToShowAnimationController(percentDrivenController: self.swipeInteractionController)
        
        setupDetailVC()
        
        navigationController?.delegate = self
    }
}

extension MainViewController: UINavigationControllerDelegate {
    
//    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        
//        if operation == .push {
//            detailViewController.viewModel = viewModel.getDetailViewModel(detailViewController: detailViewController)
//        }
//        
//        return swipeAnimationController
//    }
//    
//    func navigationController(_ navigationController: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
//        
//        return swipeInteractionController
//    }
}

extension MainViewController: RedditPostListingNavigationDelegate {
    
    func displayDetailVC() {
        didSingleTap()
    }
}
