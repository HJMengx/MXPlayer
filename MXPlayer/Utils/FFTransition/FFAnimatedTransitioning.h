//
//  FFAnimatedTransitioning.h
//  FFTransition
//
//  Created by mx on 2016/10/25.
//  Copyright © 2016年 mengx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    Presented,
    Dismiss
}PresentedType;

#define DEFAULTDURATION 2

#define RADIUS 30

#define ScreenWidth [UIScreen mainScreen].bounds.size.width

#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define LeftStartPoint CGPointMake(0, ScreenHeight / 2)

#define LeftendPoint CGPointMake(ScreenWidth / 2 - RADIUS,ScreenHeight / 2)

#define RightStartPoint CGPointMake(ScreenWidth / 2 + RADIUS,ScreenHeight / 2)

#define RightEndPoint CGPointMake(ScreenWidth, ScreenHeight / 2)

#define CircleCenter CGPointMake(ScreenWidth / 2,ScreenHeight / 2)

#define ANGLEFORMIDDLE M_PI / 6

#define RectLength RADIUS * 2 * cos(M_PI_4)
@interface FFAnimatedTransitioning : NSObject

@property (assign,nonatomic)PresentedType type;

@property (assign,nonatomic)CGFloat duration;
@end
