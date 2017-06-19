//
//  IBController.h
//  ImageBrowser
//
//  Created by 张雁军 on 2017/5/23.
//  Copyright © 2017年 smlkts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBModel.h"

@interface IBController : UIViewController
+ (UINavigationController *)controller;
@property (nonatomic, copy) NSArray <IBModel *> *images;
@property (nonatomic, readonly) NSInteger currentPage;
@property (nonatomic) NSInteger startIndex;
@property (nonatomic, strong) UIView *fromView;
@property (nonatomic, strong, readonly) UIImageView *currentImageView;
//- (void)showFromView:(UIView *)fromView;
- (void)show;
- (void)hide;
@end
