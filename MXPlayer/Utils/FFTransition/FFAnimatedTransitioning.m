//
//  FFAnimatedTransitioning.m
//  FFTransition
//
//  Created by mx on 2016/10/25.
//  Copyright © 2016年 mengx. All rights reserved.
//

#import "FFAnimatedTransitioning.h"

@interface FFAnimatedTransitioning() <UIViewControllerAnimatedTransitioning,CAAnimationDelegate>

@property (nonatomic,strong,nonnull)id<UIViewControllerContextTransitioning> context;

@property (nonnull,nonatomic,strong)CAShapeLayer* UpLayer;

@property (nonatomic,nonnull,strong)CAShapeLayer* DownLayer;

@property (nonnull,nonatomic,strong)CAShapeLayer* MiddleLayer;

@property (nonatomic,strong,nonnull)UIBezierPath* FromPath;

@property (nonatomic,strong,nonnull)UIBezierPath* ToPath;

@property (nonnull,nonatomic,strong)UIBezierPath* UpPath;

@property (nonatomic,nonnull,strong)UIBezierPath* DownPath;

@property (nullable,nonatomic,strong)UIView* AnimationView;

//动画
@property (nonatomic,nonnull,strong)CABasicAnimation* ToViewAnimationUp;

@property (nonatomic,nonnull,strong)CABasicAnimation* FromViewAnimationUp;

@property (nonatomic,nonnull,strong)CABasicAnimation* ToViewAnimationDown;

@property (nonatomic,nonnull,strong)CABasicAnimation* FromViewAnimationDown;

@property (nonatomic,nonnull,strong)CAAnimationGroup* ToViewAnimationMiddle;

@property (nonatomic,nonnull,strong)CAAnimationGroup* FromViewAnimationMiddle;

//判断条件
@property (nonatomic,assign)BOOL IsPresentedComplete;

@property (nonatomic,assign)BOOL IsDismissComplete;

@end

@implementation FFAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    self.context = transitionContext;
    
    if(self.duration == 0 || self.duration == 2){
        return DEFAULTDURATION;
    }
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    
    UIView* ToView = [transitionContext viewForKey:UITransitionContextToViewKey];
    
    UIView* FromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    if(self.type == Presented){
        
        [ToView.layer addSublayer:self.MiddleLayer];
        [ToView.layer addSublayer:self.UpLayer];
        [ToView.layer addSublayer:self.DownLayer];
    }else{
        
        //Dismiss,时间要快，退出等待时间不好
        [FromView.layer addSublayer:self.MiddleLayer];
        [FromView.layer addSublayer:self.UpLayer];
        [FromView.layer addSublayer:self.DownLayer];
    }
     //Presented
    if(self.type == Presented){
        
        [self.MiddleLayer addAnimation:self.ToViewAnimationMiddle forKey:@"ToViewMiddle"];
        [self.UpLayer addAnimation:self.ToViewAnimationUp forKey:@"ToViewUp"];
        [self.DownLayer addAnimation:self.ToViewAnimationDown forKey:@"ToViewDown"];
     
        //[ToView addSubview:self.AnimationView];
    }else{
        
        [self.MiddleLayer addAnimation:self.FromViewAnimationMiddle forKey:@"FromViewDown"];
        [self.UpLayer addAnimation:self.FromViewAnimationUp forKey:@"FromViewUp"];
        [self.DownLayer addAnimation:self.FromViewAnimationDown forKey:@"FromViewDown"];
        
        
        //[FromView addSubview:self.AnimationView];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self CompletionAnimation];
}
//完成动画
- (void)CompletionAnimation{
    [self.context completeTransition:YES];
    
    [self.UpLayer removeFromSuperlayer];
    [self.DownLayer removeFromSuperlayer];
    [self.MiddleLayer removeFromSuperlayer];
}

- (void)animationEnded:(BOOL)transitionCompleted{
    //完成动画
}

- (UIBezierPath *)UpPath{
    
    if(!_UpPath){
        _UpPath = [UIBezierPath bezierPath];
        [_UpPath moveToPoint:LeftStartPoint];
        [_UpPath addLineToPoint:LeftendPoint];
        
        UIBezierPath* UpCirclePath = [UIBezierPath bezierPath];
        [UpCirclePath addArcWithCenter:CircleCenter radius:RADIUS startAngle:0 endAngle:M_PI clockwise:NO];
        
        [_UpPath appendPath:UpCirclePath];
        
        [_UpPath moveToPoint:RightStartPoint];
        [_UpPath addLineToPoint:RightEndPoint];
    }
    
    return _UpPath;
}

