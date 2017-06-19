//
//  ActionSheet.m
//  ImageBrowser
//
//  Created by 张雁军 on 2017/5/19.
//  Copyright © 2017年 smlkts. All rights reserved.
//

#import "ActionSheet.h"

@interface ActionSheet ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray <NSString *> *items;
@property (nonatomic, copy) Action action;
@property (nonatomic) CGFloat margin;

@end

@implementation ActionSheet{
    UITableView *_tableView;
}

- (instancetype)initWithTitle:(NSString *)title items:(NSArray <NSString *> *)items action:(Action)action{
    if (self = [super init]) {
        _title = title;
        _titleFont = [UIFont systemFontOfSize:12];
        _rowHeight = 45;
        _margin = 5;
        self.items = items;
        self.action = action;
        
        _tableView  = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];//!<隐藏sectionheader
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.scrollEnabled = NO;
        [self addSubview:_tableView];
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        _tableView.backgroundView = blurView;
    }
    return self;
}

- (void)showInView:(UIView *)view{
    CGFloat tableHeight = [self titleHeightWithLimitWidth:view.bounds.size.width] + _items.count * _rowHeight + _margin + _rowHeight;
    _tableView.frame = CGRectMake(0, view.bounds.size.height, CGRectGetWidth(view.bounds), tableHeight);
    
    self.frame = view.bounds;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    [view addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _tableView.transform = CGAffineTransformMakeTranslation(0, -tableHeight);
    }];
}

- (void)show{
    [self showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)hide{
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
        _tableView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (self.didHide) {
            self.didHide();
        }
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return NO;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.didTapBackground) {
        self.didTapBackground();
    }
    [self hide];
}

#pragma mark - helper

- (CGFloat)titleHeightWithLimitWidth:(CGFloat)width{
    if (_title.length) {
        CGFloat titleHeight = [_title boundingRectWithSize:CGSizeMake(width - 15 - 15, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: _titleFont} context:nil].size.height;
        return (10 + titleHeight + 10);
    }
    return 0;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    if (section == 1) {
        return _items.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const sheet = @"sheet";
    ActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:sheet];
    if (!cell) {
        cell = [[ActionSheetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sheet];
    }
    if (indexPath.section == 0) {
        cell.textLabel.text = _title;
        cell.textLabel.font = _titleFont;
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.bottomSeparator.hidden = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (indexPath.section == 1) {
        cell.textLabel.text = _items[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor blackColor];
        if (indexPath.row == _items.count-1) {
            cell.bottomSeparator.hidden = YES;
        }else{
            cell.bottomSeparator.hidden = NO;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    if (indexPath.section == 2) {
        cell.textLabel.text = @"取消";
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.bottomSeparator.hidden = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return CGFLOAT_MIN;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section == 1) {
        return _margin;
    }
    return CGFLOAT_MIN;
}

//- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
//    return [[UIView alloc] init];
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        return;
    }
    if (indexPath.section == 1) {
        if (self.action) {
            self.action(indexPath.row);
        }
    }
    [self hide];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return [self titleHeightWithLimitWidth:tableView.bounds.size.width];
    }
    if (indexPath.section == 1) {
        return _rowHeight;
    }
    return _rowHeight;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end


@implementation ActionSheetCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.numberOfLines = 0;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont systemFontOfSize:14];
        
        CGFloat scale = [UIScreen mainScreen].scale;
        _bottomSeparator = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds)-1.f/scale, CGRectGetWidth(self.bounds), 1.f/scale)];
        _bottomSeparator.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        _bottomSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:_bottomSeparator];
    }
    return self;
}

@end

