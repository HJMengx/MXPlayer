//
//  MXTransitionAnimation.swift
//  MXPlayer
//
//  Created by mx on 2017/3/3.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

enum MXAnimationType{
    case present
    case dismiss
}

class MXTransitionAnimation: NSObject,CAAnimationDelegate,UIViewControllerAnimatedTransitioning{
    
    var type : MXAnimationType!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    //动画执行
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //取出View,都是操作同一个
        //放到前面的时候
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        //从前面消失的时候
        let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from)
        //动画
        if self.type == .present {
            //后面到前面来
            //扩大
            toView!.transform = toView!.transform.scaledBy(x: 0.1, y: 0.1)
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                
                toView!.transform = CGAffineTransform.identity
                
            }, completion: { (isComplete : Bool) in
                transitionContext.completeTransition(true)
            })
        }else{
            //前面的消失，缩小
            //扩大
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.allowUserInteraction, animations: {
                fromView!.transform = fromView!.transform.scaledBy(x: 0.01, y: 0.01)
            }, completion: { (isComplete : Bool) in
                transitionContext.completeTransition(true)
            })
        }
    }
}
