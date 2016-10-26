//
//  ViewController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol ActionDelegate {
    func showFrontPage()
    func showAll()
}

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
        settingsView.actionDelegate = viewModel
        
        settingsView.layer.zPosition = CGFloat.greatestFiniteMagnitude
        
        view.addSubview(settingsView)
        
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
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension MainViewController: RedditPostListingNavigationDelegate {
    
    func didFinishReadingAfterSwipe(direction: ScrollDirection) {
        
    }
    
    func displayDetailVC() {
        didSingleTap()
    }
}
