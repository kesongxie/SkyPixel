//
//  HorizontalSlideInAnimator.m
//  SkyPixel
//
//  Created by Xie kesong on 12/25/16.
//  Copyright © 2016 ___KesongXie___. All rights reserved.
//


#import "HorizontalSlideInAnimator.h"


static NSTimeInterval const TransitionDuration = 0.30;

@interface HorizontalSlideInAnimator()

@end


@implementation HorizontalSlideInAnimator

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return TransitionDuration;
}


- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // Get the set of relevant objects.
    UIView *containerView = [transitionContext containerView];
    containerView.backgroundColor = [UIColor blueColor];

    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    CGRect toViewStartFrame;
    CGRect toViewFinalFrame;
    CGRect fromViewFinalFrame;
    // Set up the animation parameters.
    [containerView addSubview:toView];

    if (!self.animatorForDismiss) {
        // Modify the frame of the presented view so that it starts
        // offscreen at the lower-right corner of the container.
        toViewStartFrame = CGRectMake(containerView.frame.size.width, 0, containerView.frame.size.width, containerView.frame.size.height);
        toViewFinalFrame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    }else{
        toViewStartFrame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
        fromViewFinalFrame = CGRectMake(containerView.frame.size.width, 0, containerView.frame.size.width, containerView.frame.size.height);
        [containerView addSubview:fromView];
    }
    toView.frame = toViewStartFrame;
    [UIView animateWithDuration:[self transitionDuration: transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        if (!self.animatorForDismiss) {
            [toView setFrame:toViewFinalFrame];
            self.animatorForDismiss = YES;
        }else{
            [fromView setFrame:fromViewFinalFrame];
            self.animatorForDismiss = NO;
        }
    }  completion:^(BOOL finished){
        BOOL success = ![transitionContext transitionWasCancelled];
        // Notify UIKit that the transition has finished
        [transitionContext completeTransition:success];
    }];
}

@end
