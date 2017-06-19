//
//  IBCell.h
//  ImageBrowser
//
//  Created by 张雁军 on 2017/5/19.
//  Copyright © 2017年 smlkts. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IBModel.h"

@interface IBCell : UICollectionViewCell
@property (nonatomic, strong) UIScrollView *scrollView;
//@property (nonatomic, strong) UIView *imageWrapperView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) IBModel *imageModel;
@property (nonatomic, copy) void (^singleTap)();
@property (nonatomic, copy) void (^longPress)();
- (void)rezoomScrollView;
- (void)ul_layoutSubviews;
@end
