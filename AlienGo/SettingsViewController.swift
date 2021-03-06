//
//  SettingsViewController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/11/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {


    @IBOutlet var tableSource: SettingsTableSource! {
        didSet {
            tableSource.displayDelegate = self
        }
    }
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var helpButton: UIButton! {
        didSet {
            originalButtonColor = helpButton.titleLabel?.textColor
        }
    }
    weak var _actionDelegate: ActionDelegate?
    private var originalButtonColor: UIColor!
    //Auto mode tries to navigate the app for you. Auto mode on the comments screen reads the top 3 comments and their direct replies
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController!.setNavigationBarHidden(true, animated: true)
        
        tableSource.refresh()
    }

    @IBAction func selectHelp(_ sender: UIButton) {
        let helpVC: InstructionsViewController = self.storyboard!.instantiateViewController(withIdentifier: String(describing: InstructionsViewController.self)) as! InstructionsViewController
        
        present(helpVC, animated: true, completion: nil)
    }
    
    @IBAction func close(_ sender: UIButton) {
        NotificationCenter.default.post(name: nSettingsWillHide, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func onSelected() {

    }
    
    func offSelected() {

    }
    
    func setColors(selected: UIView, selectedLabel: UILabel, notSelected: UIView, notSelectedLabel: UILabel) {
        
        selected.backgroundColor = UIColor(ColorConstants.appBlue)
        selectedLabel.textColor = .white
        
        notSelected.backgroundColor = .white
        notSelectedLabel.textColor = UIColor(ColorConstants.appBlue)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension SettingsViewController: SettingsDisplayDelegate {
    weak var actionDelegate: ActionDelegate? {
        return _actionDelegate
    }

    var vc: UIViewController {
        return self
    }
    
    func display(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
