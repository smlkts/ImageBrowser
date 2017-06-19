//
//  IBPresent.m
//  ImageBrowser
//
//  Created by 张雁军 on 2017/5/23.
//  Copyright © 2017年 smlkts. All rights reserved.
//

#import "IBPresent.h"

@implementation IBPresent

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 2.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *inView = [transitionContext containerView];
    UINavigationController *toNC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *toVC = toNC.topViewController;
    [inView addSubview:toVC.view];

    toVC.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [UIView animateWithDuration:0.25f animations:^{
        toVC.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}
@end
