//
//  SettingsView.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/11/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

enum SettingsState {
    case closed, open
}

let nSettingsWillShow = Notification.Name("SettingsWillShow")
let nSettingsWillHide = Notification.Name("SettingsWillHide")

class SettingsView: UIView {

    @IBOutlet weak var containerView: UIView!
    var state: SettingsState = .closed
    var settingsVC: UINavigationController?
    var actionDelegate: ActionDelegate!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let touch: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showSettingsVC))
        touch.numberOfTapsRequired = 1
        addGestureRecognizer(touch)
    }
    
    @IBAction func didSelectSettings(_ sender: UIButton) {
        showSettingsVC()
    }
    
    func showSettingsVC() {
        NotificationCenter.default.post(name: nSettingsWillShow, object: nil)
        
        settingsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingsNavigationController") as? UINavigationController
        
        if settingsVC?.topViewController is SettingsViewController {
            (settingsVC?.topViewController as! SettingsViewController)._actionDelegate = actionDelegate
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.presentViewControllerFromVisibleViewController(viewControllerToPresent: settingsVC!, animated: true, completion: nil)
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.layer.cornerRadius = containerView.frame.height / 2
        
        let bezPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: containerView.layer.cornerRadius)
        containerView.layer.masksToBounds = false
        containerView.layer.shadowColor = UIColor("#D3D3D3").cgColor
        containerView.layer.shadowOffset = CGSize(width: 1, height: 1)
        containerView.layer.shadowOpacity = 0.5
        containerView.layer.shadowPath = bezPath.cgPath
    }
}
