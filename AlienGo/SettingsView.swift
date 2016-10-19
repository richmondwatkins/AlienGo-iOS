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
  
    @IBAction func didSelectSettings(_ sender: UIButton) {
        NotificationCenter.default.post(name: nSettingsWillShow, object: nil)
        
        settingsVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "SettingsNavigationController") as? UINavigationController
        
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

extension UIViewController {
    func presentViewControllerFromVisibleViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        if let navigationController = self as? UINavigationController {
            navigationController.topViewController?.presentViewControllerFromVisibleViewController(viewControllerToPresent: viewControllerToPresent, animated: flag, completion: completion)
        } else if let tabBarController = self as? UITabBarController {
            tabBarController.selectedViewController?.presentViewControllerFromVisibleViewController(viewControllerToPresent: viewControllerToPresent, animated: flag, completion: completion)
        } else if let presentedViewController = presentedViewController {
            presentedViewController.presentViewControllerFromVisibleViewController(viewControllerToPresent: viewControllerToPresent, animated: flag, completion: completion)
        } else {
            present(viewControllerToPresent, animated: flag, completion: completion)
        }
    }
}
