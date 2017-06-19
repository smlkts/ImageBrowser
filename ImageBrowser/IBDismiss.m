//
//  IBDismiss.m
//  ImageBrowser
//
//  Created by 张雁军 on 2017/5/24.
//  Copyright © 2017年 smlkts. All rights reserved.
//

#import "IBDismiss.h"
#import "UIView+Layout.h"

@implementation IBDismiss

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return .25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIView *inView = [transitionContext containerView];
    UINavigationController *fromNC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    IBController *fromVC = fromNC.viewControllers.firstObject;
    CGRect toRect = [fromVC.fromView.superview convertRect:fromVC.fromView.frame toView:fromVC.currentImageView.superview];
    
    fromVC.currentImageView.contentMode = UIViewContentModeScaleAspectFill;
//    [UIView animateWithDuration:0.95 animations:^{
//        if (fromVC.currentImageView.tz_width/fromVC.currentImageView.tz_height > fromVC.fromView.tz_width/fromVC.fromView.tz_height) {
//            fromVC.currentImageView.tz_width = fromVC.currentImageView.tz_height * fromVC.fromView.tz_width / fromVC.fromView.tz_height;
//        }else{
//            fromVC.currentImageView.tz_height = fromVC.currentImageView.tz_width * fromVC.fromView.tz_height / fromVC.fromView.tz_width;
//        }
//        fromVC.currentImageView.center = CGPointMake(fromVC.view.tz_width/2, fromVC.view.tz_height/2);
//
//    } completion:^(BOOL finished) {
//        
//    }];

    [UIView animateWithDuration:.25 animations:^{
        fromVC.currentImageView.frame = toRect;
    } completion:^(BOOL finished) {
        [fromVC.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end
