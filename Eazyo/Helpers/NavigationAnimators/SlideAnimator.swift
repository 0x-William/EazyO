//
//  SlideUpAnimator.swift
//  Eazyo
//
//  Created by SoftDev0420 on 3/24/16.
//  Copyright © 2016 SoftDev0420. All rights reserved.
//

let SLIDE_UP_PUSH = 0
let SLIDE_DOWN_POP = 1

let SLIDE_DOWN_PUSH = 2

class SlideAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let slideType: Int
    let duration: TimeInterval = 0.5
    
    init(slideType: Int) {
        self.slideType = slideType
        
        super.init()
    }
    
    // ---- UIViewControllerAnimatedTransitioning methods
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)  {
        switch slideType {
        case SLIDE_UP_PUSH:
            animatePresentationWithSlideUpTransitionContext(transitionContext)
            break
            
        case SLIDE_DOWN_POP:
            animateDismissalWithSlideDownTransitionContext(transitionContext)
            break
            
        case SLIDE_DOWN_PUSH:
            animatePresentationWithSlideDownTransitionContext(transitionContext)
            break
            
        default:
            break
        }
    }
    
    // ---- Helper methods
    
    func animatePresentationWithSlideUpTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        // Position the presented view off the top of the container view
        
        toViewController.view.frame.origin.y = containerView.bounds.size.height
        containerView.insertSubview(toViewController.view, aboveSubview: fromViewController.view)
        
        // Animate the presented view to it's final position
        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            toViewController.view.frame.origin.y = 0
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
        })
    }
    
    func animateDismissalWithSlideDownTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        // Animate the presented view off the bottom of the view
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            fromViewController.view.frame.origin.y = containerView.bounds.size.height
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
        })
    }
    
    func animatePresentationWithSlideDownTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        
        // Animate the presented view off the bottom of the view
        containerView.insertSubview(toViewController.view, belowSubview: fromViewController.view)
        
        UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
            fromViewController.view.frame.origin.y = containerView.bounds.size.height
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
        })
    }
}
