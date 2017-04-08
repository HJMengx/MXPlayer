//
//  MXTransitionDelegate.swift
//  MXPlayer
//
//  Created by mx on 2017/3/3.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

class MXTransitionDelegate:NSObject,UIViewControllerTransitioningDelegate {
   
    static let share = MXTransitionDelegate()
    
    private override init(){
        super.init()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animation = MXTransitionAnimation()
        
        animation.type = .dismiss
        
        return animation
    }
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
       
        let animation = MXTransitionAnimation()
        
        animation.type = .present
        
        return animation
    }
    
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        let controller = MXTransitionPresentationController.init(presentedViewController: presented, presenting: presenting)
        
        return controller
    }
    

}
