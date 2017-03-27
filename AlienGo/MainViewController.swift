//
//  ViewController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol ActionDelegate: class {
    func showFrontPage()
    func showAll()
    func show(subreddit: Category)
}

class MainViewController: UIViewController {

    @IBOutlet weak var loadingLabel: LoadingLabel!
    @IBOutlet var viewModel: RedditPostListingViewModel! {
        didSet {
            viewModel.navigationDelegate = self
            viewModel.getPostsFor(subreddit: Category(name: "front"))
        }
    }
    private var disapearFromDetailNav: Bool = false
    private var settingsView: SettingsView = Bundle.main.loadNibNamed("SettingsView", owner: nil, options: nil)!.first as! SettingsView
    private var disappearFromInstructionsVC: Bool = false
    private var viewDidDisappearFromPush: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingLabel.start()
        
        let settingsWidthHeight: CGFloat = 50
        
        settingsView.frame = CGRect(x: UIScreen.main.bounds.width - settingsWidthHeight - 8, y: 15, width: settingsWidthHeight, height: settingsWidthHeight)
        settingsView.actionDelegate = viewModel
        
        settingsView.layer.zPosition = 100
        
        view.addSubview(settingsView)
        
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(reReadCurrent(press:)))
        view.addGestureRecognizer(longPress)
        
        let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didSingleTap))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if disapearFromDetailNav && (StateProvider.isAuto || UserAppState.autoNavAfterComments) {
            viewModel.readAndShowNextPost()
            disapearFromDetailNav = false
        } else if disappearFromInstructionsVC {
            viewModel.readFirst()
            disappearFromInstructionsVC = false
        }
        
        viewDidDisappearFromPush = false
        
        if Configuration.showCategorySelection && !UserAppState.hasSelectedCategories {
            self.presentViewControllerFromVisibleViewController(viewControllerToPresent: UIStoryboard(name: "Onboarding", bundle: Bundle.main).instantiateViewController(withIdentifier: "NRCategorySelectionViewController"), animated: true, completion: nil)
        }
    }
    
    func reReadCurrent(press: UILongPressGestureRecognizer) {
        viewModel.reReadCurrent(press: press)
    }
    
    func didSingleTap() {
        viewModel.didSelect()
        disapearFromDetailNav = true
        
        if !viewDidDisappearFromPush {
            viewDidDisappearFromPush = true
            let detailViewController = storyboard!.instantiateViewController(withIdentifier: String(describing: DetailViewController.self)) as! DetailViewController
            if let detaiViewModel = viewModel.getDetailViewModel(detailViewController: detailViewController) {
                detailViewController.viewModel = detaiViewModel
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
    }
    
    func setupDetailVC() {
       
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension MainViewController: RedditPostListingNavigationDelegate {
    func showingCategory(category: Category) {
        DispatchQueue.main.async {
            self.loadingLabel.text = category.name
        }
    }
    
    func didFinishReadingAfterSwipe(direction: ScrollDirection) {
        
    }
    
    func displayDetailVC() {
        didSingleTap()
    }
    
    func loading() {
        loadingLabel.start()
    }
}
