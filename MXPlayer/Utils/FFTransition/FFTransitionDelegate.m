//
//  FFTransitionDelegate.m
//  FFTransition
//
//  Created by mx on 2016/10/25.
//  Copyright © 2016年 mengx. All rights reserved.
//

#import "FFTransitionDelegate.h"
#import "FFAnimatedTransitioning.h"
#import "FFPresentationController.h"

@interface FFTransitionDelegate()

@end

@implementation FFTransitionDelegate

static FFTransitionDelegate* _instance;

+ (instancetype)shareInstance{
    if(!_instance){
        _instance = [[FFTransitionDelegate alloc] init];
    }
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    if(!_instance){
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            _instance = [super allocWithZone:zone];
        });
    }
    return _instance;
}

- (instancetype)init{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _instance = [super init];
    });
    return _instance;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    FFAnimatedTransitioning* animated = [[FFAnimatedTransitioning alloc] init];
    
    animated.type = Dismiss;
    
    animated.duration = 2;
    
    return animated;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    
    FFAnimatedTransitioning* animated = [[FFAnimatedTransitioning alloc] init];
    
    animated.type = Presented;
    
    animated.duration = 2;
    
    return animated;
}


- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source{
    
    FFPresentationController* presentController = [[FFPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
    
    return presentController;
}
@end
