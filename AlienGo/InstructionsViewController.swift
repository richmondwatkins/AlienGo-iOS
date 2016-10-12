//
//  InstructionsViewController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/11/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class InstructionsViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let v = settingsView() {
            v.isHidden = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let v = settingsView() {
            v.isHidden = false
        }
    }
    
    func settingsView() -> SettingsView? {
        for view in UIApplication.shared.keyWindow!.subviews {
            if view is SettingsView {
                return view as? SettingsView
            }
        }
        
        return nil
    }
    
    @IBAction func close(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "hasLaunched")
        UserDefaults.standard.synchronize()
        self.dismiss(animated: true, completion: nil)
    }
}
