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
    private var settingsView: SettingsView = Bundle.main.loadNibNamed("SettingsView", owner: nil, options: nil)!.first as! SettingsView
    private var disappearFromInstructionsVC: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let settingsWidthHeight: CGFloat = 60
        
        settingsView.frame = CGRect(x: UIScreen.main.bounds.width - settingsWidthHeight - 8, y: UIApplication.shared.statusBarFrame.height, width: settingsWidthHeight, height: settingsWidthHeight)
        
        settingsView.layer.zPosition = CGFloat.greatestFiniteMagnitude
        
        view.addSubview(settingsView)
        
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(reReadCurrent(press:)))
        view.addGestureRecognizer(longPress)
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
        
        if !UserDefaults.standard.bool(forKey: "hasLaunched") {
            let helpVC: InstructionsViewController = self.storyboard!.instantiateViewController(withIdentifier: String(describing: InstructionsViewController.self)) as! InstructionsViewController
            
            
            
            present(helpVC, animated: true, completion: {
                self.disappearFromInstructionsVC = true
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if disapearFromDetailNav && StateProvider.isAuto {
            viewModel.readAndShowNextPost()
            disapearFromDetailNav = false
        } else if disappearFromInstructionsVC {
            viewModel.readFirst()
            disappearFromInstructionsVC = false
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