- (UIBezierPath *)DownPath{
    
    if(!_DownPath){
        _DownPath = [UIBezierPath bezierPath];
        [_DownPath moveToPoint:CGPointMake(LeftStartPoint.x, 0)];
        [_DownPath addLineToPoint:CGPointMake(LeftendPoint.x, 0)];
        
        UIBezierPath* DownCirclePath = [UIBezierPath bezierPath];
        [DownCirclePath addArcWithCenter:CGPointMake(CircleCenter.x, 0) radius:RADIUS startAngle:0 endAngle:M_PI clockwise:YES];
        
        [_DownPath appendPath:DownCirclePath];
        
        [_DownPath moveToPoint:CGPointMake(RightStartPoint.x, 0)];
        [_DownPath addLineToPoint:CGPointMake(RightEndPoint.x, 0)];
    }
    
    
    return _DownPath;
}

- (UIBezierPath *)FromPath{
    //dismiss
    if(!_FromPath){
        _FromPath = [UIBezierPath bezierPath];
        //A
        [_FromPath moveToPoint:CGPointMake(CircleCenter.x - RADIUS * sin(ANGLEFORMIDDLE), CircleCenter.y + RADIUS * cos(ANGLEFORMIDDLE))];
        //C
        [_FromPath addLineToPoint:CGPointMake(CircleCenter.x - RADIUS * sin(ANGLEFORMIDDLE), CircleCenter.y - RADIUS *cos(ANGLEFORMIDDLE))];
        //B
        [_FromPath moveToPoint:CGPointMake(CircleCenter.x + RADIUS * sin(ANGLEFORMIDDLE), CircleCenter.y - cos(ANGLEFORMIDDLE))];
        //D
        [_FromPath addLineToPoint:CGPointMake(CircleCenter.x + RADIUS * sin(ANGLEFORMIDDLE), CircleCenter.y + RADIUS * cos(ANGLEFORMIDDLE))];
        
        _FromPath.lineWidth = 3;
    }
    
    return _FromPath;
}

- (UIBezierPath *)ToPath{
    //present
    if(!_ToPath){
        //三角形
        _ToPath = [UIBezierPath bezierPath];
        
        //基于屏幕的
        //        [_ToPath moveToPoint:CGPointMake(CircleCenter.x - RADIUS * sin(ANGLEFORMIDDLE), CircleCenter.y - RADIUS * cos(ANGLEFORMIDDLE))];
        //
        //        [_ToPath addLineToPoint:CGPointMake(CircleCenter.x - RADIUS * sin(ANGLEFORMIDDLE),CircleCenter.y + RADIUS *cos(ANGLEFORMIDDLE))];
        //
        //        [_ToPath addLineToPoint:CGPointMake(CircleCenter.x + RADIUS, CircleCenter.y)];
        //基于Layer的
        [_ToPath moveToPoint:CGPointMake(RADIUS * 2 * cos(M_PI / 6) - RectLength,  0)];
        
        [_ToPath addLineToPoint:CGPointMake(RADIUS * 2 * cos(M_PI / 6) - RectLength,RectLength)];
        
        [_ToPath addLineToPoint:CGPointMake(RectLength, RectLength / 2)];
        
        [_ToPath closePath];
        _ToPath.lineWidth = 3;
    }
    
    return _ToPath;
}

- (CAShapeLayer *)UpLayer{
    
    if(!_UpLayer){
        _UpLayer = [CAShapeLayer layer];
        _UpLayer.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight / 2);
        _UpLayer.path = self.UpPath.CGPath;
        _UpLayer.strokeColor = [UIColor whiteColor].CGColor;
        _UpLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    
    return _UpLayer;
}

- (CAShapeLayer *)DownLayer{
    
    if(!_DownLayer){
        _DownLayer = [CAShapeLayer layer];
        _DownLayer.frame = CGRectMake(0, ScreenHeight / 2, ScreenWidth, ScreenHeight / 2);
        _DownLayer.path = self.DownPath.CGPath;
        _DownLayer.strokeColor = [UIColor whiteColor].CGColor;
        _DownLayer.backgroundColor = [UIColor blackColor].CGColor;
    }
    
    return _DownLayer;
}

