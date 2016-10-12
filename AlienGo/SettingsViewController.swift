//
//  SettingsViewController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/11/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var autoOnView: UIView!
    @IBOutlet weak var autoOffView: UIView!
    @IBOutlet weak var offLabel: UILabel!
    @IBOutlet weak var onLabel: UILabel!
    
    var reader: ReadableDelegate = ReadHandler.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let onTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onSelected))
        onTap.numberOfTapsRequired = 1
        
        autoOnView.addGestureRecognizer(onTap)
        
        let offTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(offSelected))
        offTap.numberOfTapsRequired = 1
        
        autoOffView.addGestureRecognizer(offTap)
        
        if StateProvider.isAuto {
            setColors(selected: autoOnView, selectedLabel: onLabel, notSelected: autoOffView, notSelectedLabel: offLabel)
        }
    }

    @IBAction func selectHelp(_ sender: UIButton) {
        let helpVC: InstructionsViewController = self.storyboard!.instantiateViewController(withIdentifier: String(describing: InstructionsViewController.self)) as! InstructionsViewController
        
        present(helpVC, animated: true, completion: nil)
    }
    
    func onSelected() {
        StateProvider.isAuto = true
        
        setColors(selected: autoOnView, selectedLabel: onLabel, notSelected: autoOffView, notSelectedLabel: offLabel)
        
        reader.readItem(readableItem: ReaderContainer(text: "Auto Mode On"), delegate: nil, completion: nil)
    }
    
    func offSelected() {
        StateProvider.isAuto = false
        
        setColors(selected: autoOffView, selectedLabel: offLabel, notSelected: autoOnView, notSelectedLabel: onLabel)
        
        reader.readItem(readableItem: ReaderContainer(text: "Auto Mode Off"), delegate: nil, completion: nil)
    }
    
    func setColors(selected: UIView, selectedLabel: UILabel, notSelected: UIView, notSelectedLabel: UILabel) {
        
        selected.backgroundColor = UIColor(ColorConstants.appBlue)
        selectedLabel.textColor = .white
        
        notSelected.backgroundColor = .white
        notSelectedLabel.textColor = UIColor(ColorConstants.appBlue)
    }
}
