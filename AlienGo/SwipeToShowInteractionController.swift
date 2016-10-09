//
//  SwipeToShowAnimationController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

enum SwipeToShowState {
    case main, detail
}

class SwipeToShowInteractionController: UIPercentDrivenInteractiveTransition {
    var navigationController: UINavigationController!
    var mainViewController: UIViewController!
    var detailViewController: UIViewController!
    var shouldCompleteTransition = false
    var transitionInProgress = false
    var completionSeed: CGFloat {
        return 1 - percentComplete
    }
    var showState: SwipeToShowState = .main
    var initialTranslation: CGFloat = 0
    var gesture: UIPanGestureRecognizer!
    
    func attachToViewController(viewController: UIViewController) {
        navigationController = viewController.navigationController
        setupGestureRecognizer(view: viewController.view)
    }
    
    private func setupGestureRecognizer(view: UIView) {
        gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(gestureRecognizer:)))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
    }
    
    func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        let viewTranslation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        let panVelocity = gestureRecognizer.velocity(in: gestureRecognizer.view)
        let percentComplete: CGFloat = abs(viewTranslation.x - initialTranslation) / 200
       
        switch gestureRecognizer.state {
        case .began:
            initialTranslation = viewTranslation.x
           
            if abs(panVelocity.y) < 100 {
                switch showState {
                case .main:
                    navigationController.pushViewController(detailViewController, animated: true)
                    break
                case .detail:
                    navigationController.popViewController(animated: true)
                    break
                }
                transitionInProgress = true
            }
        case .changed:
//            if showState == .main && gestureRecognizer.isLeft() ||
//                showState == .detail && !gestureRecognizer.isLeft() {
                shouldCompleteTransition = percentComplete > 0.5
//                
                if percentComplete <= 1.0 && transitionInProgress {
                    update(percentComplete)
                }
//            }
        case .cancelled, .ended:
            if transitionInProgress {
                if !shouldCompleteTransition || gestureRecognizer.state == .cancelled {
                    cancel()
                } else  {
                    finish()
                }
                
                transitionInProgress = false
            }
        default:
            print("Swift switch must be exhaustive, thus the default")
        }
    }
    
    override func finish() {
        super.finish()
        sharedComplete(didCancel: false)
    }
    
    override func cancel() {
        super.cancel()
        sharedComplete(didCancel: true)
    }
    
    private func sharedComplete(didCancel: Bool) {
        if !didCancel && showState == .main && shouldCompleteTransition {
            showState = .detail
            mainViewController.view.removeGestureRecognizer(gesture)
            attachToViewController(viewController: detailViewController)
        } else if !didCancel && shouldCompleteTransition {
            showState = .main
            detailViewController.view.removeGestureRecognizer(gesture)
            attachToViewController(viewController: mainViewController)
        }
    }
}

extension SwipeToShowInteractionController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UIPanGestureRecognizer {
    
    func isLeft() -> Bool {
        return velocity(in: self.view).x < 0
    }
}