- (CAShapeLayer *)MiddleLayer{
    
    if(!_MiddleLayer){
        _MiddleLayer = [CAShapeLayer layer];
        _MiddleLayer.path = self.ToPath.CGPath;
        //设置frame才能设置锚点
        _MiddleLayer.frame = CGRectMake(ScreenWidth / 2 - RADIUS  * cos(M_PI_4), ScreenHeight / 2 - RADIUS * cos(M_PI_4), RADIUS * cos(M_PI_4), RADIUS * cos(M_PI_4));
        _MiddleLayer.anchorPoint = CGPointMake(0.5, 0.5);
        
        _MiddleLayer.strokeColor = [UIColor whiteColor].CGColor;
    }
    
    return _MiddleLayer;
}

- (UIView *)AnimationView{
    
    if(!_AnimationView){
        _AnimationView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        
        [_AnimationView.layer addSublayer:self.DownLayer];
        [_AnimationView.layer addSublayer:self.UpLayer];
        [_AnimationView.layer addSublayer:self.MiddleLayer];
        
    }
    
    return _AnimationView;
}

- (CABasicAnimation *)ToViewAnimationUp{
    
    if(!_ToViewAnimationUp){
        _ToViewAnimationUp = [CABasicAnimation animationWithKeyPath:@"position.y"];
        _ToViewAnimationUp.fromValue = [NSNumber numberWithFloat:self.UpLayer.position.y];
        _ToViewAnimationUp.toValue = [NSNumber numberWithFloat:-self.UpLayer.position.y];
        _ToViewAnimationUp.removedOnCompletion = NO;
        _ToViewAnimationUp.repeatCount = 1;
        _ToViewAnimationUp.duration = self.duration;
        _ToViewAnimationUp.autoreverses = NO;
        _ToViewAnimationUp.fillMode = kCAFillModeForwards;
        _ToViewAnimationUp.delegate = self;
    }
    
    return _ToViewAnimationUp;
}

- (CABasicAnimation *)FromViewAnimationUp{
    
    if(!_FromViewAnimationUp){
        _FromViewAnimationUp = [CABasicAnimation animationWithKeyPath:@"position.y"];
        _FromViewAnimationUp.toValue = [NSNumber numberWithFloat:self.UpLayer.position.y];
        _FromViewAnimationUp.fromValue = [NSNumber numberWithFloat:-self.UpLayer.position.y];
        _FromViewAnimationUp.removedOnCompletion = NO;
        _FromViewAnimationUp.repeatCount = 1;
        _FromViewAnimationUp.duration = self.duration;
        _FromViewAnimationUp.autoreverses = NO;
        _FromViewAnimationUp.fillMode = kCAFillModeForwards;
        _FromViewAnimationUp.delegate = self;
    }
    
    return _FromViewAnimationUp;
}

- (CABasicAnimation *)ToViewAnimationDown{
    
    if(!_ToViewAnimationDown){
        _ToViewAnimationDown = [CABasicAnimation animationWithKeyPath:@"position.y"];
        _ToViewAnimationDown.toValue = [NSNumber numberWithFloat:self.DownLayer.position.y + self.DownLayer.bounds.size.height];
        _ToViewAnimationDown.fromValue = [NSNumber numberWithFloat:self.DownLayer.position.y];
        _ToViewAnimationDown.removedOnCompletion = NO;
        _ToViewAnimationDown.repeatCount = 1;
        _ToViewAnimationDown.duration = self.duration;
        _ToViewAnimationDown.autoreverses = NO;
        _ToViewAnimationDown.fillMode = kCAFillModeForwards;
    }
    
    return _ToViewAnimationDown;
}

- (CABasicAnimation *)FromViewAnimationDown{
    
    if(!_FromViewAnimationDown){
        _FromViewAnimationDown = [CABasicAnimation animationWithKeyPath:@"position.y"];
        _FromViewAnimationDown.toValue = [NSNumber numberWithFloat:self.DownLayer.position.y];
        _FromViewAnimationDown.fromValue = [NSNumber numberWithFloat:self.DownLayer.position.y + self.DownLayer.bounds.size.height];
        _FromViewAnimationDown.removedOnCompletion = NO;
        _FromViewAnimationDown.repeatCount = 1;
        _FromViewAnimationDown.duration = self.duration;
        _FromViewAnimationDown.autoreverses = NO;
        _FromViewAnimationDown.fillMode = kCAFillModeForwards;
    }
    
    return _FromViewAnimationDown;
}

