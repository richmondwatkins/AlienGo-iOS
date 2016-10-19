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
    private var originalButtonColor: UIColor!
    var reader: ReadableDelegate = ReadHandler.shared
    //Auto mode tries to navigate the app for you. Auto mode on the comments screen reads the top 3 comments and their direct replies
    
    override func viewDidLoad() {
        super.viewDidLoad()
//
//        let onTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSelected))
//        onTap.numberOfTapsRequired = 1
//        
//        autoOnView.addGestureRecognizer(onTap)
//        
//        let offTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(offSelected))
//        offTap.numberOfTapsRequired = 1
//        
//        autoOffView.addGestureRecognizer(offTap)
//        
//        if StateProvider.isAuto {
//           onSelected()
//        }
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
}

extension SettingsViewController: SettingsDisplayDelegate {
    
    func display(vc: UIViewController) {
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
