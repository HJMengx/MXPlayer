//
//  FFPresentationController.m
//  FFTransition
//
//  Created by mx on 2016/10/25.
//  Copyright © 2016年 mengx. All rights reserved.
//

#import "FFPresentationController.h"

@implementation FFPresentationController


- (void)presentationTransitionWillBegin{
    self.presentedView.frame = self.containerView.frame;
    [self.containerView addSubview:self.presentedView];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed{
    [self.presentedView removeFromSuperview];
}

@end