- (CAAnimationGroup *)ToViewAnimationMiddle{
    
    if(!_ToViewAnimationMiddle){
        CABasicAnimation* MiddleRotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        MiddleRotateAnimation.fromValue = [NSNumber numberWithFloat:0];
        MiddleRotateAnimation.toValue = [NSNumber numberWithFloat:-M_PI_2];
        MiddleRotateAnimation.duration = self.duration / 2;
        MiddleRotateAnimation.repeatCount = 1;
        MiddleRotateAnimation.removedOnCompletion = NO;
        MiddleRotateAnimation.fillMode = kCAFillModeForwards;
        MiddleRotateAnimation.autoreverses = NO;
        //旋转之后等价于上移了一半的边长，所以要下移
        CABasicAnimation* MiddleDownAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        MiddleDownAnimation.fromValue = [NSNumber numberWithFloat:_MiddleLayer.position.y];
        MiddleDownAnimation.toValue = [NSNumber numberWithFloat:_MiddleLayer.position.y + RectLength / 2];
        MiddleDownAnimation.duration = self.duration / 2;
        MiddleDownAnimation.repeatCount = 1;
        MiddleDownAnimation.removedOnCompletion = NO;
        MiddleDownAnimation.fillMode = kCAFillModeForwards;
        MiddleDownAnimation.autoreverses = NO;
        
        //动画组
        _ToViewAnimationMiddle = [CAAnimationGroup animation];
        _ToViewAnimationMiddle.animations = @[MiddleRotateAnimation,MiddleDownAnimation];
        _ToViewAnimationMiddle.duration = self.duration / 2;
        _ToViewAnimationMiddle.repeatCount = 1;
        _ToViewAnimationMiddle.removedOnCompletion = NO;
        _ToViewAnimationMiddle.fillMode = kCAFillModeForwards;
        _ToViewAnimationMiddle.autoreverses = NO;
    }
    
    return _ToViewAnimationMiddle;
}

- (CAAnimationGroup *)FromViewAnimationMiddle{
    
    if(!_FromViewAnimationMiddle){
        CABasicAnimation* MiddleRotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        MiddleRotateAnimation.fromValue = [NSNumber numberWithFloat:-M_PI_2];
        MiddleRotateAnimation.toValue = [NSNumber numberWithFloat:0];
        MiddleRotateAnimation.duration = self.duration / 2;
        MiddleRotateAnimation.repeatCount = 1;
        MiddleRotateAnimation.removedOnCompletion = NO;
        MiddleRotateAnimation.autoreverses = NO;
        MiddleRotateAnimation.fillMode = kCAFillModeForwards;
        [self.MiddleLayer addAnimation:MiddleRotateAnimation forKey:@"Middle"];
        
        CABasicAnimation* MiddleUpAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
        MiddleUpAnimation.fromValue = [NSNumber numberWithFloat:_MiddleLayer.position.y + RectLength / 2];
        MiddleUpAnimation.toValue = [NSNumber numberWithFloat:_MiddleLayer.position.y];
        MiddleUpAnimation.duration = self.duration / 2;
        MiddleUpAnimation.repeatCount = 1;
        MiddleUpAnimation.removedOnCompletion = NO;
        MiddleUpAnimation.fillMode = kCAFillModeForwards;
        MiddleUpAnimation.autoreverses = NO;
        
        //动画组
        _FromViewAnimationMiddle = [CAAnimationGroup animation];
        _FromViewAnimationMiddle.animations = @[MiddleRotateAnimation,MiddleUpAnimation];
        _FromViewAnimationMiddle.duration = self.duration / 2;
        _FromViewAnimationMiddle.repeatCount = 1;
        _FromViewAnimationMiddle.removedOnCompletion = NO;
        _FromViewAnimationMiddle.fillMode = kCAFillModeForwards;
        _FromViewAnimationMiddle.autoreverses = NO;
    }
    
    return _FromViewAnimationMiddle;
}
@end
