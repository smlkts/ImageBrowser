//
//  ActionSheet.h
//  ImageBrowser
//
//  Created by 张雁军 on 2017/5/19.
//  Copyright © 2017年 smlkts. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Action)(NSUInteger selectedItem);

@interface ActionSheet : UIView
- (instancetype)initWithTitle:(NSString *)title items:(NSArray <NSString *> *)items action:(Action)action;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic) CGFloat rowHeight;///<default 45
@property (nonatomic, copy) void(^didTapBackground)();///<点击黑色背景回调
@property (nonatomic, copy) void(^didHide)();
- (void)showInView:(UIView *)view;
- (void)show;///<Added to [UIApplication sharedApplication].keyWindow
- (void)hide;
@end

@interface ActionSheetCell : UITableViewCell
@property (nonatomic, strong, readonly) UIView *bottomSeparator;
@end

