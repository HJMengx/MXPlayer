//
//  MXTransitionPresentationController.swift
//  MXPlayer
//
//  Created by mx on 2017/3/3.
//  Copyright © 2017年 mengx. All rights reserved.
//

import UIKit

class MXTransitionPresentationController: UIPresentationController {
   
    override func presentationTransitionWillBegin() {
        self.presentedView?.frame = (self.containerView?.frame)!
        self.containerView?.addSubview(self.presentedView!)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        self.presentedView?.removeFromSuperview()
    }
    
    public override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
}
