//
//  SwipeToShowAnimationController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class SwipeToShowAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let percentDrivenController: SwipeToShowInteractionController
    
    init(percentDrivenController: SwipeToShowInteractionController) {
        self.percentDrivenController = percentDrivenController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.6
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        let containerView = transitionContext.containerView
        let _ = transitionContext.initialFrame(for: fromVC)
        let _ = fromVC.view.snapshotView(afterScreenUpdates: false)

        containerView.addSubview(toVC.view)
        
        var toX = containerView.frame.width
        var fromX = -(fromVC.view.frame.width)
        if percentDrivenController.showState == .detail {
            toX = -(containerView.frame.width)
            fromX = containerView.frame.width
        }
        
        toVC.view.frame = CGRect(x: toX, y: 0, width: fromVC.view.frame.width, height: fromVC.view.frame.height)
        
        UIView.animate(withDuration: 0.6, animations: {
            fromVC.view.frame = CGRect(x: fromX, y: fromVC.view.frame.origin.y, width: fromVC.view.frame.width, height: fromVC.view.frame.height)
            toVC.view.frame = CGRect(x: 0, y: 0, width: fromVC.view.frame.width, height: fromVC.view.frame.height)
            
        }) { (finished) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
