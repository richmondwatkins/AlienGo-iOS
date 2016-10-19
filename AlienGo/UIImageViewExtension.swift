//
//  UIImageViewExtension.swift
//  ReaderApp
//
//  Created by Richmond Watkins on 5/14/16.
//  Copyright © 2016 Apptly. All rights reserved.
//

import UIKit
import PINRemoteImage

extension UIImageView {
    
    func ra_setImageFromUrlString(urlString: String?, defaultToPlaceholder: Bool = true, completion: ((_ image: UIImage?) -> Void)? = nil) {
        if let urlString = urlString {
            ra_setImageFromURL(url: URL(string:  urlString), defaultToPlaceholder: defaultToPlaceholder, completion: completion)
        } else {
            ra_setImageFromURL(url: nil, completion: completion)
        }
    }
    
    func ra_setImageFromURL(url: URL?, defaultToPlaceholder: Bool = true, completion: ((_ image: UIImage?) -> Void)? = nil)  {
        let placeholder = defaultToPlaceholder ? UIImage(named: "placeholder") : nil
        
        if let url = url {
            self.pin_setImage(from: url, placeholderImage: #imageLiteral(resourceName: "placeholder"), completion: { (result) in
                if result.resultType == .download {
                    UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: {
                        if let image = result.image {
                            self.image = image
                        } else if defaultToPlaceholder {
                            self.image = placeholder
                        }
                        
                        }, completion: nil)
                } else {
                    self.image = result.image
                }
                
                completion?(result.image)
            })
        } else if defaultToPlaceholder {
            self.image = placeholder
            completion?(nil)
        }
    }
}
